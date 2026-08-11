#!/bin/bash
# Pre-commit gate (canonical copy lives in forkable/scripts/): blocks the
# commit if `flutter analyze` or the full `flutter test` suite fails.
# Installed as .git/hooks/pre-commit (calls this script). Manual run:
# bash scripts/pre_commit_check.sh
#
# Skips when only docs/markdown/scripts changed — doc/script commits don't
# need a build check. Also see the "Cost Discipline" rules in AGENTS.md: the
# gate enforces "no commits with known failures" mechanically.
#
# Layered gates (loop-engineering spec P1): after the mechanical gate
# (analyze + suite) passes, scripts/loop_verify.sh runs the SEMANTIC gate —
# arch/skill-rule compliance (hard-block -> commit rejected + #agent-errors
# emit) + state consistency (advisory warn). Docs/scripts-only commits skip
# the build but still run loop_verify (its stage-2 state check applies to
# markdown commits).
set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"
cd "$REPO"

CHANGED="$(git diff --cached --name-only)"
if [ -z "$CHANGED" ]; then
  exit 0
fi

# Docs-only commits (sessions, reviews, markdown, shell scripts) skip the gate.
if ! printf '%s\n' "$CHANGED" | rg -q '\.(dart|yaml|yml)$'; then
  bash "$REPO/scripts/loop_verify.sh"
  exit 0
fi

if ! flutter analyze > /tmp/pre_commit_analyze.log 2>&1; then
  echo "PRE-COMMIT BLOCKED: flutter analyze failed" >&2
  cat /tmp/pre_commit_analyze.log >&2
  exit 1
fi

if ! flutter test > /tmp/pre_commit_test.log 2>&1; then
  echo "PRE-COMMIT BLOCKED: flutter test failed (see /tmp/pre_commit_test.log)" >&2
  tail -20 /tmp/pre_commit_test.log >&2
  exit 1
fi

# Inner-loop semantic gate AFTER the mechanical gate passes (arch/skill
# compliance hard-blocks — set -e propagates the non-zero; state consistency
# warns only).
bash "$REPO/scripts/loop_verify.sh"

exit 0
