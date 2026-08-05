# Handoff — v1 Execution: Agent Knowledge Hierarchy v2

> **For the background agent starting 2026-08-06.** Carry out the TODO steps in order, in the background, and deliver a final report to the user when done. Do NOT redo anything under "Done". The user wants the report when finished — no mid-progress pings.

## 1. Context (read first)

The user's vision (7 points, decided 2026-08-05): (1) AGENTS.md hierarchy — global software-engineer persona with a dedicated Flutter section, project rules in project `.md` files; (2) feature-wise PRD `.md` files instead of session-wise implementation for huge projects (more context); (3) token/model/`npx ccusage` pricing data; (4) performance analytics including the user's own performance; (5) weekly review + improvement in background with STRICT reporting (CSV + chart recommendations + performance summary + update log); (6) v2 comms integration for chat delivery; (7) autonomous project building with limited sub-agents, task breakdown with estimates, user as PM → "Visionary CEO".

**Architect's design was delivered and grilled (9 decisions, all locked):**
1. Per-repo data: direct SQL on opencode.db + ccusage fallback
2. **Analytics live in GLOBAL `~/analytics/`** (user override): `weekly/`, `monthly/`, `performance-summary.md`, `update-log.md`, `charts.md`
3. Keep derived monthly rollup CSV
4. CSV primary + PNGs on demand (`scripts/analytics_charts.py`, graceful if matplotlib missing)
5. Feature docs USER-DECLARED ("PRD"/"feature"); code boundaries = `lib/features/<feature>/`; before switching to a different feature dir, consult that feature's prior context (feature README if declared, else prior session docs)
6. HR#1 split: template + mandate GLOBAL; lifecycle/paths project-local
7. commons AGENTS.md DELETED (graphify section now global); forkable + backend get 3-line marker files; **forkable = future source of truth — khelam's full setup gets copied to forkable at the end of khelam development**
8. Raw token columns from opencode.db; cost joined weekly via ccusage pricing (cost NULL fallback, documented)
9. Dual-author update-log: session writes at change time, weekly review verifies (missing entry = violation)

## 2. Current state

