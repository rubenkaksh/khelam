# Spec: Booking Bottom Sheet with Phone Input

> **Date:** 2026-07-28  
> **Status:** Approved  
> **Checklist:** `docs/superpowers/checklist.md`

---

## 1. Goal

When a user taps an available slot in the schedule, instead of immediately booking it, open a bottom sheet asking for the booker's phone number. On Confirm, the booking is created with the phone number attached.

All new UI components (bottom sheet, phone input) must be **atomic and reusable** — designed to be merged into the forkable parent project for future scalability.

---

## 2. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Phone validation | 10-digit Indian mobile (`^[6-9]\d{9}$`) | Standard Indian mobile format |
| Phone storage | Add `customerPhone` field to `Booking` model | Clean, explicit, no semantic misuse |
| Bottom sheet style | Standard modal (drag handle, scrollable, Confirm/Cancel) | Familiar UX, non-blocking |
| Architecture | Atomic common widgets + booking-specific composition | Forkable, reusable across features |

---

## 3. Layer 1: Common Reusable Widgets

These widgets go into `lib/ui/common/` and contain zero booking-specific logic.

### 3.1 `FormBottomSheet`

**File:** `lib/ui/common/bottom_sheet.dart`

A generic bottom sheet with:
- Drag handle indicator at top
- Title (required) + optional subtitle
- Scrollable body (accepts any `Widget`)
- Fixed bottom area with Confirm + Cancel CTAs
- `confirmEnabled` flag to gate the Confirm button (e.g., until validation passes)
- Drag-to-dismiss enabled
- Keyboard-safe (body scrolls when keyboard opens)

**Interface:**
```dart
class FormBottomSheet extends StatelessWidget {
  const FormBottomSheet({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
    this.subtitle,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.confirmEnabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool confirmEnabled;
}
```

**Utility function:**
```dart
Future<T?> showFormBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: builder,
  );
}
```

### 3.2 `PhoneInput`

**File:** `lib/ui/common/phone_input.dart`

A phone number input field with:
- `+977` prefix display (non-editable)
- `TextInputType.phone` keyboard
- `maxLength: 10`
- Real-time validation: only digits, starts with 6-9
- Error text display on invalid input
- Visual consistency with existing `TextInput` from `inputs.dart`

**Interface:**
```dart
class PhoneInput extends StatelessWidget {
  const PhoneInput({
    super.key,
    this.onChanged,
    this.error,
    this.controller,
  });

  final ValueChanged<String>? onChanged;
  final String? error;
  final TextEditingController? controller;
}
```

**Validation rule:**
```dart
static final RegExp _indianMobileRegex = RegExp(r'^[6-9]\d{9}$');

static bool isValid(String phone) {
  return _indianMobileRegex.hasMatch(phone);
}
```

---

## 4. Layer 2: Booking-Specific Composition

### 4.1 Domain Model Update

**File:** `lib/domain/models/booking.dart`

Add optional `customerPhone` field:
```dart
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String bookingCode,
    required String userId,
    required String turfId,
    required String slotId,
    required double totalAmount,
    required double advanceAmount,
    required double remainingAmount,
    required BookingStatus status,
    String? customerPhone,  // NEW
  }) = _Booking;
}
```

**Action:** Regenerate freezed code (`dart run build_runner build`).

### 4.2 Interface Updates

**File:** `lib/domain/repositories/booking_service.dart`

```dart
Future<ScheduleSlotItem> bookSlot({
  required String turfId,
  required String slotId,
  String? customerPhone,  // NEW
});
```

**File:** `lib/data/repositories/booking_repository.dart`

Pass `customerPhone` through to service.

**File:** `lib/data/services/mock_booking_service.dart`

Accept `customerPhone` and include it in the created `Booking`.

### 4.3 `BookingConfirmationSheet`

**File:** `lib/ui/features/schedule/widgets/booking_confirmation_sheet.dart`

A stateful widget that composes `FormBottomSheet` + `PhoneInput`:

```dart
class BookingConfirmationSheet extends StatefulWidget {
  const BookingConfirmationSheet({super.key, required this.slot});

  final Slot slot;
}

// Returns BookingResult on confirm
class BookingResult {
  const BookingResult({required this.slotId, required this.customerPhone});
  final String slotId;
  final String customerPhone;
}
```

