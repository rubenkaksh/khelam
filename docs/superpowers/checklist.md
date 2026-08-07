# Booking Bottom Sheet — Iteration Checklist

> **Feature:** Click available slot → bottom sheet for phone number → Confirm → booked  
> **Date:** 2026-07-28  
> **Goal:** Atomic reusable components for forkable parent + booking composition

---

## Design Decisions (Locked)

- [x] Phone validation: 10-digit Indian mobile (^[6-9]\d{9}$)
- [x] Phone storage: Add `customerPhone` field to `Booking` model
- [x] Bottom sheet: Standard modal (drag handle, scrollable, Confirm/Cancel)
- [x] Architecture: Atomic common widgets (forkable) + booking-specific composition

---

## Layer 1: Common Reusable Widgets (forkable parent)

### `lib/ui/common/bottom_sheet.dart`
- [x] `FormBottomSheet` widget — title, subtitle?, body, confirm/cancel CTAs
- [x] `showFormBottomSheet<T>()` static helper utility
- [x] Drag handle indicator
- [x] Scrollable body with keyboard safety
- [x] Drag-to-dismiss enabled
- [x] `confirmEnabled` flag for validation gating

### `lib/ui/common/phone_input.dart`
- [x] `PhoneInput` widget — 10-digit Indian mobile validation
- [x] `+977` prefix display (non-editable)
- [x] `TextInputType.phone` keyboard
- [x] `maxLength: 10`
- [x] Error text on invalid input
- [x] `onChanged` callback returning formatted value

---

## Layer 2: Booking-Specific Composition

### Domain Model Update
- [x] Add `customerPhone` field to `Booking` freezed model
- [x] Regenerate `booking.freezed.dart` + `booking.g.dart`
- [x] Update `MockBookingService.bookSlot` to accept `customerPhone`

### Booking Confirmation Sheet
- [x] `BookingConfirmationSheet` widget (composes `FormBottomSheet` + `PhoneInput`)
- [x] Shows slot time info in the sheet body
- [x] Validates phone before enabling Confirm CTA
- [x] Returns `BookingResult` (slotId + phone) on confirm

### Schedule View Update
- [x] Replace direct `bookSlot` call with bottom sheet open
- [x] `onAvailableSlotTap` → opens `BookingConfirmationSheet`
- [x] On confirm → calls `cubit.bookSlot(slotId, customerPhone)`
- [x] On cancel → dismisses sheet (no action)

### ScheduleCubit Update
- [x] Update `bookSlot(String slotId)` → `bookSlot(String slotId, {String? customerPhone})`
- [x] Pass phone to repository

### Repository/Service Update
- [x] `BookingRepository.bookSlot` accepts `customerPhone`
- [x] `BookingService.bookSlot` interface updated
- [x] `MockBookingService.bookSlot` creates booking with phone

---

## Tests

### Common Widget Tests
- [x] `FormBottomSheet` — renders title, body, CTAs; confirm disabled when `confirmEnabled: false`
- [x] `PhoneInput` — validates 10-digit Indian mobile; shows error for invalid

### Feature Tests
- [x] `BookingConfirmationSheet` — validates phone, returns result on confirm
- [x] `ScheduleCubit.bookSlot` — accepts phone, passes to repository
- [x] Updated `schedule_cubit_test.dart` — bookSlot with phone parameter

---

## Documentation
- [x] Design doc written
- [x] Implementation plan written
- [x] Checklist updated
- [ ] Update `docs/commons.md` with new common widgets
- [ ] Update handoff doc if session ends

---

## Current Status

| Step | Status |
|------|--------|
| Design: Common widgets | ✅ Complete |
| Design: Booking composition | ✅ Complete |
| Design doc written | ✅ Complete |
| Implementation | ✅ Complete |
| Tests | ✅ Complete |
| Documentation | 🔄 In progress |
