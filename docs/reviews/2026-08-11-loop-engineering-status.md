# Loop-Engineering System — Status & Verification Report

**Date**: 2026-08-11 · **Status**: ALL PHASES SHIPPED · **Scope**: loop-engineering architecture, P1 → P4

**Spec**: `docs/superpowers/specs/2026-08-11-loop-engineering-design.md` (Grill-Gate locked 08-10, user go-ahead 08-11)
**Canonical repo**: `~/projects/agent-tools` — consumers (khelam, forkable, commons, rms-futsal-backend, sandbox) pull scripts byte-identical and pin via `scripts/agent-tools.version`.

---

## TL;DR

The ad-hoc automation that already existed (Sunday weekly review, 08:00 daily digest) is now a **formal two-gate loop**, fully implemented today:

- **Gate 1 — mechanical (every commit):** pre-commit (analyze + full test suite) → then `loop_verify.sh` (architecture/skill-rule compliance blocks; state drift warns).
- **Gate 2 — human (every Sunday):** the weekly review now carries the loop's **Loop-Ready score** + an optional `loop audit` deep-dive.

Plus a **07:30 daily triage** that re-ranks the work board (markdown-only, L1 trust dial) and a **state-reconciliation layer** that keeps derived state in sync with the markdown source of truth.

Everything below was verified live today — all green.

---

## What was done — the 4 phases

| Phase | Deliverable | What it does | Status |
|---|---|---|---|
| **P1** Inner-loop verifier | `scripts/loop_verify.sh` | Semantic gate layered in the pre-commit hook: architecture/skill-rule violations **block the commit** (+ `#agent-errors`); state-file inconsistency **warns** only. Runs on every commit, including docs-only ones. | ✅ shipped |
| **P2** Loop scaffold + state sync | `scripts/sync_loop_state.sh` | Reconciliation layer: tasklog.md / review-memory (source of truth) → `LOOP-STATE.json` + `STATE.md` (derived). Idempotent; runs post-digest and post-review. | ✅ shipped |
| **P3** Daily triage loop | `scripts/daily_triage.sh` + `com.khelam.daily-triage.plist` | 07:30 Mon–Fri, machine-wide: an agent re-ranks each repo's tasklog (≤3 🔴, ≤5 🟡) by Open-Action severity → backlog freshness → cross-repo dependencies. Markdown-only, L1 trust dial (no code commits). Live run proved **Ready 100/100 L2**. | ✅ shipped, plist user-installed |
| **P4** Formalization | `weekly_review.sh` LOOP HEALTH CHECK + two-gate refs | Sunday review prompt now computes the **Loop-Ready score** (`loop status --json`) and audits the two-gate model; AGENTS.md (both repos) + review-memory document the gates; **OA#14 CLOSED**. | ✅ shipped |

**Commits**: agent-tools `210b2c1` · forkable `3aed067` · khelam `f2b1189` · pins → `210b2c1` (both consumers, verified by `dev_daily.sh --sync-only`).

---

## Verification run — everything in place (2026-08-11, all green)

### Static health

| Check | Command | Result |
|---|---|---|
| Syntax | `bash -n` on 5 canonical scripts + 6 consumer wrappers | ✅ all OK |
| Lint | `shellcheck` on the 4 loop scripts | ✅ 0 new findings (9 pre-existing info-level only) |
| Plist validity | `plutil -lint` on 4 launchd templates | ✅ all OK |
| Wrapper parity | `diff -rq forkable/scripts khelam/scripts` | ✅ identical, no drift |

### Live system state

| Check | Command | Result |
|---|---|---|
| Loop-Ready score | `npx @cobusgreyling/loop status .` | ✅ **Ready 100/100 L2** · pattern daily-triage · state 2026-08-11 |
| Inner-loop verifier | `bash scripts/loop_verify.sh` | ✅ exit 0 (state consistency passes) |
| State reconciliation | `sync_loop_state.sh` | ✅ exit 0, idempotent |
| Derived state | STATE.md + LOOP-STATE.json | ✅ last run 2026-08-11 · active tasks 1 · open actions 3 |
| Scheduled jobs | `launchctl list \| grep khelam` | ✅ 4 loaded: daily-triage, daily-digest, weekly-review, weekly-review.retry |
| Pin sync | `dev_daily.sh --sync-only` | ✅ khelam + forkable pinned to agent-tools `210b2c1` |

### Re-run it yourself — one command

```bash
cd ~/projects/khel-service/khelam && \
bash scripts/loop_verify.sh && \
npx --yes @cobusgreyling/loop status . && \
REPO=$PWD bash ~/projects/agent-tools/scripts/sync_loop_state.sh && \
bash ~/projects/agent-tools/scripts/dev_daily.sh --sync-only | tail -4 && \
launchctl list | grep khelam
```

Every line green = the loop stack is healthy and wired.

---

## How the architecture changes going forward

### Before → After

| | Before | After |
|---|---|---|
| **Commit gate** | analyze + full test suite only (mechanical) | mechanical **+ semantic** (`loop_verify.sh`): arch violations block, state drift warns |
| **Weekly review** | human audit; self-reported tooling discipline | human audit **+ computed Loop-Ready score** + optional `loop audit`; audit checklist includes the two-gate model |
| **Daily board** | hand-sorted | **07:30 triage** re-ranks tasklog (≤3 🔴, ≤5 🟡) by OA severity → freshness → cross-repo deps; **08:00 digest** delivers it to Discord |
| **State** | tasklog + ad-hoc derived files, drift-prone | tasklog/review-memory = **source of truth**; STATE.md + LOOP-STATE.json = **derived**, reconciled by `sync_loop_state.sh` (never hand-edit) |
| **Tooling location** | per-repo script copies | **agent-tools = canonical**, consumers thin-wrapper + pin (`scripts/agent-tools.version`); weekly tripwire catches drift |

### The two-gate model (the core of the design)

1. **Inner-loop automated verifier = Maker's mechanical gate** — runs on EVERY checkpoint commit, for ALL work. Fast (staged-diff filter, cached codegraph/graphify indices; degrades to advisory if >15s — never stalls development).
2. **Outer-loop human audit = Checker's gate** — the Sunday review (existing, no new tool). L1 triage halts (e.g. a backlog demotion without user authorization) surface here, not in the commit gate.

### What this means day-to-day

- **Commits**: you'll only *see* the inner gate when it blocks — a genuine architecture/skill-rule violation. State drift prints a warning and proceeds.
- **Sundays**: the review prompt shows `LOOP HEALTH CHECK: Ready 100/100 L2 · pattern: daily-triage · last run: <date>` — a glance tells you the loop is healthy.
- **Mornings**: the board arrives re-ranked before the 08:00 digest; the triage agent never writes code (L1) and stops at boundaries it can't decide.
- **New repos**: clone `agent-tools`, pin `scripts/agent-tools.version`, set `core.hooksPath` → the whole loop stack applies. No per-repo copies.

---

## Open items / next

| When | What |
|---|---|
| **Wed 08-12 07:30** | First scheduled triage fire (plist installed). Watch `/tmp/daily-triage.log`. |
| **Sun 08-16** | First weekly review under P4: LOOP HEALTH CHECK line renders live; OA#14 close gets its user-signed resolution (two-review policy); OA#11 formal close. |
| — | Optional future: enable L2 (loop may edit source) — explicit human decision only. |

---

*Generated 2026-08-11 from the P1–P4 verification run. Durable session record: `docs/sessions/2026-08-11.md` (Sessions 1–4).*
