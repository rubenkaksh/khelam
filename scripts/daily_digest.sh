#!/bin/bash
# daily_digest.sh — cross-project daily overview for the Discord #daily-overview channel.
# Canonical copy lives in forkable/scripts/ (base template); children pull synced
# copies. Runs Mon-Fri 08:00 via launchd com.khelam.daily-digest (installed by the
# user; templates in forkable/scripts/) AND at every login (RunAtLoad) for catch-up.
#
# Reports the PREVIOUS calendar day's activity across khelam / forkable / commons:
#   1. Token deltas + session counts (opencode.db, local midnight→midnight of the
#      target date; epoch convention mirrors weekly_review.sh session_boundary_check():
#      time_created is UNIX ms).
#   2. Open Actions in docs/reviews/review-memory.md that are NOT struck-through.
#   3. Untriaged backlog items in docs/backlog.md (top-level bullets).
#   4. Session activity: count of docs/sessions/<date>.md files across repos.
# Each fire scans the 14-day lookback and sends ONE message per MISSED day (oldest
# first). Catch-up + retry design: docs/superpowers/specs/2026-08-08-auto-digest-
# reliability-design.md (approved 2026-08-08).
#
# Delivery is idempotent: a persistent marker per target date
# (~/Library/Application Support/khelam/daily-digest/markers/YYYY-MM-DD.sent),
# written ONLY after a successful send. Missed at 08:00 (off/logged-out) →
# RunAtLoad catches up at next login. Asleep at 08:00 → launchd wake-coalescing.
# Transient Discord/network failure → 3-attempt backoff retry (0/5/15s), then no
# marker + an agent-errors report; the next fire retries.
#
# Due-set rule (D is a target date): D is due iff D < today AND no marker for D AND
# D within the 14-day lookback AND (D+1 is a weekday OR D is Friday). The Friday
# exception exists because the Mon–Fri 08:00 schedule reports Sun–Thu only.
# Saturday is never a target (matches the normal schedule).
#
# Repo paths (env overrides mirror weekly_review.sh):
#   KHELAM_REPO    (default ~/projects/khel-service/khelam)
#   FORKABLE_REPO  (default ~/projects/forkable)
#   COMMONS_REPO   (default ~/projects/commons)
#   DB_PATH        (default ~/.local/share/opencode/opencode.db)
#   STATE_DIR      (default ~/Library/Application Support/khelam/daily-digest)
#   DAILY_DIGEST_LOG (default $STATE_DIR/daily-digest.log)
# A repo whose dir is missing is skipped with a note — the digest still ships.
#
# Heuristics (documented — robust-enough, not exhaustive):
#   * Open Actions: lines inside the '## Open Actions...' section that are not
#     struck through (no '~~'); excludes blockquotes, table chrome (header +
#     separator rows), and placeholder rows whose title is empty/'—'. Titles: the
#     first **...** span when present (else the stripped line), prefixed with the
#     OA#/rank when the file carries one (e.g. "OA#8: …"), ~60 chars each. Count +
#     up to 3 titles.
#   * Backlog: top-level bullets matching '^- ' at column 0 anywhere in the file
#     (this includes watchpoint/DONE-note bullets — a stricter untriaged-only
#     filter is future work); '^- (empty)' placeholders excluded. Titles likewise
#     the **...** span, ~60 chars each. Count + up to 3 titles.
#
# Exit codes: 0 always after a fire completes (send failures degrade via
# report_sink — fallback + log — and never abort this script). 1 only on a hard
# failure before any scan (report_sink.sh missing, python3 missing).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$DIR/report_sink.sh" ] || { echo "report_sink.sh not found next to daily_digest.sh" >&2; exit 1; }
# shellcheck disable=SC1091
. "$DIR/report_sink.sh"

# --- Config ------------------------------------------------------------------------
STATE_DIR="${STATE_DIR:-$HOME/Library/Application Support/khelam/daily-digest}"
MARKER_DIR="$STATE_DIR/markers"
LOG="${DAILY_DIGEST_LOG:-$STATE_DIR/daily-digest.log}"   # overrides report_sink's LOG (set at source time)
LOCKDIR="$STATE_DIR/.lock"
MAX_CATCHUP_DAYS=14
RETRY_ATTEMPTS=3
RETRY_BASE_DELAY=5    # seconds; delays between attempts: 5, 15 (×3 backoff)

