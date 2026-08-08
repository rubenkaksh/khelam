# Design: Automatic CodeGraph + Graphify Index Refresh (HOOK-ONLY FINAL)

**Date:** 2026-08-08 (Sat) — design finalized after user decision-tree confirmation.
**Owner:** architect (this Mac: khelam / forkable / commons)
**Status:** IMPLEMENTED & verified live (hook-only — no launchd timer installed).
**Spec:** docs/superpowers/specs/2026-08-08-auto-index-refresh-design.md
**Cost note:** design-only; refresh paths are zero-cost (codegraph sync, graphify update).
Semantic graphify extract stays user/weekly-driven (never unattended).

## 1. Goal
Indexes must never be stale without human intervention. The user opted into the
COMBINED CodeGraph + Graphify stack for khelam, forkable, commons and rejected
"indexing is the user's decision" as a standing manual chore. Auto-refresh is
the norm; the only human decision is FIRST-TIME INIT of a new repo (it writes
local machine files). Target: survive full-autonomous / 80% autonomous operation.

## 2. User-Locked Decisions (decision tree, confirmed 2026-08-08)

| Q | Choice | Notes |
|---|--------|-------|
| 1. Trigger strategy | (a) Hook only | NO launchd timer, NO plist, NO master-loop. post-commit hook is the single trigger. Weekly freshness_check() is the safety net for a broken hook. Accepted tradeoff: uncommitted edits refresh on next commit only. |
| 2. Forkable graphify gap | (b) YES | One-time graphify update . + graphify hook install . in forkable (authorized; graphify-out/ gitignored -> reversible). |
| 3. Token-cost graphify extract | (b) Never auto | check-update flags it weekly as an Open Action; agents may run ad-hoc only when flagged. |
| 4. Staleness tolerance | (b) >7 days | Knob FRESHNESS_DAYS=7; also hard-fail on any pendingChanges > 0. |
| 5. Failure notification | (b) report_sink.sh | send_error_report -> #agent-errors Discord + macos notification, rate-limited (1/hr/repo). |
| 6. First-time-init consent | (b) User decides init; refresh auto | Once .codegraph/ or graphify-out/ exists -> refresh automatic; creating either from scratch is a user decision. |

## 3. Architecture (hook-only)
commit (khelam/commons/forkable)
        |
        v
git post-commit hook (.git/hooks/post-commit -- gitignored)
   |-- graphify block (khelam+commons: present; forkable: added via graphify hook install .)
   |-- codegraph block (forkable-first template git-hooks/post-commit.codegraph,
   |                    appended by install_codegraph_hooks.sh; never clobbers graphify)
         -> codegraph_refresh.sh <repo>  (DETACHED, never blocks commit)
              reads `codegraph status --json`:
                pendingChanges==0 -> skip (no-op guard vs commit bursts)
                pendingChanges>0  -> `codegraph sync --quiet <repo>` (cheap, incremental)
              on lock error -> `codegraph unlock` + retry once
              on hard failure -> log + send_error_report (rate-limited)
              log: ~/.cache/codegraph-refresh-<repo>.log
        |
        v
next symbol lookup / graphify query just works -- index is fresh

Why no launchd timer: user locked hook-only. freshness_check() (sec 4.4) is the
backstop: if the hook breaks, the weekly review fails rather than serving stale.

## 4. Design Decisions

### 4.1 CodeGraph -- all three repos
- Refresh primitive: codegraph sync (cheap/incremental, idempotent, internally lock-guarded).
- Trigger: post-commit hook runs codegraph_refresh.sh <repo> detached (never blocks git commit).
- No-op guard: reads `codegraph status --json` first; pendingChanges==0 -> exit 0.
  Falls back to "always sync" if python3/codegraph unavailable.
- Lock safety: on stale lock, runs `codegraph unlock` once and retries.
- Forkable-first: canonical forkable/scripts/codegraph_refresh.sh. khelam pulls an
  identical copy (forkable-sync tripwire stays green). commons has no scripts/ dir
  -> its hook + script fall back to $FORKABLE_REPO (defaults to ~/projects/forkable)
  for both codegraph_refresh.sh and report_sink.sh.

### 4.2 Graphify -- khelam+commons (present); forkable (added today)
- khelam + commons: graphify's own post-commit hook already correct and active
  (detached _rebuild_code, 600s timeout, ~/.cache/graphify-rebuild.log,
  rebase/merge/cherry-pick + graphify-out-only skips). No change needed.
- forkable: was missing graphify-out/ + hook. INIT RAN LIVE 2026-08-08:
  `graphify update .` (629 nodes, 749 edges, 47 communities) +
  `graphify hook install .` (post-commit + post-checkout + merge driver).
  graphify-out/ is gitignored.

### 4.3 Cost discipline (locked)
- Zero-cost automated: codegraph sync + graphify AST-only _rebuild_code (in hook).
- Token-cost graphify extract: nowhere in hook/timer/freshness path. Only
  check-update flags it -> weekly Open Action. Agents may run extract ad-hoc when
  flagged, logging a >5k cost-note per existing Cost Discipline.

