# Book Available Slots Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `bookSlot` method across the data layer and wire it through the cubit to the UI so tapping an available slot instantly converts it to a booked slot.

**Architecture:** Extend the `BookingService` interface with `bookSlot`, implement it in `MockBookingService` (mutating an in-memory set), expose it through `BookingRepository`, add a `bookSlot` action to `ScheduleCubit`, and hook the tap callback in `BookingTimeline`.

**Tech Stack:** Dart, flutter_bloc, freezed (model layer)

## Global Constraints
- Follow existing clean-architecture layering: domain → data → ui
- `MockBookingService` is the only service implementation — no real API calls
- Do NOT use the null force operator `!`. Use null-aware patterns instead (`if case final x? = y` or `?.` / `??` operators)
- Preserve existing test patterns (FakeBookingRepository, FakeBookingService)

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `lib/domain/repositories/booking_service.dart` | Modify | Add `bookSlot` to the interface |
| `lib/data/services/mock_booking_service.dart` | Modify | Implement `bookSlot` with in-memory state |
| `lib/data/repositories/booking_repository.dart` | Modify | Delegate `bookSlot` to service |
| `lib/ui/features/schedule/bloc/schedule_cubit.dart` | Modify | Add `bookSlot` method + emit optimistic state |
| `lib/ui/features/schedule/widgets/booking_timeline.dart` | Modify | Wire `onAvailableSlotTap` to cubit |
| `lib/ui/features/schedule/views/schedule_view.dart` | Modify | Pass cubit as tap handler |
| `test/features/schedule/schedule_cubit_test.dart` | Modify | Add `bookSlot` tests |

---

### Task 1: Add `bookSlot` to the Domain Interface

**Files:**
- Modify: `lib/domain/repositories/booking_service.dart:1-10`

**Interfaces:**
- Consumes: `ScheduleSlotItem` from `domain/models/schedule_slot_item.dart`
- Produces: `Future<ScheduleSlotItem>` — the same slot item now with a booking attached

- [ ] **Step 1: Add `bookSlot` method to `BookingService`**

```dart
import '../../domain/models/schedule_slot_item.dart';
import '../../domain/models/turf_summary.dart';

abstract interface class BookingService {
  Future<TurfSummary> getTurf(String turfId);
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  });
  Future<ScheduleSlotItem> bookSlot({
    required String turfId,
    required String slotId,
  });
}
```

- [ ] **Step 2: Verify compilation**