DB_PATH="${DB_PATH:-$HOME/.local/share/opencode/opencode.db}"
KHELAM_REPO="${KHELAM_REPO:-$HOME/projects/khel-service/khelam}"
FORKABLE_REPO="${FORKABLE_REPO:-$HOME/projects/forkable}"
COMMONS_REPO="${COMMONS_REPO:-$HOME/projects/commons}"

mkdir -p "$STATE_DIR" "$MARKER_DIR"

log() { echo "$(date): [daily_digest] $*" >> "$LOG"; }

# --- Lock: atomic mkdir = single writer even when a wake-coalesced 08:00 fire races
# a RunAtLoad login fire. The loser exits 0 silently; the holder runs the full scan.
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT

# --- helpers -----------------------------------------------------------------------
join() { # join <sep> <item>...
  local sep="$1"; shift
  local out=""
  for it in "$@"; do out="${out:+$out$sep}$it"; done
  printf '%s' "$out"
}

# local_midnight_window <date YYYY-MM-DD> — prints "WIN_START WIN_END" (epoch ms,
# local midnight→midnight). python3 is a HARD dependency (aborts under set -e if
# missing — ops issue, logged to launchd stdout/stderr).
local_midnight_window() {
  python3 - "$1" <<'PY'
import datetime, sys
day = datetime.datetime.strptime(sys.argv[1], '%Y-%m-%d')
nxt = day + datetime.timedelta(days=1)
print(int(day.timestamp() * 1000), int(nxt.timestamp() * 1000))
PY
}

