# Design — Task/Ticket Breakdown Dashboard (v0, initial)

> Date: 2026-08-06. Status: PROPOSED — awaiting approval. Spec lives at `docs/superpowers/specs/` (not a declared feature; matches the 2026-08-06 screenshot-verification precedent). Implementation target once approved: `lib/features/dashboard/` + a macOS run target.

## 1. Purpose

A personal, macOS-only decision-support dashboard over the project's *existing* markdown memory (Open Actions, backlog, day-plan batches, learnings). It is a **read-only mirror** — markdown stays the source of truth. The board is a three-column kanban per the user's locked UI spec; a local isar DB caches the parsed artifacts so the user can scan state, spot blockers, and step through an in-progress execution batch without re-reading half a dozen files.

## 2. Locked decisions (user, 2026-08-06)

| # | Decision | Constraint |
|---|----------|------------|
| 1 | Form factor | Flutter (house growth path), macOS surface |
| 2 | Layout | Row of Expanded, each a ListView of Cards (todo / in-progress / done) |
| 3 | In-progress card | step counter ("Step 2/5") + `LinearProgressIndicator` |
| 4 | Done card | subtle opacity dip + completed timestamp |
| 5 | Status marker | `Container`+`BoxDecoration` circle, no icon assets; colors red=blocked, amber=in-progress, green=done, gray=todo |
| 6 | Storage | local DB (hive/isar), user's choice of shape, free-tier cost preserved |

## 3. App form factor & location (options evaluated)

| Option | How | Pros | Cons | Verdict |
|---|---|---|---|---|
| (a) separate Flutter repo | new `khelam-dashboard/` repo | total separation from mobile app | new repo + commons re-wire + new DI; heaviest; violates "no new infra" | REJECTED |
| (b) feature slice inside khelam | `lib/features/dashboard/` | reuses theme, commons, DI, test infra | must platform-gate so it never builds into iOS/Android | ACCEPTED (see below) |
| (c) macOS run target only | `flutter run -d macos` | khelam's macos target already builds (committed fix `f108c0f`) | needs a route that never appears on mobile | ACCEPTED — hybrid with (b) |

**Decision — (b)+(c) hybrid, one app.** New slice `lib/features/dashboard/` (ADR-0004 layout: `bloc/`, `data/`, `models/`, `views/`, `widgets/`), behind a macOS-only route guard (`assert(defaultTargetPlatform == TargetPlatform.macOS)` + a `go_router` route `/dashboard` not registered on mobile shells). Run with `flutter run -d macos`. Rationale: zero new infra/CI/repos, reuses the existing macOS target the user already fixed, keeps Flutter as the growth surface, and the dashboard never ships to iOS/Android binaries because the route is unreachable on mobile. **Note:** the booking-calendar README lists the slice path as `lib/ui/features/schedule/` but the *actual* ADR-0004 layout is `lib/features/<name>/` (auth, booking, home, theme_preview) — the design follows the real layout.

## 4. Storage: Hive vs Isar (options evaluated)

| | Hive | Isar |
|---|---|---|
| Pub latest stable | `hive 2.2.3` (Jun 2022) | `isar 3.1.0+1` |
| Platforms | Android/iOS/Linux/macOS/web/Windows | Android/iOS/Linux/macOS/web/Windows |
| Native deps | none (pure Dart: `crypto, meta`) | `isar_flutter_libs` (native core via ffi) |
| Codegen | optional (`hive_generator`) — Map boxes need none | **required** (`isar_generator` + `build_runner`) |
| Dart 3.8 fit | **BLOCKED** — 2.2.3 predates Dart 3; issue #1334 reports "Hive generator incompatible with Dart 3.7+". Only `4.0.0-dev.2` (prerelease) resolves on Dart 3.x | Dart 3.x compatible, actively maintained |
| Maintenance | README now says "If you need queries → check out Isar"; issues #1331/#1339/#1340 ask to deprecate | active (4.0.0-dev.14) |

