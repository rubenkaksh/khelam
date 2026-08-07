# Review Memory — khelam Cost Discipline

**Purpose**: Persistent record of weekly reviews, implemented waste-reduction measures, and open actions. Updated after each weekly review (append-only).

---

## Review History

| Date | Key Findings | Review Doc |
|------|--------------|------------|
| 2026-08-05 | 8 waste instances (DTO rebuild, double @librarian, router guard ×2, deferred API tests, known-broken E2E, samseer rework, widget-test hang, minor churn). Top 3 cuts: upfront scope questions, no deferred diagnosis, check Blockers before E2E. | `docs/reviews/2026-08-05.md` |
| 2026-08-06 | 7 waste incidents in week 08-05→08-06; 167.5M tokens all free-tier ($0); ~59% estimate accuracy (safe direction); 23 sessions; booking-calendar Out-list stale (API integration + auth guard shipped). Background-agent v1 executed under 08-05 execution-model spec: 7 batches, 5 L2/L1 gates passed, 1 latent bug caught by validation (`mechanical_check` ordering), sandbox guard scripts NOT mechanically installed (deviation). | `docs/reviews/2026-08-06.md` |

---

## Implemented Measures (as of 2026-08-05, commit `145d653`)

| Measure | Location | What It Closes |
|---------|----------|----------------|
| Cost Discipline rules (scope question, codegraph/graphify first, targeted tests, live tests on live-path change only, no commits with known failures, check Blockers before E2E, shared fakes, read files once) | `AGENTS.md` Cost Discipline section | DTO rebuild, deferred diagnosis, redundant verification, integration vs blockers, shared token store, scope back-and-forth |
| Session template `Environment` section | `AGENTS.md` session template | Service-kill accidents (`pkill`) |
| Weekly review automation (script + launchd Sun 18:00) | `scripts/weekly_review.sh`, `scripts/com.khelam.weekly-review.plist` | Automated audit cadence |
| Shared `RecordingTokenStore` fake | `test/helpers/recording_token_store.dart` | Widget-test hang, per-file duplication |
| Review agent reads this memory doc + must cite codegraph/graphify usage | `scripts/weekly_review.sh` prompt | Keeps memory across weeks; dogfoods tooling discipline |
| Pre-edit rule: every symbol-level edit logs its codegraph/graphify lookup in the Work Log | `AGENTS.md` Cost Discipline | Enforces the tooling rule (0-use week was the top burn) |
| Pre-commit gate (analyze + full test, blocks on failure; docs-only skip) | `.git/hooks/pre-commit` → `scripts/pre_commit_check.sh` | Enforces "no commits with known failures" mechanically |
| "Verify current state before debugging" + known-good commands | `AGENTS.md` Cost Discipline | Kills stale-idToken/wrong-port/tsx DI debug cycles |
| Cost note for >5k-token operations, before starting | `AGENTS.md` Cost Discipline | Makes invisible token spend visible |
| `Cleanup` subsection in session template | `AGENTS.md` template | Prevents temp instrumentation / regen noise in commits |
| Dependency-constraint check before `flutter pub add` | `AGENTS.md` Cost Discipline | Avoids version-solving failures (samseer 0.1.0 class) |
| Commons consumer check (analyze both apps when commons changed) | `scripts/weekly_review.sh` | Catches breaking commons changes weekly |
| Sidetrack guard (global): passive `[nudge]` one-liners on prompt drift, major drift → one question; weekly review audits user prompt drift (category 6) | `~/.config/opencode/AGENTS.md` + `scripts/weekly_review.sh` | Catches user-side scope creep / deferred decisions / missing bars before they cost cycles |
| Hard Rule #2 (Strict Rules with rationale, `as T` covered, generated-code exemption) + precedence chain; review-memory wired into Hard Rule #1; session lifecycle (30-day archive); global-config pointer; symbol-level-edit definition; estimate feedback loop; session-time commons check; read-once carve-out | `AGENTS.md` (audit-driven restructure, 2026-08-05) | Closes the audit's structural + rule-coverage gaps |
| Mechanical codegraph/graphify tripwire + filename-date session selection | `scripts/weekly_review.sh` (2026-08-05) | Replaces pure self-report with a computed check; kills mtime double-count |
| Analytics pipeline v2 (SQL → CSV weekly/monthly, charts on demand, idempotent collector, venv) | `scripts/ccusage_collect.sh`, `scripts/analytics_charts.py`, `~/analytics/` (2026-08-06) | Self-serve cost data, no blind trust in review agent |
| Report delivery abstraction (macos notification / webhook stubs) | `scripts/report_sink.sh` (2026-08-06) | Review results reach the user reliably |
| Feature-doc model (declared features `docs/features/<name>/README.md`, Objective convention for collector) | `docs/features/booking-calendar/README.md` + khelam `AGENTS.md` (2026-08-06) | Feature_parent attribution in analytics; PRD replaced |
| Background-agent execution model (trust dial L1/L2/L3, fresh session per batch, status file, checkpoint commits, scopeshift protocol, learnings log) | `docs/superpowers/specs/2026-08-05-background-agent-execution-model-design.md` (2026-08-06, experiment) | One-off v1 experiment; formalize after next task |
| `mechanical_check` ordering fix | `scripts/weekly_review.sh` `0bde76f` (2026-08-06) | Latent bug caught by batch-6 validation — functions must precede PROMPT expansion |
| Quarterly rule gut-check | `docs/reviews/review-memory.md` How-to-Update | Tracks whether the rule set stays net-positive |
| OA#1: commons `_FakeStrings` `registerLabel` override | commons `7e0f5a2` (2026-08-07) | Analyzer red in commons since v0.5.0 `1890d05`; `implements` requires all members incl. defaults |
| OA#4: booking-calendar README refresh | `docs/features/booking-calendar/README.md` (2026-08-07) | Out-list no longer claims API integration + auth guard are pending (both shipped 08-05); ADR table corrected to current architecture |
| OA#2 + OA#3 + archive-proofing: session-boundary check, origin self-check, archive-excluded session selection | `scripts/weekly_review.sh` (2026-08-07) | Long sessions (>1 day, >50M cache reads) now flagged mechanically; commons analyzed itself; archive layout can't leak into reviews |
| OA#5: forkable-first policy — base template; shared capabilities forkable-first (user-driven, manual); agent executes + weekly tripwire + user sign-off | forkable `1c87fc7` (AGENTS.md marker), strategy doc Ch. 4/6 (2026-08-07) | Resolves the "no trigger, no owner" contradiction; khelam-first leniency not extended to new work |
| OA#6: UI screenshot verification — canonical `capture_screens.sh` (forkable-first, repo-agnostic) + khelam screens.yaml + `docs/screenshots/` gitignored | forkable `scripts/capture_screens.sh` + khelam pulled copy (2026-08-07) | Human-review artifact for UI-affecting changes; E2E-verified on booted sim (1320×2868 PNG); tripwire green |

