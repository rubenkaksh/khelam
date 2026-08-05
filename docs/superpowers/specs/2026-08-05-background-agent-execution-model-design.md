# Design — Background Agent Execution Model (v0, one-off experiment)

> Date: 2026-08-05. Status: APPROVED by user (Sections A + B acked). Next action: morning planning session 2026-08-06 produces the Day Plan contract from this design + `docs/handoff-v1-execution.md`.

## 1. Purpose

Design how background agents execute tasks under a user review → permission → execution loop. Tomorrow's v1 execution (Steps A–G of `docs/handoff-v1-execution.md`) is a **ONE-OFF experiment**: the goal is to *solidify agent knowledge* — observe how the background agent behaves, where it drifts, how the review loop feels — BEFORE formalizing a standing protocol. The task AFTER tomorrow gets the first formalized protocol, built from observed evidence. No standing protocol document is written today.

## 2. Locked decisions (brainstorm 2026-08-05)

1. **One-off experiment.** Tomorrow's run is the test. The task AFTER tomorrow gets the first formalized protocol, built from observed evidence.
2. **Per-batch granularity, daily shape:** MORNING planning session (user + planner co-review/refine the day's task breakdown, user approves before any autonomous execution) → DAY execution (background agent) → EVENING results review (per-batch results vs acceptance bars, deviations, I/O numbers so the user can parallel-measure the agent against their own instincts, control flow, and gradually hand over control as trust builds).
3. **Trust dial, assigned per task in the morning plan:**
   - **L1** = agent halts at every batch boundary, waits for explicit user approval before continuing
   - **L2** = auto-proceeds within the approved plan, halts only on deviations
   - **L3** = fully autonomous, escalate only on blockers
   - **Prioritization:** L1 tasks execute FIRST while the user is present; then L2/L3 continue autonomously; user checks in at intervals.
4. **Knowledge capture:** LIVE LEARNINGS LOG in the session file — at each checkpoint the agent logs observations (what worked, drift, review-loop friction, gut-checks vs actuals). Evening review ends with a "Learnings for the next protocol" section. No separate retrospective doc.
5. **Session architecture: THREE-PHASE PIPELINE** (architect-reviewed, Section A acked):
   - Phase 1: Morning planning session → committed Day Plan doc (THE contract)
   - Phase 2: Day execution — **a FRESH opencode session per batch** (architect modification), not one long session
   - Phase 3: Evening review session

## 3. Section A — Three-phase pipeline

### Phase 1 — Morning planning session (user + planner)

**Planner prep (before user joins, read-only):**
- `git status`/branch in all 4 repos (khelam, commons, forkable, backend) — capture dirty state
- Verify backend alive (port 8000, PID, log path), launchd `com.khelam.weekly-review` loaded
- Confirm opencode.db schema unchanged
- Read `docs/reviews/review-memory.md` Open Actions (mandatory before cost-discipline work)
- Read prior session file (carry-forward context)
- Pre-draft the full Day Plan (batches, trust levels, estimates, acceptance bars, dependencies)

**Joint agenda:**
1. Confirm context is current (repos/branches/dirty trees as captured)
2. Walk each batch: first wrong move possible? destructive op? where's the L1 halt needed?
3. Assign trust dial + prioritization (L1-first)
4. **Estimate calibration setup:** user fills `user_estimate` per batch, agent fills `agent_estimate` — the parallel-measure hook
5. User signs the contract (approval checkbox)
6. Escalation protocol agreed: **15-minute idle wait** on L1 halts (user override; architect proposed 2h), then proceed to independent batches

**Output:** `docs/plans/2026-08-06-day-plan.md` — committed, THE contract.

**Empirical validation before user leaves:** morning session spawns a throwaway test session that reads ONLY the Day Plan and recites Batch 1's first command + repo + branch. If it can't, the doc is incomplete — fix and re-test.

### Phase 2 — Day execution (background agent)

- **Fresh session per batch**, marked by explicit `SESSION BOUNDARY` lines in the Day Plan. Rationale: Steps A–G span 4 repos + script authoring + validation; one session accumulates the day's context and drifts by Step G (evidence: 6-round-trip samseer diagnosis from context pressure, 2026-08-05). Each batch session carries forward only: the Day Plan + session file + status file.
- **Status file:** `docs/sessions/2026-08-06-status.md` — one line per batch: `batch=N step=<tag> status=<done|partial|blocked|elevated> tokens_est=(agent,user) next=<step> trust=<L1|L2|L3>`. Survives session restarts; user can `cat` it at intervals without opening opencode.
- **Checkpoint commits:** each batch ends with a labeled commit `day-plan/v1-step-X-batch-N: <summary>` so any batch is rollbackable via `git reset --hard <label>` — no force-push ever.
- **Notifications:** macos notification (unique sound) + `## ⏸️ WAITING FOR APPROVAL` marker at top of session file + `/tmp/day-plan-status` file.

### Phase 3 — Evening review session (user + agent)

- **Hard prerequisite gate:** Step F validation must have produced ≥1 CSV row in `~/analytics/weekly/` before this session starts (I/O data for gut-check). **Fallback:** if the collector failed, count tokens manually from the session file's cost-note lines (degraded mode, not a blocker).
- **Agenda:** per-batch results vs acceptance bars → calibration table (user estimate vs agent estimate vs actual, error %) → drift/blocker audit → write **"Learnings for the next protocol"** section ending with a structured protocol-change proposal table:

  | Learning | Current Rule | Proposed Change | Urgency (1–3) |
  |----------|-------------|-----------------|---------------|

  — which becomes the input for the next task's formalized protocol.

## 4. Section B — Trust dial refinements + contract mechanics

### Trust dial refinements

1. **Self-elevation clause:** trust level is a FLOOR, not a ceiling. Any L2/L3 task encountering a destructive operation (`git rm`, `git reset`, branch delete, force-push, schema migration, staging dirty files) **self-elevates to L1** — agent writes `ELEVATED TO L1: <reason>` in the learnings log and halts. Concrete tomorrow: Batch 2's `git rm AGENTS.md` in commons (dirty `graphify-out/` present; pre-commit gate won't catch Rust/JSON dirt — it checks Dart/YAML).
2. **L3 quality checkpoint:** L3 = mechanically-gated commit (scripts run, acceptance bar met) + **deferred human quality audit** — evening review explicitly audits one L3 batch's output quality. Trust level controls *when commits happen*; it never removes the evening audit.
3. **Crisp deviation definition (L2):** scope change >20% of estimate, any destructive op, acceptance bar not met. Anything else = proceed.
4. **Dependency-aware scheduling:** L1 batches run first, but if user is unavailable when an L1 halt fires, **independent L2/L3 batches proceed** — the L1 halt blocks only its direct dependents. Day Plan carries the inter-batch dependency graph (`A → B → C → D → E → F → G`; F depends on C+D+E; G depends on F).

