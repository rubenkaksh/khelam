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
ANALYTICS_DIR="$HOME/analytics"
SCRIPTS_DIR="$REPO/scripts"

REVIEW_DATE="$(date +%F)"
REVIEW_FILE="$REVIEWS_DIR/$REVIEW_DATE.md"
mkdir -p "$REVIEWS_DIR"

# Source report_sink for delivery abstraction (REPORT_SINK env honored).
. "$SCRIPTS_DIR/report_sink.sh"

# Step 0 (v2): run the analytics collector FIRST so the review agent has
# I/O data. Degrades gracefully (logs to $LOG) — never blocks the review.
bash "$SCRIPTS_DIR/ccusage_collect.sh" >> "$LOG" 2>&1 || \
  echo "$(date): WARNING — analytics collector failed; review proceeds without I/O data" >> "$LOG"

# Sessions for the last 7 days, selected by FILENAME date (not mtime —
# editing an old session file would otherwise drag it into a later week).
# Only files DIRECTLY in SESSION_DIR are candidates: the archive/ subdir
# holds monthly merged files (YYYY-MM.md) that must never be read into a
# weekly review — explicit -maxdepth 1 + archive exclusion keeps the
# selection correct whatever archiving layout evolves into.
CUTOFF="$(date -v-7d +%F)"
SESSION_FILES="$(find "$SESSION_DIR" -maxdepth 1 -type f -name '*.md' ! -path '*/archive/*' 2>/dev/null | while read -r f; do
  base="$(basename "$f" .md)"
  if [[ "$base" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ "$base" > "$CUTOFF" ]] && [[ "$base" != "$REVIEW_DATE" ]]; then
    echo "$f"
  fi
done | sort | tr '\n' ' ')"

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
  # Open Action #3: origin self-check — analyze commons ITSELF, not just its
  # consumers (its own test fake was broken while only consumers were checked).
  CONSUMER_NOTE="Commons had commits this week. Origin + consumer check:"$'\n'
  CONSUMER_NOTE+="- commons flutter analyze (origin): $(cd "$COMMONS" && flutter analyze 2>&1 | tail -1)"$'\n'
  CONSUMER_NOTE+="- khelam flutter analyze: $(cd "$REPO" && flutter analyze 2>&1 | tail -1)"$'\n'
  if [ -d "$FORKABLE/.git" ]; then
    CONSUMER_NOTE+="- forkable flutter analyze: $(cd "$FORKABLE" && flutter analyze 2>&1 | tail -1)"
  fi
fi

# Mechanical codegraph/graphify usage verification: counts actual tool
# invocations in the week's session files vs grep/read volume. Sessions with
# zero lookups but heavy grep/read activity are flagged for the review agent
# (a real check, not just self-report).
mechanical_check() {
  local dir="$SESSION_DIR"
  local calls reads
  # Exclude archive/ — monthly merged files are not per-session evidence.
  calls="$(rg -l --glob '!archive/**' 'codegraph (explore|node|sync|status)|graphify (query|path|explain)' "$dir" 2>/dev/null | wc -l | tr -d ' ')"
  reads="$(rg -l --glob '!archive/**' '\b(rg|grep|find|read)\b' "$dir" 2>/dev/null | wc -l | tr -d ' ')"
  if [ "${calls:-0}" -eq 0 ] && [ "${reads:-0}" -gt 0 ]; then
    echo "FAILED: 0 session files log codegraph/graphify usage but $reads log grep/read activity — tooling-discipline rule violated. Investigate and cite it."
  else
    echo "OK: $calls session file(s) log codegraph/graphify usage vs $reads with grep/read activity."
  fi
}

# Session-boundary check (Open Action #2, execution-model spec): flag weekly
# sessions that ran >1 day with >50M cache reads. Long sessions violate the
# fresh-session-per-batch rule (one long context accumulates cache reads; a
# fresh session resets them). Computed from opencode.db; degrades gracefully.
session_boundary_check() {
  local db="$HOME/.local/share/opencode/opencode.db"
  if [[ ! -f "$db" || ! -x "$(command -v sqlite3)" ]]; then
    echo "SKIPPED: opencode.db or sqlite3 unavailable — session-boundary check not run"
    return
  fi
  local rows
  rows="$(sqlite3 -separator ' | ' "$db" "
    SELECT title || ' (' || printf('%.0f', COALESCE(tokens_cache_read,0)/1000000.0) || 'M cache, ' ||
           printf('%.1f', (time_updated - time_created)/3600000.0) || 'h span)'
    FROM session
    WHERE (directory LIKE '%/khelam' OR directory LIKE '%khel-service/khelam%')
      AND time_updated > CAST(strftime('%s','now','-7 day') AS INTEGER) * 1000
      AND (time_updated - time_created) > 86400000
      AND COALESCE(tokens_cache_read,0) > 50000000
    ORDER BY tokens_cache_read DESC
    LIMIT 10;" 2>/dev/null || true)"
  if [[ -z "$rows" ]]; then
    echo "OK: no weekly session ran >1 day with >50M cache reads (fresh-session-per-batch rule holds)."
  else
    echo "FAILED: long sessions with heavy cache reads (violates fresh-session-per-batch):"
    echo "$rows" | sed 's/^/  - /'
  fi
}

