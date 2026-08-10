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
# v3 delivery: SECTION D writes THREE files, one per Discord message
# (Summary / Agent Metrics / User Metrics) — no attachments in the flow.
SUMMARY_FILE_SUMMARY="$REVIEWS_DIR/$REVIEW_DATE.discord.summary.txt"
SUMMARY_FILE_AGENT="$REVIEWS_DIR/$REVIEW_DATE.discord.agent.txt"
SUMMARY_FILE_USER="$REVIEWS_DIR/$REVIEW_DATE.discord.user.txt"
mkdir -p "$REVIEWS_DIR"

# Source report_sink for delivery abstraction (REPORT_SINK env honored).
. "$SCRIPTS_DIR/report_sink.sh"

# Step 0 (v2): run the analytics collector FIRST so the review agent has
# I/O data. Degrades gracefully (logs to $LOG) — never blocks the review.
bash "$SCRIPTS_DIR/ccusage_collect.sh" >> "$LOG" 2>&1 || \
  echo "$(date): WARNING — analytics collector failed; review proceeds without I/O data" >> "$LOG"

# The collector names its week file by `date -v-1d` (NOT the review date —
# on a Sunday run the file is Saturday's date). Resolve the actual latest
# week file so the prompt and the Discord attachment point at the real CSV.
WEEK_CSV_NAME="$(basename "$(ls -t "$ANALYTICS_DIR"/weekly/*.csv 2>/dev/null | head -1)" 2>/dev/null || true)"

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
# NOTE on the two guards below (Aug 2026 root-cause of the silent 18:00 failure):
# 1) `git log | rg -q .` is a SIGPIPE race — rg -q exits on its first match and
#    SIGPIPEs git (exit 141), which pipefail turns into a FALSE; whether the
#    branch fires is nondeterministic. Select by output length instead.
# 2) flutter lives under ~/fvm, which is NOT on the launchd PATH. A missing
#    binary inside $(...) (via pipefail) aborts the WHOLE review under set -e,
#    silently, with exit 127 and no report. So flutter must be guarded and the
#    analyze pipeline must never fail the substitution — degrade to a WARNING.
if [ -d "$COMMONS/.git" ] && [ -n "$(git -C "$COMMONS" log --oneline --since='7 days ago' 2>/dev/null)" ]; then
  CONSUMER_NOTE="Commons had commits this week. Origin + consumer check:"$'\n'
  if command -v flutter >/dev/null 2>&1; then
    CONSUMER_NOTE+="- commons flutter analyze (origin): $(cd "$COMMONS" && flutter analyze 2>&1 | tail -1 || true)"$'\n'
    CONSUMER_NOTE+="- $REPO_NAME flutter analyze: $(cd "$REPO" && flutter analyze 2>&1 | tail -1 || true)"$'\n'
    if [ -d "$FORKABLE/.git" ]; then
      CONSUMER_NOTE+="- forkable flutter analyze: $(cd "$FORKABLE" && flutter analyze 2>&1 | tail -1 || true)"
    fi
  else
    echo "$(date): WARNING — flutter not on PATH; skipping commons consumer analyze check (launchd PATH lacks fvm shim)" >> "$LOG"
    CONSUMER_NOTE+="flutter not on PATH — analyze check skipped"
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

# User-session stats (v3 delivery): top-level (user-driven) vs subagent split,
# active days, longest idle gap between user sessions, most active day by
# tokens — feeds the User Metrics Discord message. Computed from opencode.db
# (parent_id IS NULL = user-driven); degrades gracefully like the checks above.
user_session_stats() {
  local db="$HOME/.local/share/opencode/opencode.db"
  if [[ ! -f "$db" || ! -x "$(command -v sqlite3)" ]]; then
    echo "SKIPPED: opencode.db or sqlite3 unavailable — user-session stats not computed"
    return
  fi
  local since total top active gap day
  since="CAST(strftime('%s','now','-7 day') AS INTEGER)*1000"
  total="$(sqlite3 "$db" "SELECT COUNT(*) FROM session WHERE time_created > $since;" 2>/dev/null || true)"
  top="$(sqlite3 "$db" "SELECT COUNT(*) FROM session WHERE parent_id IS NULL AND time_created > $since;" 2>/dev/null || true)"
  active="$(sqlite3 "$db" "SELECT COUNT(DISTINCT date(time_created/1000,'unixepoch','localtime')) FROM session WHERE parent_id IS NULL AND time_created > $since;" 2>/dev/null || true)"
  gap="$(sqlite3 "$db" "SELECT printf('%.1fh', MAX((t2-t1)/3600000.0)) FROM (SELECT time_created AS t1, LEAD(time_created) OVER (ORDER BY time_created) AS t2 FROM session WHERE parent_id IS NULL AND time_created > $since);" 2>/dev/null || true)"
  day="$(sqlite3 "$db" "SELECT date(time_created/1000,'unixepoch','localtime') || ' (' || printf('%.1fM', SUM(COALESCE(tokens_input,0)+COALESCE(tokens_output,0)+COALESCE(tokens_cache_read,0)+COALESCE(tokens_cache_write,0)+COALESCE(tokens_reasoning,0))/1000000.0) || ')' FROM session WHERE parent_id IS NULL AND time_created > $since GROUP BY date(time_created/1000,'unixepoch','localtime') ORDER BY SUM(COALESCE(tokens_input,0)+COALESCE(tokens_output,0)+COALESCE(tokens_cache_read,0)+COALESCE(tokens_cache_write,0)+COALESCE(tokens_reasoning,0)) DESC LIMIT 1;" 2>/dev/null || true)"
  if [[ -z "${total:-}" ]]; then
    echo "SKIPPED: no session rows in the last 7 days"
    return
  fi
  echo "Total sessions: ${total:-0} · Top-level (user-driven): ${top:-0} · Subagent: $(( ${total:-0} - ${top:-0} )) · Active days: ${active:-0} · Longest idle gap between user sessions: ${gap:-n/a} · Most active user day: ${day:-n/a}"
}

# Index-freshness verification (codegraph + graphify auto-refresh guard).
# HARD FAIL: any codegraph index stale > FRESHNESS_DAYS (default 7) or
# pendingChanges > 0 (a sync did not complete). Advisory only: graphify
# check-update flags semantic re-extraction pending → Open Action (never
# hard-fails; extract never runs unattended).
# Covers the indexed repos on this machine: the current repo + siblings
# commons + forkable (machine-local paths, override via $COMMONS_REPO /
# $FORKABLE_REPO). hook-only design (2026-08-08) — no launchd timer backs
# the hook, so this is the safety net that catches a broken hook.
freshness_check() {
  local threshold="${FRESHNESS_DAYS:-7}"
  local out="" fail=0

  # Indexed repos (all have .codegraph/). commons has no scripts/ so its hook
  # falls back to forkable's codegraph_refresh.sh — covered here regardless.
  local repos=()
  [ -d "${REPO}/.codegraph" ] && repos+=("$REPO")
  [ -d "${COMMONS:-/Users/rubenk/projects/commons}/.codegraph" ] && \
      repos+=("${COMMONS:-/Users/rubenk/projects/commons}")
  [ -d "${FORKABLE:-/Users/rubenk/projects/forkable}/.codegraph" ] && \
      repos+=("${FORKABLE:-/Users/rubenk/projects/forkable}")

  if [ "${#repos[@]}" -eq 0 ]; then
    echo "SKIPPED: no indexed repos (.codegraph/) found."
    return
  fi

  for repo in "${repos[@]}"; do
    local name; name="$(basename "$repo")"

    # --- CodeGraph freshness (hard fail) ---
    # status --json → lastIndexed (ISO-8601) + pendingChanges{added,modified,removed}.
    local cg_st="false" cg_pending=1 cg_last="" agedays=0
    if ! command -v codegraph >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
      out+="  FAILED: $name — codegraph/python3 unavailable\n"; fail=1
    elif ! cg="$(codegraph status --json "$repo" 2>/dev/null)"; then
      out+="  FAILED: $name — codegraph status errored\n"; fail=1
    else
      # Capture the python parse into a var first, THEN read — nesting a
      # multi-line $($(...)) inside a here-string <<< is mis-parsed by bash.
      local _parsed
      _parsed="$(printf '%s' "$cg" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
    pc=d.get("pendingChanges",{})
    total=int(pc.get("added",0))+int(pc.get("modified",0))+int(pc.get("removed",0))
    print(str(d.get("initialized",False)).lower(), total, d.get("lastIndexed",""))
except Exception:
    print("false 1 \"")
' 2>/dev/null || printf 'false 1 \"\"')"
      read -r cg_st cg_pending cg_last <<< "$_parsed"
      if [ "$cg_st" = "true" ] && [ -n "$cg_last" ]; then
        local last_epoch now_epoch
        last_epoch="$(python3 -c 'from datetime import datetime,sys
ts=sys.argv[1].replace("Z","+00:00")
print(int(datetime.fromisoformat(ts).timestamp()))' "$cg_last" 2>/dev/null || echo 0)"
        now_epoch="$(date +%s)"
        [ "$last_epoch" -gt 0 ] && agedays=$(( (now_epoch - last_epoch) / 86400 ))
      fi
    fi

    if [ "$cg_st" = "true" ]; then
      if [ "${cg_pending:-0}" -gt 0 ]; then
        out+="  FAILED: $name — codegraph pendingChanges=${cg_pending} (sync did not complete)\n"; fail=1
      elif [ "$agedays" -gt "$threshold" ]; then
        out+="  FAILED: $name — codegraph lastIndexed ${agedays}d ago (> ${threshold}d)\n"; fail=1
      else
        out+="  OK: $name — codegraph fresh (lastIndexed ${cg_last}, pending=${cg_pending}, ${agedays}d old)\n"
      fi
    fi

    # --- Graphify freshness (advisory → Open Action; never hard-fail) ---
    if [ -d "$repo/graphify-out" ]; then
      if graphify check-update "$repo" >/dev/null 2>&1; then
        out+="  OK: $name — graphify up to date\n"
      else
        out+="  OPEN-ACTION: $name — graphify check-update flags semantic re-extraction pending (run: graphify extract $repo)\n"
      fi
    fi
  done

    if [ "$fail" -ne 0 ]; then
        printf 'FAILED\n%b' "$out"
    else
        printf 'OK\n%b' "$out"
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

INDEX FRESHNESS CHECK (computed by the script): $(freshness_check)

SESSION-BOUNDARY CHECK (computed by the script): $(session_boundary_check)

USER-SESSION STATS (computed by the script — feeds the User Metrics Discord message): $(user_session_stats)

FORKABLE-SYNC CHECK (computed by the script, base-template policy): $(forkable_sync_check)

DENY-DEFERRED SURVEY (computed by the script, sandbox policy): $(deny_deferred_survey)

CONFIG-GUARD CHECK (computed by the script, sandbox policy): $(config_guard_check)

WEEKLY I/O DATA (from the analytics collector): weekly CSV at $ANALYTICS_DIR/weekly/$WEEK_CSV_NAME (may be absent on the first run of a week — then note that). Monthly rollup at $ANALYTICS_DIR/monthly/.

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

SECTION A — ANALYTICS (v2): read the week's CSV ($ANALYTICS_DIR/weekly/$WEEK_CSV_NAME if it exists, else note its absence) and the monthly rollup ($ANALYTICS_DIR/monthly/). Write $ANALYTICS_DIR/performance-summary.md (OVERWRITE each week) with EXACT structure:
# Performance Summary — $REVIEW_DATE
## Agent Metrics (table)
Columns: Metric | This Week | 4-Week Trend
Rows: Total tokens, Cost USD, Estimate accuracy %, Waste incidents (w/ categories), Full test runs, codegraph/graphify lookups, Sessions
## User Metrics (table)
Columns: Sidetrack pattern | Count | Cheaper phrasing
Rows: one per sidetrack pattern found this week (destination layer missing, follow-up scope extension, deferred decision, missing acceptance bar, praise-then-scope-creep) + a Total nudges issued row.

SECTION B — UPDATE LOG (v2): append '## $REVIEW_DATE' entries to $ANALYTICS_DIR/update-log.md (create the file with a header if missing) for every knowledge/rule change made or recommended this week. Format: '- **AGENTS.md** (global|project): <what> (Review: $REVIEW_DATE, action: <#>)'. If nothing changed, write 'No changes — <reason>'.

SECTION C — FEATURE AUDIT (v2): for each docs/features/<feature>/README.md touched this week: checklist completion %, ADRs added, scope drift (sessions on untracked items), stale (>7 days no progress → flag for CEO review). If no features are declared yet, write 'No declared features this week'.

SECTION D — DISCORD DELIVERY (v3): write THREE plain-text files, one per Discord message. Discord markdown only: **bold** + emoji; NO tables, NO code fences, NO • bullets, NO attachments, NO update-log content. Each file is a complete message body (no title prefix needed — the body leads with its emoji headline). HARD LIMIT: 1900 characters each — count before writing.
1. $SUMMARY_FILE_SUMMARY (📊 Summary):
   - Headline: '📊 **Weekly Review $REVIEW_DATE — <sessions> sessions · <tokens> tokens · $<cost> cost**' (tokens rounded to 1 decimal, M).
   - '🚀 **What shipped this week** (<N> groups):' then numbered lines 'N. **GroupName** — one short sentence (what + where it landed)'. Batch by CONCERN — robustness / user-facing feature / comms / tooling / governance — max 5 groups, merge related items; NO batch codenames (T2/T5).
   - '⚠️ **Top waste** — <single biggest burn + cause, ≤2 lines>'.
   - '✅ **Resolved this cycle** — <items finished this week that weren't in last week's outlook>'. Items already fixed before posting (e.g. drift re-pulls) go HERE, not in Focus.
   - '🎯 **Focus next week** (what / why / who):' then ≤3 numbered items, plain language, no jargon: 'N. **Title** — <one sentence what>. _Why: <cause>. Who: <role>._'. If an item is done-but-uncommitted/pending-sign-off, append '_Held to <date>._'.
   - Final line: '📄 Full review: docs/reviews/$REVIEW_DATE.md'.
2. $SUMMARY_FILE_AGENT (🤖 Agent metrics): headline '🤖 **Agent metrics — $REVIEW_DATE**'; then from $ANALYTICS_DIR/performance-summary.md + the weekly CSV + USER-SESSION STATS: '📈 **Sessions run**: N total (khelam · backend · forkable) + subagent / top-level split'; '🔢 **Tokens**: N.NM · Cost: $X' with input/output/cache-read split; '🖥️ **Cache efficiency**: NN%'; '🏗️ **Model mix**: per-model token share'; '📊 **4-week trend**: a → b → c → d'; '🔥 **Top 3 token hogs**: numbered lines (title — Mtokens, cause)'; '🧪 **Verification**: N full-suite/analyze · N integration runs'; '🔍 **Tooling lookups**: N codegraph/graphify'; '⚠️ **Waste** (N incidents): category ×count · category ×count'; '🎯 **Estimate accuracy**: ≈N% (N/N within/under)'.
3. $SUMMARY_FILE_USER (🧑 User metrics): headline '🧑 **User metrics — $REVIEW_DATE**'; then: '📱 **Sessions initiated**: N top-level · N with delegation' + active days + cadence (from USER-SESSION STATS); '⏱️ **Session gaps**: longest idle + most active day'; '🧭 **Prompt drift (sidetrack guard)**: one line per pattern found — '✅ <pattern>: 0' or '🎯 <pattern>: N — <brief cause>' (from your SECTION A User Metrics table); '💬 **Nudges issued**: N'; '💡 **Cheaper phrasing** seen this week: <one example>'; '📋 **Data source note**: <what came from DB vs CSV vs text analysis>'.

Then write $REVIEW_FILE with this exact structure (plain language, under 60 lines):
# Weekly Review — $REVIEW_DATE
## What shipped this week (5-8 bullets)
## Waste observed (top items: what happened, why it cost, how to avoid)
## Top 3 cuts for next week (concrete and actionable)
## One thing that went well
## Memory update (changes to make in docs/reviews/review-memory.md: new review-history row, actions closed or added)
## Performance Summary (see $ANALYTICS_DIR/performance-summary.md)
## Feature Audit

Do NOT commit, push, or modify any file other than $REVIEW_FILE, $SUMMARY_FILE_SUMMARY, $SUMMARY_FILE_AGENT, $SUMMARY_FILE_USER, $ANALYTICS_DIR/performance-summary.md, and $ANALYTICS_DIR/update-log.md."

cd "$REPO"

# Failure guarantee: the EXIT trap is the single safety net. It fires
# send_error_report whenever the script exits without a review file and the
# explicit failure path did not already report. Previously a `set -e` abort
# mid-script (e.g. the Aug 9 flutter/127) skipped ALL reporting — launchd
# recorded the 127 and nothing was notified. _reported_failure prevents
# double-reporting when the explicit path below already fired.
_reported_failure=0
_on_exit() {
  local code=$?
  if [ "$_reported_failure" -eq 1 ] || [ -f "$REVIEW_FILE" ]; then
    return 0
  fi
  echo "$(date): ERROR — weekly review FAILED (exit $code) without producing $REVIEW_FILE" >> "$LOG"
  send_error_report "$REPO_NAME Weekly Review" "Weekly review FAILED (exit $code) — check /tmp/weekly-review.log" || true
}
trap _on_exit EXIT

# Run the review agent, retrying transient failures (agent/CLI hiccups, PATH
# races): up to WEEKLY_REVIEW_ATTEMPTS (default 3), with a delay between
# attempts. All attempts exhausted → the EXIT trap reports the failure.
MAX_ATTEMPTS="${WEEKLY_REVIEW_ATTEMPTS:-3}"
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  opencode run --auto --dir "$REPO" "$PROMPT" >> "$LOG" 2>&1 || true
  [ -f "$REVIEW_FILE" ] && break
  echo "$(date): weekly review attempt $attempt/$MAX_ATTEMPTS produced no $REVIEW_FILE" >> "$LOG"
  if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
    sleep "${WEEKLY_REVIEW_RETRY_DELAY:-90}"
  fi
done

if [ -f "$REVIEW_FILE" ]; then
  # --- Discord delivery (v3): 3 separate text messages, NO attachments -----
  # SECTION D writes three files (Summary / Agent Metrics / User Metrics),
  # each a complete message body. Clamp to 1900c as a safety net (Discord
  # caps at 2000; the sink falls back to a macos notification on a 400).
  # Missing files degrade to a pointer message — never block delivery.
  send_review_message() { # <file> <fallback-body>
    local f="$1" body=""
    if [ -f "$f" ]; then
      body="$(cat "$f")"
      if [ "${#body}" -gt 1900 ]; then
        body="${body:0:1900}"
        body="${body%$'\n'*}"
      fi
    else
      body="$2"
    fi
    send_report_to weekly-reviews "" "$body" || true
  }
  send_review_message "$SUMMARY_FILE_SUMMARY" "Weekly review ready: docs/reviews/$REVIEW_DATE.md"
  send_review_message "$SUMMARY_FILE_AGENT" "🤖 Agent metrics: see docs/reviews/$REVIEW_DATE.md"
  send_review_message "$SUMMARY_FILE_USER" "🧑 User metrics: see docs/reviews/$REVIEW_DATE.md"
  echo "$(date): review written to $REVIEW_FILE" >> "$LOG"
else
  _reported_failure=1
  echo "$(date): ERROR — review agent did not produce $REVIEW_FILE after $MAX_ATTEMPTS attempts" >> "$LOG"
  send_error_report "$REPO_NAME Weekly Review" "Weekly review FAILED after $MAX_ATTEMPTS attempts — check /tmp/weekly-review.log" || true
fi
