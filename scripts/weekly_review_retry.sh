#!/bin/bash
# Weekly-review retry leg (launchd: com.khelam.weekly-review.retry, Sun 19-22h).
# Re-runs the primary script only when today's review is still missing — the
# 18:00 run either succeeded or its internal retries may still land. Guards:
#   * Sunday only (%u: 1=Mon .. 7=Sun) — never fires on other days.
#   * Skips when docs/reviews/<today>.md already exists (already delivered).
#   * mkdir-based lock (no flock on macOS) prevents overlap with a long
#     primary run — a concurrent retry bails instead of double-running.
set -euo pipefail
REPO="${WEEKLY_REVIEW_REPO:-/Users/rubenk/projects/khel-service/khelam}"
LOG="${WEEKLY_REVIEW_LOG:-/tmp/weekly-review.log}"
TODAY="$(date +%F)"

[ "$(date +%u)" -eq 7 ] || exit 0
[ -f "$REPO/docs/reviews/$TODAY.md" ] && exit 0

LOCK_DIR="${TMPDIR:-/tmp}/weekly-review-retry.lockdir"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "$(date): retry leg skipped — primary run still in progress" >> "$LOG"
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

echo "$(date): retry leg — $TODAY review missing, re-running weekly_review.sh" >> "$LOG"
bash "$REPO/scripts/weekly_review.sh"