**Decision — Isar primary.** Hive stable cannot resolve against khelam's `sdk: ^3.8.0`; the only Hive that does is a dev prerelease on a project signaling deprecation. Isar's latest stable supports Dart 3.x + macOS and is the maintained path. Codegen is a one-time local `dart run build_runner build` (no network, no model calls → no token cost). The extra native binary is acceptable for a macOS-debug-only personal tool. Lighter fallback: Hive `4.0.0-dev.2` Map boxes (zero codegen) if the prerelease risk is acceptable — documented as the "if you want zero-codegen" escape hatch.

## 5. Entity model — `Ticket`

Single entity (keeps the board schema-flat). Stored in one isar collection; no joins.

| Field | Type | Source |
|---|---|---|
| `id` | String | derived (§6) |
| `title` | String | Open Action / backlog bullet / batch step / learning |
| `type` | enum `openAction\|backlogItem\|dayPlan\|learning` | row origin |
| `status` | enum `todo\|inProgress\|done` | maps to column |
| `isBlocked` | bool | red dot (see §8) |
| `priority` | enum `p0\|p1\|p2\|p3` | severity / urgency / backlog priority |
| `sourcePath` | String | `file:LiN` (tap → reveal in Finder) |
| `estTokens`, `actualTokens` | int? | day-plan batch line; OA screenshot-verify ~7k |
| `stepIndex`, `stepCount` | int? | `current_batch` / batch-log count (in-progress day-plan) |
| `progress` | double 0..1 | stepIndex/stepCount; 1.0 done / 0.0 todo |
| `trust` | String? | "L1\|L2\|L3" (day-plan) |
| `scope` | String? | "clean\|dirty" (day-plan) |
| `createdAt`,`updatedAt` | DateTime | file mtime |
| `completedAt` | DateTime? | done-card timestamp |
| `deferralCount` | int | "(Review: …, add #N)" count; external gate max 2 |
| `notes` | String? | deferral history line / full body excerpt |

## 6. Artifact → entity mapping

| Markdown artifact | Ticket type | id pattern | status @2026-08-06 |
|---|---|---|---|
| review-memory.md Open Actions §6.1–6.6 (lines 61–66) | `openAction` | `oa-N` (N=1..6) | all `todo`; OA#5 `isBlocked=true` (pending user decision) |
| backlog.md bullets (8 items; 3 marked DONE 2026-08-01) | `backlogItem` | `bl-<slug>` | 3 DONE→`done`(completed 08-01); C5 drift/revenue/home/auth/turfs/screenshot/watchpoint/nav → `todo` |
| `*-status.md` (`current_batch=N` + batch log) | `dayPlan` | `dp-<YYYY-MM-DD>` | 2026-08-06 → `done` (batch 7 ALL DONE) |
| session file §4 LEARNINGS table (lines 148–158, 9 rows) | `learning` | `learn-N` | `todo` (new); urgency→priority (1=p1…3=p3) |

Active execution detection (drives in-progress): a status file whose `current_batch=N` line is *not* `ALL DONE` AND whose last batch-log entry is `status=done` with `batch < N` → ticket `status=inProgress`, `stepIndex=current_batch`, `stepCount=batch-log rows`. At the 2026-08-06 snapshot the day-plan is complete → in-progress column is empty (renders a "no active execution" placeholder).

## 7. Ingestion/sync — manifest bridge

The DB is Flutter-native; a bash/python script cannot author isar binaries safely. House style = bash+python3 for parsing logic (cf. `ccusage_collect.sh`). → **bridge pattern**: script writes a JSON manifest; the app imports it.

```
docs/reviews/review-memory.md ─┐
docs/backlog.md               ├─→ scripts/sync_tasks.sh ──→ lib/features/dashboard/data/task_manifest.json ──import──▶ isar Ticket box
docs/sessions/*-status.md     │    (bash: grep/parse; python3: emit canonical JSON; idempotent)
docs/sessions/<date>.md §4    ┘
```

