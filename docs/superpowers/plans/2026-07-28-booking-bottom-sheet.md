# Booking Bottom Sheet — Implementation Plan

> **Spec:** `docs/superpowers/specs/2026-07-28-booking-bottom-sheet-design.md`  
> **Checklist:** `docs/superpowers/checklist.md`  
> **For agentic workers:** Use subagent-driven-development to implement task-by-task.

**Goal:** Add a phone number collection bottom sheet before booking, with atomic reusable widgets for the forkable parent.

**Architecture:** Common widgets (bottom_sheet.dart, phone_input.dart) → Domain model update → Interface updates → Booking confirmation sheet → View/Cubit wiring → Tests.

**Tech Stack:** Dart, Flutter, flutter_bloc, freezed, flutter_test

## Global Constraints
- Follow existing clean-architecture layering: domain → data → ui
- Do NOT use the null force operator `!`. Use null-aware patterns instead
- Common widgets must be fully reusable — zero booking-specific logic
- Preserve existing test patterns (FakeBookingRepository, FakeBookingService)

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `lib/ui/common/bottom_sheet.dart` | **Create** | Generic FormBottomSheet + showFormBottomSheet utility |
| `lib/ui/common/phone_input.dart` | **Create** | Phone input with Indian mobile validation |
| `lib/domain/models/booking.dart` | Modify | Add `customerPhone` field |
| `lib/domain/repositories/booking_service.dart` | Modify | Add `customerPhone` param to bookSlot |
| `lib/data/repositories/booking_repository.dart` | Modify | Pass customerPhone through |
| `lib/data/services/mock_booking_service.dart` | Modify | Accept + store customerPhone |
| `lib/ui/features/schedule/widgets/booking_confirmation_sheet.dart` | **Create** | Composes FormBottomSheet + PhoneInput |
| `lib/ui/features/schedule/bloc/schedule_cubit.dart` | Modify | Accept customerPhone in bookSlot |
| `lib/ui/features/schedule/views/schedule_view.dart` | Modify | Open bottom sheet on tap |
| `test/ui/common/bottom_sheet_test.dart` | **Create** | FormBottomSheet tests |
| `test/ui/common/phone_input_test.dart` | **Create** | PhoneInput tests |
| `test/features/schedule/widgets/booking_confirmation_sheet_test.dart` | **Create** | BookingConfirmationSheet tests |
| `test/features/schedule/schedule_cubit_test.dart` | Modify | Update bookSlot test with phone |
| `docs/commons.md` | Modify | Document new common widgets |

---

### Task 1: Create `FormBottomSheet` Common Widget

**Files:**
- Create: `lib/ui/common/bottom_sheet.dart`

**Interfaces:**
- Consumes: None (standalone)
- Produces: `FormBottomSheet` widget + `showFormBottomSheet<T>()` utility

- [ ] **Step 1: Create `FormBottomSheet` widget**

```dart
import 'package:flutter/material.dart' as m;

class FormBottomSheet extends m.StatelessWidget {
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
  final m.Widget body;
  final String confirmLabel;
  final m.VoidCallback? onConfirm;
  final String cancelLabel;
  final m.VoidCallback? onCancel;
  final bool confirmEnabled;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (m.BuildContext context, m.ScrollController scrollController) {
        return m.Container(
          decoration: m.BoxDecoration(
            color: colors.surface,
            borderRadius: const m.BorderRadius.vertical(
              top: m.Radius.circular(20),
            ),
          ),
          child: m.Column(
            children: <m.Widget>[
              // Drag handle
              m.Container(
                margin: const m.EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: m.BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: m.BorderRadius.circular(2),
                ),
              ),
              // Header
              m.Padding(
                padding: const m.EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: m.Column(
                  crossAxisAlignment: m.CrossAxisAlignment.start,
                  children: <m.Widget>[
                    m.Text(
                      title,
                      style: m.Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (subtitle case final subtitle?) ...[
                      const m.SizedBox(height: 4),
                      m.Text(
                        subtitle,
                        style: m.Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Scrollable body
              m.Expanded(
                child: m.SingleChildScrollView(
                  controller: scrollController,
                  padding: const m.EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: body,
                ),
              ),
              // CTAs
              m.Padding(
                padding: const m.EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: m.Row(
                  children: <m.Widget>[
                    m.Expanded(
                      child: m.OutlinedButton(
                        onPressed: onCancel ?? () => m.Navigator.pop(context),
                        child: m.Text(cancelLabel),
                      ),
                    ),
                    const m.SizedBox(width: 12),
                    m.Expanded(
                      child: m.FilledButton(
                        onPressed: confirmEnabled ? onConfirm : null,
                        child: m.Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<T?> showFormBottomSheet<T>({
  required m.BuildContext context,
  required m.WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return m.showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: builder,
  );
}
```