PROMPT="Weekly cost review for the khelam project (and sibling repos commons/forkable when mentioned).

Read every session file listed below, plus the persistent review memory at docs/reviews/review-memory.md (its Open Actions table lists what is still outstanding — check each one), plus run 'git log --oneline --since=\"7 days ago\"' in the repo.

Inputs (this week's session files): $SESSION_FILES

$(if [ -n "$CONSUMER_NOTE" ]; then echo "Consumer health note (from the script): $CONSUMER_NOTE"; fi)

MECHANICAL CHECK (computed by the script, not by you): $(mechanical_check)

SESSION-BOUNDARY CHECK (computed by the script, Open Action #2): $(session_boundary_check)

WEEKLY I/O DATA (from the analytics collector): weekly CSV at $ANALYTICS_DIR/weekly/$REVIEW_DATE.csv (may not exist yet on the first run of a week — then note that). Monthly rollup at $ANALYTICS_DIR/monthly/.

Audit checklist — be specific, quote file names and commit hashes:
1. Redundant verification: full 'flutter test'/'flutter analyze' runs that were not needed; integration tests re-run without the live path changing; anything re-verified that was already green.
2. Tooling discipline: for symbol/codebase questions, was 'codegraph explore' / 'codegraph node' / 'graphify query' used, or did the agent grep/read files repeatedly? Scan the session text for 'codegraph'/'graphify' mentions vs grep/read volume. Cite the actual tool calls you find — if the agent never logged any codegraph/graphify call, say so explicitly.
3. Scope back-and-forth: tasks where the requirements, repo scope, or depth changed mid-way; where one upfront question would have saved a whole cycle.
4. Output waste: huge webfetch dumps read fully, same file read multiple times in one session, verbose logs consumed unnecessarily.
5. Open Actions from review-memory.md: were any worked on? Close or keep them in your report.
6. User prompt drift (sidetrack guard): did the user's prompts cause waste this week? Look for the patterns in the global AGENTS.md 'User Prompt Discipline' section (destination layer missing, follow-up scope extensions, deferred decisions, missing acceptance bars, praise-then-scope-creep). Name each instance and the cheaper phrasing. This feeds the guard's pattern list.

SECTION A — ANALYTICS (v2): read the week's CSV ($ANALYTICS_DIR/weekly/$REVIEW_DATE.csv if it exists, else note its absence) and the monthly rollup ($ANALYTICS_DIR/monthly/). Write $ANALYTICS_DIR/performance-summary.md (OVERWRITE each week) with EXACT structure:
# Performance Summary — $REVIEW_DATE
## Agent Metrics (table)
Columns: Metric | This Week | 4-Week Trend
Rows: Total tokens, Cost USD, Estimate accuracy %, Waste incidents (w/ categories), Full test runs, codegraph/graphify lookups, Sessions
## User Metrics (table)
Columns: Sidetrack pattern | Count | Cheaper phrasing
Rows: one per sidetrack pattern found this week (destination layer missing, follow-up scope extension, deferred decision, missing acceptance bar, praise-then-scope-creep) + a Total nudges issued row.

SECTION B — UPDATE LOG (v2): append '## $REVIEW_DATE' entries to $ANALYTICS_DIR/update-log.md (create the file with a header if missing) for every knowledge/rule change made or recommended this week. Format: '- **AGENTS.md** (global|project): <what> (Review: $REVIEW_DATE, action: <#>)'. If nothing changed, write 'No changes — <reason>'.

SECTION C — FEATURE AUDIT (v2): for each docs/features/<feature>/README.md touched this week: checklist completion %, ADRs added, scope drift (sessions on untracked items), stale (>7 days no progress → flag for CEO review). If no features are declared yet, write 'No declared features this week'.

Then write $REVIEW_FILE with this exact structure (plain language, under 60 lines):
# Weekly Review — $REVIEW_DATE
## What shipped this week (5-8 bullets)
## Waste observed (top items: what happened, why it cost, how to avoid)
## Top 3 cuts for next week (concrete and actionable)
## One thing that went well
## Memory update (changes to make in docs/reviews/review-memory.md: new review-history row, actions closed or added)
## Performance Summary (see $ANALYTICS_DIR/performance-summary.md)
## Feature Audit

Do NOT commit, push, or modify any file other than $REVIEW_FILE, $ANALYTICS_DIR/performance-summary.md, and $ANALYTICS_DIR/update-log.md."

cd "$REPO"
opencode run --auto --dir "$REPO" "$PROMPT" >> "$LOG" 2>&1

if [ -f "$REVIEW_FILE" ]; then
  send_report "Khelam Weekly Review" "Weekly review ready: docs/reviews/$REVIEW_DATE.md" \
    "performance-summary.md" "update-log.md" "weekly/$REVIEW_DATE.csv"
  echo "$(date): review written to $REVIEW_FILE" >> "$LOG"
else
  echo "$(date): ERROR — review agent did not produce $REVIEW_FILE" >> "$LOG"
  send_error_report "Khelam Weekly Review" "Weekly review FAILED — check /tmp/weekly-review.log"
fi
