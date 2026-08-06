# The Khelam Memory System — A Story-Driven Guide

> Written 2026-08-06, revised after an adversarial architecture review. This is the story of how context survives in this project — what we built, what broke, and the decision that changed how it's governed.

---

## Chapter 1 — Why this document exists

You switch contexts a lot. One hour we're planning a background-agent experiment, the next we're fixing a macOS build, then designing screenshot tooling. Each switch risks losing the thread — unless the project itself remembers.

This project is built around one belief: **the agent should never re-derive what it already knows**. Everything is designed to carry forward — but carrying forward only works if the system is *honest* about what's actually running versus what was only designed. This document tells you which is which.

## Chapter 2 — Where we started

In June 2026, the project had a problem: sessions were expensive, mistakes repeated, and nothing remembered. The first architecture review (06-22) flagged a theme monolith. The 07-31 session planted the seed of an idea: **measure the agent's own cost**. By 08-01, a full history audit (librarian) had catalogued 8 waste instances — rebuilt DTOs, double-invoked agents, known-broken test endpoints run anyway.

The answer took shape in two moves:

1. **08-05 — the hierarchy**: global rules moved to `~/.config/opencode/AGENTS.md` (hard rules, cost discipline, session template); each repo got a slim project file. Two design specs were locked: the background-agent execution model and the scope-sandbox/retry policy.
2. **08-06 — the experiment**: a day-plan contract drove 7 batches (sibling AGENTS.md, analytics pipeline, review v2, feature docs, validation, closeout). It worked — 7/7 acceptance bars, −17% under budget — and its evening review produced 9 learnings for the next protocol.

Then the architect grilled the strategy. It found the truth beneath the tidy story.

## Chapter 3 — The design: eight layers of memory

When everything works, context flows through eight layers. Think of them as a filing cabinet with a rule for every drawer:

| Layer | Where it lives | What it holds |
|---|---|---|
| 0. Global rules | `~/.config/opencode/AGENTS.md` | Hard rules, cost discipline, sidetrack guard |
| 1. Project rules | `AGENTS.md` (4 repos) | Session mandate, conventions, pre-commit gate |
| 2. Daily session file | `docs/sessions/YYYY-MM-DD.md` | The living handoff: Work Log, Decisions, Environment, Next Steps |
| 3. Status + plan | `docs/sessions/*-status.md`, `docs/plans/` | `current_batch=N`, per-batch progress, scope manifests |
| 4. Review memory | `docs/reviews/review-memory.md` | Implemented measures, Open Actions (ranked) |
| 5. Update log | `~/analytics/update-log.md` | Every rule/tooling change, dual-authored |
| 5b. Context map | `.codegraph/`, `graphify-out/` | Symbol index + semantic graph (codegraph = "where is X", graphify = "how do A and B relate") |
| 6. Analytics | `~/analytics/` | Weekly CSV, performance summary, charts |
| 7. Decisions & features | `docs/superpowers/specs/`, `docs/features/*/README.md`, `docs/backlog.md` | Locked designs, per-feature memory, unscheduled work |

Two ideas hold the cabinet together:

- **The session file is the anchor.** Every session starts by reading it; the `Environment` section records running services so nothing gets killed; `Next Steps` is the handoff. When you branch topics, each becomes a Work Log section in the same day's file — fresh sessions pick up from the file, not from chat memory.
- **The context map is the compass.** Codegraph answers symbol questions ("who calls X?"), graphify answers architecture questions ("how does the auth slice relate to booking?"). Every symbol-level edit is supposed to log its lookup line — the weekly review's tripwire counts them.

And work happens under a protocol: **morning planning** writes a day-plan contract → **batches** run under a trust dial (L1 halts for you, L2 auto-proceeds, L3 autonomous) → **evening review** audits acceptance bars, calibrates estimates, and writes a learnings table that feeds the next protocol.

That's the design. Here's the truth.

## Chapter 4 — The hard truth: what's real and what isn't

The architect's grilling (08-06) compared every claim against the actual files. The verdict: **the system is selectively honest** — it admits some gaps while selling others as live. Here is the status of every mechanism, no softening:

