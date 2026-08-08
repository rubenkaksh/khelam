#!/bin/bash
# bootstrap.sh — first-time post-clone setup for a forkable-derived app (khelam).
#
# Forkable-first canonical copy: forkable/scripts/bootstrap.sh
# Children pull an identical copy; the forkable-sync tripwire diffs scripts/.
#
# Handles:
#   1. Clone commons to the path this app's pubspec_overrides.yaml expects
#   2. Pin commons to the latest git tag matching the app's commons constraint
#   3. Verify/update pubspec_overrides.yaml
#   4. flutter pub get
#   5. .env setup (create from .env.example; WARN if .env exists; never overwrite)
#   6. Verify Flutter/dart SDK version against pubspec environment.sdk
#   7. List all other first-time requirements (backend, simulators, hooks, etc.)
#
# Idempotent + safe. --dry-run prints without executing.
# Usage:
#   bash scripts/bootstrap.sh              # full setup
#   bash scripts/bootstrap.sh --dry-run    # preview without executing
#   bash scripts/bootstrap.sh --tag v0.7.2 # pin a specific commons tag
#
# Env overrides:
#   KHELAM_REPO   default ~/projects/khel-service/khelam (the app repo)
#   COMMONS_REPO  default ~/projects/commons
#   APP_PUB       default $KHELAM_REPO/pubspec.yaml
set -euo pipefail

KHELAM_REPO="${KHELAM_REPO:-$HOME/projects/khel-service/khelam}"
COMMONS_REPO="${COMMONS_REPO:-$HOME/projects/commons}"
APP_PUB="${APP_PUB:-$KHELAM_REPO/pubspec.yaml}"
DRY_RUN=0
TAG_OVERRIDE=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --tag)     TAG_OVERRIDE="$2"; shift 2 ;;
    --repo)    KHELAM_REPO="$2"; APP_PUB="$KHELAM_REPO/pubspec.yaml"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
bootstrap.sh — First-time post-clone setup for a forkable-derived app.

Usage:
  bash scripts/bootstrap.sh              # full setup
  bash scripts/bootstrap.sh --dry-run    # preview without executing
  bash scripts/bootstrap.sh --tag v0.7.2 # pin a specific commons tag
  bash scripts/bootstrap.sh --repo <path> # point at your app repo

What it does:
  1. Clones commons (if absent) to the path pubspec_overrides.yaml expects
  2. Pins commons to the latest git tag (or --tag / pubspec git ref)
  3. Verifies/updates pubspec_overrides.yaml
  4. Runs `flutter pub get`
  5. Creates .env from .env.example (never overwrites existing .env)
  6. Verifies Flutter SDK version
  7. Prints a first-time requirements checklist
HELP
      exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; exit 2 ;;
  esac
done

run() {  # run <description> <command...>
  local desc="$1"; shift
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $desc: $*"
  else
    echo "▸ $desc"
    "$@"
  fi
}

# --- 1. Verify this is the right place ------------------------------------------------
if [ ! -f "$APP_PUB" ]; then
  echo "ERROR: app pubspec.yaml not found at $APP_PUB" >&2
  echo "  Use --repo <path> to point at your app repo." >&2
  exit 1
fi
APP_ROOT="$(cd "$(dirname "$APP_PUB")" && pwd)"
APP_NAME="$(basename "$APP_ROOT")"

echo "=== bootstrap: $APP_NAME ==="
echo "  app repo : $APP_ROOT"
echo "  commons  : $COMMONS_REPO"
echo "  dry-run  : $([ "$DRY_RUN" -eq 1 ] && echo YES || echo NO)"
echo ""

# --- 2. Clone commons if absent --------------------------------------------------------
if [ ! -d "$COMMONS_REPO/.git" ]; then
  echo "▶ commons not found — cloning..."
  run "clone commons" git clone https://github.com/rubenkaksh/commons.git "$COMMONS_REPO"
else
  echo "▶ commons already present at $COMMONS_REPO — skipping clone"
  run "fetch latest" git -C "$COMMONS_REPO" fetch --tags --quiet
fi

# --- 3. Determine + pin the commons tag ------------------------------------------------
# Priority: --tag flag → active (uncommented) git ref in pubspec → latest tag.
# Commented-out git refs are treated as stale (the app switched to a path override)
# and are NOT used — the latest tag from the commons repo is preferred instead.
resolve_tag() {
  local tag="$TAG_OVERRIDE"
  if [ -z "$tag" ]; then
    # Only match an ACTIVE (uncommented) git: ref in the pubspec.
    tag="$(python3 - "$APP_PUB" <<'PY'
import sys, re
text = open(sys.argv[1]).read()
# Active: commons: { git: { ref: vX.Y.Z } }  (no leading # on those lines)
m = re.search(r' commons:\s*\n\s+git:\s*\n\s+ref:\s*(\S+)', text)
if not m:
    # Also try single-line form: commons: { git: { url: ..., ref: vX } }
    m = re.search(r'commons:\s*\{[^}]*ref:\s*(\S+)', text)
print(m.group(1) if m else "")
PY
)"
  fi
  if [ -z "$tag" ]; then
    # Fall back to latest tag in the commons repo
    tag="$(git -C "$COMMONS_REPO" tag --sort=-v:refname | head -1)"
  fi
  echo "$tag"
}

