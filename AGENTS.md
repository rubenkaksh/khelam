## Hard Rule #1 — Daily Session File

**Always prepare a session file for the day. This is the number one rule; nothing overrides it.**

- At the start of the first session of each working day, create `docs/sessions/YYYY-MM-DD.md` (date in `YYYY-MM-DD`, e.g. `docs/sessions/2026-07-31.md`).
- Read the current day's file at the start of every session. If the day's file doesn't exist yet, create it — carrying forward relevant context from the previous day's file.
- Keep the file updated continuously during the day, after each task, decision, or commit — not just at the end. It is the living handoff for any later session.
- Use the template below.

Template:

```markdown
# Session — YYYY-MM-DD

## Objective
(What are we trying to accomplish today?)

## Work Log
(Chronological: tasks done, files touched, commits with hashes)

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

## Cost Discipline (budget rules — audited weekly)

The weekly review (`docs/reviews/`) audits these. Violations are budget burns.

- **Scope question first.** When a task is ambiguous in scope, repo, or depth (e.g. "add X" — dependency only or wired? khelam only or also forkable/commons? unit tests or live verification?), ask ONE question via the question tool with a recommended default before writing code. A 30-second question is cheaper than a full duplicate cycle.
- **codegraph/graphify BEFORE grep/read** for any symbol or codebase question (see sections below). Grepping for something already indexed is a budget burn. **Every symbol-level edit must log its `codegraph explore`/`graphify query` lookup in the Work Log** — no lookup logged = rule violated.
- **Verify current state before debugging.** Confirm the symptom exists on current HEAD + current config (one `flutter test` or curl) before investigating; stale idToken/port/DI-bug debug cycles are the classic waste. Use known-good commands (`npm run start:dev`, not `tsx`).
- **Check dependency constraints before `flutter pub add`**: compare the package's `environment.sdk` against the project's `dart --version` (e.g. Dart 3.8 caps samseer at 0.1.0); note the result in the session file.
- **Cost-note large operations**: anything estimated >5k tokens (graph rebuilds, doc dumps, PDFs, big audits) gets a one-line estimated-cost note in the session file BEFORE starting.
- **Targeted tests during development**: after an edit, run only the affected test files (`flutter test test/features/auth/...`). Full suite + `flutter analyze` once, right before the commit.
- **Live/integration tests only when the live path changed or the user asks.** Never re-verify something already green — the session file records the last verified state; trust it.
- **No commits with known failures; no deferred diagnosis.** Read the failing assertion and fix or revert in-session.
- **Check the Blockers section before E2E/live runs** — known-broken endpoints fail predictably; fix (or trim the test) first.
- **Shared test fakes, not per-file copies**: e.g. the token-store fake lives in `test/helpers/recording_token_store.dart`. A widget test must never hit a real platform channel (those futures never complete in tests).
- **Read files once per session**; reuse earlier reads instead of re-reading the same file.

## Strict Rules

- **Never use the null force operator `!`.** Use null-aware patterns instead (`if case final x? = y` or `?.` / `??` operators). This applies everywhere: null assertions, force casts, force unwraps. Prefer pattern matching with `if case` for conditional unwrapping.

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
