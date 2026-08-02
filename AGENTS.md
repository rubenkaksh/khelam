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

## Blockers
(Anything stuck or waiting on)

## Next Steps
(What comes next — for this session or the next)
```

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