**Behavior:**
1. Displays slot time range (e.g., "10:00 AM – 11:00 AM")
2. Shows `PhoneInput` below the time info
3. Confirm button disabled until valid phone entered
4. On confirm → `Navigator.pop(context, BookingResult(...))`
5. On cancel/drag-down → `Navigator.pop(context, null)`

### 4.4 Cubit Update

**File:** `lib/ui/features/schedule/bloc/schedule_cubit.dart`

```dart
Future<void> bookSlot(String slotId, String customerPhone) async {
  // ... existing logic, now passes phone to repository
  final bookedItem = await _repository.bookSlot(
    turfId: state.turf?.id ?? 'turf-a',
    slotId: slotId,
    customerPhone: customerPhone,
  );
}
```

### 4.5 View Update

**File:** `lib/ui/features/schedule/views/schedule_view.dart`

Replace:
```dart
onAvailableSlotTap: (item) {
  context.read<ScheduleCubit>().bookSlot(item.slot.id);
},
```

With:
```dart
onAvailableSlotTap: (item) async {
  final result = await showFormBottomSheet<BookingResult>(
    context: context,
    builder: (_) => BookingConfirmationSheet(slot: item.slot),
  );
  if (case final result? = result) {
    if (context.mounted) {
      context.read<ScheduleCubit>().bookSlot(result.slotId, result.customerPhone);
    }
  }
},
```

---

## 5. Data Flow

```
User taps AvailableSlotCard
       │
       ▼
ScheduleView.onAvailableSlotTap(item)
       │
       ▼
showFormBottomSheet<BookingResult>(
  builder: BookingConfirmationSheet(slot: item.slot)
)
       │  ├─ User enters phone
       │  ├─ Validates 10-digit Indian mobile
       │  └─ Taps Confirm
       │
       ▼
Navigator.pop(BookingResult(slotId, phone))
       │
       ▼
ScheduleCubit.bookSlot(slotId, phone)
       │
       ▼
BookingRepository.bookSlot(turfId, slotId, phone)
       │
       ▼
MockBookingService.bookSlot(turfId, slotId, phone)
       │  └─ Creates Booking with customerPhone field
       │
       ▼
Returns booked slot → UI updates
```

---

## 6. Files Changed

| File | Action | Layer |
|------|--------|-------|
| `lib/ui/common/bottom_sheet.dart` | **Create** | Common (forkable) |
| `lib/ui/common/phone_input.dart` | **Create** | Common (forkable) |
| `lib/ui/features/schedule/widgets/booking_confirmation_sheet.dart` | **Create** | Schedule feature |
| `lib/domain/models/booking.dart` | Modify | Domain |
| `lib/domain/repositories/booking_service.dart` | Modify | Domain |
| `lib/data/repositories/booking_repository.dart` | Modify | Data |
| `lib/data/services/mock_booking_service.dart` | Modify | Data |
| `lib/ui/features/schedule/bloc/schedule_cubit.dart` | Modify | Schedule feature |
| `lib/ui/features/schedule/views/schedule_view.dart` | Modify | Schedule feature |
| `test/features/schedule/schedule_cubit_test.dart` | Modify | Tests |
| `test/ui/common/bottom_sheet_test.dart` | **Create** | Tests |
| `test/ui/common/phone_input_test.dart` | **Create** | Tests |
| `test/features/schedule/widgets/booking_confirmation_sheet_test.dart` | **Create** | Tests |

---

## 7. Testing Strategy

### Common Widget Tests
- **FormBottomSheet:** Renders title/body/CTAs; confirm disabled when `confirmEnabled: false`; cancel dismisses
- **PhoneInput:** Shows error for invalid input; accepts valid 10-digit Indian mobile; keyboard type correct

### Feature Tests
- **BookingConfirmationSheet:** Shows slot time; validates phone; returns BookingResult on confirm
- **ScheduleCubit.bookSlot:** Accepts phone parameter; passes to repository; updates state with booked slot

### Regression
- Existing 25 tests continue to pass
- All new tests follow existing patterns (flutter_test, no mocking frameworks needed for widget tests)

---

## 8. Checklist Reference

Full implementation tracking: `docs/superpowers/checklist.md`
