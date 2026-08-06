# Design — UI Screenshot Verification (v0, initial)

> Date: 2026-08-06. Status: PROPOSED — awaiting morning-planning slot. Lives at `docs/superpowers/specs/` (not a declared feature; matches the 2026-08-06 precedent for `docs/superpowers/specs/`).

## 1. Purpose

When a UI-affecting change ships (replacing a component, adding a feature chunk visible in the UI), provide a shell-first, CI-runnable way to capture a screenshot on the iOS simulator and embed it in the PR description for human review. This is a **human-review artifact**, not a pixel-regression gate — it complements (not replaces) the pre-commit `flutter analyze` + `flutter test` gate.

## 2. Locked decisions (user, 2026-08-06 session)

| # | Decision | Constraint |
|---|----------|------------|
| 1 | Script lives in khelam, pulled to forkable with migrations. Must also solve "khelam-common points → forkable" sync of the tooling itself. | khelam is primary; forkable = future source of truth |
| 2 | Trigger on feature-doc chunk added **and** UI-visible (component replace/add, large feature chunk). **Skip** text changes, layout tweaks. | Avoid screenshot noise |
| 3 | Screenshots embedded into the PR description. | PR = review surface |
| 4 | iOS only (iPhone 16 Pro Max simulator). Android out of scope. | Platform cap |

## 3. Mechanism for capture — options evaluated

| Option | How | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) `xcrun simctl`** | Boot sim → `simctl launch <bundle>` → `simctl io booted screenshot <path>` | Pure shell, no new deps, house-style bash, iOS-native fidelity | Navigation to non-initial routes needs a URL scheme (not registered today) | **PRIMARY** |
| **(b) `integration_test` + `takeScreenshot`** | Dart test drives GoRouter → `IntegrationTestScreenshots.takeScreenshot` → pull via simctl | Programmatic nav to any route | Requires Dart test per screen + iOS `flutter drive` harness; heavier; violates shell-first | Fallback for screens deep-link can't reach |
| **(c) Golden tests** | `matchesGoldenFile` in `flutter test` | Catches pixel regressions in CI | Runs on-host (Linux/Mac), not iOS; baseline-diff not a PR artifact; different acceptance bar | **REJECTED** — different concern (CI regression vs PR review). Keep goldens separate. |
| **(d) `flutter drive`** | Legacy driver | — | Deprecated since 3.10, replaced by (b) | **REJECTED** |

## 4. Recommended mechanism + navigation

**Primary: `xcrun simctl io booted screenshot`.** Rationale: shell-first (house style), zero new dependencies, iOS-native fidelity, and the **schedule screen is the app's initial route** (`initialLocation: AppRoutes.schedulePath` in `app_router.dart`) — so a bare `simctl launch com.megamanus.khelam` lands exactly on it. The app uses `MockBookingService` by default (`USE_MOCK_BOOKING` / `API_BASE_URL` null → mock; see `booking_dependencies.dart`), so no live backend is required for the schedule screenshot.

**Navigation table by screen role:**

| Screen | How the script reaches it |
|---|---|
| Initial route (e.g. `schedule`) | `xcrun simctl launch com.megamanus.khelam` — nothing else needed |
| Non-initial route (future: `home`, `login`, `theme-preview`) | `xcrun simctl openurl booted khelam://<route>` — **requires a one-time URL-scheme registration** (iOS `Info.plist` + `go_router` `routes:` deep-link). Tracked as a deferred Dart change. |
| Screens needing in-app interaction state | `(b)` integration-test fallback — not built now. |

**Settle detection:** poll two consecutive screenshots; if byte-identical (or within a small hash tolerance) after `N` seconds → rendered. Falls back to a 5-second fixed wait. This avoids capturing a loading spinner.

## 5. Script interface

```
scripts/capture_screens.sh <screen-name> [--out <dir>] [--no-backend] [--device <name>]
```

**Step-by-step:**
1. Parse args; resolve `<screen-name>` against the screen registry (§6).
2. Boot iOS simulator if not booted (`xcrun simctl boot <udid>` → ignore `AlreadyBooted` error).
3. If app not installed: build + install (`flutter build ios --simulator --no-codesign` → `xcrun simctl install`). Cached: `--reuse-installed` skips rebuild.
4. Navigate to target: `simctl launch` (initial route) or `simctl openurl` (deep-link). If screen `needs_auth`, restore demo session via the token store path (see §6 flags).
5. Wait for settle (§4 poll, max 15 s).
6. Capture: `xcrun simctl io booted screenshot <out>/<screen>_<timestamp>.png`.
7. Verify PNG is non-trivial (>5 KB, valid header via `file`).
8. Print PR-markdown snippet (§7).

**Exit codes:** `0` ok · `1` invalid args / unknown screen · `2` simulator unavailable · `3` backend unreachable (only when `--no-backend` not set) · `4` app launch/crash · `5` navigation/settle timeout · `6` screenshot write failure. Failures are audible: `send_error_report` from `report_sink.sh` (Sosumi).

## 6. Screen registry

Per-feature YAML at `docs/features/<feature>/screens.yaml`, discovered by globbing `docs/features/*/screens.yaml`. The script reads the `name`, `deep_link`, `initial`, `needs_auth`, `needs_backend` fields. Adding a feature-doc chunk + UI-visible screen → add an entry here → `capture_screens.sh <name>` picks it up. No code change to the script.

