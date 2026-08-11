#!/bin/bash
# daily_digest.sh — daily delivery of the LIVE TASKLOG BOARD to Discord #daily-overview.
# Canonical copy lives in forkable/scripts/ (base template); children pull synced
# copies. Runs Mon-Fri 08:00 via launchd com.khelam.daily-digest (installed by the
# user; templates in forkable/scripts/) AND at every login (RunAtLoad) for catch-up.
#
# Message layout (user decisions 2026-08-08 + 2026-08-11):
#   ONE message per day — "Daily overview — <date>" heading, then the curated
#   board: 🔴 Active queue + 🟡 Backlog share ONE 10-item budget (Active fills
#   first up to 10, Backlog gets the remainder); 🟠 Parked and ⚪ Descoped each
#   render whenever non-empty (own cap of 10) — empty sections are skipped
#   (per-section independence; the old "Parked/Descoped only when Active AND
#   Backlog are both empty" rule is gone). Done tasks never show: any card
#   whose status carries DONE/CLOSED is excluded from the digest (it moves to
#   the repo board's done section, date-wise — not Discord). Sections separate
#   by a blank line + "## <emoji> <label>" heading; card rows are TRIMMED to
#   *italic title* + subtitle + **short status** + date, bulleted.
#   No dividers and no .md attachment: per user 2026-08-08, Discord renders
#   dividers as plain text and a .md file as a download chip (not glanceable);
#   the full board (Closed section, exact tables) stays in the repo.
#   Token/cost/session analysis is OUT: per user 2026-08-08, cost accounting is
#   a weekly-review concern, not daily.
#
# Reliability design (approved 2026-08-08): docs/superpowers/specs/2026-08-08-
# auto-digest-reliability-design.md — idempotent delivery markers per target date
# (~/Library/Application Support/khelam/daily-digest/markers/YYYY-MM-DD-1.sent,
# written ONLY after a successful send; the "-1" suffix is the per-message marker
# scheme from the 4-message layout, kept for marker continuity — a missing marker
# re-sends the whole day), atomic mkdir lock with stale (>30min) takeover
# (SIGKILL on sleep/reboot skips EXIT traps and would otherwise wedge the digest),
# 3-attempt backoff retry (0/5/15s) + agent-errors report on exhaustion, 14-day
# oldest-first catch-up scan, launchd RunAtLoad + Mon-Fri 08:00 calendar. Sleep at
# 08:00 → launchd wake-coalescing fires it.
#
# Due-set rule (D is a target date): D is due iff D < today AND D within the
# 14-day lookback AND (D+1 is a weekday OR D is Friday). The Friday exception
# exists because the Mon–Fri 08:00 schedule reports Sun–Thu only. Saturday is
# never a target (matches the normal schedule).
#
# Env overrides:
#   KHELAM_REPO      (default ~/projects/khel-service/khelam — the board owner)
#   STATE_DIR        (default ~/Library/Application Support/khelam/daily-digest)
#   DAILY_DIGEST_LOG (default $STATE_DIR/daily-digest.log)
# A missing tasklog degrades to a note line — the digest still ships.
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

KHELAM_REPO="${KHELAM_REPO:-$HOME/projects/khel-service/khelam}"

mkdir -p "$STATE_DIR" "$MARKER_DIR"

log() { echo "$(date): [daily_digest] $*" >> "$LOG"; }

# --- Lock: atomic mkdir = single writer even when a wake-coalesced 08:00 fire races
# a RunAtLoad login fire. The loser exits 0 silently; the holder runs the full scan.
# Staleness guard: a fire killed with SIGKILL (sleep/reboot — skips EXIT traps)
# leaves the lock behind; a lock older than 30min is abandoned (fires take
# seconds) and taken over.
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  if find "$LOCKDIR" -maxdepth 0 -mmin +30 -print -quit 2>/dev/null | grep -q .; then
    echo "$(date): [daily_digest] stale lock ($LOCKDIR, >30min) — taking over" >> "$LOG"
    rmdir "$LOCKDIR" 2>/dev/null
    mkdir "$LOCKDIR" 2>/dev/null || exit 0
  else
    exit 0   # concurrent fire holds a fresh lock
  fi
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT

# --- helpers -----------------------------------------------------------------------
# day_info <date YYYY-MM-DD> — prints "DOW DOW_PLUS1" (Mon=1..Sun=7, %u convention).
# python3 is already a hard dependency (used here) — single date-math source of
# truth; avoids BSD `date -j -v` arg-order fragility (bug found 08-08: `-v+1d`
# after the parsed date made date print the full default format).
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

# marker_exists / write_marker — delivery markers (persistent; NOT /tmp — a reboot
# between a successful send and the marker write would re-send).
marker_exists() { [ -f "$MARKER_DIR/$1.sent" ]; }
write_marker()  { : > "$MARKER_DIR/$1.sent"; }

