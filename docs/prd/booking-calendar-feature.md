# PRD: Booking Calendar Feature

## Problem Statement

Turf owners and operators need a visual schedule to view and manage bookings across their facilities. Currently, there is no calendar interface to see available slots, booked slots, and key metrics for a given day. Operators must rely on external tools or manual tracking, leading to double-bookings and revenue leakage.

## Solution

A read-only calendar screen showing a 7-day date strip, turf header, hourly timeline with booked/available slot cards, and daily stats (booking count, revenue). The feature uses a mock service for data and provides a clean, reusable UI component library for future booking workflows.

## User Stories

1. As a **turf operator**, I want to view a horizontal date strip for the next 7 days, so that I can quickly navigate to any day's schedule.
2. As a **turf operator**, I want today's date to be visually highlighted in the date strip, so that I can instantly orient myself.
3. As a **turf operator**, I want to see the turf name and address at the top of the schedule, so that I know which facility I'm viewing.
4. As a **turf operator**, I want to see an hourly timeline from 7:00 AM to 10:00 PM, so that I can view the full day's schedule at a glance.
5. As a **turf operator**, I want each hourly row to show a time label on the left, so that I can quickly identify the slot's start time.
6. As a **turf operator**, I want a decorative vertical rail with hour markers, so that the timeline feels structured and scannable.
7. As a **turf operator**, I want booked slots to display as filled green cards with the customer/team name, a "Confirmed" badge, and a chevron, so that I can identify confirmed bookings instantly.
8. As a **turf operator**, I want available slots to display as dashed-outline cards with a "+ Available" label, so that I can see openings at a glance.
9. As a **turf operator**, I want to tap a booked slot card (stub callback), so that future workflows can navigate to booking details.
10. As a **turf operator**, I want to tap an available slot card (stub callback), so that future workflows can initiate a new booking.
11. As a **turf operator**, I want a "Today's Stats" section showing booking count and total revenue for the selected date, so that I can track daily performance without leaving the screen.
12. As a **turf operator**, I want the stats to update automatically when I change the selected date, so that I always see relevant metrics.
13. As a **turf operator**, I want loading and error states handled gracefully, so that the app feels robust even with slow or failing mock data.
14. As a **turf operator**, I want the schedule to load on app launch without requiring login, so that I can demo the feature immediately.
15. As a **developer**, I want the feature built as a self-contained slice (Cubit → Repository → Mock Service) with freezed domain models, so that it follows the project's clean architecture and is easy to extend.

## Implementation Decisions

### Architecture
- **Pattern**: Cubit → Repository → Mock Service (following ADR-0001, ADR-0002, ADR-0003)
- **Feature slice**: Self-contained under `lib/ui/features/schedule/` with its own DI, bloc, views, widgets
- **State management**: `flutter_bloc` Cubit with immutable state classes (manual `copyWith`, no freezed for state)
- **Navigation**: `go_router` with `/schedule` as initial route (public, no auth guard)

### Domain Models (freezed)
| Model | Key Fields |
|-------|------------|
| `SlotStatus` enum | `available`, `booked`, `locked`, `unavailable` |
| `BookingStatus` enum | `pending`, `confirmed`, `cancelled`, `completed` |
| `Slot` | `id`, `turfId`, `slotDate`, `startTime`, `endTime`, `status`, `lockedBy?`, `lockedAt?` |
| `Booking` | `id`, `bookingCode`, `userId`, `turfId`, `slotId`, `totalAmount`, `advanceAmount`, `remainingAmount`, `status` |
| `TurfSummary` | `id`, `name`, `address?` |
| `ScheduleSlotItem` | `slot` + `booking?` + `customerName?` (presentation join) |

### Mock Data Strategy
- Single turf: "Turf A" (Sector 12, Sports Complex)
- 7-day rolling window (today + 6 days)
- Hourly slots 07:00–22:00 (15 slots/day)
- ~50% booked with fake `Booking` + `customerName` (rotating pool of 5 team names)
- Slot status consistent with booking presence

