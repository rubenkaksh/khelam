#!/bin/bash
# Weekly cost/budget review for the repo this script lives in (canonical copy
# lives in forkable/scripts/ — the base template; children pull synced copies).
#
# Runs automatically every Sunday 18:00 via launchd (per-machine scheduling).
# Produces a review doc at docs/reviews/YYYY-MM-DD.md and fires a notification.
# Nothing is committed or pushed.
#
# Manual run:  bash scripts/weekly_review.sh
set -euo pipefail

# Repo-agnostic: derive the repo root from this script's own location
# (scripts/ sits at the repo root). Override for odd layouts via $REPO_OVERRIDE.
if [ -n "${REPO_OVERRIDE:-}" ]; then
  REPO="$REPO_OVERRIDE"
else
  REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
REPO_NAME="$(basename "$REPO")"
REVIEWS_DIR="$REPO/docs/reviews"
SESSION_DIR="$REPO/docs/sessions"
LOG="/tmp/weekly-review.log"
ANALYTICS_DIR="${ANALYTICS_DIR:-$HOME/analytics}"
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

# Commons consumer check: if commons had commits this week, verify commons
# ITSELF (origin self-check) and the consumer apps still analyze clean
# (catches breaking commons changes before they cost a rework cycle).
# Machine-local sibling paths — override via $COMMONS_REPO / $FORKABLE_REPO.
CONSUMER_NOTE=""
COMMONS="${COMMONS_REPO:-/Users/rubenk/projects/commons}"
FORKABLE="${FORKABLE_REPO:-/Users/rubenk/projects/forkable}"
if [ -d "$COMMONS/.git" ] && git -C "$COMMONS" log --oneline --since="7 days ago" 2>/dev/null | rg -q .; then
  CONSUMER_NOTE="Commons had commits this week. Origin + consumer check:"$'\n'
  CONSUMER_NOTE+="- commons flutter analyze (origin): $(cd "$COMMONS" && flutter analyze 2>&1 | tail -1)"$'\n'
  CONSUMER_NOTE+="- $REPO_NAME flutter analyze: $(cd "$REPO" && flutter analyze 2>&1 | tail -1)"$'\n'
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

# Session-boundary check (execution-model spec): flag weekly sessions that ran
# >1 day with >50M cache reads. Long sessions violate the fresh-session-per-batch
# rule (one long context accumulates cache reads; a fresh session resets them).
# Computed from opencode.db; degrades gracefully. Matches sessions of THIS repo
# by directory suffix (covers legacy + current paths alike).
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
    WHERE directory LIKE '%' || '$(basename "$REPO")'
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

# Forkable-sync tripwire (base-template policy): shared tooling (scripts/,
# pre-commit gate) is canonical in forkable; children pull synced copies.
# Flags child-only drift mechanically for the user's sign-off.
forkable_sync_check() {
  local base="${FORKABLE_REPO:-/Users/rubenk/projects/forkable}"
  if [ "$REPO" = "$base" ]; then
    echo "SKIPPED: this repo IS forkable (canonical base) — nothing to compare."
    return
  fi
  if [ ! -d "$base/scripts" ]; then
    echo "SKIPPED: forkable base has no scripts/ yet — base not migrated."
    return
  fi
  local drift
  drift="$(diff -rq -x '__pycache__' "$SCRIPTS_DIR" "$base/scripts" 2>/dev/null | rg -v '\.pyc$' || true)"
  if [ -z "$drift" ]; then
    echo "OK: scripts/ identical to forkable canonical (child is up to date)."
  else
    echo "DRIFT: this repo's scripts/ differs from forkable canonical — child has not pulled:"
    echo "$drift" | sed 's/^/  - /'
  fi
  if [ ! -f "$REPO/.git/hooks/pre-commit" ]; then
    echo "WARNING: no pre-commit gate installed in this repo."
  fi
}

# Deny-deferral survey (sandbox policy): L3 tasks that hit a denied path record
# one line per hit in ~/projects/sandbox/logs/deny-deferred-YYYY-MM-DD.log (the
# agent writes it synchronously, does NOT retry the denied path, and continues
# without the resource). The weekly review aggregates unsolved entries so the
# user can execute them supervised and sign off. Override via $SANDBOX_LOGS_DIR.
deny_deferred_survey() {
  local logs="${SANDBOX_LOGS_DIR:-$HOME/projects/sandbox/logs}"
  if [ ! -d "$logs" ]; then
    echo "SKIPPED: no sandbox deny-deferral logs at $logs — sandbox not in use."
    return
  fi
  local files
  files="$(ls "$logs"/deny-deferred-*.log 2>/dev/null | sort | tail -7 || true)"
  if [ -z "$files" ]; then
    echo "OK: no deny-deferred entries in the last 7 log files."
    return
  fi
  echo "DENY-DEFERRED (sandbox policy — entries need user supervised execution + sign-off):"
  local n=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    echo "  - $line"
    n=$((n+1))
  done < <(rg -v 'resolved_by_user' $files 2>/dev/null | tail -20)
  if [ "$n" -eq 0 ]; then
    echo "  (none unsolved)"
  fi
}

