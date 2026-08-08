#!/bin/bash
# dev_daily.sh — Everyday dev + task-closeout loop (forkable-first canonical).
#
# THE melos centerpiece. Batch-runs finishing-up checks across all repos in one
# invocation to avoid wasting tokens on manual one-by-one runs.
#
# Canonical copy: forkable/scripts/dev_daily.sh → synced byte-identical to khelam/scripts/
#
# Flags:
#   --analyze-only    Run only flutter analyze (skip tests, pre-commit, sync check)
#   --skip-tests      Skip flutter test
#   --skip-precommit  Skip pre_commit_check.sh
#   --skip-sync       Skip forkable↔khelam sync parity check
#   --changed-only    Only run on repos with uncommitted changes (git diff HEAD)
#   --repo <name>     Only run on the specified repo (khelam|commons|forkable)
#   --dry-run         Show what would run without executing
#   --help            Show this help
#
# Usage:
#   bash scripts/dev_daily.sh                              # full closeout loop
#   melos run daily -- --analyze-only                      # via melos
#   bash scripts/dev_daily.sh --repo khelam --changed-only # targeted
#   bash scripts/dev_daily.sh --sync-only                   # just sync parity
#   bash scripts/dev_daily.sh --dry-run                     # preview
#
# What it does (per Dart repo, unless filtered):
#   1. git diff HEAD → if only docs/scripts changed (no .dart/.yaml/.yml), skip analyze+test
#      (mirrors the pre_commit_check.sh docs-only skip, but for unstaged changes)
#   2. flutter analyze    (unless --analyze-only skips others, or --skip-tests)
#   3. flutter test       (skipped if docs-only; skipped if --analyzer-only or --skip-tests)
#   4. bash -n scripts/*.sh  (syntax-check every shell script in the repo)
#   5. forkable↔khelam scripts/ parity diff (unless --skip-sync or --analyze-only)
#
# Env overrides:
#   KHELAM_REPO   default ~/projects/khel-service/khelam
#   COMMONS_REPO  default ~/projects/commons
#   FORKABLE_REPO default ~/projects/forkable
set -euo pipefail

# ── Flag parsing ───────────────────────────────────────────────────────────
ANALYZE_ONLY=0
SKIP_TESTS=0
SKIP_PRECOMMIT=0
SKIP_SYNC=0
CHANGED_ONLY=0
SYNC_ONLY=0
REPO_FILTER=""
DRY_RUN=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --analyze-only)  ANALYZE_ONLY=1; shift ;;
    --skip-tests)    SKIP_TESTS=1; shift ;;
    --skip-precommit) SKIP_PRECOMMIT=1; shift ;;
    --skip-sync)     SKIP_SYNC=1; shift ;;
    --changed-only)  CHANGED_ONLY=1; shift ;;
    --sync-only)     SYNC_ONLY=1; shift ;;
    --repo)          REPO_FILTER="$2"; shift 2 ;;
    --dry-run)       DRY_RUN=1; shift ;;
    -h|--help)
      cat <<'HELP'
dev_daily.sh — Everyday dev + task-closeout loop (forkable-first canonical).

Flags:
  --analyze-only    Run only flutter analyze (skip tests, pre-commit, sync check)
  --skip-tests      Skip flutter test
  --skip-precommit  Skip pre_commit_check.sh
  --skip-sync       Skip forkable↔khelam sync parity check
  --changed-only    Only run on repos with uncommitted changes (git diff HEAD)
  --repo <name>     Only run on the specified repo (khelam|commons|forkable)
  --dry-run         Show what would run without executing
  --help            Show this help

Usage:
  bash scripts/dev_daily.sh                              # full closeout loop
  melos run daily -- --analyze-only                      # via melos
  bash scripts/dev_daily.sh --repo khelam --changed-only # targeted
  bash scripts/dev_daily.sh --sync-only                   # just sync parity
  bash scripts/dev_daily.sh --dry-run                     # preview
HELP
      exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; exit 2 ;;
  esac
done

KHELAM_REPO="${KHELAM_REPO:-$HOME/projects/khel-service/khelam}"
COMMONS_REPO="${COMMONS_REPO:-$HOME/projects/commons}"
FORKABLE_REPO="${FORKABLE_REPO:-$HOME/projects/forkable}"

# ── Repo registry ────────────────────────────────────────────────────────────
# name|path|has_dart(0/1)|has_scripts(0/1)
REPOS=(
  "khelam|$KHELAM_REPO|1|1"
  "commons|$COMMONS_REPO|1|0"
  "forkable|$FORKABLE_REPO|1|1"
)

select_repos() {
  local out=()
  for entry in "${REPOS[@]}"; do
    local name repo has_dart has_scripts
    IFS='|' read -r name repo has_dart has_scripts <<< "$entry"
    if [ -n "$REPO_FILTER" ] && [ "$name" != "$REPO_FILTER" ]; then continue; fi
    out+=("$entry")
  done
  printf '%s\n' "${out[@]}"
}

