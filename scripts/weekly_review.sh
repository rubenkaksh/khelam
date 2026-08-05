#!/bin/bash
# Weekly cost/budget review for the khelam project.
#
# Runs automatically every Sunday 18:00 via launchd
# (com.khelam.weekly-review.plist — see scripts/). Produces an
# understandable review doc at docs/reviews/YYYY-MM-DD.md and fires a macOS
# notification. Nothing is committed or pushed.
#
# Manual run:  bash scripts/weekly_review.sh
set -euo pipefail

REPO="/Users/rubenk/projects/khel-service/khelam"
REVIEWS_DIR="$REPO/docs/reviews"
SESSION_DIR="$REPO/docs/sessions"
LOG="/tmp/weekly-review.log"

REVIEW_DATE="$(date +%F)"
REVIEW_FILE="$REVIEWS_DIR/$REVIEW_DATE.md"
mkdir -p "$REVIEWS_DIR"

# Sessions touched in the last 8 days (covers the previous Sunday..now).
SESSION_FILES="$(find "$SESSION_DIR" -name '*.md' -mtime -8 2>/dev/null | sort | tr '\n' ' ')"

if [ -z "${SESSION_FILES// }" ]; then
  echo "$(date): no session files this week — skipping review" >> "$LOG"
  exit 0
fi

# Commons consumer check: if commons had commits this week, verify both
# consumer apps still analyze clean (catches breaking commons changes
# before they cost a rework cycle).
CONSUMER_NOTE=""
COMMONS="/Users/rubenk/projects/commons"
FORKABLE="/Users/rubenk/projects/forkable"
if [ -d "$COMMONS/.git" ] && git -C "$COMMONS" log --oneline --since="7 days ago" 2>/dev/null | rg -q .; then
  CONSUMER_NOTE="Commons had commits this week. Consumer check:"$'\n'
  CONSUMER_NOTE+="- khelam flutter analyze: $(cd "$REPO" && flutter analyze 2>&1 | tail -1)"$'\n'
  if [ -d "$FORKABLE/.git" ]; then
    CONSUMER_NOTE+="- forkable flutter analyze: $(cd "$FORKABLE" && flutter analyze 2>&1 | tail -1)"
  fi
fi

PROMPT="Weekly cost review for the khelam project (and sibling repos commons/forkable when mentioned).

Read every session file listed below, plus the persistent review memory at docs/reviews/review-memory.md (its Open Actions table lists what is still outstanding — check each one), plus run 'git log --oneline --since=\"7 days ago\"' in the repo.

Inputs (this week's session files): $SESSION_FILES

$(if [ -n "$CONSUMER_NOTE" ]; then echo "Consumer health note (from the script): $CONSUMER_NOTE"; fi)

Audit checklist — be specific, quote file names and commit hashes:
1. Redundant verification: full 'flutter test'/'flutter analyze' runs that were not needed; integration tests re-run without the live path changing; anything re-verified that was already green.
2. Tooling discipline: for symbol/codebase questions, was 'codegraph explore' / 'codegraph node' / 'graphify query' used, or did the agent grep/read files repeatedly? Scan the session text for 'codegraph'/'graphify' mentions vs grep/read volume. Cite the actual tool calls you find — if the agent never logged any codegraph/graphify call, say so explicitly.
3. Scope back-and-forth: tasks where the requirements, repo scope, or depth changed mid-way; where one upfront question would have saved a whole cycle.
4. Output waste: huge webfetch dumps read fully, same file read multiple times in one session, verbose logs consumed unnecessarily.
5. Open Actions from review-memory.md: were any worked on? Close or keep them in your report.
6. User prompt drift (sidetrack guard): did the user's prompts cause waste this week? Look for the patterns in the global AGENTS.md 'User Prompt Discipline' section (destination layer missing, follow-up scope extensions, deferred decisions, missing acceptance bars, praise-then-scope-creep). Name each instance and the cheaper phrasing. This feeds the guard's pattern list.

Then write $REVIEW_FILE with this exact structure (plain language, under 60 lines):
# Weekly Review — $REVIEW_DATE
## What shipped this week (5-8 bullets)
## Waste observed (top items: what happened, why it cost, how to avoid)
## Top 3 cuts for next week (concrete and actionable)
## One thing that went well
## Memory update (changes to make in docs/reviews/review-memory.md: new review-history row, actions closed or added)

Do NOT commit, push, or modify any file other than $REVIEW_FILE."

cd "$REPO"
opencode run --auto --dir "$REPO" "$PROMPT" >> "$LOG" 2>&1

if [ -f "$REVIEW_FILE" ]; then
  osascript -e "display notification \"Weekly review ready: docs/reviews/$REVIEW_DATE.md\" with title \"Khelam Weekly Review\"" >> "$LOG" 2>&1
  echo "$(date): review written to $REVIEW_FILE" >> "$LOG"
else
  echo "$(date): ERROR — review agent did not produce $REVIEW_FILE" >> "$LOG"
  osascript -e 'display notification "Weekly review FAILED — check /tmp/weekly-review.log" with title "Khelam Weekly Review" sound name "Sosumi"' >> "$LOG" 2>&1
fi