### 4.4 Freshness verification in weekly review
Added freshness_check() to forkable/scripts/weekly_review.sh (canonical), invoked
in the review PROMPT alongside mechanical_check(). For each indexed repo:
- CodeGraph (HARD FAIL): codegraph status --json -> lastIndexed age > FRESHNESS_DAYS
  (7) OR pendingChanges > 0 -> review fails.
- Graphify (advisory -> Open Action): graphify check-update <repo> -> non-zero exit
  -> "graphify re-extraction pending" Open Action (never hard-fails).
> graphify check-update verified: exit 0 = up to date (cron-safe gate).

### 4.5 Operational details
- No daemon reliance: codegraph daemon has a 5-min idle backstop that shuts it down.
  Design uses explicit sync calls only.
- No launchd: nothing installed (per user lock + instruction).
- Idempotency / thundering-herd: sync is idempotent + internally lock-guarded;
  hook fires once per commit; status short-circuit skips no-ops.
- Logs: ~/.cache/codegraph-refresh-<repo>.log (sync activity) +
  ~/.cache/codegraph-refresh-hook.log (hook invocation).
- Failure notification: report_sink.sh send_error_report -> #agent-errors Discord
  webhook + macos notification; rate-limited to 1/hr/repo.

## 5. Implementation Plan (forkable-first) -- ALL DONE
Canonical artifacts in forkable/scripts/ (children pull identical copies):

| Artifact | Status |
|----------|--------|
| scripts/codegraph_refresh.sh | DONE -- per-repo helper (status short-circuit, sync, unlock+retry, log, rate-limited notify) |
| scripts/git-hooks/post-commit.codegraph | DONE -- canonical hook template (detached caller) |
| scripts/install_codegraph_hooks.sh | DONE -- idempotent installer (appends codegraph block; never clobbers graphify block) |
| scripts/weekly_review.sh | DONE -- added freshness_check() + INDEX FRESHNESS CHECK line in PROMPT |
| AGENTS.md (global) | DONE -- CodeGraph block (hook-only auto-refresh + first-init consent) + Graphify freshness bullet |
| forkable graphify-out/ + post-commit | DONE -- graphify update . + graphify hook install . ran live |
| codegraph post-commit hook | DONE -- installed in khelam, forkable, commons |
| FORKABLE_REPO .gitignore | DONE -- graphify-out/ appended to forkable .gitignore |

One-time install command (per repo, idempotent, safe to re-run):
  cd ~/projects/forkable  && bash scripts/install_codegraph_hooks.sh
  cd ~/projects/khel-service/khelam  && bash scripts/install_codegraph_hooks.sh
  cd ~/projects/commons  && bash scripts/install_codegraph_hooks.sh

## 6. Deviations from the original (hybrid) plan
- No launchd timer / plist / codegraph_refresh_all.sh: hook-only per user lock (Q1).
- commons has no scripts/ dir: its hook falls back to FORKABLE_REPO/scripts/
  (template + installer both support the fallback). commons does NOT get a scripts/
  dir -- it is a shared package reviewed from khelam, not a child repo.
- khelam AGENTS.md NOT edited: it only references global "codegraph/graphify guidance"
  (no mirrored indexing-consent line), so the global edit is sufficient. forkable's
  AGENTS.md also only references global.

## 7. Risks / Gotchas (final, verified)
- codegraph daemon idle-shutdown (5 min): N/A -- design uses explicit sync calls.
- Hook recursion / rebuild loops: SAFE -- codegraph sync does not index its own
  .codegraph/ (gitignored, not in codegraph manifest). graphify hook skips when
  only graphify-out/ changed.
- Thundering herd (hook on every commit): mitigated by status short-circuit
  (pendingChanges==0 skips) + codegraph internal lock.
- Token-cost extract leak: SAFE -- extract appears nowhere in hook/timer/freshness.
- forkable on branch test/aider: scripts are branch-agnostic (resolve repo root
  via git rev-parse / own location). No merge needed.
- commons tracks graphify-out/ in git (PRE-EXISTING): commons .gitignore has no
  graphify-out/ entry and graphify-out/ is a tracked tree. Adding the gitignore
  entry does NOT untrack already-committed files; untracking requires an explicit
  `git rm -r --cached graphify-out` (a git index change requiring user consent).
  This is out of scope for this task and left as-is -- flagged for the user.

## 8. Verification (all passed live, 2026-08-08)
- bash -n: codegraph_refresh.sh, install_codegraph_hooks.sh,
  git-hooks/post-commit.codegraph, weekly_review.sh -- all syntax OK.
- forkable graphify init: graphify update . -> 629 nodes; graphify hook install .
  -> post-commit + post-checkout + merge driver installed.
- codegraph end-to-end: tweaked a tracked .py file -> codegraph_refresh.sh
  detected pendingChanges=1 -> ran codegraph sync --quiet -> logged "sync OK",
  status caught up to pending=0 -> reverted file -> re-run logged "skipped
  (pendingChanges=0)".
- Hook parity: all 3 repos' .git/hooks/post-commit have BOTH graphify (1) and
  codegraph (1) blocks.
- freshness_check(): OK for all 3 (khelam/commons/forkable codegraph fresh
  lastIndexed 2026-08-08, pending=0; graphify up to date).
- AGENTS.md edits present in global ~/.config/opencode/AGENTS.md.
- No launchd artifacts installed (per instruction).