- **Idempotent**: `sync_tasks.sh` re-emits the same manifest on re-run; the app upserts by `id` (delete-then-rewrite the box if manifest mtime is newer than last import).
- **Staleness**: app reimports on launch when `task_manifest.json` mtime > imported-at; a manual "Refresh" button always reimports.
- **No continuous watcher** (cheap): the script is run on demand by the user OR optionally wrapped by the existing `weekly_review.sh` cadence (V2). `bash -n` + `python3 -m json.tool` smoke on every run.
- **One-way**: the manifest is the only write target of the script; the app never writes markdown; drag-to-column reorders are local-only (see §9).

## 8. UI structure (user spec locked; fleshed)

- **Column header** = status dot (`Container` 10×10, `BoxDecoration` circle) + name + count badge. Dot color per §5; `isBlocked` overrides any column to **red**.
- **Todo card**: title + priority pill + source path line (small). 
- **In-progress card** (day-plan ticket): title + trust badge ("L2") + **"Step 3/7"** + `LinearProgressIndicator(value: 3/7)` + est/actual tokens row ("est 3500 → actual 4500") when present.
- **Done card**: opacity `0.6` + `completedAt` timestamp line + progress 100%.
- **Tap card** → Material `showModalBottomSheet` (macOS: constrained width): full `notes`, `sourcePath` (tap → `dart:io` `Process.run('open', [dir])` reveal in Finder — no new dep), `est/actualTokens`, `trust`/`scope`, `deferralCount`.
- **State**: `DashboardCubit extends Cubit<DashboardState>` holding `List<Ticket>` + `isLoading` (matches khelam's `flutter_bloc` Cubit convention, ADR-0004; not Riverpod, not bare setState). Single `DashboardState` value class.

## 9. One-way sync policy (explicit)

The dashboard is a **decision-support mirror only**. The markdown files are the single source of truth (per `management-strategy.md` Ch. 4 "source of truth" + the external-audit gate). **Nothing the user does in the dashboard writes back to markdown** — reordering, blocking flags, or notes are local scratch and discard on reimport. This is deliberate: the external-audit gate (user signs every Open Action) must remain anchored to `review-memory.md`, never to a local reorder. One `localNote` field is permitted on the Ticket for in-session scratch only.

## 10. Token-cost preservation (user-raised)

- **No network**: isar local only; `sync_tasks.sh` reads local files; no HTTP, no `ccusage` calls, no `opencode.db` writes.
- **No analytics writes**: `~/analytics/`, `performance-summary.md`, `update-log.md`, `opencode.db` are untouched. The dashboard reads `docs/sessions/*-status.md` (per-batch cost) for the in-progress token row — it does **not** re-derive analytics.
- **Idempotent + cheap**: re-running the script + app reimport is a no-op when nothing changed.
- **Codegen is local**: `dart run build_runner build` for isar_generator — a build step, zero model calls.
- **No CI / no launchd additions** (V2 only): run via `flutter run -d macos` + `bash scripts/sync_tasks.sh`.
- **Expected implementation cost**: §12 estimates ~12–20k tokens across B1–B3, all free-tier ($0) — consistent with `performance-summary.md` Week 1 (167.5M tokens, $0). The dashboard must not regress that $0 discipline.

## 11. Deliverables (files)

| File | Purpose |
|---|---|
| `docs/superpowers/specs/2026-08-06-task-dashboard-design.md` | this spec |
| `lib/features/dashboard/models/ticket.dart` | isar `@collection` Ticket + enums |
| `lib/features/dashboard/models/ticket.g.dart` | generated (build_runner) |
| `lib/features/dashboard/bloc/dashboard_cubit.dart` | loads manifest → isar → emits `List<Ticket>` |
| `lib/features/dashboard/views/dashboard_view.dart` | 3-column board |
| `lib/features/dashboard/widgets/task_card.dart` | card + status dot + opacity + progress |
| `lib/features/dashboard/data/manifest_repository.dart` | reads `task_manifest.json` + upserts isar |
| `scripts/sync_tasks.sh` | parses markdown → JSON manifest (idempotent) |
| `docs/features/dashboard/README.md` | feature doc (V2, after feature is real) |

## 12. Batch breakdown (background-agent protocol)

- **Batch 1 [L2] — Storage + sync**: add `isar`/`isar_flutter_libs`/`isar_generator` to `pubspec.yaml`; write `ticket.dart` + run codegen; write `sync_tasks.sh`; smoke: script parses review-memory → `task_manifest.json` with ≥6 open-action rows, `python3 -m json.tool` valid. Acceptance: `bash -n` clean; manifest valid; `dart run build_runner build` succeeds. Est ~6k tokens.
- **Batch 2 [L1] — Board UI**: `DashboardCubit` + `dashboard_view.dart` (Row/Expanded/ListView/Cards), step counter + `LinearProgressIndicator`, done opacity+timestamp, status dots, macOS route guard. Acceptance: `flutter analyze` clean; `flutter run -d macos` shows 3 columns with real Open Actions; in-progress card renders "Step X/N"+bar when a status file is active; done card shows opacity+timestamp. Est ~10k tokens.
- **Batch 3 [L2] — Detail + import**: card tap → bottom sheet (deferral history, notes, source path "reveal in Finder"; reimport-on-launch + Refresh button; idempotent). Acceptance: sheet shows OA#1 deferral history; reveal opens `review-memory.md` at the action; re-run script + relaunch → no duplicates. Est ~4k tokens.

## 13. Acceptance bar

1. `bash scripts/sync_tasks.sh` exits 0 and writes `lib/features/dashboard/data/task_manifest.json`.
2. Manifest contains ≥6 `oa-1..6` tickets + ≥3 DONE backlog tickets + the `dp-2026-08-06` day-plan ticket + 9 `learn-N` tickets.
3. `dart run build_runner build` succeeds; `flutter analyze` clean.
4. `flutter run -d macos` renders exactly three columns (Todo / In-Progress / Done) with real Open Actions.
5. In-progress day-plan card shows "Step N/M" + `LinearProgressIndicator`; done `dp-2026-08-06` card shows opacity dip + `completedAt` timestamp.
6. Tapping OA#1 card → bottom sheet shows deferral line + sourcePath; tapping sourcePath reveals `docs/reviews/review-memory.md` in Finder.
7. Re-running `sync_tasks.sh` + relaunching the app yields no duplicate rows (idempotent).

## 14. Deferred scope (V2)

- Optional `launchd` job (mirror `com.khelam.weekly-review.plist`) to run `sync_tasks.sh` on a cadence — keep out until proven needed (no new infra per constraint).
- Hive `4.0.0-dev.2` Map-box mode as a codegen-free alternative if isar native-libs prove troublesome on macOS.
- `docs/features/dashboard/README.md` migration to the declared-feature model (once the feature is real) + the Session Objective convention `Feature: docs/features/dashboard/README.md — <task>` for collector attribution.
- Gold/screenshot pipeline not needed — macOS screenshots of the board go straight into the PR description (reuse §6 of the screenshot-verification spec).

## 15. Open questions (for the external gate)

1. **Is isar's native-libs + codegen acceptable** vs the Hive `4.0.0-dev.2` Map-box zero-codegen path? (Recommendation: isar — supported; Hive-dev only as escape hatch.)
2. **macOS route guard strength** — OK to gate with a debug-only `assert(defaultTargetPlatform == TargetPlatform.macOS)` + route not registered on mobile, or do you want `dart:io` `Platform.isMacOS` compile-time exclusion from mobile flavors?
3. **Reimport cadence** — manual Refresh only, or also auto-reimport-on-launch when manifest is newer? (Lean: auto-on-launch, no launchd.)
