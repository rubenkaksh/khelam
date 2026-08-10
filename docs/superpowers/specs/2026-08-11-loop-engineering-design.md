# Loop-Engineering Architecture — Design (Grill-Gate Locked)

- **Status**: DECISIONS LOCKED via Grill Gate (2026-08-10, @architect `ses_013fe2b54ffeoBI4tkvsCWUScZ`, 2 question rounds + §2B empty-resume). **Implementation NOT started** — user: "Record only, don't implement" (2026-08-10). Implementation begins on user go-ahead.
- **Source**: `docs/sandbox/gemini-code-1786370796569.md` (user's "most core vision").
- **This spec is the durable record** — a fresh session must be able to implement the full plan from this file alone (session files may be summarized).

---

## 1. Framing

The doc is a **vision blueprint** for a 4-phase autonomous-loop architecture. Most of it already exists (weekly_review.sh `opencode run --auto`, daily_digest.sh, background-agent execution model with trust dial L1/L2/L3, report_sink.sh v3). Decision: **formally absorb the existing systems' goals into the loop architecture — fill gaps, never scrap-and-replace.**

## 2. Locked Decisions

1. **Doc = blueprint, not rewrite** — existing systems are the implementation; loops formalize + fill gaps.
2. **`@cobusgreyling/loop` (v0.1.2, ALREADY INSTALLED) = scaffold-only** — `loop init --pattern daily-triage` scaffolds + writes state files; dispatch/gates stay opencode-native (`opencode run --auto` + shell scripts like weekly_review.sh). No rewrite around the package.
3. **Two-gate model**:
   - **Inner-loop automated verifier** (NEW) = Maker's mechanical gate. Runs EVERY checkpoint commit, for ALL batches (quality bar, not a trust gate). Checks: (a) architecture/skill-rule compliance — codegraph/graphify diff patterns for layer violations (hard-block on violation → `#agent-errors`); (b) state-file consistency — tasklog ↔ session status ↔ Open Actions (advisory — warn, don't block). Layered AFTER the pre-commit gate (pre-commit = mechanical analyze+suite; inner-loop = semantic); both required.
   - **Outer-loop human audit** (EXISTING) = Checker's gate. The evening review session from the 2026-08-05 execution model. No new tool.
4. **Trust dial inherited** — triage=L1 (halt at boundary), sweeper=L2 (auto-proceed, halt on deviation), maker=L2/L3; sandbox workspace default L3. L1 halts happen at the outer-loop audit, not the inner-loop gate.
5. **State: consolidated, markdowns = truth** — tasklog.md = active queue; session status file = loop state; review-memory.md = Open Actions. `loop`'s LOOP-STATE.json/STATE.md are DERIVED artifacts; `sync_loop_state.sh` translation layer keeps them in sync (reads `loop status --json`, the stable API surf — not raw JSON parsing). No new parallel source-of-truth files.
6. **Scope: machine-wide** — khelam + commons + forkable + rms-futsal-backend + sandbox. Triage board = per-repo tasklog.md (no new central board); daily_digest.sh aggregates cross-repo for Discord as today.
7. **Triage input = markdown board** — tasklog.md + backlog.md + Open Actions. Crash-log scanning DROPPED (no crash-reporting infra).
8. **Triage → digest = upstream/downstream** — triage sorts/updates the board; daily_digest.sh delivers it. No replacement.
9. **Phase 3 CI Sweeper DROPPED** — no CI/CD exists; the pre-commit gate is the failure-catcher. Deferred until CI/CD exists.
10. **Maker/checker mapping** — inner-loop verifier = Maker's mechanical pre-commit gate; outer-loop evening review = Checker's human post-batch audit.

## 3. Implementation Plan

### Phase 1 — Inner-Loop Verifier (ships FIRST — the quality bar must exist before any loop dispatches)

**Deliverable**: `scripts/loop_verify.sh` — forkable-first canonical; khelam pulls byte-identical (diff -rq tripwire).

**Mechanism**: wrapper invoked from the pre-commit hook, two stages:
1. **Arch/skill-compliance check** — `codegraph explore` + `graphify query` on the STAGED DIFF (git diff --name-only filter, cached indices only) to detect layer violations (e.g., presentation importing domain). Grep-style assertions on codegraph output. Non-zero exit on violation.
2. **State-consistency check** — staged commit leaves tasklog/status/Open Actions mutually consistent. Advisory: exit 0 + warning to stderr.