- [ ] **Step 2: Create test**

```dart
// test/ui/common/bottom_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/ui/common/bottom_sheet.dart';

void main() {
  group('FormBottomSheet', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Test Title',
            body: const Text('Test Body'),
            confirmLabel: 'Confirm',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            subtitle: 'Subtitle',
            body: const SizedBox(),
            confirmLabel: 'OK',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('confirm button disabled when confirmEnabled is false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            confirmEnabled: false,
          ),
        ),
      ));
      final finder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(finder).onPressed, isNull);
    });

    testWidgets('cancel button calls onCancel or pops', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            onCancel: () => cancelled = true,
          ),
        ),
      ));
      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });
  });
}
```

- [ ] **Step 3: Verify + Commit**

Run: `flutter test test/ui/common/bottom_sheet_test.dart`
Commit: `feat(ui): add reusable FormBottomSheet common widget`

---

### Task 2: Create `PhoneInput` Common Widget

**Files:**
- Create: `lib/ui/common/phone_input.dart`

- [ ] **Step 1: Create `PhoneInput` widget**

```dart
import 'package:flutter/material.dart' as m;

class PhoneInput extends m.StatelessWidget {
  const PhoneInput({
    super.key,
    this.onChanged,
    this.error,
    this.controller,
  });

  final m.ValueChanged<String>? onChanged;
  final String? error;
  final m.TextEditingController? controller;

  static final RegExp _indianMobileRegex = RegExp(r'^[6-9]\d{9}$');

  static bool isValid(String phone) {
    return _indianMobileRegex.hasMatch(phone);
  }

  @override
  m.Widget build(m.BuildContext context) {
    return m.TextFormField(
      controller: controller,
      keyboardType: m.TextInputType.phone,
      maxLength: 10,
      decoration: m.InputDecoration(
        labelText: 'Phone Number',
        hintText: '9876543210',
        errorText: error,
        prefixIcon: const m.Padding(
          padding: m.EdgeInsets.only(left: 12, right: 8),
          child: m.Text(
            '+977',
            style: m.TextStyle(fontSize: 16),
          ),
        ),
        prefixIconConstraints: const m.BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        }
        if (!isValid(value)) {
          return 'Enter a valid 10-digit mobile number';
        }
        return null;
      },
    );
  }
}
```

- [ ] **Step 2: Create test**

```dart
// test/ui/common/phone_input_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/ui/common/phone_input.dart';

void main() {
  group('PhoneInput', () {
    testWidgets('renders with +977 prefix', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: PhoneInput()),
      ));
      expect(find.text('+977'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    test('isValid accepts valid 10-digit Indian mobile', () {
      expect(PhoneInput.isValid('9876543210'), isTrue);
      expect(PhoneInput.isValid('6123456789'), isTrue);
      expect(PhoneInput.isValid('7987654321'), isTrue);
    });

    test('isValid rejects invalid numbers', () {
      expect(PhoneInput.isValid('1234567890'), isFalse); // starts with 1
      expect(PhoneInput.isValid('987654321'), isFalse);  // 9 digits
      expect(PhoneInput.isValid('98765432101'), isFalse); // 11 digits
      expect(PhoneInput.isValid(''), isFalse);
      expect(PhoneInput.isValid('abcdefghij'), isFalse);
    });

    testWidgets('shows error when validation fails', (tester) async {
      final key = GlobalKey<FormFieldState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            child: PhoneInput(
              controller: TextEditingController(),
            ),
          ),
        ),
      ));
      // Enter invalid input
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.pump();
      expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3: Verify + Commit**

Run: `flutter test test/ui/common/phone_input_test.dart`
Commit: `feat(ui): add reusable PhoneInput common widget`

---

### Task 3: Update `Booking` Model with `customerPhone`

**Files:**
- Modify: `lib/domain/models/booking.dart`

- [ ] **Step 1: Add `customerPhone` field**

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
    String? customerPhone,
  }) = _Booking;
}
```