```yaml
# docs/features/booking-calendar/screens.yaml
- name: schedule
  route: /schedule
  deep_link: khelam://schedule   # used when not the initial route
  initial: true                   # simctl launch lands here
  needs_auth: false               # /schedule is public
  needs_backend: false            # MockBookingService by default
```

## 7. PR integration

Screenshots are **not** committed (binary, regenerable — keeps the repo lean and the pre-commit gate fast). The script writes PNGs to a timestamped dir and prints a markdown snippet the caller pastes into the PR description; the user drags the PNGs from Finder into the PR (GitHub embed support) — zero upload deps.

```
---
## UI Screenshots — 2026-08-06 18:20 (iOS / iPhone 16 Pro Max)

![schedule](docs/screenshots/2026-08-06_18-20-00/schedule_2026-08-06_18-20-00.png)
> Drag the PNGs from Finder into this block to embed.
---
```

## 8. Sync strategy to forkable (decision 1)

| Artifact | Where it lives | Sync mechanics | Why here |
|---|---|---|---|
| `scripts/capture_screens.sh` | khelam `scripts/` | `scripts/sync_to_forkable.sh` mirrors `scripts/` → forkable (NEW, ~15-line rsync/cp). Triggered manually, part of the khelam→forkable migration batch. | Shell tooling stays in-app (per decision 1); no commons involvement. |
| `docs/features/*/screens.yaml` | khelam `docs/features/` | Same mirror script (`docs/features/`) → forkable. | Screen registry is feature-doc metadata, not shared code. |
| Shared **Dart** logic (future, e.g. URL-scheme routing helper) | `commons` package (versioned) | `commons` version bump → both apps `pub get` via git ref. | Only shared Dart goes to commons; shell scripts never do. |
| Design spec (this file) | khelam `docs/superpowers/specs/` | Mirror to forkable `docs/superpowers/specs/`. | Specs are doc artifacts, mirrored with the rest. |

**Current gap:** forkable has no `scripts/` dir today — the first sync run creates it. The mirror is one-directional (khelam → forkable), matching the "forkable is future source of truth" migration pattern (forkable `AGENTS.md` §3: copy khelam's setup at end of development).

## 9. Deviation from existing patterns

- **Goldens**: none exist in either app (no `matchesGoldenFile` usages found via grep). Goldens are CI regression (on-host rendering), this deliverable is PR review (iOS simulator). Explicit divergence — do not conflate.
- **`flutter-add-widget-preview` / `previews.dart`**: interactive in-app component previews for dev-cycle speed. Different surface (live in-app overlay). Not reused — this feature is for static PR artifacts only.
- **`scripts/`**: reuse the bash conventions (`set -euo pipefail`, `report_sink.sh` for audible failure, pre-commit gate pattern). `capture_screens.sh` is deliberately **excluded** from the pre-commit gate (it needs a running simulator; the gate runs analyze+test only).
- **Integration tests**: reuse the backend conventions (`API_BASE_URL`, demo phone `9800000001`/`khelam123`, turf `44444444-…`) for auth-required screens, but the script calls the same services the app does (not a parallel Dart service layer).

## 10. Deliverables (if executed)

| File | Purpose |
|---|---|
| `docs/superpowers/specs/2026-08-06-ui-screenshot-verification-design.md` | This design doc |
| `scripts/capture_screens.sh` | Primary capture script (new) |
| `scripts/sync_to_forkable.sh` | Lightweight khelam→forkable mirror for `scripts/` + `docs/features/` (new) |
| `docs/features/booking-calendar/screens.yaml` | Screen registry entry for `schedule` (new) |

**Batch breakdown (background-agent protocol):**
- **Batch 1 [L2]** — `capture_screens.sh` + `schedule` screens.yaml entry; acceptance = `bash -n` clean + dry-run resolving the screen.
- **Batch 2 [L1]** — End-to-end validation on booted iOS sim: `bash scripts/capture_screens.sh schedule --out /tmp/ss-test` → exit 0, PNG exists, `file` reports valid PNG >5 KB.
- **Batch 3 [L2]** — `sync_to_forkable.sh` + mirror verification; acceptance = forkable receives both files.

## 11. Acceptance bar

1. iOS simulator (iPhone 16 Pro Max, UDID `450FA9FA-…`) booted.
2. `bash scripts/capture_screens.sh schedule --out /tmp/ss-test` exits `0`.
3. `/tmp/ss-test/schedule_<timestamp>.png` exists, `file` reports `PNG image data` (1320×2868), size >5 KB.
4. Screenshots are of the schedule screen (date strip + turf header visible) — verified by sanity size + the initial-route invariant.

## 12. Open items

- **URL-scheme registration**: to reach non-initial routes via `simctl openurl`, `Info.plist` + `go_router` deep-link config must be added (one-time Dart/iOS change; not in this design's scope, tracked for when trigger expands beyond `schedule`).
- **CI hook**: a non-blocking CI job that captures on PRs is deferred — the primary path is local/scripted, run by the agent before PR closeout.
- **Cost estimate**: implementation ≈ 3 k tokens writing scripts + 4 k tokens CLI validation (free tier, $0).
