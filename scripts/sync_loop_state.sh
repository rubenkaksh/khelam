#!/bin/bash
# sync_loop_state.sh — loop state reconciliation (loop-engineering spec, P2).
# Canonical copy lives in forkable/scripts/ (forkable-first); children pull
# byte-identical (diff -rq tripwire).
#
# Runs after every loop iteration (post-digest, post-weekly-review — callers
# invoke it guarded with `|| true`: this script never blocks or stalls them).
# Reads the STABLE surfaces — `loop status --json` (the stable API surf; never
# raw LOOP-STATE parsing), tasklog.md active queue, review-memory.md Open
# Actions — and writes the DERIVED artifacts:
#   LOOP-STATE.json   (gitignored, regenerated every run — deterministic)
#   STATE.md          (High Priority = tasklog 🔴 queue; Watch List = Open
#                      Actions; every other section preserved untouched)
# Idempotent: identical inputs -> identical outputs (same-day runs match).
# Degrades gracefully: npx/loop absence -> loop_status {} , tasklog/OA data
# still written.
#
# Usage: bash scripts/sync_loop_state.sh   (from anywhere in the repo)
set -u

REPO="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$REPO" ] || REPO="$(pwd)"
cd "$REPO" || exit 1

TASKS="docs/tasklog.md"
REVIEW="docs/reviews/review-memory.md"
STATE_FILE="STATE.md"
OUT="LOOP-STATE.json"

# --- gather: loop status (stable surf, optional enrichment) ------------------
LOOP_STATUS='{}'
if command -v npx >/dev/null 2>&1 && [ -f "$STATE_FILE" ]; then
  if raw="$(npx --yes @cobusgreyling/loop status . --json 2>/dev/null)"; then
    LOOP_STATUS="$raw"
  fi
fi

# --- gather: tasklog active queue (🔴 Active rows, first cell) ---------------
ACTIVE="$(awk -F'|' '
  /^## 🔴/ {f=1; next}
  /^## /   {f=0}
  f {
    cell=$2
    gsub(/^[ \t]+|[ \t]+$/, "", cell)
    if (cell=="" || cell=="Card" || cell ~ /^-+$/) next
    gsub(/\*\*/, "", cell)
    print cell
  }
' "$TASKS" 2>/dev/null || true)"

# --- gather: open Open Actions count (numbered, not struck, not CLOSED) ------
OA_COUNT=0
if [ -f "$REVIEW" ]; then
  OA_COUNT="$(awk '/^## Open Actions/{f=1;next} /^## /{f=0} f' "$REVIEW" 2>/dev/null \
    | grep -E '^[0-9]+\.' | grep -v '~~' | grep -v 'CLOSED' | grep -c .)"
  [ -n "$OA_COUNT" ] || OA_COUNT=0
fi

# --- write LOOP-STATE.json (derived, deterministic, atomic) ------------------
LOOP_ACTIVE="$ACTIVE" LOOP_OA_COUNT="$OA_COUNT" LOOP_STATUS="$LOOP_STATUS" LOOP_OUT="$OUT" \
  python3 -c 'import json, os
out = {
  "active_tasks": [l.strip() for l in os.environ.get("LOOP_ACTIVE", "").splitlines() if l.strip()],
  "open_actions": int(os.environ.get("LOOP_OA_COUNT", "0") or 0),
  "loop_status": json.loads(os.environ.get("LOOP_STATUS", "{}")),
}
tmp = os.environ["LOOP_OUT"] + ".tmp"
with open(tmp, "w") as f:
    json.dump(out, f, indent=2, sort_keys=True)
os.replace(tmp, os.environ["LOOP_OUT"])' || true

# --- update STATE.md sections (preserve everything else) ---------------------
if [ -f "$STATE_FILE" ]; then
  tmp_active="/tmp/sync_loop_active.$$"
  tmp_watch="/tmp/sync_loop_watch.$$"
  printf '%s\n' "$ACTIVE" | sed '/^$/d' | sed 's/^/- /' > "$tmp_active"
  [ -s "$tmp_active" ] || printf '%s\n' '- (empty)' > "$tmp_active"
  if [ -f "$REVIEW" ]; then
    awk '/^## Open Actions/{f=1;next} /^## /{f=0} f' "$REVIEW" 2>/dev/null \
      | grep -E '^[0-9]+\.' | grep -v '~~' | grep -v 'CLOSED' \
      | sed -E 's/^([0-9]+)\. \*\*([^*]+)\*\*.*/- OA#\1: \2/' > "$tmp_watch"
  fi
  [ -s "$tmp_watch" ] || printf '%s\n' '- (none)' > "$tmp_watch"

  for spec in "## High Priority:$tmp_active" "## Watch List:$tmp_watch"; do
    hdr="${spec%%:*}"
    body="${spec#*:}"
    awk -v hdr="$hdr" -v body="$body" '
      $0 ~ hdr { print; while ((getline l < body) > 0) print l; close(body); in_sec=1; next }
      in_sec && /^## / { in_sec=0 }
      !in_sec { print }
    ' "$STATE_FILE" > "$STATE_FILE.new" && mv "$STATE_FILE.new" "$STATE_FILE"
  done
  sed -E "s/^(Last run:).*/\1 $(date +%F)/" "$STATE_FILE" > "$STATE_FILE.new" \
    && mv "$STATE_FILE.new" "$STATE_FILE"
  rm -f "$tmp_active" "$tmp_watch"
fi

exit 0
