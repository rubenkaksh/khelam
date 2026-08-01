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
- **forkable DI modernization** — forkable still runs pre-ADR-0004 layered architecture: `lib/di/data_dependencies.dart`, `lib/data/services/*` (5 services incl. BASE-LEGACY `sample_api_service`, `template_catalog_service`, `local_sample_storage_service`, `mock_auth_service`), repositories, `lib/domain/`. Adopt ADR-0004 feature modules, then delete the BASE-LEGACY services.
- **Navigation slice (low priority)** — `app_router.dart` + `app_routes.dart` stay in each fork (decision 2026-08-01); revisit only if a shared router skeleton is ever wanted.
