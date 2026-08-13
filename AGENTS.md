# AGENTS.md — khelam (Flutter app)

Inherits the global software-engineer instructions at `~/.config/opencode/AGENTS.md`: **Flutter Specialization**, **Cost Discipline**, **Work Tracking template**, codegraph/graphify guidance, and the **sidetrack guard**. Project rules below tighten or extend the global rules — they never weaken them (see Precedence & Composition in the global file).

## Skills (automatic routing)

Skills load automatically by task — the global **Skill Routing** table in `~/.config/opencode/AGENTS.md` maps task types to skills (brainstorming before features, diagnose for bugs, flutter-* per task, grill-me for design stress-tests, loop-* for runs, etc.). **Full 46-skill inventory + complete table: `~/projects/agent-tools/docs/skills-inventory.md`.** Want a skill loaded for a task? Just name it — an explicit user mention beats the table.

## Hard Rule #1 — Daily Session File (khelam lifecycle)

**Always prepare a session file for the day. This is the number one rule; nothing overrides it.** The session template itself is global (Objective / Work Log / Decisions / Environment / Cleanup / Blockers / Next Steps).

- At the start of the first session of each working day, create `docs/sessions/YYYY-MM-DD.md`; read the current day's file at the start of every session — if missing, create it carrying forward relevant context.
- **Before starting any Cost-Discipline-flagged work, check `docs/reviews/review-memory.md` Open Actions table** — do not begin until outstanding actions are reviewed.
- Keep the file updated continuously after each task, decision, or commit. Every symbol-level edit must include its codegraph/graphify lookup reference in the Work Log (per global rule).
- **Lifecycle:** files in `docs/sessions/` older than 30 days may be archived to `docs/sessions/archive/YYYY-MM.md` (one file per month). The current day + previous 7 days remain unarchived. Archive at the start of a new day if needed.
- **Session Hygiene (khelam teeth — hardens the global Session Hygiene umbrella):** subagents (any type) are **forbidden from writing session files at all** — they report content back to the main agent, which owns the file (documented waste pattern: subagent file-writes created orphaned/duplicated session content). The main agent's own day file is append/patch-only — never rewrite it in place. Sessions past ~24h active or 50M cache reads: propose a fresh session BEFORE the weekly review's `session_boundary_check()` flags it (mechanical flag = safety net, not trigger).

## Project Conventions

- **Base-template tooling**: `scripts/` + the pre-commit gate are thin wrappers delegating to **agent-tools** (`~/projects/agent-tools`, the tooling canonical — see its AGENTS.md). Consumers pin agent-tools via `scripts/agent-tools.version` (commit sha); the weekly review's `agent_tools_version_check()` flags drift mechanically. Never edit agent-tools scripts khelam-first.
- **Sandbox/guard**: global `external_directory` allows `~/projects/sandbox/**` + 3 unrelocatables + narrow `/tmp`; everything else asks. This repo is a **temporary L3 test workspace** (see `docs/sandbox/test-window.md`, revoke 08-21). Full policy in forkable's AGENTS.md Sandbox section: never bypass the global deny-list, ask-shift work into `~/projects/sandbox/`, deny-deferral → `~/projects/sandbox/logs/deny-deferred-*.log` (weekly review surveys it).
- **Integration tests**: `integration_test/*_test.dart` run against the live backend (emulator-5554). Only run when the live path changed or the user asks — the session file records the last verified state.
- **Commons consumer check**: after any `commons` change (or a consumer pubspec change), run `flutter analyze` in both `khelam` and `forkable` before committing — don't wait for the weekly review.
- **Demo seam**: phone `9800000001` / password `khelam123`; default turf `44444444-4444-4444-4444-444444444441` (`ScheduleCubit._defaultTurfId`).
- **Pre-commit gate**: `.git/hooks/pre-commit` → `scripts/pre_commit_check.sh` (analyze + full test suite; docs-only commits skip). Never bypass it.
- **Weekly review**: launchd `com.khelam.weekly-review` (Sunday 18:00) → `scripts/weekly_review.sh` — produces `docs/reviews/YYYY-MM-DD.md` + aggregates token data to `~/analytics/` (CSVs, performance summary, update log). Manual: `bash scripts/weekly_review.sh`.
- **Analytics**: token/cost data is collected post-hoc from `opencode.db` into `~/analytics/` by the weekly pipeline — sessions don't record usage, they only log cost-notes for >5k-token operations (estimate + actual, per global rule).
- **Update-log**: any change to agent rules or tooling scripts is logged at the moment of change in `~/analytics/update-log.md` (or the session Work Log, flagged for the weekly review to verify).
- **Session Objective convention**: when working on a declared feature, the session Objective line MUST be `Feature: docs/features/<name>/README.md — <task>` (machine-parseable by the analytics collector for the `feature_parent` column); otherwise plain `<task>`.
- **Grill Gate (inherited from global AGENTS.md)**: major drift — breaking changes, major diversion from a locked plan/spec, mid-task "also do X" scope changes — escalates to a full @architect brainstorm + grill-me session before any conclusion; minor drift stays a one-line `[nudge]`. See `### Major drift escalation — Architect Grill Gate` in `~/.config/opencode/AGENTS.md`.

## RTK (dry-run)

[rtk](https://github.com/rtk-ai/rtk) (v0.42.4) is a CLI proxy that compresses shell command output for AI agents, reducing token usage by 60-90%. It runs **alongside** existing tooling — does NOT replace scripts/, agent-tools, or the pre-commit gate.

**Setup**: OpenCode plugin installed at `~/.config/opencode/plugins/rtk.ts` (global). The plugin transparently rewrites bash commands via `rtk rewrite` — no workflow change needed.

**Usage**:
- Explicit: `rtk git status`, `rtk proxy flutter analyze`, `rtk proxy flutter test`
- Transparent: OpenCode plugin auto-rewrites commands — just use normal commands
- Check savings: `rtk gain --all`

**Data collection**: `bash scripts/rtk_metrics.sh` saves daily JSON to `docs/rtk-data/YYYY-MM-DD.json`. Idempotent (overwrites same-day). C17 will analyze accumulated data to compare with baseline analytics.

**Dry-run status**: Active as of 2026-08-13. Underlying tools still execute — rtk only filters their output. No hooks replace existing infrastructure. See `docs/rtk-data/README.md` for full details.

## Loop Mode (loop-engineering scaffold, spec 2026-08-11)

The daily-triage loop (scaffold: STATE.md, LOOP.md, loop-budget.md, loop-constraints.md, skills/loop-triage/) runs report-only by default:

- **L1 default**: reads STATE.md + skills/loop-triage/SKILL.md before any triage; updates STATE.md after every run; **no source edits** until the human explicitly enables L2.
- **State files are derived**: LOOP-STATE.json is regenerated by scripts/sync_loop_state.sh (post-digest, post-weekly-review) — never hand-edit it; tasklog.md / review-memory.md / session files remain the source of truth.
- **Kill switch**: `loop-pause-all` in STATE.md or tasklog pauses scheduled loops until cleared by the human.
- **Budget**: if token spend hits 80% of the daily cap, switch to report-only.
- **Two-gate model** (loop spec locked decision #3): inner-loop verifier (`scripts/loop_verify.sh`, layered in the pre-commit gate AFTER analyze + tests — arch violations block, state drift warns) = Maker's mechanical gate; the outer-loop weekly review = Checker's human audit. The review prompt carries the optional Loop-Ready score (`loop status --json` via `loop_health_check()` in weekly_review.sh).