**Pre-commit integration**: `scripts/pre_commit_check.sh` (forkable-first) calls `loop_verify.sh` AFTER analyze + tests pass. Non-zero (arch violation) → block commit + `send_error_report "Loop verify: arch violation"` (report_sink.sh → #agent-errors). State drift → warn + log only.

**Performance guardrail**: verifier must be sub-second (staged-diff filter + cached codegraph). If it exceeds ~15s → log warning + degrade to advisory for that run, flagged in #agent-errors (fail closed, never stall development).

**Acceptance bar**:
1. `bash -n` + `shellcheck` clean.
2. Mock arch violation (staged diff importing presentation into domain) → blocks commit, emits to #agent-errors.
3. Mock state drift (tasklog card DONE but session status blocked) → warns, commit proceeds.
4. `diff -rq` forkable↔khelam `loop_verify.sh` = identical.
5. Both repos' existing gates still green (analyze + suite).

**Estimate**: ~6k.

### Phase 2 — Loop Scaffold + State Reconciliation

**Deliverables**: `loop init .` per repo root (scaffold-only, one-time); `scripts/sync_loop_state.sh` (forkable-first).

**Mechanism**:
- `loop init . --pattern daily-triage --tool opencode` per repo → LOOP-STATE.json + STATE.md + loop config. Treated as derived thereafter.
- `sync_loop_state.sh` runs after every loop iteration (post-digest, post-weekly-review): tasklog.md active queue → LOOP-STATE.json `active_tasks`; `loop status` → STATE.md summary; Open Actions count → LOOP-STATE.json `open_actions`. Idempotent.
- Flag: if `loop init` requires `.opencodec.json`/opencode.json schema changes → Phase 2 user question (currently opencode.json already has `doom_loop: allow`).

**Acceptance bar**:
1. `loop init` produces LOOP-STATE.json + STATE.md in each repo root without error.
2. `sync_loop_state.sh` idempotent: `loop status --json` matches tasklog.md active-queue count.
3. No markdown content lost/degraded by sync.
4. `diff -rq` forkable↔khelam `sync_loop_state.sh` = identical.

**Estimate**: ~8k.

### Phase 3 — Daily Triage Loop

**Deliverables**: `scripts/daily_triage.sh` (forkable-first); launchd plist `com.khelam.daily-triage.plist` (forkable-first template; **user installs** — agent never auto-installs launchd jobs). 07:30 Mon–Fri (30 min before the 08:00 digest so it reflects fresh priority). Single machine-wide plist that loops over repos (default) — sandbox workspace config.

**Mechanism**:
- Per-repo `opencode run --auto` agent: scan tasklog.md 🔴 Active + 🟡 Backlog, review-memory Open Actions (non-struck), backlog.md; re-rank by (1) Open Actions severity, (2) backlog freshness, (3) cross-repo dependencies; output re-sorted tasklog (≤3 🔴, ≤5 🟡).
- After run: `sync_loop_state.sh` fires.
- Trust dial: L1 (writes markdown only, no code commits); skip repos with no prior-day session (token budget). Sandbox runs at default L3.

**Acceptance bar**:
1. `bash -n` + `shellcheck` green.
2. Live run → tasklog 🔴 ≤3, re-ranked by criteria.
3. `sync_loop_state.sh` fires; `loop status` reflects updated board.
4. Plist template in forkable; user-installed.
5. `diff -rq` forkable↔khelam identical.

**Estimate**: ~10k.

### Phase 4 — Formalization (parallel with Phase 3 finalization)

**Deliverables**: this spec already written (2026-08-10, pulled forward as the durable record); AGENTS.md + review-memory.md reference the two gates by name; weekly_review.sh PROMPT gains optional `loop audit`/`loop doctor` check (Loop-Ready score).

**Acceptance bar**:
1. Two-gate model referenced in AGENTS.md (global Session Hygiene / khelam Cost Discipline) + review-memory Implemented Measures.
2. `weekly_review.sh` PROMPT references `loop audit` as optional.
3. `pre_commit_check.sh` calls `loop_verify.sh` in the layered position (post-tests).
4. review-memory OA#14 CLOSED (machine-wide = loop-engineering); OA#11 formal close already pending weekly review.

**Estimate**: ~4k.

## 4. Phasing Order + Dependencies

1. **P1** — BLOCKS everything; no dependencies.
2. **P2** — depends on P1 (verifier must exist before loop state references it as the gate); precedes P3.
3. **P3** — depends on P2 (scaffold + sync live before the daily agent writes state).
4. **P4** — depends on P1–P3 shipping; doc portions already pulled forward.

**Total estimate: ~28k tokens, all free-tier.**

## 5. Risks + Guardrails

1. **Two-gate serial bottleneck** — pre-commit (analyze + full suite) + inner-loop verifier serialize on every commit. Mitigations: verifier runs only on code-changed files; cached `.codegraph/`/graphify-out indices (no re-extraction); >15s → degrade-to-advisory + flag #agent-errors. Verifier must stay sub-second or fail closed.
2. **`@cobusgreyling/loop` schema lock-in** — schema may evolve. Mitigation: read `loop status --json` (stable surf), never parse LOOP-STATE.json directly; idempotency test (P2 acceptance #2) catches schema changes.
3. **Machine-wide token blowout** — 5 repos × daily triage. Mitigations: triage capped L1 (30s max, halt on uncertainty); skip repos without prior-day session; sandbox L3 default but token-bounded.
4. **`loop init` schema coupling** — if it requires opencode.json changes, that's a user question at P2 (do not silently modify opencode.json).

## 6. Explicitly OUT of scope

- Phase 3 CI Sweeper (no CI/CD).
- Crash-log scanning (no crash-reporting infra).
- New separate `loop-verifier` tool (mapped to existing evening review + the new inner-loop script).
- Any scrap-and-replace of weekly_review.sh / daily_digest.sh / execution model.
- New central machine-wide state files (per-repo tasklog stays source of truth).

## 7. Open Items (blocking implementation start)

- **User go-ahead** (sole blocker; user chose "Record only" 2026-08-10).
- P2: `.opencodec`/opencode.json schema question IF `loop init` demands it.
- P3: plist install is a user action.
- Weekly review: OA#11 (formal close), OA#14 (close when P1 ships).
