<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tools** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them. `codegraph_node` returns one symbol's source + callers, or reads a whole file with line numbers. If the tools are listed but deferred, load them by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` and `codegraph node <symbol-or-file>` print the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

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
