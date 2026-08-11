#!/bin/bash
# loop_verify.sh — inner-loop automated verifier (Maker's mechanical gate).
# Canonical copy lives in forkable/scripts/ (forkable-first); children pull
# byte-identical (diff -rq tripwire). Spec:
# docs/superpowers/specs/2026-08-11-loop-engineering-design.md (P1).
#
# Runs on EVERY checkpoint commit, for ALL batches (quality bar, not a trust
# gate). Two stages:
#
#   Stage 1 — Arch/skill-rule compliance (HARD-BLOCK, exit 1):
#     The staged diff must not introduce layer violations (e.g. a domain/data
#     file importing presentation). Deterministic core: import scan of the
#     staged file contents (`git show :<path>` — index-accurate, sees NEW files
#     that the codegraph index cannot). Enrichment: `codegraph node` (cached
#     index only, 3s per-file cap) re-checks the same assertions on files the
#     index already knows. graphify is deliberately NOT called in the gate: its
#     query output is traversal prose, not greppable for mechanical assertions
#     (documented deviation — the layer rule is path-derived and fully covered
#     by the deterministic core + codegraph enrichment).
#     Violation -> non-zero exit -> pre-commit gate blocks the commit AND emits
#     to #agent-errors (report_sink.sh send_error_report).
#
#   Stage 2 — State consistency (ADVISORY, exit 0 + warning):
#     A staged tasklog.md marking cards DONE/CLOSED while the latest session
#     file still shows Blockers -> warn to stderr, commit proceeds.
#     (Open-Actions <-> tasklog cross-check deferred to Phase 4.)
#
# Performance guardrail (spec): sub-second target via staged-diff filter +
# cached indices. If the whole run exceeds 15s -> BOTH stages degrade to
# advisory for this run, #agent-errors flagged, exit 0 (fail closed, never
# stall development).
#
# Usage: bash scripts/loop_verify.sh   (from anywhere in the repo)
set -u

REPO="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "loop_verify: not a git repo" >&2; exit 0; }
cd "$REPO" || exit 0

START="$(date +%s)"
BUDGET=15

CHANGED="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)"
[ -z "$CHANGED" ] && exit 0

warn() { echo "LOOP VERIFY (advisory): $*" >&2; }

over_budget() { [ "$(( $(date +%s) - START ))" -gt "$BUDGET" ]; }

# emit_error <title> <body> — best-effort #agent-errors emit, fully isolated
# (subshell, set +u: report_sink.sh env-loading must never break the gate).
emit_error() {
  local sink="$REPO/scripts/report_sink.sh" title="$1" body="$2"
  [ -f "$sink" ] || return 0
  (
    set +u
    # shellcheck disable=SC1090
    . "$sink" >/dev/null 2>&1
    send_error_report "$title" "$body" >/dev/null 2>&1
  ) || true
}

# run_capped <seconds> <cmd...> — kill-after timeout (portable, no GNU timeout)
run_capped() {
  local cap="$1" pid killer rc tmp
  shift
  tmp="/tmp/loop_verify.$$"
  "$@" > "$tmp" 2>/dev/null &
  pid=$!
  ( sleep "$cap"; kill "$pid" 2>/dev/null ) &
  killer=$!
  wait "$pid" 2>/dev/null
  rc=$?
  kill "$killer" 2>/dev/null
  cat "$tmp" 2>/dev/null
  rm -f "$tmp"
  return $rc
}

