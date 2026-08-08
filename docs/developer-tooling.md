# Developer Tooling Guide

One reference for everything dev — Melos batch runner, first-time setup, daily
loop, screenshots, digests, weekly review, and troubleshooting. Written for
when the agent is unavailable.

**Workspace root** (run every command from here):

```
cd ~/projects/khel-service
```

The workspace spans three separate git repos (via Melos):

| Repo       | Path (relative to workspace) | Language | Has scripts/ |
|------------|------------------------------|----------|--------------|
| khelam     | `./khelam`                   | Flutter  | yes          |
| commons    | `../commons`                 | Dart     | no           |
| forkable   | `../forkable`                | Flutter  | yes (canonical) |

The NestJS backend lives at `./rms-futsal-backend` (Node.js — not a Melos package).

---

## First Time Setup

```bash
cd ~/projects/khel-service
dart pub get                        # install melos dependency
melos run bootstrap                 # or: bash ./khelam/scripts/bootstrap.sh
```

### What bootstrap.sh does (idempotent)

1. **Clones commons** if absent at `~/projects/commons`.
2. **Pins commons to the latest git tag** — v0.7.0, v0.7.1, v0.7.2 etc. (reads the
   active `git: ref:` in your app's `pubspec.yaml`; falls back to the latest tag).
   Override with `melos run bootstrap -- --tag v0.7.2`.
3. **Verifies `pubspec_overrides.yaml`** points to `$HOME/projects/commons`. Updates it on confirmation.
4. **Runs `flutter pub get`** in khelam.
5. **Creates `.env`** from `.env.example` if missing. **Never overwrites** an existing `.env` — you'll get a warning instead.
6. **Checks your Flutter SDK version** against `pubspec.yaml`'s `environment.sdk`.
7. **Prints a checklist** of remaining manual steps.

### First-time requirements checklist

- [ ] **Backend running** — the app needs the NestJS API. Start it:
  ```bash
  cd ~/projects/khel-service/rms-futsal-backend
  npm run start:dev
  curl http://localhost:5000/health   # should return 200
  ```
- [ ] **iOS simulator** — for screenshot capture:
  ```bash
  xcrun simctl boot "iPhone 16 Pro Max"
  ```
- [ ] **Android emulator** — if testing Android:
  ```bash
  emulator -avd <your-avd-name>
  ```
- [ ] **Discord env** (optional — for digest/screenshot/reviews delivery):
  ```bash
  mkdir -p ~/.config/opencode
  touch ~/.config/opencode/discord.env
  chmod 600 ~/.config/opencode/discord.env
  # Add webhook URLs, comma-separated or one per line:
  # DISCORD_WEBHOOK_URL=...
  # DAILY_OVERVIEW_WEBHOOK_URL=...
  # WEEKLY_REVIEWS_WEBHOOK_URL=...
  # SCREENSHOTS_WEBHOOK_URL=...
  # AGENT_ERRORS_WEBHOOK_URL=...
  ```
  Leave empty → messages fall back to macOS notifications.
- [ ] **CodeGraph hooks** — auto-index refresh (one-time install):
  ```bash
  melos run hooks
  ```
- [ ] **Launchd jobs** (optional — for auto digest + weekly review every day/Sunday):
  ```bash
  sudo cp forkable/scripts/com.khelam.daily-digest.plist  ~/Library/LaunchAgents/
  sudo cp forkable/scripts/com.khelam.weekly-review.plist ~/Library/LaunchAgents/
  launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.khelam.daily-digest.plist
  launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.khelam.weekly-review.plist
  ```
  Or kick the daily digest manually: `bash ./khelam/scripts/daily_digest.sh`

### Dry-run first

Every script supports `--dry-run` to preview without executing:

```bash
bash ./khelam/scripts/bootstrap.sh --dry-run
bash ./khelam/scripts/dev_daily.sh --dry-run
```

---

## Daily Dev Loop

One command runs the entire finishing-up loop across all repos:

```bash
melos run daily
```

Or with flags (append after `--`):

```bash
melos run daily -- --analyze-only             # just flutter analyze, nothing else
melos run daily -- --skip-tests               # skip flutter test
melos run daily -- --skip-precommit           # skip pre-commit gate
melos run daily -- --skip-sync                # skip forkable↔khelam parity check
melos run daily -- --changed-only             # only repos with uncommitted changes
melos run daily -- --repo khelam              # only one repo
melos run daily -- --dry-run                  # preview what would run
melos run daily -- --analyze-only --repo commons   # combine flags
```

### What each step does

| Step | What it runs | When it's skipped |
|------|-------------|-------------------|
| `flutter analyze` | Dart static analysis | --analyze-only, docs-only changes |
| `flutter test` | Full test suite | --skip-tests, --analyze-only, docs-only changes |
| `pre_commit_check.sh` | Analyze + test (docs-only skip built in) | --skip-precommit, --analyze-only, repo without scripts/ |
| `bash -n scripts/*.sh` | Shell syntax check on every .sh in scripts/ | none — always runs if scripts/ exists |
| sync parity | `diff` forkable/scripts ↔ khelam/scripts | --skip-sync, --analyze-only |

**Docs-only skip**: if the only changes in a repo are `.md`/`.sh` files (no `.dart`/`.yaml`/`.yml`),
`dev_daily.sh` automatically skips analyze + test — matching the pre-commit gate's logic.

**Changed-only mode**: `--changed-only` uses `git diff HEAD` to skip repos with no
uncommitted changes. Useful when you know you only touched one repo.

### Running dev_daily.sh directly (without Melos)

```bash
bash ./khelam/scripts/dev_daily.sh --analyze-only --dry-run
```

### Individual Melos shortcuts

```bash
melos run analyze          # flutter analyze in all 3 Dart repos
melos run test             # flutter test in all 3 Dart repos
melos run pre-commit       # pre-commit gate in khelam + forkable only
melos run sync-check       # forkable ↔ khelam scripts/ parity check
```

---

## Screenshots to Discord

```bash
melos run screenshot -- schedule       # capture the "schedule" screen → #screenshots
bash ./khelam/scripts/screenshot.sh schedule --no-backend   # direct, skip backend check
bash ./khelam/scripts/screenshot.sh schedule --device "iPhone 16"
```

The screen name comes from `docs/features/*/screens.yaml`. Known screens:

```bash
# List known screens:
grep 'name:' docs/features/*/screens.yaml
```

`screenshot.sh` is a thin wrapper around `capture_screens.sh` — it resolves your
app repo automatically and forwards all flags. `capture_screens.sh` handles the
simulator navigation, PNG capture (1320×2868), and Discord upload.

---

## Daily Digest to Discord

Already set up via launchd (`com.khelam.daily-digest.plist`). No new script needed.

```bash
# Manual run (re-sends the current day's digest if not already sent):
bash ./khelam/scripts/daily_digest.sh

# Force via launchd (if the plist is installed):
launchctl kickstart gui/$(id -u)/com.khelam.daily-digest

# Check markers (sent days):
ls ~/Library/Application\ Support/khelam/daily-digest/markers/

# Check the log:
cat ~/Library/Application\ Support/khelam/daily-digest/daily-digest.log
```

The digest fires **Mon–Fri at 08:00** and at every login (`RunAtLoad`) for
catch-up. Idempotent — a missing marker `<date>.sent` triggers re-send.
See `docs/superpowers/specs/2026-08-08-auto-digest-reliability-design.md` for
the full reliability design.

---

## Weekly Review

Automatically runs every **Sunday 18:00** via launchd.

```bash
# Manual:
bash ./khelam/scripts/weekly_review.sh

# Force via launchd:
launchctl kickstart gui/$(id -u)/com.khelam.weekly-review

# View output:
ls docs/reviews/                           # review docs
~/analytics/weekly/                         # CSV data
~/analytics/performance-summary.md          # perf summary
```

The weekly review also runs:
- **Token analytics collection** (`ccusage_collect.sh`) → `~/analytics/`
- **CodeGraph freshness check** → hard-fails if any index is stale >7 days
- **Forkable sync parity check** → flags script drift between forkable and khelam

---

## Index Refresh (Auto — Nothing to Do)

CodeGraph + Graphify indexes refresh **automatically** after every commit via the
post-commit hook. Installed by:

```bash
melos run hooks     # or: bash ./khelam/scripts/install_codegraph_hooks.sh
```

The weekly review's `freshness_check()` is the safety net — it hard-fails if any
index hasn't been refreshed in 7+ days or has pending changes (a sign the hook broke).

Manual trigger (if you need to force a refresh):

```bash
melos run refresh
```

---

## Troubleshooting

### Backend not up

Symptom: screenshot capture fails with exit code 3 (backend unreachable), or
the app shows network errors.

```bash
# Check:
curl http://localhost:5000/health
# If down, start it:
cd ~/projects/khel-service/rms-futsal-backend && npm run start:dev
# Or use --no-backend flag for mock-only screens:
melos run screenshot -- schedule --no-backend
bash ./khelam/scripts/screenshot.sh schedule --no-backend
```

### Commons pin mismatch

Symptom: `flutter pub get` fails or `pubspec_overrides.yaml` points to the wrong path.

```bash
# Check current commons tag:
git -C ~/projects/commons describe --tags --exact-match
# Check latest tag:
git -C ~/projects/commons tag --sort=-v:refname
# Re-pin (override):
melos run bootstrap -- --tag v0.7.2 --repo ~/projects/khel-service/khelam
# Or manually:
cd ~/projects/commons && git checkout v0.7.2 && cd ~/projects/khel-service/khelam && flutter pub get
```

### discord.env missing or misconfigured

Symptom: messages appear as macOS notifications instead of Discord posts.

```bash
# Check:
ls -la ~/.config/opencode/discord.env
# If missing, create it:
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/discord.env <<'EOF'
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/xxx
DAILY_OVERVIEW_WEBHOOK_URL=https://discord.com/api/webhooks/yyy
WEEKLY_REVIEWS_WEBHOOK_URL=https://discord.com/api/webhooks/zzz
SCREENSHOTS_WEBHOOK_URL=https://discord.com/api/webhooks/aaa
AGENT_ERRORS_WEBHOOK_URL=https://discord.com/api/webhooks/bbb
EOF
chmod 600 ~/.config/opencode/discord.env
# Check env var:
echo $REPORT_SINK   # should be discord_webhook (set in launchd plist)
```

### Daily digest re-send / marker issues

Symptom: digest didn't fire or sent a duplicate.

```bash
# Check markers (one per date):
ls -la ~/Library/Application\ Support/khelam/daily-digest/markers/
# Remove a marker to force re-send for that date:
rm ~/Library/Application\ Support/khelam/daily-digest/markers/2026-08-08-1.sent
# Re-run manually:
bash ./khelam/scripts/daily_digest.sh
# Check the lock (stale lock >30min is auto-taken-over):
ls -la ~/Library/Application\ Support/khelam/daily-digest/.lock/
rm -rf ~/Library/Application\ Support/khelam/daily-digest/.lock/   # only if truly stuck
```

### Forkable sync drift

Symptom: `melos run sync-check` reports `DRIFT`.

```bash
# See what differs:
diff -rq ~/projects/forkable/scripts/ ~/projects/khel-service/khelam/scripts/
# Sync from forkable (canonical → khelam):
rsync -av --delete ~/projects/forkable/scripts/ ~/projects/khel-service/khelam/scripts/
# Verify:
melos run sync-check
```

### Melos can't find packages

Symptom: `melos list` shows fewer packages than expected, or `melos run` fails.

```bash
# Ensure melos is installed:
dart pub global activate melos
# Ensure pubspec.yaml at workspace root has melos dev_dependency:
grep melos pubspec.yaml
# Re-run:
dart pub get && melos list
```