### DONE (do NOT redo)
- [x] **Global AGENTS.md rewritten**: `~/.config/opencode/AGENTS.md` — Persona, CodeGraph, graphify, Work Tracking template, Cost Discipline (generic), Flutter Specialization (incl. `!`/`as T` ban with user rationale, dep-constraint checks, targeted tests, shared fakes, feature-boundary handoff, commons consumer check), Precedence & Composition (5 tiers, `# non_flutter: true` marker), sidetrack guard (kept), Analytics section. **This file is LIVE — the background agent is governed by it.**
- [x] **khelam AGENTS.md slimmed**: project-local only (HR#1 lifecycle + review-memory check + archive rule, Project Conventions: integration tests, commons consumer check, demo seam, pre-commit gate, weekly review, analytics, update-log). Inheritance reference to global.
- [x] Session file `docs/sessions/2026-08-05.md`: cost note (estimate ~35k for v1; actual to be logged) + all 9 decisions logged.
- [x] opencode.db schema verified: `~/.local/share/opencode/opencode.db`, table `session` — columns `id, title, directory, agent, model (JSON {"id","providerID","variant"}), cost (always 0.0 for free tiers), tokens_input, tokens_output, tokens_reasoning, tokens_cache_read, tokens_cache_write, time_created, time_updated (epoch MS)`. NOTE: khelam sessions exist under BOTH `/Users/rubenk/projects/khelam` (legacy) and `/Users/rubenk/projects/khel-service/khelam` (current) — use LIKE matching. ccusage (`npx ccusage opencode daily|weekly|monthly|session -j`) has NO per-repo field — pricing join only.

### NOT done (the TODO below)
- Sibling repo AGENTS.md files (commons still has its graphify-only AGENTS.md; forkable + backend have none — verified 2026-08-05)
- `~/analytics/` structure + collector script
- weekly_review.sh v2 + report_sink.sh
- Feature doc migration
- Validation + closeout (update-log, review-memory, commits, report)

## 3. TODO — detailed steps in order

### Step A — Commit current WIP (if not already committed)
`git add AGENTS.md docs/sessions/2026-08-05.md docs/handoff-v1-execution.md` → commit (docs-only, gate skips) → push origin/main. The global config is outside git — nothing to commit there.

### Step B — Sibling repos
1. **commons** (`/Users/rubenk/projects/commons`): `git rm AGENTS.md` (its graphify section now lives in global). NOTE: commons working tree has dirty `graphify-out/` files (expected after graphify runs — do NOT stage them). Commit ONLY the AGENTS.md deletion. Branch: current (check `git branch --show-current` first).
2. **forkable** (`/Users/rubenk/projects/forkable`, branch `test/aider`): create `AGENTS.md` (3 lines):
   `# AGENTS.md — forkable (Flutter app)\nInherits the global software-engineer instructions at ~/.config/opencode/AGENTS.md (Flutter Specialization, Cost Discipline, Work Tracking, sidetrack guard). Conventions reference: khelam repo docs/ — forkable is the future source of truth; copy khelam's full setup here at the end of khelam development.`
   Commit + push to `test/aider`.
3. **backend** (`/Users/rubenk/projects/khel-service/rms-futsal-backend`, branch `feature/login-auth`): create `AGENTS.md` marker:
   `# AGENTS.md — rms-futsal-backend (NestJS)\n# non_flutter: true\nInherits Global Engineering Hygiene + Sidetrack Guard from ~/.config/opencode/AGENTS.md. Flutter Specialization sections do not apply.`
   Commit + push to `feature/login-auth`.
4. Validate: `flutter analyze` in commons + forkable (they now inherit the `!` ban — both already compliant per 2026-08-01 session, but verify).

### Step C — `~/analytics/` + collector + charts
1. `mkdir -p ~/analytics/{weekly,monthly,charts}`
2. **`scripts/ccusage_collect.sh`** (khelam repo, new):
   - sqlite3 query opencode.db: sessions from last 7 days where `directory LIKE '%/khelam' OR directory LIKE '%khel-service/khelam%' OR directory LIKE '%/forkable' OR directory LIKE '%/commons'` (LIKE matching per verified data)
   - Append row per session to `~/analytics/weekly/YYYY-MM-DD.csv` (week-ending date). Schema (exact columns):
     `date,session_id,agent,model_name,input_tokens,output_tokens,cache_read_tokens,cache_write_tokens,reasoning_tokens,total_tokens,cost_usd,repo,title,duration_seconds,feature_parent`
     - `model_name` parsed from model JSON via python3 (id field); `total_tokens` = input+output+cache_read+cache_write+reasoning; `duration_seconds` = (time_updated−time_created)/1000; `repo` derived from directory; `feature_parent` = cross-ref the week's session files' Objective lines for `docs/features/<name>/README.md` refs (else `-`); `cost_usd` = join with `npx ccusage opencode session -j` by sessionId when pricing available, else NULL
   - Monthly rollup → `~/analytics/monthly/YYYY-MM.csv` (one row per week): `week_ending,repos_active,total_tokens,total_cost_usd,estimated_tokens,actual_tokens,estimate_error_pct,estimate_accuracy_pct,waste_incidents,scope_extensions,deferred_decisions,drift_nudges,codegraph_lookups,full_test_runs,flutter_analyze_runs,efficiency_ratio` — token/cost/repos computed by script; estimate/waste/metrics columns filled by the weekly review agent (or left blank with a note)
   - Graceful degradation: if the sqlite query fails (schema changed) → log warning to `/tmp/weekly-review.log` and fall back to ccusage global-only (no per-repo split); the review agent flags "analytics collector degraded"
3. **`scripts/analytics_charts.py`** (new, ~50-100 lines): 8 charts, `--chart <n>` arg, PNGs to `~/analytics/charts/`: (1) cost trend line, (2) waste-category pareto horizontal bar, (3) estimate calibration scatter (y=x line), (4) model usage stacked bar, (5) cache-efficiency ratio bar, (6) drift per pattern bar, (7) verification waste dual-axis line, (8) tooling efficiency line. Graceful exit with `pip3 install matplotlib` hint if the module is missing.
4. **`~/analytics/charts.md`**: chart recipes doc — for each chart: CSV source, columns, chart type, the question it answers, code snippet.

### Step D — weekly_review.sh v2
1. Prepend `ccusage_collect.sh` invocation to the existing flow (step 1 before session selection).
2. Evolve the review-agent PROMPT with 3 new sections:
   - **SECTION A (Analytics)**: read the week's CSV + monthly rollup → write `~/analytics/performance-summary.md` (overwritten weekly) with EXACT structure: `# Performance Summary — <date>` → `## Agent Metrics` table (Total tokens, Cost USD, Estimate accuracy %, Waste incidents w/ categories, Full test runs, codegraph/graphify lookups, Sessions; each with This Week + 4-Week Trend) → `## User Metrics` table (per sidetrack pattern: count + cheaper phrasing, Total nudges issued)
   - **SECTION B (Update log)**: append `## YYYY-MM-DD` entries to `~/analytics/update-log.md` for every knowledge/rule change made or recommended (format: `- **AGENTS.md** (global|project): <what> (Review: <date>, action: <#>)`); if nothing changed, write `No changes — <reason>`
   - **SECTION C (Feature audit)**: for each `docs/features/<feature>/README.md` touched this week: checklist completion %, ADRs added, scope drift (sessions on untracked items), stale (>7 days no progress → flag for CEO)
   - Review doc gains `## Performance Summary (see ~/analytics/performance-summary.md)` + `## Feature Audit` sections (appended after existing ones — keep existing structure: What shipped / Waste observed / Top 3 cuts / One thing went well / Memory update)
3. **`scripts/report_sink.sh`** (new): `send_report <title> <body> [artifact...]` honoring `REPORT_SINK` env — `macos_notification` (default; osascript, current behavior), `discord_webhook` / `slack_webhook` (curl stubs, v2), `noop` (testing). Wire into weekly_review.sh replacing the inline osascript calls; notification lists the artifacts produced. Keep the existing FAILED fallback notification.
4. Preserve: filename-date session selection, commons consumer check, mechanical codegraph/graphify tripwire. `bash -n` before done.

### Step E — Feature doc model
1. Migrate `docs/prd/booking-calendar-feature.md` → `docs/features/booking-calendar/README.md` (keep content; wrap in the template: Problem Statement / Scope In-Out / User Stories / Architecture Decisions table / Data Models / Implementation Plan checklist with acceptance bars / Test Plan / Progress Tracker / Backlinks). ≤200 lines.
2. Update links in session files + backlog.md that reference the old path; leave `docs/prd/` with a one-line redirect notice (or delete after link sweep).
3. `docs/superpowers/` stays as-is for now (not declared features) — add a backlog note.
4. Session Objective convention (document in khelam AGENTS.md or session template): `Feature: docs/features/<name>/README.md — <task>` when working on a declared feature (machine-parseable by the collector for feature_parent).

### Step F — Validation (acceptance bar)
- `bash -n` on all new/edited scripts
- Run `bash scripts/ccusage_collect.sh` manually → CSV rows appear in `~/analytics/weekly/`
- Run `bash scripts/weekly_review.sh` end-to-end → 4 artifacts exist (review doc in `docs/reviews/`, weekly CSV, `~/analytics/performance-summary.md`, `~/analytics/update-log.md`) + notification fired + nothing committed by the script
- `python3 scripts/analytics_charts.py --chart 1` → PNG in `~/analytics/charts/`
- `flutter analyze` in khelam clean (post-slim; the `!` ban is now global-enforced — repo already compliant)

### Step G — Closeout
- Update-log entries for EVERY change made this session (dual-author rule — entry at change time, not after)
- `docs/reviews/review-memory.md`: add implemented-measures rows (hierarchy v2, analytics pipeline, feature PRD model, report_sink) + a Review History note
- Commit + push: khelam (main), forkable (test/aider), commons, backend
- Log the ACTUAL cost of this execution (vs the ~35k estimate) in the session file cost-note line
- Final report to the user: what shipped (per repo), artifacts produced, decisions honored, deviations from this handoff + why, what remains for v2 (comms swap, autonomous build)

## 4. Rules the background agent MUST follow
- You are governed by the NEW global AGENTS.md (live now): Flutter Specialization, Cost Discipline (scope-question, codegraph/graphify before grep, verify-before-debug, targeted tests), Work Tracking (this repo's session file is `docs/sessions/2026-08-06.md` — create it, carry forward relevant context), update-log discipline, sidetrack guard applies to the user.
- Cost-note any operation >5k tokens in the session file BEFORE starting (estimate) + AFTER (actual).
- Do NOT modify `~/.config/opencode/AGENTS.md` — it is the settled deliverable. Propose changes through the weekly review instead.
- Do NOT redo Done items. Do NOT commit graphify-out/ dirt in any repo. Do NOT touch the launchd plist (already loaded).
- Never commit with known failures; the pre-commit gate enforces it mechanically.
- Environment: backend running on :8000 (`nohup npm run start:dev`, log `/tmp/rms-backend.log`) — DO NOT pkill it; launchd `com.khelam.weekly-review` loaded (Sunday 18:00); emulator-5554 available for integration tests if the live path changes.
