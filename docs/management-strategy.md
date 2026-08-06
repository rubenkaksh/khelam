# Khelam Management Strategy — How Context Survives Across Sessions

> **What this is**: a user-readable summary of how khelam's agent system keeps context alive across sessions, how work is planned and executed, and the project-management plan going forward. Written 2026-08-06.

---

## 1. TL;DR

Khelam runs on a **layered memory system**: durable rules live in `AGENTS.md` files, daily life lives in session files, decisions live in specs and review docs, and everything is measured by a weekly analytics review. Work executes under a **contract-based protocol** (morning plan → trust-dialed batches → evening review) whose learnings feed the *next* protocol. When you switch contexts mid-stream, the session file's `Environment` + `Next Steps` sections are the anchor that lets any fresh session pick up exactly where things stopped — nothing is re-derived, everything is carried forward.

---

## 2. The story so far

| When | What happened | Artifact |
|---|---|---|
| 2026-06-22 | First architecture review → theme monolith watchpoint | review |
| 2026-07-31 | Analytics idea: measure agent cost per session | session file |
| 2026-08-01 | Commons migration (Dio, theme, auth slices v0.2–v0.6) + full-history audit | `docs/reviews/2026-08-05-full-history-audit.md` |
| 2026-08-05 | **AGENTS.md hierarchy rewrite**: global rules live in `~/.config/opencode/AGENTS.md`; khelam/commons/forkable/backend each get slim project files. Two design specs locked: background-agent execution model + scope-sandbox/retry policy. Weekly review automation + launchd. | `AGENTS.md`, 2 specs |
| 2026-08-06 (AM) | **v1 experiment**: day-plan contract, 7 trust-dialed batches (sibling AGENTS.md, analytics pipeline, review v2, feature docs, validation, closeout) | `docs/plans/2026-08-06-day-plan.md` |
| 2026-08-06 (PM) | Evening review: 7/7 acceptance bars, calibration 27.5k est → 22.7k actual, 9 learnings for next protocol. macOS build fix. UI-screenshot-verification design (architect). | session + review docs |

---

## 3. The memory layers (how context is kept)

| Layer | Location | What it holds | Written by |
|---|---|---|---|
| **0. Global rules** | `~/.config/opencode/AGENTS.md` | Hard rules (`!`/`as T` ban), cost discipline, sidetrack guard, session template | me (audited weekly) |
| **1. Project rules** | `AGENTS.md` (khelam + siblings) | HR#1 session-file mandate, conventions, demo seam, pre-commit gate | me |
| **2. Daily session file** | `docs/sessions/YYYY-MM-DD.md` | Objective / Work Log / Decisions / Environment / Cleanup / Blockers / Next Steps — **the living handoff** | me, continuously |
| **3. Status + plan contract** | `docs/sessions/*-status.md`, `docs/plans/*-day-plan.md` | `current_batch=N`, per-batch progress, scope manifests, dependency graph | me, per batch |
| **4. Review memory** | `docs/reviews/review-memory.md` | Implemented measures, Review History, **ranked Open Actions** (checked before cost-flagged work) | me + weekly review |
| **5. Update log** | `~/analytics/update-log.md` | Ledger of every rule/tooling change (dual-author: session logs, weekly verifies) | me + weekly review |
| **5b. Context map** | `.codegraph/` (per repo), `graphify-out/` (per repo + cross-repo merge graphs) | Symbol index + semantic graph of the codebase — see §3b | codegraph + graphify (auto-rebuilt on commit) |
| **6. Analytics** | `~/analytics/` | weekly CSV (23 sessions → cost/tokens), performance-summary, charts | weekly review (Sun 18:00) |
| **7. Decisions & specs** | `docs/superpowers/specs/`, `docs/backlog.md` | Locked design decisions, unscheduled work | me + architect |
| **7b. Feature READMEs** | `docs/features/<name>/README.md` | **Per-feature memory**: Problem/Solution/Scope, user stories, ADR decision table, domain models, implementation checklist, Test Plan, progress, backlinks | me (per feature, when chunks ship) |

**The README roles, explicitly:**
- **Feature READMEs are the feature-boundary handoff** — before work enters a feature directory, the session consults that feature's README (per global AGENTS.md "feature-boundary handoff" rule). They answer "what is this feature, what did we decide, what's done" without re-deriving from chat or session history.
- **They are the screenshot-verification trigger anchor**: a feature-doc chunk added + UI-visible = screenshot for that screen (per the 08-06 design spec — `docs/features/<feature>/screens.yaml` sits next to the README).
- **They feed analytics**: session Objective convention `Feature: docs/features/<name>/README.md — <task>` is machine-parseable → the weekly CSV's `feature_parent` column attributes cost to the feature. (First week: no session used it yet — convention added 08-06.)
- **Root `README.md`** is the template identity (khelam = reusable starter template; points to legacy `memory.md`/`phase-1-checklist.md`) — informational, not part of the memory loop; feature work lives in feature READMEs.

**Key invariants**: rules never live in two places (global vs project split); every symbol-level edit logs its lookup; a change without an update-log entry = violation; Open Actions are ranked so the highest-value fix gets picked first.

## 3b. The context map — codegraph + graphify

The **navigation layer** that lets the agent find code instead of brute-force grepping. Two tools, one routing rule:

| Tool | What it indexes | Questions it answers | When to use |
|---|---|---|---|
| **codegraph** (`explore`/`node`/`sync`) | Symbols per repo (functions, classes, callers) | "Where is `X` defined?" "Who calls `Y`?" | Symbol-level questions before editing |
| **graphify** (`query`/`path`/`explain`) | Semantic knowledge graph — cross-file, **cross-repo merge graphs** (khelam graph includes commons) | "How does A relate to B?" "Explain this concept" | Architecture/semantic questions |

- **Routing rule** (global AGENTS.md): symbol → codegraph, architecture → graphify. Use them BEFORE grep/read.
- **Pre-edit rule**: every symbol-level edit logs its codegraph/graphify lookup reference in the session Work Log — the weekly review's `mechanical_check()` tripwire counts these lines (an edit without a lookup line = flagged).
- **Auto-maintained**: graphify hooks rebuild the graph on commits (watch + merge-driver); codegraph syncs on demand. `graphify-out/` is denylisted from commits in khelam/commons.
- **Honest gap**: this week's work sessions logged **zero** active lookups (the tripwire passed only on 08-01's setup session). Learnings row 3 (urgency 3) proposes: count work-session lookups only, and require per-symbol lookup lines. The system is designed to *measure* its own discipline and feed the fix into the next protocol.

---

## 4. The protocol — how work gets done

Three phases, one contract:

1. **Morning planning** — I verify environment, write a Day Plan contract (batches, trust levels, scope manifests, estimates, dependency graph), you approve it. The contract is the ONLY document execution reads.
2. **Batch execution** — each batch runs under a **trust dial**: `L1` halts for your approval, `L2` auto-proceeds (halts on deviations >20% estimate / destructive ops / bar not met), `L3` autonomous with deferred audit. Every batch logs a greppable `[CHECKPOINT]` line and checkpoint commit.
3. **Evening review** — per-batch acceptance-bar audit, calibration table (est vs actual), drift/blocker audit, and a **Learnings for the next protocol** table.

**Failure handling**: retry policy (1-min wait × 4 = 5 attempts, 2-strike identical-error rule), sandbox scope manifests (deny beats allow, force-push banned), `[FAIL]` log lines.

**The learning loop**: the evening review's 9-row learnings table (urgency-ranked) is the **input for the next task's protocol** — at the next morning planning, each row gets adopted / amended / rejected into protocol v2, and that task's evening review verifies the adoptions worked. The table is a feedback instrument, not a report.

---

## 5. Context follow-through (your branching sessions)

When you switch between topics mid-day, this is what keeps everything consistent:

1. **Session start**: I read today's session file; if missing, create it carrying forward `Next Steps` + `Environment` from the previous day.
2. **Environment section**: running services (backend :8000, launchd, emulator, simulator) are recorded — the next session never kills or duplicates them.
3. **Read-once discipline**: files are read once per session; earlier reads are reused. Session files reference codegraph/graphify lookups so navigation isn't repeated.
4. **Status file is machine-readable**: scripts read `current_batch=N`; you can `cat` it anytime for a one-glance state.
5. **Branching is safe**: each topic becomes a Work Log section in the same day's file (e.g. "macOS build fix", "screenshot verification design" after the experiment closeout). Fresh sessions pick up from the file, not from chat memory.
6. **Weekly review is the safety net**: any rule drift, waste, or missed Open Action gets caught Sunday 18:00 and lands in review-memory.

---

## 6. Project management plan (going forward)

- **Work intake**: new ideas → `docs/backlog.md` with source link + open questions → when picked up, becomes a feature README or a spec → then a day-plan contract.
- **Cadence**: daily session file (mandatory, HR#1); weekly review (automated Sun 18:00 → review doc + analytics + update-log); quarterly rule gut-check ("did this rule cost more than it saved?").
- **Memory hygiene**: session files archived after 30 days (monthly file); review-memory kept ≤120 lines; update-log dual-author; screenshots land in gitignored `docs/screenshots/`.
- **One-off experiment rule**: v1 execution protocol is an experiment — the formalized protocol is built from its learnings at the **next** task's planning.
- **Current queue**: 4 Open Actions (registerLabel fix, session boundaries, commons self-analyze, README refresh) + screenshot-verification design (3 batches) + 9 learnings awaiting next-task adoption.

---

## 7. Where things live (quick map)

```
~/.config/opencode/AGENTS.md        → global rules (never edit casually)
AGENTS.md (4 repos)                 → project rules
README.md                           → template identity (informational)
docs/sessions/YYYY-MM-DD.md         → daily living memory
docs/sessions/*-status.md           → machine-readable progress
docs/plans/                         → day-plan contracts
docs/reviews/review-memory.md       → Open Actions + measures (read first)
docs/reviews/YYYY-MM-DD.md          → weekly review reports
docs/superpowers/specs/             → locked designs (execution model, sandbox, screenshot)
.codegraph/ + graphify-out/          → context map: symbol index + semantic graph (auto-rebuilt; gitignored)
docs/features/*/README.md           → declared features (booking-calendar): per-feature memory + screens.yaml registry
docs/backlog.md                     → unscheduled work
~/analytics/                        → measured truth (CSV, summary, charts, update-log)
```