| Mechanism | Status | Evidence |
|---|---|---|
| Lookup-logging on symbol edits | ⚠️ **BROKEN** | Zero lookups in all feature sessions; tripwire passed only on a tooling-setup session |
| Fresh session per batch | ⚠️ **BROKEN in v1** | One 5-day session ran the whole experiment (126M cache reads) |
| Sandbox mechanical guard | ❌ **NOT SHIPPED** | `scope_guard.sh`, `sandbox_audit.sh` don't exist; update-log: "NOT installed" |
| Open Actions get closed | ❌ **ACCUMULATING** | registerLabel (1-line fix) survived two deferral cycles |
| `feature_parent` cost attribution | 🚧 **VAPOR** | `"-"` in all 23 CSV rows — no session used the Objective convention |
| 30-day session archive | 🚧 **NOT IMPLEMENTED** | `docs/sessions/archive/` doesn't exist |
| Learnings → next protocol | 🚧 **INFORMAL** | 9 learnings sit in a session file; no parser, no gate, nothing carries them forward |
| Analytics "measured truth" | 🚧 **WEEK 1** | One week of data; trend columns all `—` |

The grilling also caught a **latent bug**: the weekly review selects sessions with `find -maxdepth 1`, so if archiving ever activates, the review silently loses old sessions.

And one contradiction in the architecture itself: forkable is called "the future source of truth," but everything mirrors khelam → forkable, with no trigger, no owner, no date for the handoff.

## Chapter 5 — The decision: you are the external gate

The grilling's core finding was simple: **the agent was the sole author, grader, and auditor of its own protocol** — acceptance bars self-set, calibration self-reported, weekly review being a script that runs a prompt (agent auditing agent). That had to end.

**Decision (user, 2026-08-06): the external gate is you, and you are in charge of review.**

Three mechanisms make it real:

1. **You close every Open Action.** At each weekly review, every open action gets a signed resolution from you: **fix / defer-with-date / drop**. No action survives two reviews without one. "Defer to review" is no longer a loop — it's a ticket with an owner and a date.
2. **Protocol changes must prove their worth.** Any proposal the weekly review emits must cite the *specific quantified waste* it prevents (e.g. "registerLabel: analyze red all week, 1-line fix"). Abstract "process improvement" proposals are rejected.
3. **Your estimate column is a hard gate.** Day plans are not approved until you fill the user-estimate column. Calibration is a two-player game, not agent self-report.

Everything else is downstream of this: the sandbox guards, the archive fix, the learnings parser — they're all buildable, but none of them matter if the system can't be trusted to audit itself. Now it can't — because you do.

## Chapter 6 — The plan from here

| What | When | Who |
|---|---|---|
| Open Actions #1–#4: your signed resolutions | Next weekly review (Sun 18:00) | You |
| Screenshot-verification design → 3-batch implementation | When scheduled | Agent (your approval gates) |
| Learnings ingestion gate (Day Plan template requires adopt/amend/reject of prior learnings) | Next task's morning planning | Agent + you |
| Sandbox guards installed OR §4 relabeled "deferred" | Next batch touching scripts | Agent |
| Archive bug fixed (selector descends into `archive/`) | Next tooling pass | Agent |
| forkable handoff trigger + owner stated | Before forkable becomes source of truth | You |
| Story-driven docs (this document + session files) | Ongoing | Agent |

## Appendix — File map

```
~/.config/opencode/AGENTS.md        → global rules (never edit casually)
AGENTS.md (4 repos)                 → project rules
README.md                           → template identity (informational)
docs/sessions/YYYY-MM-DD.md         → daily living memory (the anchor)
docs/sessions/*-status.md           → machine-readable progress
docs/plans/                         → day-plan contracts (need your estimate column)
docs/reviews/review-memory.md       → Open Actions + measures (you close actions here)
docs/reviews/YYYY-MM-DD.md          → weekly review reports
docs/superpowers/specs/             → locked designs (execution model, sandbox, screenshot)
.codegraph/ + graphify-out/         → context map (auto-rebuilt, gitignored)
docs/features/*/README.md           → per-feature memory + screens.yaml registry
docs/backlog.md                     → unscheduled work
~/analytics/                        → measured truth (week 1; trends accumulate)
```

**One line to remember:** the agent carries the memory; you carry the review.
