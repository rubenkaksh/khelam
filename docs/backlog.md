# Backlog

Work items not yet scheduled into a plan. Each entry links its source (review/session). When an item is picked up, move it into a plan under `docs/superpowers/plans/` and close it out here.

## From the 2026-08-01 architecture review (`601ec7b`)

- **[C5] BookingService adapter drift** — three owners of turf identity: mock ignores the requested `turfId` (returns `turf-a`), API `getTurf` returns hardcoded strings with no HTTP call, cubit hardcodes dev turf id `44444444-4444-4444-4444-444444444441`. Also decide the fate of `ScheduleSlotItem.booking` (filled by mock, always null via API; `customerName` overlaps). Fix: mock honors requested id, API `getTurf` calls a real endpoint once it exists, one place owns turf identity.
- **Revenue stat is ₹0 in API mode** — `DayStats.revenue` sums `item.booking?.totalAmount`, but the slots list endpoint returns no booking object. Backend must include booking details (or amounts) on list slots before the revenue card is meaningful.
- **Real home experience** — `lib/features/home/views/home_view.dart` is a placeholder (welcome + schedule link). Design the actual post-login home.

## From the 2026-07-31 session

- **Real auth/JWT wiring** — `POST /slots/:id/book` returns 401 until a bearer token is sent via `DioApiClient.setBearerToken`. Unlocks booking against the real backend.
- **Turfs endpoint (backend)** — `GET /turfs/:id` does not exist yet; `BookingApiService.getTurf` returns hardcoded dummy data until it does.

## Watchpoints (not scheduled)

- **Theme monolith** (`lib/ui/core/theme/app_component_themes.dart`, from the 2026-06-22 review) — if `build()` exceeds ~600 lines or feature-specific theme variants appear, split into per-group builders and keep feature variants at the feature level.

## Commons package follow-ups (from the 2026-08-01 commons migration)

- **[Slice 2] DONE 2026-08-01** — `DioApiClient` migrated to commons v0.2.0 (`lib/src/network/dio_api_client.dart`, barrel export, dio ^5.9.2 dep, 6 tests moved). khelam rewired to barrel, `lib/core/network/` deleted; forkable rewired `data_dependencies.dart` + kept its 2 dio tests against commons, old copy deleted. Both consumers at `ref: v0.2.0`.
- **[Slice 3] DONE 2026-08-01** — theme infrastructure migrated to commons v0.3.0 (`lib/src/theme/`): palette-agnostic `ComponentThemes.build()` (monolith split into 9 per-group builder files under `lib/src/theme/groups/`; `lightColorScheme()`/`darkColorScheme()` removed from commons), `AppTypography` moved as-is. **Identity stays per project**: `AppPalette` + `AppTheme` composition (now building its own `ColorScheme.fromSeed` from local brand seeds) remain in khelam and forkable. Both consumers at `ref: v0.3.0`.
- **[forkable DI modernization] DONE 2026-08-01** — forkable `692dfc8 refactor: collapse forkable into feature modules (ADR-0004)`: mirrors khelam's target shape (`lib/features/{auth,home,theme_preview}` own their slice, `AuthService` interface + `MockAuthService`, `AuthCubit(service:)`, per-route cubits via router factories, home = placeholder). Deleted `lib/data/`, `lib/domain/`, `lib/features/presentation/`, `lib/di/{app,data}_dependencies.dart` — including all BASE-LEGACY services (template/sample/pagination chains) — and their tests. Kept `AuthUser` freezed trio, the 2 commons dio tests, and the demo-login flow. Branch note: committed on forkable's `test/aider` branch. Verify: analyze clean, 5/5 tests, debug APK builds.
- **Navigation slice (low priority)** — `app_router.dart` + `app_routes.dart` stay in each fork (decision 2026-08-01); revisit only if a shared router skeleton is ever wanted.

## Note (2026-08-06)
- `docs/superpowers/specs/` + `docs/superpowers/plans/` stay as-is — not declared features (no feature READMEs yet). Declared-feature model: `docs/features/<name>/README.md`; booking-calendar is the first (migrated from `docs/prd/`).

## From the 2026-08-06 session

- **UI screenshot verification** — when making any UI-affecting feature (major changes), run on the simulator/emulator and capture screenshots as part of the acceptance bar. Idea: a separate package/script (`khelam_screenshot_verify` or similar) that boots the app, navigates the flow, and saves screenshots to a timestamped dir for the review/closeout. Open questions before scheduling: (a) standalone package vs script inside khelam, (b) which UI flows are the canonical capture set, (c) whether screenshots gate the commit or just attach to the report, (d) iOS simulator + Android emulator both, or one first.

## From the 2026-08-07 session

- **Task dashboard — PARKED (user 2026-08-07, defer-with-date)** — design stays locked at `docs/superpowers/specs/2026-08-06-task-dashboard-design.md` (standalone Flutter + Supabase queue, est ~28–34k). User: "park at backlog for a while, decide if we really need it" — hypothesis: Discord-comms may cover the need. **Revisit at the 2026-08-16 review** (or sooner if Discord-comms ships): DROP if the channel covers the review surface, else re-estimate + re-schedule.
- **Comms → Discord — IMPLEMENTED (2026-08-07)**: v1 single-webhook delivery shipped forkable-first (forkable `f771d0c`, khelam `b815d6c`) + v2 multi-channel cross-project hub locked via Grill Gate (12/12 answers + Q3b; forkable `1e4c942`, khelam `e0f59bf` + spec v2 `8cab2a4`). Channels: `#daily-overview` (new `daily_digest.sh` @ 08:00 Mon–Fri, launchd template `com.khelam.daily-digest.plist`), `#weekly-reviews`, `#screenshots`, `#agent-errors`; shared env `~/.config/opencode/discord.env` (v1 alias `DISCORD_WEBHOOK_URL` kept). **GO-LIVE STEPS — PARKED (user 2026-08-07, on hold)**: (1) create `~/.config/opencode/discord.env` with `DISCORD_WEBHOOK_URL` + `DAILY_OVERVIEW_WEBHOOK_URL`/`WEEKLY_REVIEWS_WEBHOOK_URL`/`SCREENSHOTS_WEBHOOK_URL`/`AGENT_ERRORS_WEBHOOK_URL`; (2) install digest job: `cp scripts/com.khelam.daily-digest.plist ~/Library/LaunchAgents/` + `launchctl load`; (3) live E2E (digest post, weekly report, screenshot → #screenshots, forced error → #agent-errors); (4) optional: forkable weekly-review arm (plist instance, rename). Resume when the user wants to go live; after go-live, the task-dashboard PARKED item above gets its 2026-08-16 decision — DROP if the channels cover the review surface, else re-estimate.

## From the 2026-08-07 turf-selection implementation (second pass)

- **Auth-sync debt (design decision #11)** — khelam's auth outgrew forkable: `AuthTokenStore` + secure storage (`flutter_secure_storage`) exist only in khelam; forkable's `lib/features/auth/data/` has just `mock_auth_service.dart`. `AuthCubit` now also clears `Preferences` on logout (khelam-only). Future sync pass (when auth lands forkable-first): forkable gains `AuthTokenStore`, khelam's `Preferences`/`StoreService` already pulled.
- **[C5] BookingService adapter drift — MOSTLY CLOSED 2026-08-07**: mock `getTurf` now honors the requested id (echoes it, maps Turf A/B names) and the cubit's hardcoded dev turf id is DELETED (id comes from the turf-selection route). Remaining: `BookingApiService.getTurf` still hardcoded until the backend `GET /turfs/:id` exists (see "Turfs endpoint (backend)").