# layer_of <file> — presentation | domain | data | core | other (path-derived,
# repo-agnostic: rules only fire when the naming exists in the repo).
layer_of() {
  case "/$1" in
    */domain/*) echo domain ;;
    */data/*)   echo data ;;
    */views/*|*/widgets/*|*/bloc/*|*/screens/*|*/presentation/*|*/ui/*) echo presentation ;;
    */di/*|*/contracts/*|*/models/*) echo core ;;
    *)          echo other ;;
  esac
}

VIOLATIONS=""
# scan_content <file> <content> — import-layer assertions; appends to
# VIOLATIONS, rc=1 when the file violates. Handles git-show (plain) and
# codegraph (line-number-prefixed) content.
scan_content() {
  local file="$1" src="$2" line imp rc=0
  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"      # leading whitespace
    line="${line#[0-9]*[[:space:]]}"             # codegraph "N<TAB>" prefix
    case "$line" in
      import\ *) imp="${line#import }" ;;
      *) continue ;;
    esac
    case "$imp" in
      */views/*|*/widgets/*|*/bloc/*|*/screens/*|*/presentation/*|*/ui/*)
        VIOLATIONS="$VIOLATIONS
  $file -> $imp"
        rc=1
        ;;
    esac
  done <<< "$src"
  return $rc
}

# ---- Stage 1: arch/skill-rule compliance (hard-block) ---------------------
DEGRADED=0
# shellcheck disable=SC2086
for file in $CHANGED; do
  if over_budget; then
    DEGRADED=1
    warn "stage 1 budget exceeded — degrading this run to advisory"
    break
  fi
  case "$file" in
    lib/*.dart) : ;;
    *) continue ;;
  esac
  case "$file" in
    *.g.dart|*.freezed.dart|*.mocks.dart) continue ;;   # generated code exempt
  esac
  case "$(layer_of "$file")" in
    domain|data) : ;;
    *) continue ;;
  esac
  # deterministic core: staged (index) content — catches NEW files
  if src="$(git show ":$file" 2>/dev/null)"; then
    scan_content "$file" "$src"
  fi
  # codegraph enrichment: cached index only (never re-extracts), 3s cap
  if command -v codegraph >/dev/null 2>&1 && [ -d .codegraph ]; then
    if cg="$(run_capped 3 codegraph node "$file")" && [ -n "$cg" ]; then
      scan_content "$file" "$cg"
    fi
  fi
done

if [ "$DEGRADED" -eq 1 ]; then
  el="$(( $(date +%s) - START ))"
  warn "run exceeded the ${BUDGET}s budget (took ~${el}s) — degraded to advisory for this run"
  emit_error "Loop verify: degraded" "Verifier exceeded ${BUDGET}s (took ~${el}s) — degraded to advisory for this run"
  exit 0
fi

if [ -n "$VIOLATIONS" ]; then
  echo "LOOP VERIFY BLOCKED: arch/skill-rule violation in staged diff:" >&2
  printf '%s\n' "$VIOLATIONS" | sort -u | sed '/^[[:space:]]*$/d' >&2
  emit_error "Loop verify: arch violation" "Staged diff violates layer rules:$VIOLATIONS"
  exit 1
fi

# ---- Stage 2: state consistency (advisory) --------------------------------
TASKS="$(printf '%s\n' "$CHANGED" | rg -F 'tasklog.md' || true)"
if [ -n "$TASKS" ]; then
  # shellcheck disable=SC2086
  NEW_DONE="$(git diff --cached -U0 -- $TASKS 2>/dev/null | rg '^\+' | rg -v '^\+\+\+' | rg '\b(DONE|CLOSED)\b' || true)"
  if [ -n "$NEW_DONE" ]; then
    card="$(printf '%s\n' "$NEW_DONE" | head -1 | sed -E 's/^\+//; s/^\|[[:space:]]*//; s/[[:space:]]*\|.*$//; s/\*\*//g' | tr -s ' ')"
    latest="$(find docs/sessions -maxdepth 1 -name '*.md' 2>/dev/null | sort | tail -1 || true)"
    if [ -n "$latest" ]; then
      blockers="$(awk 'BEGIN{f=0} /^## Blockers/{f=1; next} /^## /{f=0} f' "$latest" | rg -v '^\s*$|\(none\)|none yet' || true)"
      if [ -n "$blockers" ]; then
        warn "tasklog card \"$card\" marked DONE/CLOSED but latest session ($latest) still shows Blockers — confirm intentional"
      fi
    fi
  fi
fi

if over_budget; then
  el="$(( $(date +%s) - START ))"
  warn "run took ${el}s (budget ${BUDGET}s) — degraded to advisory for this run"
  emit_error "Loop verify: degraded" "Verifier took ${el}s (budget ${BUDGET}s) — degraded to advisory"
fi

exit 0