---

## Waste Register Summary (Full Week 07-31 → 08-05)

**Categories with UNCOVERED items** (not fully addressed by implemented measures):
- Tooling discipline: codegraph/graphify rule exists but **not followed** (0 uses in 08-05 session vs 20+ grep/read round trips) — now enforced via pre-edit Work Log rule (closed 08-05)
- Scope back-and-forth: samseer wired app-side → move to commons; auth slice grilling → scrap → execute — covered by scope-question rule + user prompting review
- Output waste: Graphify 15.5k token build, PDF manual venv, stale debug cycles — covered by >5k cost-note + verify-state rules
- Diagnosis waste: stale idToken, wrong port (5000 = AirPlay), tsx DI bug, wrong lead on API tests — covered by verify-state rule + pre-commit gate
- Process gaps: temp instrumentation left in commons, stray files, platform regen noise, dependency constraints — covered by Cleanup subsection + dep-check rule

Full register: `docs/reviews/2026-08-05-full-history-audit.md` (librarian audit, all sessions).

---

## Open Actions (Ranked)

> **Policy (2026-08-06, user decision — external audit gate):** you are the external reviewer. At each weekly review every Open Action gets a user-signed resolution — **fix / defer-with-date / drop**. No action survives two reviews unresolved. Protocol-change proposals must cite quantified waste; Day Plans require your estimate column.