Run: `dart analyze lib/domain/repositories/booking_service.dart`
Expected: Only info hints, no errors. The implementing classes will fail until Task 2.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/repositories/booking_service.dart
git commit -m "feat(domain): add bookSlot to BookingService interface"
```

---

### Task 2: Implement `bookSlot` in MockBookingService

**Files:**
- Modify: `lib/data/services/mock_booking_service.dart:1-105`

**Interfaces:**
- Consumes: `BookingService.bookSlot` from Task 1
- Produces: In-memory mutation of slot status + `Future<ScheduleSlotItem>` return

- [ ] **Step 1: Write the test for `bookSlot` in mock service**

Add to `test/features/schedule/schedule_cubit_test.dart` inside the existing `ScheduleCubit` group:

```dart
    test('bookSlot converts available slot to booked', () async {
      final cubit = ScheduleCubit(repository: mockRepo);
      await cubit.load();

      // Find first available slot
      final available = cubit.state.slots.firstWhere(
        (item) => item.booking == null,
      );

      await cubit.bookSlot(available.slot.id);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);

      final updated = cubit.state.slots.firstWhere(
        (item) => item.slot.id == available.slot.id,
      );
      expect(updated.booking, isNotNull);
      expect(updated.customerName, isNotNull);
      expect(updated.slot.status, SlotStatus.booked);
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/features/schedule/schedule_cubit_test.dart --name "bookSlot"`
Expected: FAIL — `bookSlot` does not exist on cubit yet

- [ ] **Step 3: Add in-memory booked-slot tracking to `MockBookingService`**

```dart
import 'dart:math';

class MockBookingService implements BookingService {
  MockBookingService();

  static const String _turfId = 'turf-a';
  static const int _openHour = 7;
  static const int _closeHour = 22;
  static const List<String> _customerNames = <String>[
    'Team Alpha',
    'FC Rovers',
    'United Stars',
    'Sporting Club',
    'Elite Academy',
  ];

  final Set<String> _extraBookedSlotIds = <String>{};

  @override
  Future<TurfSummary> getTurf(String turfId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const TurfSummary(
      id: _turfId,
      name: 'Turf A',
      address: 'Sector 12, Sports Complex',
    );
  }

  @override
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    final List<ScheduleSlotItem> items = <ScheduleSlotItem>[];

    for (int hour = _openHour; hour < _closeHour; hour++) {
      final DateTime startTime = normalizedDate.add(Duration(hours: hour));
      final DateTime endTime = normalizedDate.add(Duration(hours: hour + 1));

      final String sid = _slotId(hour, date);
      final bool isBooked =
          _isSlotBooked(hour, date) || _extraBookedSlotIds.contains(sid);
      final SlotStatus slotStatus =
          isBooked ? SlotStatus.booked : SlotStatus.available;

      final Slot slot = Slot(
        id: sid,
        turfId: _turfId,
        slotDate: normalizedDate,
        startTime: startTime,
        endTime: endTime,
        status: slotStatus,
      );

      Booking? booking;
      String? customerName;
      if (isBooked) {
        final int customerIndex = (hour * 7 + date.day) % _customerNames.length;
        customerName = _customerNames[customerIndex];
        booking = Booking(
          id: _bookingId(hour, date),
          bookingCode:
              'BK-${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${hour.toString().padLeft(2, '0')}',
          userId: 'user-1',
          turfId: _turfId,
          slotId: sid,
          totalAmount: 100.0,
          advanceAmount: 50.0,
          remainingAmount: 50.0,
          status: BookingStatus.confirmed,
        );
      }

      items.add(ScheduleSlotItem(slot: slot, booking: booking, customerName: customerName));
    }

    return items;
  }

  @override
  Future<ScheduleSlotItem> bookSlot({
    required String turfId,
    required String slotId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _extraBookedSlotIds.add(slotId);

    // Parse date info from slot ID: "slot-YYYY-M-D-H"
    final List<String> parts = slotId.split('-');
    final int year = int.parse(parts[1]);
    final int month = int.parse(parts[2]);
    final int day = int.parse(parts[3]);
    final int hour = int.parse(parts[4]);

    final DateTime normalizedDate = DateTime(year, month, day);
    final DateTime startTime = normalizedDate.add(Duration(hours: hour));
    final DateTime endTime = normalizedDate.add(Duration(hours: hour + 1));

    final Slot slot = Slot(
      id: slotId,
      turfId: turfId,
      slotDate: normalizedDate,
      startTime: startTime,
      endTime: endTime,
      status: SlotStatus.booked,
    );

    final int customerIndex = Random().nextInt(_customerNames.length);
    final String customerName = _customerNames[customerIndex];
    final Booking booking = Booking(
      id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
      bookingCode:
          'BK-${normalizedDate.month.toString().padLeft(2, '0')}${normalizedDate.day.toString().padLeft(2, '0')}-${hour.toString().padLeft(2, '0')}',
      userId: 'user-1',
      turfId: turfId,
      slotId: slotId,
      totalAmount: 100.0,
      advanceAmount: 50.0,
      remainingAmount: 50.0,
      status: BookingStatus.confirmed,
    );

    return ScheduleSlotItem(slot: slot, booking: booking, customerName: customerName);
  }

  bool _isSlotBooked(int hour, DateTime date) {
    final int totalSlots = _closeHour - _openHour;
    final int daySeed = date.day + date.month * 31;
    final int slotIndex = hour - _openHour;
    final int threshold = totalSlots ~/ 2;
    return (slotIndex * 7 + daySeed * 13) % totalSlots < threshold;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/features/schedule/schedule_cubit_test.dart --name "bookSlot"`
Expected: PASS (cubit.bookSlot still missing — will fail on compilation, fix in Task 3)

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/mock_booking_service.dart test/features/schedule/schedule_cubit_test.dart
git commit -m "feat(data): implement bookSlot in MockBookingService"
```

---

### Task 3: Expose `bookSlot` through BookingRepository

**Files:**
- Modify: `lib/data/repositories/booking_repository.dart:1-21`

**Interfaces:**
- Consumes: `BookingService.bookSlot` from Task 1
- Produces: `BookingRepository.bookSlot` — same signature

- [ ] **Step 1: Add `bookSlot` to `BookingRepository`**

```dart
import '../../domain/models/schedule_slot_item.dart';
import '../../domain/models/turf_summary.dart';
import '../../domain/repositories/booking_service.dart';

class BookingRepository {
  const BookingRepository({required BookingService service})
      : _service = service;

  final BookingService _service;

  Future<TurfSummary> getTurf(String turfId) {
    return _service.getTurf(turfId);
  }

  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) {
    return _service.getSchedule(turfId: turfId, date: date);
  }

  Future<ScheduleSlotItem> bookSlot({
    required String turfId,
    required String slotId,
  }) {
    return _service.bookSlot(turfId: turfId, slotId: slotId);
  }
}
```

- [ ] **Step 2: Update `FakeBookingRepository` in test to include `bookSlot`**

Add to the `FakeBookingRepository` in `test/features/schedule/schedule_cubit_test.dart`:

```dart
class FakeBookingRepository implements BookingRepository {
  bool shouldThrow = false;

  @override
  Future<TurfSummary> getTurf(String turfId) async {
    if (shouldThrow) throw Exception('Network error');
    return const TurfSummary(id: 'turf-a', name: 'Turf A');
  }

  @override
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    final Slot slot = Slot(
      id: 's1',
      turfId: turfId,
      slotDate: date,
      startTime: date.add(const Duration(hours: 7)),
      endTime: date.add(const Duration(hours: 8)),
      status: SlotStatus.available,
    );
    return <ScheduleSlotItem>[ScheduleSlotItem(slot: slot)];
  }

  @override
  Future<ScheduleSlotItem> bookSlot({
    required String turfId,
    required String slotId,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    final Slot slot = Slot(
      id: slotId,
      turfId: turfId,
      slotDate: DateTime.now(),
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      status: SlotStatus.booked,
    );
    final Booking booking = Booking(
      id: 'b-new',
      bookingCode: 'BK-NEW',
      userId: 'user-1',
      turfId: turfId,
      slotId: slotId,
      totalAmount: 100.0,
      advanceAmount: 50.0,
      remainingAmount: 50.0,
      status: BookingStatus.confirmed,
    );
    return ScheduleSlotItem(slot: slot, booking: booking, customerName: 'You');
  }
}
```

- [ ] **Step 3: Verify compilation**

Run: `dart analyze lib/data/repositories/booking_repository.dart test/features/schedule/schedule_cubit_test.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/booking_repository.dart test/features/schedule/schedule_cubit_test.dart
git commit -m "feat(data): add bookSlot to BookingRepository"
```

---

### Task 4: Add `bookSlot` to ScheduleCubit

**Files:**
- Modify: `lib/ui/features/schedule/bloc/schedule_cubit.dart:45-124`

**Interfaces:**
- Consumes: `BookingRepository.bookSlot` from Task 3
- Produces: `ScheduleCubit.bookSlot(String slotId)` — emits optimistic state update

- [ ] **Step 1: Write failing test for cubit.bookSlot**

Already added in Task 2 step 1. Run it to verify it fails:

Run: `dart test test/features/schedule/schedule_cubit_test.dart --name "bookSlot"`
Expected: FAIL — `bookSlot` not found on `ScheduleCubit`

- [ ] **Step 2: Implement `bookSlot` in `ScheduleCubit`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/booking_repository.dart';
import '../../../../domain/models/schedule_slot_item.dart';
import '../../../../domain/models/turf_summary.dart';
import '../widgets/day_stats_section.dart';

class ScheduleState {
  const ScheduleState({
    this.selectedDate,
    this.turf,
    this.slots = const <ScheduleSlotItem>[],
    this.dayStats = const DayStats(),
    this.isLoading = false,
    this.errorMessage,
  });

  final DateTime? selectedDate;
  final TurfSummary? turf;
  final List<ScheduleSlotItem> slots;
  final DayStats dayStats;
  final bool isLoading;
  final String? errorMessage;

  ScheduleState copyWith({
    DateTime? selectedDate,
    TurfSummary? turf,
    List<ScheduleSlotItem>? slots,
    DayStats? dayStats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      turf: turf ?? this.turf,
      slots: slots ?? this.slots,
      dayStats: dayStats ?? this.dayStats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({required BookingRepository repository})
      : _repository = repository,
        super(const ScheduleState());

  final BookingRepository _repository;

  Future<void> load({String? turfId}) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final TurfSummary turf = await _repository.getTurf(turfId ?? 'turf-a');
      final DateTime today = DateTime.now();
      final DateTime normalizedDate = DateTime(today.year, today.month, today.day);
      final List<ScheduleSlotItem> slots = await _repository.getSchedule(
        turfId: turf.id,
        date: normalizedDate,
      );
      emit(state.copyWith(
        selectedDate: normalizedDate,
        turf: turf,
        slots: slots,
        dayStats: _computeStats(slots),
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Could not load schedule.'));
    }
  }

  Future<void> selectDate(DateTime date) async {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: normalizedDate, isLoading: true));
    try {
      final List<ScheduleSlotItem> slots = await _repository.getSchedule(
        turfId: state.turf?.id ?? 'turf-a',
        date: normalizedDate,
      );
      emit(state.copyWith(
        slots: slots,
        dayStats: _computeStats(slots),
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load schedule for selected date.',
      ));
    }
  }

  Future<void> bookSlot(String slotId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final ScheduleSlotItem bookedItem = await _repository.bookSlot(
        turfId: state.turf?.id ?? 'turf-a',
        slotId: slotId,
      );

      final List<ScheduleSlotItem> updatedSlots = state.slots.map((item) {
        if (item.slot.id == slotId) return bookedItem;
        return item;
      }).toList();

      emit(state.copyWith(
        slots: updatedSlots,
        dayStats: _computeStats(updatedSlots),
        isLoading: false,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Could not book slot. Please try again.',
      ));
    }
  }

  DayStats _computeStats(List<ScheduleSlotItem> items) {
    int count = 0;
    double revenue = 0.0;
    for (final ScheduleSlotItem item in items) {
      if (item.booking != null) {
        count++;
        revenue += item.booking!.totalAmount;
      }
    }
    return DayStats(bookingCount: count, revenue: revenue);
  }
}
```

- [ ] **Step 3: Run tests to verify they pass**

Run: `dart test test/features/schedule/schedule_cubit_test.dart`
Expected: All PASS including the new `bookSlot` test

- [ ] **Step 4: Commit**

```bash
git add lib/ui/features/schedule/bloc/schedule_cubit.dart
git commit -m "feat(schedule): add bookSlot to ScheduleCubit with optimistic update"
```

---

### Task 5: Wire UI Tap Callbacks

**Files:**
- Modify: `lib/ui/features/schedule/views/schedule_view.dart:1-88`
- Modify: `lib/ui/features/schedule/widgets/booking_timeline.dart:1-76`

**Interfaces:**
- Consumes: `ScheduleCubit.bookSlot(String slotId)` from Task 4
- Produces: Tap handlers that call cubit.bookSlot

- [ ] **Step 1: Add `onAvailableSlotTap` callback to `BookingTimeline`**

The `BookingTimeline` already accepts `onAvailableSlotTap` — no changes needed there. We just need to pass it from `ScheduleView`.

- [ ] **Step 2: Update `ScheduleView` to pass tap handler**

```dart
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/feedback.dart';
import '../bloc/schedule_cubit.dart';
import '../widgets/booking_timeline.dart';
import '../widgets/date_strip.dart';
import '../widgets/day_stats_section.dart';
import '../widgets/turf_header.dart';

class ScheduleView extends m.StatefulWidget {
  const ScheduleView({super.key});

  @override
  m.State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends m.State<ScheduleView> {
  @override
  void initState() {
    super.initState();
    final ScheduleCubit cubit = context.read<ScheduleCubit>();
    m.WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load();
    });
  }

  @override
  m.Widget build(m.BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (m.BuildContext context, ScheduleState state) {
        return m.Scaffold(
          appBar: m.AppBar(
            title: const m.Text('Schedule'),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  m.Widget _buildBody(m.BuildContext context, ScheduleState state) {
    if (state.isLoading && state.turf == null) {
      return const LoadingView();
    }

    if (state.errorMessage != null && state.slots.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<ScheduleCubit>().load(),
      );
    }

    final List<DateTime> dates = _generateDateRange();

    return m.ListView(
      children: <m.Widget>[
        DateStrip(
          dates: dates,
          selectedDate: state.selectedDate ?? DateTime.now(),
          onDateSelected: (DateTime date) {
            context.read<ScheduleCubit>().selectDate(date);
          },
        ),
        if (state.turf != null) TurfHeader(turf: state.turf!),
        if (state.isLoading && state.slots.isNotEmpty)
          const m.Padding(
            padding: m.EdgeInsets.all(16),
            child: m.CircularProgressIndicator(),
          ),
        BookingTimeline(
          items: state.slots,
          onAvailableSlotTap: (item) {
            context.read<ScheduleCubit>().bookSlot(item.slot.id);
          },
        ),
        if (state.slots.isNotEmpty)
          DayStatsSection(stats: state.dayStats),
      ],
    );
  }

  List<DateTime> _generateDateRange() {
    final DateTime today = DateTime.now();
    return List<DateTime>.generate(
      7,
      (int i) => DateTime(today.year, today.month, today.day + i),
    );
  }
}
```

- [ ] **Step 3: Verify compilation**

Run: `dart analyze lib/ui/features/schedule/views/schedule_view.dart`
Expected: No errors

- [ ] **Step 4: Run full test suite**

Run: `dart test`
Expected: All PASS

- [ ] **Step 5: Commit**

```bash
git add lib/ui/features/schedule/views/schedule_view.dart
git commit -m "feat(schedule): wire available slot tap to bookSlot"
```

---

### Task 6: Run Full Verification

**Files:** None — verification only

- [ ] **Step 1: Run all tests**

Run: `dart test`
Expected: All PASS (no regressions)

- [ ] **Step 2: Run analyzer**

Run: `dart analyze`
Expected: No errors

- [ ] **Step 3: Build check (optional)**

Run: `flutter build apk --debug`
Expected: Build succeeds

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "chore: verify booking feature compiles and tests pass"
```