- [ ] **Step 2: Regenerate freezed code**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Verify + Commit**

Run: `dart analyze lib/domain/models/booking.dart`
Commit: `feat(domain): add customerPhone field to Booking model`

---

### Task 4: Update `BookingService` Interface + Repository + MockService

**Files:**
- Modify: `lib/domain/repositories/booking_service.dart`
- Modify: `lib/data/repositories/booking_repository.dart`
- Modify: `lib/data/services/mock_booking_service.dart`

- [ ] **Step 1: Update interface**

```dart
// booking_service.dart
Future<ScheduleSlotItem> bookSlot({
  required String turfId,
  required String slotId,
  String? customerPhone,
});
```

- [ ] **Step 2: Update repository**

```dart
// booking_repository.dart
Future<ScheduleSlotItem> bookSlot({
  required String turfId,
  required String slotId,
  String? customerPhone,
}) {
  return _service.bookSlot(turfId: turfId, slotId: slotId, customerPhone: customerPhone);
}
```

- [ ] **Step 3: Update MockBookingService**

Add `customerPhone` param to `bookSlot` and include in `Booking` creation:
```dart
@override
Future<ScheduleSlotItem> bookSlot({
  required String turfId,
  required String slotId,
  String? customerPhone,
}) async {
  // ... existing logic ...
  final Booking booking = Booking(
    // ... existing fields ...
    customerPhone: customerPhone,
  );
  return ScheduleSlotItem(slot: slot, booking: booking, customerName: customerName);
}
```

- [ ] **Step 4: Verify + Commit**

Run: `dart analyze lib/data/ lib/domain/repositories/`
Commit: `feat(data): pass customerPhone through booking layer`

---

### Task 5: Create `BookingConfirmationSheet`

**Files:**
- Create: `lib/ui/features/schedule/widgets/booking_confirmation_sheet.dart`

- [ ] **Step 1: Create widget**

```dart
import 'package:flutter/material.dart' as m;
import 'package:intl/intl.dart';

import '../../../../domain/models/slot.dart';
import '../../../common/bottom_sheet.dart';
import '../../../common/phone_input.dart';

class BookingResult {
  const BookingResult({required this.slotId, required this.customerPhone});
  final String slotId;
  final String customerPhone;
}

class BookingConfirmationSheet extends m.StatefulWidget {
  const BookingConfirmationSheet({super.key, required this.slot});

  final Slot slot;

  @override
  m.State<BookingConfirmationSheet> createState() => _BookingConfirmationSheetState();
}

class _BookingConfirmationSheetState extends m.State<BookingConfirmationSheet> {
  final m.TextEditingController _phoneController = m.TextEditingController();
  String? _phoneError;
  bool _isValid = false;

  void _onPhoneChanged(String value) {
    setState(() {
      _isValid = PhoneInput.isValid(value);
      _phoneError = null;
    });
  }

  void _onConfirm() {
    if (!_isValid) {
      setState(() {
        _phoneError = 'Enter a valid 10-digit mobile number';
      });
      return;
    }
    m.Navigator.pop(
      context,
      BookingResult(
        slotId: widget.slot.id,
        customerPhone: _phoneController.text,
      ),
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    final DateFormat timeFormat = DateFormat('hh:mm a');
    final String startTime = timeFormat.format(widget.slot.startTime);
    final String endTime = timeFormat.format(widget.slot.endTime);

    return FormBottomSheet(
      title: 'Confirm Booking',
      subtitle: '$startTime – $endTime',
      body: PhoneInput(
        controller: _phoneController,
        onChanged: _onPhoneChanged,
        error: _phoneError,
      ),
      confirmLabel: 'Confirm',
      confirmEnabled: _isValid,
      onConfirm: _onConfirm,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Create test**

```dart
// test/features/schedule/widgets/booking_confirmation_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/domain/models/slot.dart';
import 'package:khelam/domain/models/slot_status.dart';
import 'package:khelam/ui/features/schedule/widgets/booking_confirmation_sheet.dart';