1. ~~**commons `_FakeStrings` missing `registerLabel` getter** — `test/auth/login_screen_test.dart:6` fails analyze (interface gained the getter in v0.5.0 `1890d05`; fake never updated). Discovered 2026-08-06 during background-agent Batch 2 validation (pre-existing, unrelated to AGENTS.md deletion). Decision: log + defer to weekly review (user 2026-08-06). Fix: add `String get registerLabel => '...'` override. Severity: low (test-only, analyze red).~~ **CLOSED 2026-08-07** (`7e0f5a2`, commons main) — override added, analyze clean in commons + khelam + forkable, 8 tests green.
2. ~~**Session boundaries** — fresh session per batch per execution-model spec; flag weekly sessions older than 1 day with >50M cache reads (Review: 2026-08-06, add #2).~~ **CLOSED 2026-08-07** — `session_boundary_check()` in `weekly_review.sh` flags them mechanically into the review prompt (already caught `List all skills`: 140M cache, 129h span).
3. ~~**Origin-repo self-check** — extend session-time commons consumer check to run `flutter analyze` in commons itself (its own test fake was broken while only consumers were checked) (Review: 2026-08-06, add #3).~~ **CLOSED 2026-08-07** — commons analyzed first in the weekly consumer check.
4. ~~**Refresh feature README** — booking-calendar Out-of-scope list stale (API integration + auth guard shipped this week); update `docs/features/booking-calendar/README.md` (Review: 2026-08-06, add #4).~~ **CLOSED 2026-08-07** — Out-list, In-list, Implementation Plan, ADR table all refreshed.
5. ~~**forkable handoff trigger (pending decision, user)** — strategy Ch. 6: "future source of truth" needs a trigger + owner (what khelam milestone copies the setup to forkable, who validates). User: pick up first thing after the 2026-08-09 weekly review (2026-08-06).~~ **CLOSED 2026-08-07** — user decision: NO big-bang copy. forkable = base template; shared capabilities land forkable-first (samseer, screenshots, any reusable), pulled/cherry-picked into children; placement is user-driven and manual; agent executes, weekly forkable-sync tripwire + user sign-off validate. forkable AGENTS.md marker rewritten (`1c87fc7`); strategy doc Ch. 4/6 updated. IMPLICATION: OA#6 screenshot design decision #1 (khelam-primary → forkable mirror) needs amendment to forkable-first at #6 planning.
6. ~~**Screenshot-verification implementation** — design locked `docs/superpowers/specs/2026-08-06-ui-screenshot-verification-design.md` (6 user decisions). 3 batches: B1 [L2] `capture_screens.sh` + screens.yaml, B2 [L1] live iOS-sim validation, B3 [L2] sync to forkable. Est ~7k tokens. User: pick up **after #5** (2026-08-06).~~ **CLOSED 2026-08-07** — implemented forkable-first (amended decision #1 per OA#5): canonical `forkable/scripts/capture_screens.sh` (repo-agnostic: `REPO` from BASH_SOURCE, bundle id from pbxproj), pulled byte-identical into khelam; `docs/features/booking-calendar/screens.yaml` (per-app data, not mirrored); `.gitignore` `docs/screenshots/` both repos; `sync_to_forkable.sh` dropped (obsoleted by pull model + tripwire). E2E verified on booted sim: exit 0, PNG 1320×2868, 255 KB. `diff -rq scripts/` = identical (tripwire OK).
7. ~~**Task dashboard implementation** — design locked `docs/superpowers/specs/2026-08-06-task-dashboard-design.md` (v2: **standalone Flutter project** `~/projects/task-dashboard`, Supabase bidirectional queue, for ALL agentic tasks needing user review — cross-project). Decisions 1–10 locked incl. auth=email/password, service key `~/.config/khelam/sb.env`, seed=manual v1. 3 batches est ~28–34k. User: pick up after #6 (2026-08-06).~~ **DEFERRED 2026-08-07 (user, "park at backlog for a while")** — parked at `docs/backlog.md`; revisit at the **2026-08-16 review** (or sooner if Discord-comms ships first). Criterion: if the Discord channel covers the review surface, **DROP**; else re-estimate. Spec stays locked at `docs/superpowers/specs/2026-08-06-task-dashboard-design.md`.

---

## How to Update

After each weekly review (manual or automated):
1. Append a row to **Review History** table.
2. Update **Implemented Measures** if new rules/scripts added.
3. Move closed actions to **Implemented Measures**; add new **Open Actions** from the review's "Top 3 cuts" + any new patterns.
4. Keep under ~120 lines — prune old detail, keep decisions.
5. **Quarterly rule gut-check (every 4th review):** for each rule in AGENTS.md Cost Discipline + Hard Rule #2, ask "did this rule cost more than it saved this quarter?" Drop or merge rules not earning their keep; log the decision in the Review History row.
