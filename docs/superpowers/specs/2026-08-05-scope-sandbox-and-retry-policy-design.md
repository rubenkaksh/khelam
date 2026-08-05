# Design — Scope Sandboxing + Failure/Retry Policy

> Date: 2026-08-05. Status: APPROVED by user (acked 2026-08-05). Supersedes/extends: `docs/superpowers/specs/2026-08-05-background-agent-execution-model-design.md`. Activates with tomorrow's v1 run (2026-08-06) as specified in §5.

## 1. Motivation (user directive)

1. **Scope sandboxing**: agents will eventually have full folder permissions. We must sandbox scope so an agent with full filesystem access cannot wander outside its approved scope.
2. **Failure/retry policy**: on failures, wait 1 minute before retry; after >4 retries, switch model to deepseek-v4-flash-free (the scout agent's model) as fallback.

## 2. Key architectural findings (verified 2026-08-05)

- `~/.config/opencode/opencode.json` has **NO file-glob-level permissions** — coarse folder access only. Cannot express `deny lib/**` in opencode config. → Sandbox must be: Day Plan manifest + mechanical scripts.
- opencode fixes a session's model at start → a "model switch" = **fresh session with the fallback model** carrying forward a failure-context blob, NOT a mid-session swap.
- v1 run shape: fresh session per batch (design §3, Section A acked). Retry/fallback orchestration needs a session orchestrator that v1 does not have → **log-only in v1**; mechanics formalized after v1 from observed failure data.

## 3. TOPIC 1 — Scope sandboxing

### 3.1 Scope = 4 dimensions, declared per batch in the Day Plan manifest

Each batch block in the Day Plan gets a `## Scope manifest (batch N)`:

```yaml
scope:
  batch: 3
  repos: [khelam]
  trust: L2
  allow:
    files: [docs/sessions/**, docs/plans/**, scripts/ccusage_collect.sh, ~/analytics/**]
    commands: [flutter analyze, flutter test, git add/rm/commit/push, python3 scripts/analytics_charts.py]
    commits: [pattern: "day-plan/v1-step-*-batch-3: *", max_force_push: false]
  deny:
    files: [lib/**, graphify-out/**, **/*.code-workspace, .env*]
    commands: [git push --force*, rm -rf, pkill, chmod]
```

- **Opt-out-proof denylist**: a file matching ANY deny glob is blocked regardless of allow. `graphify-out/**`, `lib/**` (for non-code batches), `**/*.code-workspace`, `*.env*` are default denylist entries.
- Written by the morning planning session; it is authoritative "what was approved".

### 3.2 Mechanical enforcement (rule-reading is unreliable)

1. **`scripts/scope_guard.sh`** (NEW, ~25 lines): reads the active batch manifest (from `docs/sessions/YYYY-MM-DD-status.md` `current_batch=N`), checks `git diff --cached --name-only` against allow/deny globs (`rg --glob`). Deny wins over allow. On violation → append to `/tmp/sandbox-violations.log`, `exit 1`. Plugged at the TOP of `scripts/pre_commit_check.sh` (before the docs-skip, so even docs-only commits are scope-checked).
2. **Post-commit backstop** (`.git/hooks/post-commit` in each repo): re-checks the just-created commit's file list against the manifest. Catches the `--no-verify` workaround. Hooks are the repo's own — not bypassable in-scope.
3. **`scripts/sandbox_audit.sh`** (NEW, ~20 lines): invoked at each SESSION BOUNDARY marker. `git status --porcelain` across the batch's repos → flags any dirty file outside allow/deny → writes `scope=<clean|dirty:lib/>` to the status file + violations log. Catches "agent edited an out-of-scope file but never committed it."

### 3.3 Trust dial × sandbox width

- **L1**: wide scope + guard as safety net (user catches at review; guard still blocks bad commits).
- **L2**: narrow scope + guard as PRIMARY control. Scope violation → **self-elevate to L1** (extends design §4.2 item 1: add trigger `operation on a file/command outside the batch manifest` → `ELEVATED TO L1: scope violation on <file>`).
- **L3**: narrowest + guard + boundary audit + **two violations = hard halt**.

### 3.4 Enforcement survives LLM misreads

- Denylist is opt-out-proof (deny wins over allow).
- Guard reads manifest + status file with `rg`/`find` — no LLM parses globs at runtime.
- Status file (`current_batch=N`) is source of truth, readable by scripts independent of opencode session state.
- Force-push detection: status file records expected checkpoint hash per batch; evening review diffs `git log` against expected sequence — rewritten history = detectable.

### 3.5 Evening review audit (extends Phase 3)

For each `day-plan/v1-step-X-batch-N` commit → `git show --stat` → verify file paths ⊆ allow-list; scan `/tmp/sandbox-violations.log`; check `git status` for uncommitted out-of-scope dirt. Violations → "sandbox integrity" row in the protocol-change proposal table.

### 3.6 Failure modes engineered against

1. Agent edits `lib/` "for convenience", doesn't commit → caught by `sandbox_audit.sh` at SESSION BOUNDARY.
2. Agent commits out-of-scope file; guard blocks; agent uses `--no-verify` → post-commit hook re-validates → logged → evening review finds it.
3. Agent commits `graphify-out/` dirt (Batch 2 commons gotcha) → denylist blocks mechanically.
4. Agent force-pushes a checkpoint, breaking rollback → `git push --force*` denylisted + hash audit.
5. Agent READS out-of-scope files → not enforced (coarse FS read access already granted); soft check in evening review ("agent read lib/ — within reasoning scope?").

## 4. TOPIC 2 — Failure/retry policy + model fallback

### 4.1 Failure definition + transient vs persistent

- **Failure** = shell non-zero exit, exception/throw, OR declared acceptance bar not met (e.g., CSV didn't appear, chart PNG not produced).
- **Transient** (retry sensibly): network blips, `address already in use`, `pub get` cache lock, flaky tests, file-lock contention.
- **Persistent** (retry = waste): logic errors, wrong assumptions, API contract changes, wrong step plan.
- **2-strike identical-error rule** (the cheap discriminator): a retry wrapper sha256s `<stderr+exit-code>` per attempt; identical signatures on N and N+1 → persistent → stop retrying, escalate immediately. Prevents burning 4 retries on a logic error.

### 4.2 Backoff + retry budget

- **1-minute fixed wait** between retries (honors user spec; no jitter in v1 — defer jitter as a next-task calibration option).
- **Max 4 retries = 5 total attempts** (initial + 4). On 5th failure → model fallback (matches ">4 retries → switch model").
- **Budget scope = per-step** (one atomic Day Plan unit with one acceptance bar). Counter resets when that step's bar passes. One hard step cannot starve the batch.
- Total retry wall-clock per step: 4 × 1 min = 4 min.

### 4.3 Model fallback = fresh scout session on ONE step

- **Trigger**: 5th attempt by primary (big_pickle) fails → primary HALTS, commits its checkpoint, writes `batch=N step=<tag> status=fallback model=deepseek-v4-flash-free` to status file.
- **Failure-context blob** (`docs/sessions/YYYY-MM-DD-fallback-context-batchN.md`, written by primary BEFORE halting — mandatory): attempts, truncated error sigs, what was tried, likely cause, checkpoint hash, instruction "re-diagnose this step ONLY; correct and complete it, or escalate to L1". Prevents scout re-deriving the wrong premise.
- **Scout session** (`deepseek_v4_flash_free` = the `@scout` agent): Objective = `Fallback retry: batch N step <tag> (primary failed 5× on: <sig>). Read <blob>, correct, complete, OR escalate to L1.` Carries Day Plan + status file + session file + blob + checkpoint.
- **Scout's job**: (a) read context, (b) fresh perspective often spots a persistent wrong assumption the primary retried blindly, (c) ATTEMPT the corrected step ONCE.
- **Scout helps**: re-planning / error-code diagnosis / simpler re-approach. **Scout hurts**: deep multi-step debugging needing full 4-repo context chain, or stylistically-consistent codegen. Failure there = correct signal to escalate.
- After scout: success → next primary session for batch N+1; failure → escalate (§4.5).

### 4.4 Logging (v1-adoptable NOW)

Each event appends a greppable line to the session file learnings log:

```
[FAIL batch=N step=<tag> model=<primary|fallback> attempt=<n/5> kind=<transient|persistent|acceptance-bar> sig=<4hex> action=<retry|fallback|escalate> wait=60s ts=<HH:MM>]
```

- `sig` = first 4 hex of sha256(error) → lets the evening review GROUP "same error repeated" mechanically.
- Feeds the weekly CSV IF the collector gains `retry_count` + `fallback_triggered` columns (deferred to next-task formalization; v1 logs to session file).
- The fallback-context blob is mandatory before any halt — scout loses step context without it.

### 4.5 Trust dial × retry/fallback (escalation is level-specific)

- **L1**: retries apply (transients waste no one), but after exhaustion → **halt + notify, do NOT auto-spawn scout** (the user present IS the fallback; a scout round-trip is wasted cost). 15-min idle rule governs; independent L2/L3 batches proceed.
- **L2**: retry → scout fallback → scout fails → **ELEVATE TO L1** (user halt). Double failure = major deviation.
- **L3**: retry → scout fallback → scout fails → `status=blocked` + macos notification (unique sound) + `⏸️ BLOCKED` marker. Dependents pause; independent batches continue.

**A fallback does NOT trigger L1 elevation** — the fallback IS the attempt to avoid elevation. Elevation fires only if the fallback also fails (L2/L3). For L1, the user is the escalation target so scout is skipped.

### 4.6 Escalation ceiling = double failure → blocked, NOT abort

After primary (5 attempts) + scout (1 attempt) both fail:
- **L3**: `status=blocked` + `⏸️ BLOCKED` + notification. Dependents pause. Day continues (independent batches proceed). Evening review decides: reassign, scrap, or user-intervene.
- **L2**: same + `ELEVATED TO L1` (user halt).
- **L1**: already halted; user intervenes directly.
- **Never auto-spawn a 3rd model** (architect/librarian). Double failure = wrong premise = human decision, not a model-stack problem.

### 4.7 Failure modes engineered against

1. Retrying a persistent failure 4× (token/time waste) → 2-strike rule stops blind retries; v1 LOGS each retry so the evening review measures "waste from blind retries".
2. Scout fallback fails too; batch stuck → double failure → `blocked` (not abort); dependency-aware scheduling keeps independent batches moving; `status=blocked` visible to `cat`.
3. Model switch loses step context → mandatory failure-context blob + checkpoint commit; scout's first action is `git checkout <checkpoint>` + read blob.
4. Retry counter resets wrong → per-step budget, resets only on acceptance-bar SUCCESS. Partial success (3/4 CSV rows) = retry unless bar's spirit met.

## 5. Activation plan (what runs tomorrow vs after v1)

| Policy piece | v1 (2026-08-06) | After v1 (formalized protocol) |
|---|---|---|
| Scope manifest (per-batch in Day Plan) | ✅ Write in morning session | ✅ Refined per learnings |
| `scripts/scope_guard.sh` + post-commit + `sandbox_audit.sh` | ✅ Activate (safety net, no behavioral risk) | ✅ Tuned |
| Failure logging (`[FAIL ...]` lines) | ✅ Adopt format; agent logs as it fails | Feeds `run_step.sh` counters |
| `run_step.sh` retry wrapper (2-strike, 1-min, sigs) | ❌ Defer (no orchestrator) | ✅ Build from v1's logged failures |
| Scout model-fallback session (blob + fresh `--model scout` session) | ❌ Defer (needs orchestrator) | ✅ Formalize + measure scout-success-rate |
| Collector `retry_count`/`fallback_triggered` columns | ❌ Defer | ✅ Add to weekly CSV |

v1 keeps its role as the OBSERVATIONAL run, with the **scope sandbox as a real safety net** (highest value, lowest risk). Retry/fallback learns from what actually breaks.

## 6. Files touched (landed-in list)

- `docs/plans/YYYY-MM-DD-day-plan.md` — `## Scope manifest (batch N)` per batch + per-step retry budget/acceptance bar declarations
- `scripts/pre_commit_check.sh` — add `scope_guard.sh` call at top (1-line edit)
- `scripts/scope_guard.sh` (NEW) — pre-commit scope checker + violations log
- `.git/hooks/post-commit` (per repo) — post-commit backstop
- `scripts/sandbox_audit.sh` (NEW) — SESSION BOUNDARY audit
- `docs/sessions/YYYY-MM-DD-status.md` — add `current_batch=N` + `scope=<clean|dirty>` per batch
- `scripts/run_step.sh` (NEW, AFTER v1) — retry wrapper: sha256 sigs, 2-strike, 1-min backoff, transient detection, status-file updates
- `docs/sessions/YYYY-MM-DD-fallback-context-batchN.md` (AFTER v1) — failure-context blob
- `scripts/ccusage_collect.sh` — add `retry_count`, `fallback_triggered` columns (AFTER v1)
- Evening review — sandbox integrity row + retry/fallback tally in protocol-change table

## 7. Conflicts with the approved design

- §1/§6 of the base design (one-off experiment): retry/fallback is log-only in v1; NOT shipping `run_step.sh` as a real wrapper in v1 (dead code in a single-agent run). Consistent, no conflict.
- §4.2 item 1 (self-elevation on destructive ops): retry/fallback adds "persistent failure after 4 retries = self-elevate" — compatible mechanism (write `ELEVATED TO L1`, halt).
- §4.1 (fresh session per batch): scout fallback creates an extra session INSIDE a batch — compatible; status file gains `model=` column + session file gains a SESSION BOUNDARY marker for the handoff (propose in protocol-change table post-v1).

## 8. Open items

- None. Morning planning session (2026-08-06) bakes the scope manifest into the Day Plan; evening review measures failure data for the post-v1 retry/fallback formalization.