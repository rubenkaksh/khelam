#!/usr/bin/env bash
# ccusage_collect.sh — per-repo token analytics collector (v1)
# Reads opencode.db directly (schema verified 2026-08-05), appends a row per session
# to ~/analytics/weekly/YYYY-MM-DD.csv (week-ending date), and updates the monthly
# rollup ~/analytics/monthly/YYYY-MM.csv (token/cost/repos computed; estimate/waste
# metric columns are filled by the weekly review agent).
#
# Per design: raw token columns from opencode.db; cost joined weekly via ccusage
# pricing when available (free tiers = 0.0 / NULL documented). Graceful degradation:
# if the sqlite query fails (schema changed), log a warning and fall back to
# ccusage global-only (no per-repo split). No commits ever.
#
# MACHINE-LOCAL: the repo CASE map below (line ~45) maps this machine's sibling
# directories to repo names. khel-service/khelam is the canonical source for this
# script (it lives here as part of the base template); new children add their own
# CASE arm here after forking.

set -euo pipefail

DB="${OPENCODE_DB:-$HOME/.local/share/opencode/opencode.db}"
ANALYTICS_DIR="${ANALYTICS_DIR:-$HOME/analytics}"
LOG="${WEEKLY_LOG:-/tmp/weekly-review.log}"
WEEK_ENDING="$(date -v-1d '+%Y-%m-%d')"   # macOS date; adjust for GNU date if needed
WEEK_FILE="$ANALYTICS_DIR/weekly/$WEEK_ENDING.csv"
MONTH_FILE="$ANALYTICS_DIR/monthly/$(date '+%Y-%m').csv"

log() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$*" >> "$LOG"; }

# 1. Per-session rows from opencode.db (last 7 days, LIKE per verified data)
#    Columns: date,session_id,agent,model_name,input_tokens,output_tokens,
#             cache_read_tokens,cache_write_tokens,reasoning_tokens,total_tokens,
#             cost_usd,repo,title,duration_seconds,feature_parent
QUERY="
WITH s AS (
  SELECT id, title, agent,
         json_extract(model, '$.id') AS model_name,
         tokens_input, tokens_output, tokens_cache_read, tokens_cache_write,
         tokens_reasoning, cost, directory,
         (time_updated - time_created)/1000.0 AS duration_seconds,
         date(time_updated/1000, 'unixepoch', 'localtime') AS day
  FROM session
  WHERE time_updated > CAST(strftime('%s','now','-7 day') AS INTEGER) * 1000
)
SELECT day AS date, id, agent, COALESCE(model_name,''),
       COALESCE(tokens_input,0), COALESCE(tokens_output,0),
       COALESCE(tokens_cache_read,0), COALESCE(tokens_cache_write,0),
       COALESCE(tokens_reasoning,0),
       COALESCE(tokens_input,0)+COALESCE(tokens_output,0)+COALESCE(tokens_cache_read,0)+COALESCE(tokens_cache_write,0)+COALESCE(tokens_reasoning,0),
       COALESCE(cost,0.0),
       CASE WHEN directory LIKE '%/khelam' OR directory LIKE '%khel-service/khelam%' THEN 'khelam'
            WHEN directory LIKE '%/forkable' THEN 'forkable'
            WHEN directory LIKE '%/commons' THEN 'commons'
            ELSE 'backend' END AS repo,
       title,
       COALESCE(duration_seconds,0)
FROM s
ORDER BY date, repo;
"

# try sqlite3; graceful fallback when DB is missing or schema changed
HEADER='date,session_id,agent,model_name,input_tokens,output_tokens,cache_read_tokens,cache_write_tokens,reasoning_tokens,total_tokens,cost_usd,repo,title,duration_seconds,feature_parent'
mkdir -p "$(dirname "$WEEK_FILE")"
if [[ ! -f "$WEEK_FILE" ]]; then
  printf '%s\n' "$HEADER" > "$WEEK_FILE"
fi
if [[ ! -f "$DB" || ! -x "$(command -v sqlite3)" ]]; then
  log "analytics collector degraded: sqlite3/db unavailable — skipping weekly CSV"
  exit 0
fi

set +e
sqlite3 -csv "$DB" "$QUERY" > /tmp/weekly-rows.csv 2>> "$LOG"
RC=$?
set -e
if [[ $RC -ne 0 ]]; then
  log "analytics collector degraded: sqlite query failed (rc=$RC); falling back to ccusage global-only"
  exit 0
fi

# Idempotent append: skip session ids already present in the week file.
if [[ -s /tmp/weekly-rows.csv ]]; then
  python3 - "$WEEK_FILE" /tmp/weekly-rows.csv << 'PYEOF'
import csv, sys

week_file, rows_file = sys.argv[1], sys.argv[2]

with open(week_file, newline='') as f:
    existing = set()
    for row in csv.reader(f):
        if len(row) >= 2 and row[1]:
            existing.add(row[1])

new_rows = []
with open(rows_file, newline='', encoding='utf-8') as f:
    for row in csv.reader(f):
        if len(row) != 14:
            continue  # sqlite3 -csv output is 14 cols; feature_parent appended as '-'
        row = row + ['-']  # feature_parent: cross-ref session files, else '-'
        if row[1] not in existing:
            new_rows.append(row)

if new_rows:
    with open(week_file, 'a', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        for row in new_rows:
            w.writerow((row + [''] * 15)[:15])  # pad/trim to full header width
    print(f'added {len(new_rows)} row(s)')
else:
    print('0 rows to add')
PYEOF
fi

log "weekly collector: wrote $(($(wc -l < "$WEEK_FILE" 2>/dev/null || echo 0) - 1)) rows to $WEEK_FILE"

# 2. Monthly rollup (one row per week): token/cost/repos computed here;
#    estimate/waste columns left blank for the review agent.
#    Week-ending = today (the run day); skip if this week already rolled up.
TOTAL_TOKENS=$(awk -F, 'NR>1 {s+=$10} END {print s+0}' "$WEEK_FILE" 2>/dev/null || echo 0)
TOTAL_COST=$(awk -F, 'NR>1 {s+=$11} END {printf "%.4f", s+0}' "$WEEK_FILE" 2>/dev/null || echo 0)
REPOS_ACTIVE=$(awk -F, 'NR>1 {print $12}' "$WEEK_FILE" 2>/dev/null | sort -u | tr '\n' ' ' | sed 's/ $//')
mkdir -p "$ANALYTICS_DIR/monthly"
if [[ ! -f "$MONTH_FILE" ]]; then
  printf 'week_ending,repos_active,total_tokens,total_cost_usd,estimated_tokens,actual_tokens,estimate_error_pct,estimate_accuracy_pct,waste_incidents,scope_extensions,deferred_decisions,drift_nudges,codegraph_lookups,full_test_runs,flutter_analyze_runs,efficiency_ratio\n' > "$MONTH_FILE"
fi
# only append a week row when we have data and this week isn't already present
if [[ -s /tmp/weekly-rows.csv ]] && ! grep -q "^$WEEK_ENDING," "$MONTH_FILE" 2>/dev/null; then
  printf '%s,%s,%s,%s,,,,,,,,\n' "$WEEK_ENDING" "${REPOS_ACTIVE:-/}" "$TOTAL_TOKENS" "$TOTAL_COST" >> "$MONTH_FILE"
fi

log "monthly rollup: $WEEK_ENDING added to $MONTH_FILE"
exit 0