# ── Helpers ──────────────────────────────────────────────────────────────────
run_or_dry() {  # run_or_dry <command...>
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

changed_files() {  # changed_files <repo-path> → prints file list or empty
  git -C "$1" diff --name-only HEAD 2>/dev/null || true
}

is_docs_only() {  # is_docs_only <repo-path> → returns 0 if only docs/scripts changed
  local files
  files="$(changed_files "$1")"
  [ -z "$files" ] && return 1
  printf '%s\n' "$files" | rg -q '\.(dart|yaml|yml)$' && return 1 || return 0
}

# ── Sync parity check ────────────────────────────────────────────────────────
sync_check() {
  echo ""
  echo "━━━ Forkable ↔ khelam sync parity ━━━"
  if [ ! -d "$FORKABLE_REPO/scripts" ] || [ ! -d "$KHELAM_REPO/scripts" ]; then
    echo "  SKIP: one or both scripts/ dirs missing"
    return 0
  fi
  local drift
  drift="$(diff -rq -x '__pycache__' -x '*.pyc' "$KHELAM_REPO/scripts" "$FORKABLE_REPO/scripts" 2>/dev/null || true)"
  if [ -z "$drift" ]; then
    echo "  ✓ scripts/ identical (tripwire green)"
  else
    echo "  ✗ DRIFT — khelam scripts/ differs from forkable canonical:"
    printf '%s\n' "$drift" | sed 's/^/    /'
    echo "  Run: melos run sync-check  (or manually copy from forkable)"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────
FAILED=0
TOTAL_REPOS=$(select_repos | wc -l | tr -d ' ')
CURRENT=0

echo "=== dev_daily.sh — $([ $DRY_RUN -eq 1 ] && echo 'DRY-RUN' || echo 'live') ==="
if [ $CHANGED_ONLY -eq 1 ]; then echo "  (changed-only mode — repos with no changes will be skipped)"; fi
if [ -n "$REPO_FILTER" ]; then echo "  (repo filter: $REPO_FILTER)"; fi
echo "  repos: $(select_repos | cut -d'|' -f1 | tr '\n' ' ')"
echo ""

# ── Sync-only shortcut ───────────────────────────────────────────────────────
if [ "$SYNC_ONLY" -eq 1 ]; then
  sync_check
  echo ""
  echo "=== done (sync-only) ==="
  exit 0
fi

# ── Per-repo loop ────────────────────────────────────────────────────────────
while IFS='|' read -r name repo has_dart has_scripts; do
  [ -z "$repo" ] && continue
  CURRENT=$((CURRENT + 1))
  echo "━━━ [$CURRENT/$TOTAL_REPOS] $name ($repo) ━━━"

  if [ ! -d "$repo/.git" ]; then
    echo "  SKIP — not a git repo (or path wrong)"
    continue
  fi

  # Changed-only: skip repos with no uncommitted changes
  if [ "$CHANGED_ONLY" -eq 1 ] && [ -z "$(changed_files "$repo")" ]; then
    echo "  SKIP — no uncommitted changes"
    continue
  fi

  # Docs-only skip: if only docs/scripts changed, skip analyze+test
  DOCS_ONLY=0
  if is_docs_only "$repo"; then
    DOCS_ONLY=1
    echo "  docs-only changes detected — skipping analyze + test"
  fi

  # ── flutter analyze ──────────────────────────────────────────────────────
  if [ "$has_dart" -eq 1 ] && command -v flutter > /dev/null 2>&1; then
    if [ "$DOCS_ONLY" -eq 0 ]; then
      echo "▸ flutter analyze"
      run_or_dry bash -c "cd '$repo' && flutter analyze" || { echo "  ✗ FAIL"; FAILED=1; }
    else
      echo "▸ flutter analyze (skipped — docs-only)"
    fi
  else
    echo "▸ flutter analyze (skipped — no dart or flutter not found)"
  fi

  # ── flutter test ─────────────────────────────────────────────────────────
  if [ "$has_dart" -eq 1 ] && [ "$ANALYZE_ONLY" -eq 0 ] && [ "$SKIP_TESTS" -eq 0 ] && \
     [ "$DOCS_ONLY" -eq 0 ] && command -v flutter > /dev/null 2>&1; then
    echo "▸ flutter test"
    run_or_dry bash -c "cd '$repo' && flutter test" || { echo "  ✗ FAIL"; FAILED=1; }
  else
    echo "▸ flutter test (skipped)"
  fi

  # ── pre-commit gate (khelam + forkable only, both have scripts/) ──────────
  if [ "$has_scripts" -eq 1 ] && [ "$SKIP_PRECOMMIT" -eq 0 ] && [ "$ANALYZE_ONLY" -eq 0 ]; then
    if [ -f "$repo/scripts/pre_commit_check.sh" ]; then
      echo "▸ pre_commit_check.sh"
       run_or_dry bash -c "cd '$repo' && bash scripts/pre_commit_check.sh" || { echo "  ✗ FAIL"; FAILED=1; }
    fi
  else
    echo "▸ pre_commit_check.sh (skipped)"
  fi

  # ── bash -n script syntax checks ─────────────────────────────────────────
  if [ "$has_scripts" -eq 1 ] && [ -d "$repo/scripts" ]; then
    echo "▸ bash -n scripts/*.sh"
    for sh in "$repo"/scripts/*.sh; do
      [ -f "$sh" ] || continue
      if [ "$DRY_RUN" -eq 1 ]; then
        echo "  [dry-run] bash -n $sh"
      else
        if bash -n "$sh" 2>&1; then :; else echo "  ✗ SYNTAX ERROR in $sh"; FAILED=1; fi
      fi
    done
    if [ "$DRY_RUN" -eq 0 ]; then echo "  ✓ all scripts syntax-checked"; fi
  fi

  echo ""
done < <(select_repos)

# ── Forkable sync parity ─────────────────────────────────────────────────────
if [ "$ANALYZE_ONLY" -eq 0 ] && [ "$SKIP_SYNC" -eq 0 ]; then
  sync_check
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "=== ✅ dev_daily.sh — all checks passed ==="
else
  echo "=== ⚠️  dev_daily.sh — $FAILED check(s) FAILED ==="
  echo "   Fix and re-run: melos run daily"
fi
exit "$FAILED"
