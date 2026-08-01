# Khelam

Khelam is a turf-booking app: players reserve hourly slots on a turf for their team, and the owner sees the day's schedule and revenue. Single Flutter client backed by the NestJS `rms-futsal-backend`.

## Language

**Turf**:
A physical futsal ground that players book. Identified by `turfId`; the app currently shows one hardcoded turf until a turfs endpoint exists.
_Avoid_: venue, ground, facility

**Slot**:
An hour of play on a turf, with a status (`available`, `booked`, `locked`, `unavailable`, `reserved`). The slots list endpoint returns one row per hour with no booking details.
_Avoid_: time block, timeslot

**Schedule**:
The day's list of slots for a turf — the schedule screen (cubit: `ScheduleCubit`) is the booking feature's main view.
_Avoid_: timeline, agenda

**Booking**:
A confirmed reservation tying a user and phone to a turf slot, with money amounts (`totalAmount`, `advanceAmount`, `remainingAmount`). The list endpoint omits booking objects; booked-ness on the schedule derives from `slot.status`, the booker's name from `bookedBy`.
_Avoid_: reservation, order, appointment

**Book slot**:
The action of reserving an available slot, sending `customerPhone`. The server is the source of truth: after booking, the client refetches the schedule.
_Avoid_: reserve, check out

**DayStats**:
Aggregate per day: `bookingCount` and `revenue`. Revenue needs the booking payload, so API mode reports ₹0 until the backend supplies it.
_Avoid_: statistics, metrics

**Auth / demo account**:
Sign-in via `AuthService` (mock adapter: `demo@khelam.dev` / `password123`). Unauthenticated users can only see login and schedule.
_Avoid_: login (for the feature), session

**Feature module**:
A self-contained directory under `lib/features/<feature>/` owning models, service interface, adapters, cubit, views, widgets and DI (ADR-0004).
_Avoid_: layer, package
