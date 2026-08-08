#!/bin/bash
# daily_digest.sh — daily delivery of the LIVE TASKLOG BOARD to Discord #daily-overview.
# Canonical copy lives in forkable/scripts/ (base template); children pull synced
# copies. Runs Mon-Fri 08:00 via launchd com.khelam.daily-digest (installed by the
# user; templates in forkable/scripts/) AND at every login (RunAtLoad) for catch-up.
#
# Message layout (user decision 2026-08-08: split by section heading):
#   msg 1: "Daily overview — <date>" (title/date heading) + 🔴 Active queue
#   msg 2: 🟡 Backlog
#   msg 3: 🟠 Parked
#   msg 4: ⚪ Descoped
# Each message = one live board section rendered Discord-friendly (## heading +
# compact table rows). The 📋 Closed (history) section is dropped — it only grows
# and is not decision input; history lives in the repo + the weekly review.
# Token/cost/session analysis is ALSO out: per user 2026-08-08, cost accounting is
# a weekly-review concern, not daily. The board is the daily decision surface
# ("what to pick, what's parked").
#
# Reliability design (approved 2026-08-08): docs/superpowers/specs/2026-08-08-
# auto-digest-reliability-design.md — idempotent delivery markers per
# TARGET-DATE-PER-MESSAGE (~/Library/Application Support/khelam/daily-digest/
# markers/YYYY-MM-DD-N.sent, written ONLY after a successful send of message N;
# a partial failure re-sends ONLY the missing messages — no duplicates), atomic
# mkdir lock (wake-coalesced 08:00 fire vs RunAtLoad login fire), 3-attempt backoff
# retry (0/5/15s) + agent-errors report on exhaustion, 14-day oldest-first catch-up
# scan, launchd RunAtLoad + Mon-Fri 08:00 calendar. Sleep at 08:00 → launchd
# wake-coalescing fires it.
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
# A missing tasklog degrades to a single note message — the digest still ships.
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

# marker_exists / write_marker — per-target-date-per-message delivery markers
# (persistent; NOT /tmp — a reboot between a successful send and the marker write
# would re-send).
marker_exists() { [ -f "$MARKER_DIR/$1.sent" ]; }
write_marker()  { : > "$MARKER_DIR/$1.sent"; }

# render_tasklog_sections <file> — prints the LIVE board sections (🔴 Active queue,
# 🟡 Backlog, 🟠 Parked, ⚪ Descoped — in board order) separated by sentinel lines
# "--SECTION--". Each section = a compact "## <emoji> <label>" heading (Discord
# heading; parenthetical policy text dropped — carried per-card in the rows) +
# table rows (chrome dropped, cells rejoined with " — ") or bullets (Descoped).
# The 📋 Closed section is excluded. ASCII section matching (Active/Backlog/
# Parked/Descoped) — robust with UTF-8 emoji bytes under BSD awk.
render_tasklog_sections() {
  awk '
    /^## / {
      if ($0 ~ /Active queue|Backlog|Parked|Descoped/) {
        if (seen) print "--SECTION--"
        sub(/ \(.*/, "", $0)
        print $0
        seen=1; keep=1
      } else { keep=0 }
      next
    }
    keep && /^[[:space:]]*$/ { print ""; next }
    keep && /^\|/ {
      line=$0
      sub(/^\|/,"",line); sub(/\|[[:space:]]*$/,"",line)
      n=split(line,f,"|")
      for (i=1;i<=n;i++) gsub(/^[[:space:]]+|[[:space:]]+$/,"",f[i])
      if (f[1]=="Card" || f[1] ~ /^[-:[:space:]]+$/) next
      out=f[1]
      for (i=2;i<=n;i++) out=out " — " f[i]
      print out
      next
    }
    keep { print $0 }
  ' "$1"
}

# build_sections <file> — fills the global SECTIONS array (one element per live
# section, in board order; trailing blank lines trimmed).
build_sections() {
  local TL="$1" cur="" line
  SECTIONS=()
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$line" = "--SECTION--" ]; then
      SECTIONS+=("${cur%$'\n'}"); cur=""
    else
      cur="${cur}${line}"$'\n'
    fi
  done < <(render_tasklog_sections "$TL")
  [ -n "$cur" ] && SECTIONS+=("${cur%$'\n'}")
}

# send_with_retry <title> <body> <date> <msg-index> — 3 attempts (0/5/15s). Writes
# the per-message marker only on a delivered send (send_report_to returns 1 when
# the Discord post failed, after the macos_notification fallback). Returns 0 on
# delivered, 1 after exhaustion (marker absent → the next fire re-sends only this
# message).
send_with_retry() {
  local title="$1" body="$2" D="$3" idx="$4"
  local attempt=1 delay=0
  while :; do
    if [ "$attempt" -gt 1 ]; then
      sleep "$delay"
    fi
    if send_report_to daily-overview "$title" "$body"; then
      write_marker "$D-$idx"
      log "sent: $D ($idx/${#SECTIONS[@]})"
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
  local sent=0 failed=0 skipped=0 D title idx i
  local TL="$KHELAM_REPO/docs/tasklog.md"
  local day_sent day_failed day_skip

  if [ -f "$TL" ]; then
    build_sections "$TL"
  else
    log "no tasklog at $TL — digest body is a note"
    SECTIONS=("no tasklog found at $TL")
  fi

  for i in $(seq "$MAX_CATCHUP_DAYS" -1 1); do
    D="$(date -v-${i}d +%Y-%m-%d)"
    if ! is_due "$D"; then
      skipped=$((skipped + 1)); continue
    fi
    # any missing message marker for this day → (re)send the missing ones only
    day_sent=0; day_failed=0; day_skip=0
    for idx in $(seq 1 ${#SECTIONS[@]}); do
      if marker_exists "$D-$idx"; then
        day_skip=$((day_skip + 1)); continue
      fi
      if [ "$idx" -eq 1 ]; then
        title="Daily overview — $D"
      else
        title=""
      fi
      if send_with_retry "$title" "${SECTIONS[$((idx - 1))]}" "$D" "$idx"; then
        day_sent=$((day_sent + 1))
      else
        day_failed=$((day_failed + 1))
      fi
    done
    if [ "$day_failed" -eq 0 ] && [ "$day_sent" -gt 0 ]; then
      sent=$((sent + 1))
    elif [ "$day_failed" -gt 0 ]; then
      failed=$((failed + 1))
      log "FAILED: $D ($day_sent sent, $day_failed not delivered) — missing markers retry next fire"
      send_error_report "Daily digest failed" "Could not deliver all messages for $D after $RETRY_ATTEMPTS attempts each" || true
    else
      skipped=$((skipped + 1))
    fi
  done
  log "=== fire done: $sent days sent, $failed days failed, $skipped days skipped ==="
}

main "$@"