# Config-guard check (sandbox policy): mechanically validates the permission
# invariants the design depends on. (a) Global external_directory map: no '*'
# catch-all key (shadows every rule under last-match-wins — issue #15664), every
# deny AFTER every allow (ordering is the enforcement since opencode has no
# structural deny-wins — ecosystem finding 2026-08-07), and the 18 deny entries
# present. (b) Project grants: omit external_directory (global deny-list
# unbypassable) and carry the workspace-relative .env deny rules — an L3 grant's
# plain 'read: allow' OVERRIDES opencode's native .env-ask default (empirically
# verified 2026-08-07: granted read of .env succeeded, granular rules then
# denied it).
config_guard_check() {
  local global_cfg="${GLOBAL_CONFIG:-$HOME/.config/opencode/opencode.json}"
  local base="${FORKABLE_REPO:-/Users/rubenk/projects/forkable}"
  local grants="$base/opencode.json $HOME/projects/sandbox/config/opencode.json"
  [ -f "$REPO/opencode.json" ] && grants="$grants $REPO/opencode.json"
  [ -f "$REPO/.opencode/opencode.json" ] && grants="$grants $REPO/.opencode/opencode.json"
  local issues=0
  if [ -f "$global_cfg" ]; then
    local out
    out="$(python3 - "$global_cfg" <<'PY'
import json, sys
issues = []
try:
    cfg = json.load(open(sys.argv[1]))
except Exception as e:
    issues.append(f"unparseable: {e}")
    print("\n".join(issues)); sys.exit(0)
ed = (cfg.get("permission") or {}).get("external_directory") or {}
if "*" in ed:
    issues.append("external_directory contains a '*' catch-all key (shadows all rules under last-match-wins)")
actions = list(ed.values())
if "deny" in actions and "allow" in actions:
    first_deny = min(i for i, a in enumerate(actions) if a == "deny")
    last_allow = max(i for i, a in enumerate(actions) if a == "allow")
    if first_deny < last_allow:
        issues.append("an allow is listed AFTER a deny (deny no longer wins under last-match-wins)")
expect = ["~/.ssh/**","~/.aws/**","~/.gnupg/**","~/.netrc","~/Library/Keychains/**","~/.config/gh/**","~/.config/gcloud/**","~/.m2/**","~/.gradle/**","~/.config/git/**","~/.npmrc","~/.pypirc","~/.config/docker/**","~/.config/Code/User/**","~/.claude/skills/**","~/.agents/skills/**","~/.zsh_history","~/.bash_history"]
missing = [p for p in expect if ed.get(p) != "deny"]
if missing:
    issues.append(f"missing deny entries: {', '.join(missing)}")
print("\n".join(issues))
PY
)"
    if [ -n "$out" ]; then
      echo "ISSUES (global config): $out" | sed 's/^/  /'
      issues=$((issues+1))
    else
      echo "OK: global external_directory (no '*', denies after allows, all 18 denies present)."
    fi
  else
    echo "SKIPPED: global config not found at $global_cfg."
  fi
  for g in $grants; do
    [ -f "$g" ] || continue
    local gname="${g#$HOME/}"
    local out2
    out2="$(python3 - "$g" "$gname" <<'PY'
import json, sys
issues = []
try:
    cfg = json.load(open(sys.argv[1]))
except Exception as e:
    issues.append(f"unparseable: {e}")
    print("\n".join(issues)); sys.exit(0)
perm = cfg.get("permission") or {}
if "external_directory" in perm:
    issues.append("grant declares external_directory (can weaken the global boundary)")
read = perm.get("read")
if isinstance(read, dict):
    if read.get("*") != "allow":
        issues.append("read catch-all is not 'allow'")
    for pat in ("*.env", "*.env.*"):
        if read.get(pat) != "deny":
            issues.append(f"read rule '{pat}' is not 'deny'")
    if read.get("*.env.example") != "allow":
        issues.append("read rule '*.env.example' is not 'allow'")
elif read != "allow":
    issues.append(f"read is neither object nor 'allow' (got {read!r})")
