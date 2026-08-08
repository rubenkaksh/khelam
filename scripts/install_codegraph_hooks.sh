#!/bin/bash
# install_codegraph_hooks.sh — idempotent installer for the CodeGraph
# post-commit refresh hook (hook-only design, 2026-08-08).
#
# Forkable-first canonical: forkable/scripts/install_codegraph_hooks.sh
# Run ONCE per repo (first-time init = user decision). Re-running is a no-op.
# Does NOT touch an existing graphify post-commit block — only appends (or
# creates) the codegraph refresh block, guarded by markers.
#
# Usage:  bash scripts/install_codegraph_hooks.sh
set -uo pipefail

start_marker="# codegraph-refresh-hook-start"
end_marker="# codegraph-refresh-hook-end"

toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "[install_codegraph_hooks] ERROR: not inside a git repo" >&2
    exit 1
}
hooks_dir="$toplevel/.git/hooks"
hook="$hooks_dir/post-commit"
scripts_dir="$toplevel/scripts"
template="$scripts_dir/git-hooks/post-commit.codegraph"
# Fallback to forkable's canonical template if this repo has no scripts/ (e.g. commons).
[ -f "$template" ] || template="${FORKABLE_REPO:-$HOME/projects/forkable}/scripts/git-hooks/post-commit.codegraph"

if [ ! -f "$template" ]; then
    echo "[install_codegraph_hooks] ERROR: post-commit.codegraph template not found." >&2
    echo "  Expected at: $scripts_dir/git-hooks/post-commit.codegraph (or forkable's copy)" >&2
    echo "  Install the canonical forkable/scripts/git-hooks/post-commit.codegraph first." >&2
    exit 1
fi

# Idempotency: if the codegraph block is already present, skip.
if [ -f "$hook" ] && grep -qF "$start_marker" "$hook"; then
    echo "[install_codegraph_hooks] post-commit already has a CodeGraph block — nothing to do."
    exit 0
fi

# Warn (but proceed) if codegraph_refresh.sh isn't executable in this repo.
# The hook template falls back to FORKABLE_REPO/scripts/codegraph_refresh.sh,
# so missing repo-local script is non-fatal (e.g. commons has no scripts/).
missing_script=false
if [ ! -x "$scripts_dir/codegraph_refresh.sh" ] && [ ! -x "${FORKABLE_REPO:-$HOME/projects/forkable}/scripts/codegraph_refresh.sh" ]; then
    echo "[install_codegraph_hooks] WARNING: codegraph_refresh.sh not found/executable in this repo or forkable." >&2
    missing_script=true
fi

# Install: create or append to post-commit.
if [ -f "$hook" ]; then
    printf '\n' >> "$hook"   # blank line separator before the appended block
else
    printf '#!/bin/sh\n# Auto-managed by install_codegraph_hooks.sh — do not edit the codegraph block by hand.\n' > "$hook"
fi
cat "$template" >> "$hook"
chmod +x "$hook"

echo "[install_codegraph_hooks] OK — CodeGraph refresh block written to $hook"
if [ "$missing_script" = "true" ]; then
    echo "  (hook will fall back to \$FORKABLE_REPO/scripts/codegraph_refresh.sh at commit time)"
fi
