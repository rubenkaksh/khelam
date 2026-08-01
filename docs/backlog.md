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