# render_tasklog <file> — prints the curated daily board as ONE Discord-friendly
# message (user decisions 2026-08-08 + 2026-08-11):
#   - Card rows are TRIMMED to: italic *title*, subtitle (text immediately after
#     the title), **short status** (first segment of the status/note cell) and a
#     date when one exists ("backlog 07-31" → 07-31, Parked revisit, etc.).
#     Scope/effort/long notes are dropped.
#   - Done tasks are EXCLUDED: any card whose status carries DONE/CLOSED never
#     renders (it moves to the repo board's done section, date-wise; the digest
#     does not send a Done section — user 2026-08-11).
#   - Sections: 🔴 Active + 🟡 Backlog share one 10-item budget (Active first,
#     Backlog = remainder); 🟠 Parked and ⚪ Descoped each render whenever
#     non-empty (own cap of 10). Empty sections are skipped (per-section
#     independence — the old "P+D only when A+B empty" rule is gone); sections
#     separate by a blank line (no dividers).
#   - The 📋 Closed section is never sent; the full board stays in the repo (the
#     digest is Discord comms, the repo is the agent console view).
# Table chrome (header + separator rows) dropped; Descoped bullets render as
# *title* + remainder. ASCII section matching — robust with UTF-8 emoji bytes
# under BSD awk.
render_tasklog() {
  awk '
    BEGIN { nc["A"]=nc["B"]=nc["P"]=nc["D"]=0 }
    /^## / {
      if ($0 ~ /Active queue/) sec="A"
      else if ($0 ~ /Backlog/) sec="B"
      else if ($0 ~ /Parked/) sec="P"
      else if ($0 ~ /Descoped/) sec="D"
      else sec=""
      next
    }
    sec == "" { next }
    /^\|/ {
      if (sec == "D") next
      line=$0
      sub(/^\|/,"",line); sub(/\|[[:space:]]*$/,"",line)
      n=split(line,f,"|")
      for (i=1;i<=n;i++) gsub(/^[[:space:]]+|[[:space:]]+$/,"",f[i])
      if (f[1]=="Card" || f[1] ~ /^[-:[:space:]]+$/) next
      card=f[1]; title=card; sub_=""
      if (match(card, /\*\*[^*]*\*\*/)) {
        title=substr(card, RSTART+2, RLENGTH-4)
        sub_=substr(card, RSTART+RLENGTH)
        gsub(/^[[:space:]]+/,"",sub_)
        sub(/^—[[:space:]]*/,"",sub_)
      }
      status=f[n]
      sub(/ — .*/,"",status)
      gsub(/\*\*/,"",status)
      # Done tasks move out of the live board: a card whose status carries
      # DONE/CLOSED is excluded from the digest (it lives in the repo board,
      # under its done section, date-wise — never rendered in Discord,
      # user 2026-08-11).
      # Verified: no live status false-positives ("blocks [C5] close" is
      # lowercase; "DESCOPED" matches neither token).
      if (status ~ /DONE/ || status ~ /CLOSED/) next
      date=""
      for (i=2;i<=n;i++) {
        if (match(f[i], /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) { date=substr(f[i],RSTART,RLENGTH); break }
        if (match(f[i], /[0-9][0-9]-[0-9][0-9]/)) { date=substr(f[i],RSTART,RLENGTH); break }
      }
      out="- *" title "*"
      if (sub_ != "") out=out " " sub_
      if (status != "") out=out " — **" status "**"
      if (date != "") out=out " — " date
      R[sec, ++nc[sec]] = out
      next
    }
    sec == "D" && /^- / {
      if (match($0, /\*\*[^*]*\*\*/)) {
        title=substr($0, RSTART+2, RLENGTH-4)
        sub_=substr($0, RSTART+RLENGTH)
        gsub(/^[[:space:]]+/,"",sub_)
        sub(/^—[[:space:]]*/,"",sub_)
        R["D", ++nc["D"]] = "- *" title "* — " sub_
      }
      next
    }
    END {
      # Per-section independence (each non-empty section renders — the old
      # "Parked/Descoped only when Active AND Backlog are both empty" rule is
      # gone, user 2026-08-11). Caps: Active+Backlog share one 10-budget
      # (Active fills first, Backlog gets the remainder); Parked/Descoped each
      # get their own independent cap of 10. Done/Closed never render.
      aRem = 10 - nc["A"]; if (aRem < 0) aRem = 0
      emit("A", "🔴 Active queue", 10)
      emit("B", "🟡 Backlog", aRem)
      emit("P", "🟠 Parked", 10)
      emit("D", "⚪ Descoped", 10)
    }
    function emit(s, label, max) {
      if (nc[s] == 0 || max <= 0) return
      print ""
      print "## " label
      for (j=1; j<=nc[s] && j<=max; j++) print R[s, j]
    }
  ' "$1"
}

# generate_body <date YYYY-MM-DD> — prints the digest body: the date heading +
# the curated board (≤1990 chars — Discord's hard cap is 2000; trimming keeps
# the body ~800 chars so the cap is a backstop, not a normal constraint).
generate_body() {
  local D="$1"
  local TL="$KHELAM_REPO/docs/tasklog.md"
  local BODY
  if [ -f "$TL" ]; then
    BODY="$(render_tasklog "$TL")"
  else
    log "no tasklog at $TL — digest body is a note"
    BODY="no tasklog found at $TL"
  fi
  BODY="Daily overview — $D"$'\n'"$BODY"
  if [ "${#BODY}" -gt 1990 ]; then
    log "body was ${#BODY} chars — truncating to 1990 (Discord 2000 hard cap)"
    BODY="${BODY:0:1990}… [truncated]"
  fi
  printf '%s' "$BODY"
}

# send_with_retry <body> <date> — 3 attempts (0/5/15s). Writes the day marker
# only on a delivered send (send_report_to returns 1 when the Discord post
# failed, after the macos_notification fallback). Returns 0 on delivered, 1
# after exhaustion (marker absent → next fire retries).
send_with_retry() {
  local body="$1" D="$2"
  local attempt=1 delay=0
  while :; do
    if [ "$attempt" -gt 1 ]; then
      sleep "$delay"
    fi
    if send_report_to daily-overview "" "$body"; then
      write_marker "$D-1"
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
    if marker_exists "$D-1"; then
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
