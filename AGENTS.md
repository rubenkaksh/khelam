## Hard Rule #1 — Daily Session File

**Always prepare a session file for the day. This is the number one rule; nothing overrides it.**

- At the start of the first session of each working day, create `docs/sessions/YYYY-MM-DD.md` (date in `YYYY-MM-DD`, e.g. `docs/sessions/2026-07-31.md`).
- Read the current day's file at the start of every session. If the day's file doesn't exist yet, create it — carrying forward relevant context from the previous day's file.
- **Before starting any Cost-Discipline-flagged work, check `docs/reviews/review-memory.md` Open Actions table** — do not begin until outstanding actions are reviewed.
- Keep the file updated continuously during the day, after each task, decision, or commit — not just at the end. It is the living handoff for any later session.
- Use the template below.

Template:

```markdown
# Session — YYYY-MM-DD

## Objective
(What are we trying to accomplish today?)

## Work Log
(Chronological: tasks done, files touched, commits with hashes. **Every symbol-level edit must include its codegraph/graphify lookup reference.**)

## Decisions
(Design/architecture decisions made, with rationale)

## Environment
(Running services: what is up, on which port, how it was started, log location — so the next session never kills or duplicates it. e.g. "backend on :8000, nohup npm run start:dev, log /tmp/rms-backend.log")

## Cleanup
(Remove before commit: temp logs, debug instrumentation, stray .code-workspace files, platform regen noise. Verify with `git status`.)

## Blockers
(Anything stuck or waiting on)

## Next Steps
(What comes next — for this session or the next)
```

**Session lifecycle:** Files in `docs/sessions/` older than 30 days may be archived to `docs/sessions/archive/YYYY-MM.md` (one file per month). The current day's file and the previous 7 days must remain unarchived. Archive at the start of a new day if needed.

## Hard Rule #2 — Strict Rules

**Strict Rules carry equal weight to Hard Rule #1. Violations are not optional.**

- **Never use the null force operator `!` (null assertions / force unwraps) or force casts (`as T`) in hand-written code.** Rationale: null handling must stay customizable — a `!` hard-codes the non-null assumption, turns a null into a runtime crash, and blocks flexible UI (a widget should be able to choose NOT to render when data is missing). Allowed instead:
  - `?.` and `??` where a fallback makes sense (`??` is fine where feasible)
  - `if case final x? = y` pattern matching for conditional unwrapping
  - `if (x is T)` type promotion instead of `as T` casts
  - `is!` negation patterns (not a force operator)
  - In widgets: conditionally render (`if (x != null) Widget(...)`) instead of forcing or defaulting
  - Generated code (`*.freezed.dart`, `*.g.dart`, build outputs) is exempt.
  - Scope: Dart code in this repo. The backend repo has its own rules.
- **Precedence on conflict:** Hard Rule #1 → Hard Rule #2 → Cost Discipline → tooling rules (codegraph/graphify) → global config. Higher rules override lower ones.

## Cost Discipline & Engineering Hygiene (budget rules — audited weekly)

The weekly review (`docs/reviews/`) audits these. Violations are budget burns.

- **Scope question first.** When a task is ambiguous in scope, repo, or depth (e.g. "add X" — dependency only or wired? khelam only or also forkable/commons? unit tests or live verification?), ask ONE question via the question tool with a recommended default before writing code. A 30-second question is cheaper than a full duplicate cycle.
- **codegraph/graphify BEFORE grep/read** for any symbol or codebase question (see sections below). Grepping for something already indexed is a budget burn. **Every symbol-level edit (any edit that adds, modifies, or deletes a function, class, method, or top-level declaration) must log its `codegraph explore`/`graphify query` lookup in the Work Log** — no lookup logged = rule violated. (Doc/comment-only edits are not symbol-level.)
- **Verify current state before debugging.** Confirm the symptom exists on current HEAD + current config (one `flutter test` or curl) before investigating; stale idToken/port/DI-bug debug cycles are the classic waste. Use known-good commands (`npm run start:dev`, not `tsx`).
- **Check dependency constraints before `flutter pub add`**: compare the package's `environment.sdk` against the project's `dart --version` (e.g. Dart 3.8 caps samseer at 0.1.0); note the result in the session file.
- **Cost-note large operations**: anything estimated >5k tokens (graph rebuilds, doc dumps, PDFs, big audits) gets a one-line estimated-cost note in the session file BEFORE starting; after completion, log the actual result in the same line so estimates calibrate.
- **Targeted tests during development**: after an edit, run only the affected test files (`flutter test test/features/auth/...`). Full suite + `flutter analyze` once, right before the commit.
- **Live/integration tests only when the live path changed or the user asks.** Never re-verify something already green — the session file records the last verified state; trust it.
- **No commits with known failures; no deferred diagnosis.** Read the failing assertion and fix or revert in-session.
- **Check the Blockers section before E2E/live runs** — known-broken endpoints fail predictably; fix (or trim the test) first.
- **Shared test fakes, not per-file copies**: e.g. the token-store fake lives in `test/helpers/recording_token_store.dart`. A widget test must never hit a real platform channel (those futures never complete in tests).
- **Read files once per session**; reuse earlier reads instead of re-reading the same file (post-edit re-reads to confirm a change landed are fine — that's verification, not waste).
- **Commons consumer check at session time**: if you modify `commons` (or a consumer's pubspec), run `flutter analyze` in both `khelam` and `forkable` before committing — don't wait for the weekly script.

## codegraph

This project has a codegraph index at `.codegraph/` for symbol-precise, zero-cost code navigation. Used together with graphify: codegraph for symbol lookups, graphify for semantic questions.

Rules:
- For **symbol-level questions before edits** ("who calls X", "show me the implementation of Y", "blast radius for refactor Z"), run `codegraph explore "X"` or `codegraph node <file>` FIRST — output is verbatim source + callers/callees, treat it as a Read you've already done. Zero LLM cost.
- `codegraph sync` keeps the index fresh incrementally; `codegraph status` confirms freshness.
- codegraph has NO semantic understanding of docs/ADRs/sessions and no community structure — never use it for architectural or "why/how" questions (that is graphify's job).
- Per-repo only: khelam, commons, forkable each have their own `.codegraph/`; there is no cross-repo query (cross-repo needs graphify `merge-graphs`).

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

## Global Configuration

This project inherits the global opencode config at `~/.config/opencode/AGENTS.md`, which defines the **User Prompt Discipline (sidetrack guard)** — a passive `[nudge]` system for known user drift patterns, active in every session. The sidetrack guard is a passive overlay: it never weakens or replaces this project's rules. On conflict, this project's rules win (see Precedence under Hard Rule #2).
