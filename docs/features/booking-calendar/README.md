# Feature: Booking Calendar

> Declared feature doc — migrated from `docs/prd/booking-calendar-feature.md` (2026-08-06). Session Objective convention when working here: `Feature: docs/features/booking-calendar/README.md — <task>`.

## Problem Statement

Turf owners and operators need a visual schedule to view and manage bookings across their facilities. Currently, there is no calendar interface to see available slots, booked slots, and key metrics for a given day. Operators must rely on external tools or manual tracking, leading to double-bookings and revenue leakage.

## Scope

**In:**
- Read-only calendar screen: 7-day date strip, turf header, hourly timeline (07:00–22:00) with booked/available slot cards, daily stats (booking count, revenue)
- Mock service for data; clean reusable UI component library for future booking workflows
- Loads on app launch without login (demo path)
- Real API integration: `BookingApiService` via commons `DioApiClient`, opt-in through `API_BASE_URL` in `.env` (mock stays default) — shipped 2026-08-05
- Booking guard: guests tapping slots route through login and back — shipped 2026-08-05 (`0544514`)

**Out:** create/edit/cancel booking flows; payment processing; slot-locking UI; multi-turf switcher; bottom-nav shell; persistence/offline.

## User Stories

1. As a **turf operator**, I want to view a horizontal date strip for the next 7 days, so that I can quickly navigate to any day's schedule.
2. …today's date visually highlighted in the date strip, so that I can instantly orient myself.
3. …the turf name and address at the top of the schedule, so that I know which facility I'm viewing.
4. …an hourly timeline 7:00 AM–10:00 PM, so that I can view the full day's schedule at a glance.
5. …each hourly row with a time label on the left, so that I can quickly identify the slot's start time.
6. …a decorative vertical rail with hour markers, so that the timeline feels structured and scannable.
7. …booked slots as filled green cards (customer/team name, "Confirmed" badge, chevron), so that I can identify confirmed bookings instantly.
8. …available slots as dashed-outline cards ("+ Available"), so that I can see openings at a glance.
9. …tap a booked slot card (stub callback), so that future workflows can navigate to booking details.
10. …tap an available slot card (stub callback), so that future workflows can initiate a new booking.
11. …a "Today's Stats" section (booking count + total revenue for selected date), so that I can track daily performance without leaving the screen.
12. …stats updating automatically on date change, so that I always see relevant metrics.
13. …loading and error states handled gracefully, so that the app feels robust with slow/failing mock data.
14. …the schedule loading on app launch without login, so that I can demo the feature immediately.
15. As a **developer**, I want the feature built as a self-contained slice (Cubit → Service → Mock/API) with freezed domain models, so that it follows the project's clean architecture and is easy to extend.

## Architecture Decisions

| # | Decision | Detail |
|---|----------|--------|
| ADR-0001/2/3 | Pattern | Cubit → Service → Mock/API (pass-through repositories dropped 2026-08-05) |
| ADR-0004 | Module slice | Self-contained under `lib/features/booking/` — own `di/`, `bloc/`, `data/`, `views/` |
| — | State | `flutter_bloc` Cubit, immutable state classes (manual `copyWith`, no freezed for state) |
| — | Navigation | `go_router`, `/schedule` initial route, public; booking guard routes guests through login and back (`0544514`) |
| — | Data | Default `MockBookingService` (fresh clones, widget tests); real `BookingApiService` (commons `DioApiClient`) when `API_BASE_URL` set and `USE_MOCK_BOOKING != true`; mock = single turf "Turf A" (Sector 12, Sports Complex), 7-day rolling window, 15 slots/day 07:00–22:00, ~50% booked, rotating pool of 5 team names, deterministic seeded hash |
| — | DI/Routing | `BookingDependencies.register(GetIt)`; `AppRoutes.schedulePath = '/schedule'`; `/login` + `/schedule` public, booking + home require auth |
| — | Theme | `AppPalette` seeds + `AppComponentThemes`; no hardcoded colors; `surfaceContainerLow` cards |
| — | Null safety | Strict: no `!`; `if case final x? = y` and `??` throughout |

### Domain models (freezed)

| Model | Key Fields |
|-------|------------|
| `SlotStatus` enum | `available`, `booked`, `locked`, `unavailable` |
| `BookingStatus` enum | `pending`, `confirmed`, `cancelled`, `completed` |
| `Slot` | `id`, `turfId`, `slotDate`, `startTime`, `endTime`, `status`, `lockedBy?`, `lockedAt?` |
| `Booking` | `id`, `bookingCode`, `userId`, `turfId`, `slotId`, `totalAmount`, `advanceAmount`, `remainingAmount`, `status` |
| `TurfSummary` | `id`, `name`, `address?` |
| `ScheduleSlotItem` | `slot` + `booking?` + `customerName?` (presentation join) |

## Implementation Plan

- [x] Domain models (freezed): `SlotStatus`, `BookingStatus`, `Slot`, `Booking`, `TurfSummary`, `ScheduleSlotItem`
- [x] Services: `BookingService` interface (`getTurf`, `getSchedule`), `MockBookingService` (seeded hash)
- [x] `BookingRepository` thin pass-through
- [x] `ScheduleCubit` (state, load flow, date switching, day-stats computation) + 6 cubit tests
- [x] DI: `ScheduleDependencies.register(GetIt)`; `AppRoutes.schedule`/`schedulePath`
- [x] Routing: initial `/schedule`, public path allowed
- [x] `DateStrip` (7 `DateChip`s, today highlight, selected state)
- [x] `TurfHeader` (turf summary + "All Day" chip)
- [x] `BookingTimeline` (ListBody of rows: `TimelineHourLabel` 64px, `TimelineRail`, `BookedSlotCard`/`AvailableSlotCard`)
- [x] `DayStatsSection` (2 `StatCard`s: bookings, revenue)
- [x] Common widgets → `lib/ui/common/`: `StatCard`, `SectionHeader`, `StatusBadge` (roster now 19 widgets)
- [x] Loading/error states (switching dates, mock failures)
- [x] Widget tests: `BookedSlotCard` (4), `AvailableSlotCard` (2)
- [x] Real API integration: `BookingApiService` + DI opt-in (`API_BASE_URL` / `USE_MOCK_BOOKING`) (2026-08-05)
- [x] Booking guard: guest slot tap → login → return (`0544514`, 2026-08-05)

## Test Plan

- **Principle**: external behavior only (state transitions, UI rendering, interactions); no private internals.
- **Cubit tests**: `FakeBookingRepository` controls success/error; construct → `await cubit.load()` → assert state (`slots isNotEmpty`, `dayStats.bookingCount == 1`).
- **Widget tests**: `pumpWidget(MaterialApp(...))` → `find.text()` / `tap()` → assert.
- **Current status**: 12 tests (6 cubit + 6 widget), all green.

## Progress Tracker

- [x] Sliced implementation committed (2026-07-28 design → implementation in khelam)
- [x] Migrated PRD → this feature README (2026-08-06)
- [x] Real API + booking guard shipped (2026-08-05); Out-of-scope list refreshed (2026-08-07)

## Backlinks

- Design spec: `docs/superpowers/specs/2026-07-28-booking-bottom-sheet-design.md`
- Old PRD location: `docs/prd/booking-calendar-feature.md` (redirect note left)
- Backlog: `docs/backlog.md`