# open_actions <file> — prints count on line 1, then up to 3 titles (one per line).
open_actions() {
  awk '
    function clean(t,   s){ s=t; sub(/^[-*+>#[:space:]]+/,"",s); sub(/^[0-9]+\.?[[:space:]]*/,"",s); gsub(/[[:space:]]+$/,"",s); return substr(s,1,60) }
    BEGIN{ insec=0; n=0 }
    /^## / { insec = ( $0 ~ /^## Open Actions/ ); next }
    insec && /^[[:space:]]*$/ { next }
    insec && /^>/ { next }
    insec && /~~/ { next }
    insec {
      line=$0; t=""; oaid=""
      if (line ~ /^\|/) {
        nf=split(line,f,"|")
        oaid=f[2]; gsub(/^[[:space:]]+|[[:space:]]+$/,"",oaid)
        t=f[3]; gsub(/^[[:space:]]+|[[:space:]]+$/,"",t)
        if (oaid == "OA#" || oaid ~ /^[[:space:]:-]+$/) next   # table chrome: header/separator
        if (t == "" || t ~ /^[[:space:]:-]+$/ || t == "(none yet)") next
        if (oaid !~ /^OA#/) oaid=""
      } else if (line ~ /^[0-9]+\./) {
        oaid="OA#" substr(line,1,index(line,".")-1)
      }
      if (t=="") {
        if (line ~ /\*\*/) {
          i=index(line,"**"); rest=substr(line,i+2); j=index(rest,"**")
          if (j>0) t=substr(rest,1,j-1)
        }
      }
      if (t=="") t=clean(line)
      if (t=="") next                      # all-dash rules / empty after cleaning
      if (oaid!="") t=oaid ": " t
      t=substr(t,1,60)
      n++
      if (n<=3) ttl[n]=t
    }
    END{ printf "%d\n", n; for(i=1;i<=3 && i<=n;i++) printf "%s\n", ttl[i] }
  ' "$1"
}

# backlog_items <file> — prints count on line 1, then up to 3 titles (one per line).
backlog_items() {
  awk '
    function clean(t,   s){ s=t; sub(/^[-*+>#[:space:]]+/,"",s); sub(/^[0-9]+\.?[[:space:]]*/,"",s); gsub(/[[:space:]]+$/,"",s); return substr(s,1,60) }
    BEGIN{ n=0 }
    /^-[[:space:]]/ {
      line=$0
      body=substr(line,2); gsub(/^[[:space:]]+/,"",body)
      if (body=="(empty)" || body=="_empty_") next
      t=""
      if (body ~ /\*\*/) {
        i=index(body,"**"); rest=substr(body,i+2); j=index(rest,"**")
        if (j>0) t=substr(rest,1,j-1)
      }
      if (t=="") t=clean(body)
      t=substr(t,1,60)
      n++
      if (n<=3) ttl[n]=t
    }
    END{ printf "%d\n", n; for(i=1;i<=3 && i<=n;i++) printf "%s\n", ttl[i] }
  ' "$1"
}

# marker_exists / write_marker — per-target-date delivery markers (persistent; NOT
# /tmp — a reboot between a successful send and the marker write would re-send).
marker_exists() { [ -f "$MARKER_DIR/$1.sent" ]; }
write_marker()  { : > "$MARKER_DIR/$1.sent"; }

# day_info <date YYYY-MM-DD> — prints "DOW DOW_PLUS1" (Mon=1..Sun=7, %u convention).
# python3 is already a hard dependency (local_midnight_window) — single date-math
# source of truth; avoids BSD `date -j -v` arg-order fragility (bug found 08-08:
# `-v+1d` after the parsed date made date print the full default format).
day_info() {
  python3 - "$1" <<'PY'
import datetime, sys
day = datetime.datetime.strptime(sys.argv[1], '%Y-%m-%d')
print(day.isoweekday(), (day + datetime.timedelta(days=1)).isoweekday())
PY
}

# is_due <date YYYY-MM-DD> — 0 if the target date needs a digest (due-set rule).
is_due() {
  local D="$1" dow dow_plus1
  read -r dow dow_plus1 <<< "$(day_info "$D")"
  # D+1 is a weekday (Mon=1..Sun=7) → a normal 08:00 fire covers D.
  [ "$dow_plus1" -le 5 ] && return 0
  # Friday exception: Fri's next day is Sat — no normal fire covers Friday.
  [ "$dow" -eq 5 ] && return 0
  return 1
}

# generate_body <date YYYY-MM-DD> — prints the digest body (≤1900 chars).
generate_body() {
  local D="$1"
  local WIN_START WIN_END
  read -r WIN_START WIN_END <<< "$(local_midnight_window "$D")"

  # --- Signal 1: token deltas + session counts (opencode.db) -----------------------
  declare -a tok_parts
  if [ ! -f "$DB_PATH" ]; then
    log "opencode.db missing at $DB_PATH — token signal skipped"
  elif ! command -v sqlite3 >/dev/null 2>&1; then
    log "sqlite3 unavailable — token signal skipped"
  else
    for r in "$KHELAM_REPO" "$FORKABLE_REPO" "$COMMONS_REPO"; do
      [ -d "$r" ] || { log "repo dir missing, skipped: $r"; continue; }
      base="$(basename "$r")"
      [[ "$base" =~ ^[A-Za-z0-9_-]+$ ]] || { log "invalid repo basename for token query: '$base'"; continue; }
      row="$(sqlite3 -separator '|' "$DB_PATH" "
        SELECT COALESCE(SUM(tokens_input + tokens_output + tokens_cache_read),0), COUNT(*)
        FROM session
        WHERE directory LIKE '%/' || '$base'
          AND time_created >= $WIN_START
          AND time_created < $WIN_END;" 2>/dev/null || true)"
      [ -z "$row" ] && { log "no token rows for '$base'"; continue; }
      toks="${row%%|*}"
      sess="${row#*|}"
      ht="$(printf '%s' "$toks" | awk '{ n=$1+0; if (n>=1000000) printf "%.1fM", n/1000000; else printf "%.1fk", n/1000 }')"
      tok_parts+=("$base $ht ($sess)")
    done
  fi
  TOK_LINE="$(join ' | ' "${tok_parts[@]}")"
  [ -z "$TOK_LINE" ] && TOK_LINE="no token data (opencode.db unavailable)"

  # --- Signal 2: Open Actions (review-memory.md) + Signal 3: Backlog (backlog.md) --
  declare -a oa_parts bl_parts
  for r in "$KHELAM_REPO" "$FORKABLE_REPO" "$COMMONS_REPO"; do
    [ -d "$r" ] || { log "repo dir missing, skipped: $r"; continue; }
    base="$(basename "$r")"
    if [ -f "$r/docs/reviews/review-memory.md" ]; then
      out="$(open_actions "$r/docs/reviews/review-memory.md")"
      cnt="$(printf '%s\n' "$out" | sed -n '1p')"
      rest="$(printf '%s\n' "$out" | sed -n '2,4p' | awk 'NF')"
      if [ "${cnt:-0}" -gt 0 ]; then
        oa_parts+=("$base $cnt ($(printf '%s' "$rest" | paste -sd ';' - | sed 's/;/; /g'))")
      else
        oa_parts+=("$base 0")
      fi
    else
      log "no review-memory.md in $r — open-actions signal skipped"
    fi
    if [ -f "$r/docs/backlog.md" ]; then
      bout="$(backlog_items "$r/docs/backlog.md")"
      bcnt="$(printf '%s\n' "$bout" | sed -n '1p')"
      brest="$(printf '%s\n' "$bout" | sed -n '2,4p' | awk 'NF')"
      if [ "${bcnt:-0}" -gt 0 ]; then
        bl_parts+=("$base $bcnt ($(printf '%s' "$brest" | paste -sd ';' - | sed 's/;/; /g'))")
      else
        bl_parts+=("$base 0")
      fi
    else
      log "no backlog.md in $r — backlog signal skipped"
    fi
  done
  OA_LINE="$(join ', ' "${oa_parts[@]}")"
  [ -z "$OA_LINE" ] && OA_LINE="none"
  BL_LINE="$(join ', ' "${bl_parts[@]}")"
  [ -z "$BL_LINE" ] && BL_LINE="none"

  # --- Signal 4: session activity count for the target date -------------------------
  ACT=0
  for r in "$KHELAM_REPO" "$FORKABLE_REPO" "$COMMONS_REPO"; do
    [ -f "$r/docs/sessions/$D.md" ] && ACT=$((ACT + 1))
  done

  # --- Assemble ----------------------------------------------------------------------
  BODY="🔥 Yesterday's agent tokens — $TOK_LINE"
  BODY+=$'\n'"📋 Open Actions: $OA_LINE"
  BODY+=$'\n'"🗂 Backlog: $BL_LINE"
  BODY+=$'\n'"📄 Sessions yesterday: $ACT"
  if [ "${#BODY}" -gt 1900 ]; then
    log "body was ${#BODY} chars — truncating to 1900 (Discord 2000 cap)"
    BODY="${BODY:0:1900}… [truncated]"
  fi
  printf '%s' "$BODY"
}

# send_with_retry <body> <date> — 3 attempts (0/5/15s). Writes the marker only on a
# delivered send (send_report_to returns 1 when the Discord post failed, after the
# macos_notification fallback). Returns 0 on delivered, 1 after exhaustion.
send_with_retry() {
  local body="$1" D="$2"
  local attempt=1 delay=0
  while :; do
    if [ "$attempt" -gt 1 ]; then
      sleep "$delay"
    fi
    if send_report_to daily-overview "Daily overview — $D" "$body"; then
      write_marker "$D"
      log "sent: $D"
      return 0
    fi
    [ "$attempt" -ge "$RETRY_ATTEMPTS" ] && return 1
    delay="$(( RETRY_BASE_DELAY * 3 ** (attempt - 1) ))"
    attempt=$((attempt + 1))
  done
}

# --- main: lock → 14-day catch-up scan (oldest first) ------------------------------
main() {
  log "=== daily digest fire started ==="
  local sent=0 failed=0 skipped=0 D body
  local i
  for i in $(seq "$MAX_CATCHUP_DAYS" -1 1); do
    D="$(date -v-${i}d +%Y-%m-%d)"
    if marker_exists "$D"; then
      skipped=$((skipped + 1)); continue
    fi
    if ! is_due "$D"; then
      skipped=$((skipped + 1)); continue
    fi
    body="$(generate_body "$D")"
    if send_with_retry "$body" "$D"; then
      sent=$((sent + 1))
    else
      failed=$((failed + 1))
      log "FAILED: $D after $RETRY_ATTEMPTS attempts — marker not written, next fire retries"
      send_error_report "Daily digest failed" "Could not deliver the digest for $D after $RETRY_ATTEMPTS attempts" || true
    fi
  done
  log "=== fire done: $sent sent, $failed failed, $skipped skipped ==="
}

main "$@"
