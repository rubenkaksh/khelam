#!/bin/bash
# screenshot.sh — thin wrapper around capture_screens.sh.
#
# Forkable-first canonical copy: forkable/scripts/screenshot.sh
# → synced byte-identical to khelam/scripts/.
#
# capture_screens.sh already does the heavy lifting (screen registry lookup,
# simulator navigation, PNG capture, Discord #screenshots delivery via report_sink).
# This wrapper just provides a shorter command name and automatic repo resolution
# so `screenshot schedule` works from anywhere in the workspace without cd-ing.
#
# Usage:
#   screenshot.sh <screen-name> [capture_screens.sh flags...]
#   screenshot.sh --help
#
# Examples:
#   screenshot.sh schedule                           # capture the "schedule" screen
#   screenshot.sh schedule --no-backend              # skip backend health check
#   screenshot.sh schedule --device "iPhone 16"       # use a specific simulator
#   screenshot.sh schedule --reuse-installed         # skip rebuild (faster iteration)
#
# Env overrides:
#   SCREENSHOT_REPO   default ~/projects/khel-service/khelam (the app with screens.yaml)
set -euo pipefail

SCREENSHOT_REPO="${SCREENSHOT_REPO:-$HOME/projects/khel-service/khelam}"

# --- Usage ---------------------------------------------------------------------
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  cat <<'EOF'
screenshot.sh — capture a UI screen and send to Discord #screenshots.

Usage:
  screenshot.sh <screen-name> [flags...]

Screens are registered in docs/features/<feature>/screens.yaml.
The wrapper delegates to capture_screens.sh (repo-agnostic) and passes
all flags through unchanged.

Flags passed through to capture_screens.sh:
  --out <dir>          output directory (default: <repo>/docs/screenshots/<feature>/)
  --no-backend         skip backend health check
  --device <name|udid> simulator name substring or UDID
  --reuse-installed    skip rebuild/install

Exit codes: same as capture_screens.sh (0 ok, 1 args, 2 simulator, 3 backend,
4 launch, 5 nav, 6 write).
EOF
  exit 0
fi

# --- Validate + resolve --------------------------------------------------------
if [ -z "${1:-}" ]; then
  echo "ERROR: screen name required." >&2
  echo "  Usage: screenshot.sh <screen-name> [flags...]" >&2
  echo "  Known screens: $(grep -h 'name:' "$SCREENSHOT_REPO"/docs/features/*/screens.yaml 2>/dev/null | sed 's/.*name: //' | tr '\n' ' ')" >&2
  exit 1
fi

SCREEN_NAME="$1"; shift  # rest of args go to capture_screens.sh

# --- Delegate ------------------------------------------------------------------
# capture_screens.sh derives REPO from its own location (BASH_SOURCE), so we
# call it directly from the app repo's scripts/ dir.
CAPTURE_SCRIPT="$SCREENSHOT_REPO/scripts/capture_screens.sh"
if [ ! -f "$CAPTURE_SCRIPT" ]; then
  echo "ERROR: capture_screens.sh not found at $CAPTURE_SCRIPT" >&2
  echo "  Ensure SCREENSHOT_REPO points to the app repo." >&2
  exit 1
fi

exec bash "$CAPTURE_SCRIPT" "$SCREEN_NAME" "$@"