print("\n".join(issues))
PY
)"
    if [ -n "$out2" ]; then
      echo "ISSUES (grant $gname): $out2" | sed 's/^/  /'
      issues=$((issues+1))
    else
      echo "OK: grant $gname (no external_directory, .env denied, .env.example allowed)."
    fi
  done
  return $issues
}

PROMPT="Weekly cost review for the $REPO_NAME project (and sibling repos commons/forkable when mentioned).

Read every session file listed below, plus the persistent review memory at docs/reviews/review-memory.md (its Open Actions table lists what is still outstanding — check each one), plus run 'git log --oneline --since=\"7 days ago\"' in the repo.

Inputs (this week's session files): $SESSION_FILES

$(if [ -n "$CONSUMER_NOTE" ]; then echo "Consumer health note (from the script): $CONSUMER_NOTE"; fi)

MECHANICAL CHECK (computed by the script, not by you): $(mechanical_check)

SESSION-BOUNDARY CHECK (computed by the script): $(session_boundary_check)

FORKABLE-SYNC CHECK (computed by the script, base-template policy): $(forkable_sync_check)

DENY-DEFERRED SURVEY (computed by the script, sandbox policy): $(deny_deferred_survey)

CONFIG-GUARD CHECK (computed by the script, sandbox policy): $(config_guard_check)

WEEKLY I/O DATA (from the analytics collector): weekly CSV at $ANALYTICS_DIR/weekly/$REVIEW_DATE.csv (may not exist yet on the first run of a week — then note that). Monthly rollup at $ANALYTICS_DIR/monthly/.

Audit checklist — be specific, quote file names and commit hashes:
1. Redundant verification: full 'flutter test'/'flutter analyze' runs that were not needed; integration tests re-run without the live path changing; anything re-verified that was already green.
2. Tooling discipline: for symbol/codebase questions, was 'codegraph explore' / 'codegraph node' / 'graphify query' used, or did the agent grep/read files repeatedly? Scan the session text for 'codegraph'/'graphify' mentions vs grep/read volume. Cite the actual tool calls you find — if the agent never logged any codegraph/graphify call, say so explicitly.
3. Scope back-and-forth: tasks where the requirements, repo scope, or depth changed mid-way; where one upfront question would have saved a whole cycle.
4. Output waste: huge webfetch dumps read fully, same file read multiple times in one session, verbose logs consumed unnecessarily.
5. Open Actions from review-memory.md: were any worked on? Close or keep them in your report.
6. User prompt drift (sidetrack guard): did the user's prompts cause waste this week? Look for the patterns in the global AGENTS.md 'User Prompt Discipline' section (destination layer missing, follow-up scope extensions, deferred decisions, missing acceptance bars, praise-then-scope-creep). Name each instance and the cheaper phrasing. This feeds the guard's pattern list.
7. Base-template drift (forkable policy): did the week build any reusable/shared capability child-first instead of in forkable? The FORKABLE-SYNC CHECK above lists script drift; the agent should also scan session files for shared-component work that landed in $REPO_NAME without a forkable home, and flag it for the user's decision.
8. Sandbox/guard health: the DENY-DEFERRED SURVEY lists tasks that hit a denied path — check the session files named in each entry and the opencode logs to confirm the agent did NOT retry the denied path (a retry is a guard violation). The CONFIG-GUARD CHECK validates the permission invariants (no '*' key, denies after allows, grants omit external_directory, .env denied in grants) — if it reports ISSUES, flag them for the user immediately, they are security-relevant. Also confirm no project config gained an 'external_directory' key this week (a config that declares it can override the global boundary). Flag all of the above for the user.
9. Grill Gate usage: for each major-drift trigger this period (breaking changes / major diversion from a locked plan / mid-task scope change), verify a full @architect brainstorm + grill-me occurred with user sign-off; skipped/rushed grills = finding. Protocol: ~/.config/opencode/AGENTS.md '### Major drift escalation — Architect Grill Gate'.

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
  send_report_to weekly-reviews "$REPO_NAME Weekly Review" "Weekly review ready: docs/reviews/$REVIEW_DATE.md" \
    "performance-summary.md" "update-log.md" "weekly/$REVIEW_DATE.csv" || true   # send_report_to returns 1 on Discord fail (fallback already fired)
  echo "$(date): review written to $REVIEW_FILE" >> "$LOG"
else
  echo "$(date): ERROR — review agent did not produce $REVIEW_FILE" >> "$LOG"
  send_error_report "$REPO_NAME Weekly Review" "Weekly review FAILED — check /tmp/weekly-review.log"
fi