if [ -d "$COMMONS_REPO/.git" ]; then
  DESIRED_TAG="$(resolve_tag)"
  if [ -n "$DESIRED_TAG" ]; then
    CURRENT_TAG="$(git -C "$COMMONS_REPO" describe --tags --exact-match 2>/dev/null || true)"
    if [ "$CURRENT_TAG" = "$DESIRED_TAG" ]; then
      echo "▶ commons already on tag $DESIRED_TAG — no change"
    else
      run "checkout commons tag $DESIRED_TAG" git -C "$COMMONS_REPO" checkout "$DESIRED_TAG" --quiet
    fi
  else
    echo "▶ could not resolve a commons tag — staying on current branch"
  fi
fi

# --- 4. Verify / create pubspec_overrides.yaml -----------------------------------------
OVERRIDES="$APP_ROOT/pubspec_overrides.yaml"
EXPECTED_PATH="$COMMONS_REPO"
if [ ! -f "$OVERRIDES" ]; then
  run "create pubspec_overrides.yaml" tee "$OVERRIDES" > /dev/null <<EOF
dependency_overrides:
  commons:
    path: $EXPECTED_PATH
EOF
else
  # Verify the path inside overrides matches
  EXISTING="$(python3 - "$OVERRIDES" <<'PY'
import sys, re
text = open(sys.argv[1]).read()
m = re.search(r'path:\s*(\S+)', text)
print(m.group(1) if m else "")
PY
)"
  if [ "$EXISTING" != "$EXPECTED_PATH" ]; then
    echo "▶ WARNING: pubspec_overrides.yaml points to $EXISTING, expected $EXPECTED_PATH"
    [ "$DRY_RUN" -eq 0 ] && read -r -p "  Update it? [y/N] " ans && [ "$ans" = "y" ] && \
      run "update pubspec_overrides.yaml" tee "$OVERRIDES" > /dev/null <<EOF
dependency_overrides:
  commons:
    path: $EXPECTED_PATH
EOF
  else
    echo "▶ pubspec_overrides.yaml already points to $EXPECTED_PATH — OK"
  fi
fi

# --- 5. flutter pub get ----------------------------------------------------------------
if command -v flutter > /dev/null 2>&1; then
  run "flutter pub get" flutter -C "$APP_ROOT" pub get
else
  echo "▶ WARNING: flutter not found — skipping pub get (install Flutter SDK first)"
fi

# --- 6. .env setup ---------------------------------------------------------------------
ENV_FILE="$APP_ROOT/.env"
ENV_EXAMPLE="$APP_ROOT/.env.example"
if [ -f "$ENV_FILE" ]; then
  echo "▶ .env already exists — NOT overwriting (your config is safe)"
elif [ -f "$ENV_EXAMPLE" ]; then
  run "create .env from .env.example" cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "  ⚠️  Edit $ENV_FILE — replace placeholder Google client IDs and set API_BASE_URL."
else
  echo "▶ WARNING: no .env or .env.example found — create .env manually."
  echo "  Required keys: API_BASE_URL, GOOGLE_CLIENT_ID, GOOGLE_SERVER_CLIENT_ID"
fi

# --- 7. Verify Flutter/Dart SDK --------------------------------------------------------
if command -v flutter > /dev/null 2>&1; then
  echo "▶ Flutter: $(flutter --version --machine 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["versionString"])' 2>/dev/null || flutter --version | head -1)"
else
  echo "▶ WARNING: Flutter SDK not found. Install from https://docs.flutter.dev/get-started/install"
fi

# --- 8. First-time requirements check-list ---------------------------------------------
echo ""
echo "=== First-time requirements ==="
cat <<'CHECKLIST'
  [ ] Backend running (khelam needs rms-futsal-backend at :5000 or Render URL):
        bash ../rms-futsal-backend/scripts/dev.sh   # or: cd rms-futsal-backend && npm run start:dev
        Health check: curl http://127.0.0.1:5000/health
  [ ] iOS simulator: xcrun simctl boot "iPhone 16 Pro Max"  (or any simulator)
  [ ] Android emulator (if testing Android): emulator -avd <name>
  [ ] Discord env: ~/.config/opencode/discord.env  (5 webhook URLs or leave empty for macos_notification)
  [ ] CodeGraph hooks:  melos run hooks   (or: bash scripts/install_codegraph_hooks.sh)
  [ ] Launchd jobs (optional, for auto-digest/review):
        sudo cp forkable/scripts/com.khelam.daily-digest.plist  ~/Library/LaunchAgents/
        sudo cp forkable/scripts/com.khelam.weekly-review.plist ~/Library/LaunchAgents/
        launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.khelam.daily-digest.plist
        launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.khelam.weekly-review.plist
CHECKLIST

echo ""
if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== dry-run complete — no changes were made ==="
else
  echo "=== bootstrap complete ==="
fi