### Services & Repository
- `BookingService` (interface): `getTurf(turfId)`, `getSchedule(turfId, date)`
- `MockBookingService`: deterministic fake data via seeded hash
- `BookingRepository`: thin pass-through

### DI & Routing
- `ScheduleDependencies.register(GetIt)` registers service, repository, factory Cubit
- `AppRoutes.schedule` = `'schedule'`, `AppRoutes.schedulePath` = `'/schedule'`
- `AppRouter`: initial location = `/schedule`; auth guard allows `/login` and `/schedule` public

### UI Composition
```
Scaffold
  AppBar("Schedule")
  CustomScrollView
    SliverToBoxAdapter: DateStrip (7 DateChips)
    SliverToBoxAdapter: TurfHeader (TurfSummary + "All Day" chip)
    SliverToBoxAdapter: loading indicator (when switching dates)
    SliverToBoxAdapter: BookingTimeline (ListBody of rows)
    SliverToBoxAdapter: DayStatsSection (2 StatCards)
```
- `DateStrip`: horizontal ListView of `DateChip` (selected + today highlight)
- `BookingTimeline`: `ListBody` (not `ListView` — avoids nested scroll) of rows:
  - `TimelineHourLabel` (64px fixed width)
  - `TimelineRail` (dot + vertical line)
  - `BookedSlotCard` | `AvailableSlotCard`
- `DayStatsSection`: `SectionHeader` + Row of 2 `StatCard`s (bookings, revenue)

### Reusable Common Widgets (added to `lib/ui/common/`)
| Widget | Props |
|--------|-------|
| `StatCard` | `icon`, `label`, `value`, `valueColor?` |
| `SectionHeader` | `title`, `leadingIcon?`, `onTap?` |
| `StatusBadge` | `label`, `icon?`, `tone` (primary/success/warning/neutral) |
- Added to `docs/commons.md` roster (total 19 widgets)

### Theme
- Uses `AppPalette` seeds + `AppComponentThemes` — no hardcoded colors
- Cards: `surfaceContainerLow` with `primary`/`secondary` accents
- Badges: semantic container colors (`secondaryContainer` for success, etc.)

### Null Safety
- Strict: no `!` operator. Used `if case final x? = y` and `??` throughout.

## Testing Decisions

### What Makes a Good Test
- Test **external behavior**: state transitions, UI rendering, user interactions
- Avoid testing private methods, internal state fields, or implementation details
- Prefer widget tests for UI, cubit tests for state logic

### Modules Tested
| Module | Test Type | Count |
|--------|-----------|-------|
| `ScheduleCubit` | Cubit (unit) | 6 |
| `BookedSlotCard` | Widget | 4 |
| `AvailableSlotCard` | Widget | 2 |

### Test Patterns (Prior Art)
- **Fake repository**: `FakeBookingRepository` implements interface, controls success/error
- **Cubit tests**: `setUp` fake repo → construct cubit → `await cubit.load()` → assert state
- **Widget tests**: `pumpWidget(MaterialApp(...))` → `find.text()` / `tap()` → assert
- **State assertions**: `expect(cubit.state.slots, isNotEmpty)`, `expect(cubit.state.dayStats.bookingCount, 1)`

## Out of Scope

- Create/edit/cancel booking flows
- Payment processing
- Slot locking UI (`locked_by` / `locked_at` stored on model but not surfaced)
- Multi-turf switcher (header shows single turf only)
- Bottom navigation shell (Dashboard/Bookings/Turfs/More)
- Real API integration
- Authentication guard on schedule route (intentionally public for demo)
- Persistence / offline support

## Further Notes

- The `ScheduleView` uses `CustomScrollView` → refactored to `ListView` to avoid nested-scroll semantics issues in tests.
- `TimelineRail` originally used `Expanded` which failed layout in unbounded-height contexts; replaced with fixed-height containers.
- `DateStrip` generates 7 days from `DateTime.now()`; timezone handled by normalizing to date-only.
- `dayStats.revenue` sums `booking.totalAmount` for confirmed/booked slots only.
- `intl` package added for `DateFormat` (EEE, h:mm a).
- All new files follow existing code style: `as m` alias for `flutter/material.dart`, `const` constructors, required positional params first.