### Halt contract (L1 halt fires, user away)

- Notification (macos, unique sound) + `⏸️ WAITING FOR APPROVAL` marker + `/tmp/day-plan-status`.
- **Idle rule: 15 minutes** (user override of architect's 2h). Then proceed to independent batches; log idle duration in learnings log. Agreed explicitly in morning session.

### Scope amendment protocol (mid-day "also do X")

Any change to the approved Day Plan requires a one-line `[scopeshift]` entry in the status file:
`scopeshift: old=<batch N scope> new=<amended scope> reason=<why> trust=<L1|L2|L3>`
Agent HALTS if the amendment raises trust risk (e.g., L2 → L1). Evening review audits scopeshifts as a drift category.

### Learnings log entry format (one line per checkpoint, greppable)

```
[BATCH_N] batch=<tag> trust=<L1|L2|L3> status=<done|partial|blocked|elevated> tokens_in=<est,actual> tokens_out=<est,actual> drift=<count> blockers=<comma-sep|none> gut_check=<user_vs_actual|skipped>
```

### Session Objective convention (locked in morning session)

Objective line MUST be `Feature: docs/features/<name>/README.md — <task>` or plain `<task>` if no feature — the collector's `feature_parent` column parses it.

## 5. Artifact set (tomorrow's run produces)

| Artifact | Location |
|---|---|
| Day Plan (contract) | `docs/plans/2026-08-06-day-plan.md` |
| Session file + learnings log | `docs/sessions/2026-08-06.md` |
| Status file | `docs/sessions/2026-08-06-status.md` |
| Protocol-change proposal table | end of evening review (in session file) |
| I/O data | `~/analytics/weekly/2026-08-06.csv` (from v1 Step C) |

## 6. Deferred (explicitly NOT in tomorrow's run)

- Standing protocol doc (written after tomorrow, from learnings)
- v2 comms integration (report_sink webhook swap)
- Autonomous Planner→Workers→Verifier→Auditor without user gates
- Trust dial relaxation beyond tomorrow's L1-first run (gradual, per user gut-check validation)

## 7. Open items

- None — all sections acked. Morning planning session (2026-08-06) executes this design.