void main() {
  final testSlot = Slot(
    id: 'slot-2026-7-28-10',
    turfId: 'turf-a',
    slotDate: DateTime(2026, 7, 28),
    startTime: DateTime(2026, 7, 28, 10),
    endTime: DateTime(2026, 7, 28, 11),
    status: SlotStatus.available,
  );

  group('BookingConfirmationSheet', () {
    testWidgets('shows slot time range', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BookingConfirmationSheet(slot: testSlot),
        ),
      ));
      expect(find.text('Confirm Booking'), findsOneWidget);
      expect(find.textContaining('10:00 AM'), findsOneWidget);
      expect(find.textContaining('11:00 AM'), findsOneWidget);
    });

    testWidgets('confirm button disabled until valid phone', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BookingConfirmationSheet(slot: testSlot),
        ),
      ));
      // Initially disabled
      final finder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(finder).onPressed, isNull);

      // Enter valid phone
      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pump();

      // Now enabled
      expect(tester.widget<FilledButton>(finder).onPressed, isNotNull);
    });

    testWidgets('returns BookingResult on confirm', (tester) async {
      BookingResult? result;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showBookingConfirmationSheet(
                  context: context,
                  slot: testSlot,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.slotId, 'slot-2026-7-28-10');
      expect(result!.customerPhone, '9876543210');
    });
  });
}
```

- [ ] **Step 3: Verify + Commit**

Run: `flutter test test/features/schedule/widgets/booking_confirmation_sheet_test.dart`
Commit: `feat(schedule): add BookingConfirmationSheet with phone input`

---

### Task 6: Wire View + Update Cubit

**Files:**
- Modify: `lib/ui/features/schedule/views/schedule_view.dart`
- Modify: `lib/ui/features/schedule/bloc/schedule_cubit.dart`
- Modify: `test/features/schedule/schedule_cubit_test.dart`

- [ ] **Step 1: Update ScheduleCubit.bookSlot signature**

```dart
Future<void> bookSlot(String slotId, String customerPhone) async {
  emit(state.copyWith(isLoading: true, clearError: true));
  try {
    final ScheduleSlotItem bookedItem = await _repository.bookSlot(
      turfId: state.turf?.id ?? 'turf-a',
      slotId: slotId,
      customerPhone: customerPhone,
    );
    // ... rest unchanged
  }
}
```

- [ ] **Step 2: Update ScheduleView tap handler**

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

- [ ] **Step 3: Update existing bookSlot test**

Update `test/features/schedule/schedule_cubit_test.dart` to pass phone:
```dart
await cubit.bookSlot(available.slot.id, '9876543210');
```

- [ ] **Step 4: Verify + Commit**

Run: `flutter test`
Commit: `feat(schedule): wire booking confirmation sheet to schedule view`

---

### Task 7: Update Documentation + Final Verification

**Files:**
- Modify: `docs/commons.md`

- [ ] **Step 1: Update commons.md with new widgets**

Add `FormBottomSheet` and `PhoneInput` to the common widgets roster.

- [ ] **Step 2: Run full test suite**

Run: `flutter test` — all tests must pass
Run: `dart analyze` — no issues

- [ ] **Step 3: Final commit**

Commit: `docs: update commons.md with FormBottomSheet and PhoneInput`
