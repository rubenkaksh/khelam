import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/booking/bloc/schedule_cubit.dart';
import 'package:khelam/features/booking/booking_service.dart';
import 'package:khelam/features/booking/models/booking.dart';
import 'package:khelam/features/booking/models/booking_status.dart';
import 'package:khelam/features/booking/models/schedule_slot_item.dart';
import 'package:khelam/features/booking/models/slot.dart';
import 'package:khelam/features/booking/models/slot_status.dart';
import 'package:khelam/features/booking/models/turf_summary.dart';

class FakeBookingService implements BookingService {
  FakeBookingService();

  bool shouldThrow = false;

  /// Slot ids that were booked; `getSchedule` reflects them so the cubit's
  /// post-book refetch sees the slot as booked (server-as-source-of-truth).
  final Set<String> bookedSlotIds = <String>{};

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
      status: bookedSlotIds.contains('s1')
          ? SlotStatus.booked
          : SlotStatus.available,
    );
    if (slot.status == SlotStatus.booked) {
      final Booking booking = Booking(
        id: 'b-new',
        bookingCode: 'BK-NEW',
        userId: 'user-1',
        turfId: turfId,
        slotId: slot.id,
        totalAmount: 100.0,
        advanceAmount: 50.0,
        remainingAmount: 50.0,
        status: BookingStatus.confirmed,
      );
      return <ScheduleSlotItem>[
        ScheduleSlotItem(slot: slot, booking: booking, customerName: 'You'),
      ];
    }
    return <ScheduleSlotItem>[ScheduleSlotItem(slot: slot)];
  }

  @override
  Future<void> bookSlot({
    required String turfId,
    required String slotId,
    String? customerPhone,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    bookedSlotIds.add(slotId);
  }
}

void main() {
  late FakeBookingService fakeService;

  setUp(() {
    fakeService = FakeBookingService();
  });

  group('ScheduleCubit', () {
    test('initial state has no date, no turf, empty slots', () {
      final cubit = ScheduleCubit(service: fakeService, turfId: 'turf-a');
      expect(cubit.state.selectedDate, isNull);
      expect(cubit.state.turf, isNull);
      expect(cubit.state.slots, isEmpty);
      expect(cubit.state.isLoading, isFalse);
    });

    test('load sets turf, date and slots on success', () async {
      final cubit = ScheduleCubit(service: fakeService, turfId: 'turf-a');
      await cubit.load();

      expect(cubit.state.turf?.name, 'Turf A');
      expect(cubit.state.selectedDate, isNotNull);
      expect(cubit.state.slots, isNotEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('load sets errorMessage on failure', () async {
      fakeService.shouldThrow = true;
      final cubit = ScheduleCubit(service: fakeService, turfId: 'turf-a');
      await cubit.load();

      expect(cubit.state.errorMessage, isNotNull);
      expect(cubit.state.turf, isNull);
      expect(cubit.state.isLoading, isFalse);
    });

    test('selectDate refreshes slots for the new date', () async {
      final cubit = ScheduleCubit(service: fakeService, turfId: 'turf-a');
      await cubit.load();

      final DateTime baseDate = cubit.state.selectedDate ?? DateTime.now();
      final DateTime nextDate = baseDate.add(const Duration(days: 1));

      await cubit.selectDate(nextDate);
      expect(cubit.state.selectedDate, nextDate);
      expect(cubit.state.isLoading, isFalse);
    });

    test(
      'selectDate keeps existing turf when turf is already loaded',
      () async {
        final cubit = ScheduleCubit(service: fakeService, turfId: 'turf-a');
        await cubit.load();

        final DateTime baseDate = cubit.state.selectedDate ?? DateTime.now();
        final DateTime nextDate = baseDate.add(const Duration(days: 1));
        await cubit.selectDate(nextDate);

        expect(cubit.state.turf, isNotNull);
        expect(cubit.state.turf?.name, 'Turf A');
      },
    );

    test('dayStats computes booking count and revenue', () async {
      final Slot slot = Slot(
        id: 's1',
        turfId: 'turf-a',
        slotDate: DateTime.now(),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        status: SlotStatus.booked,
      );
      final Booking booking = Booking(
        id: 'b1',
        bookingCode: 'BK-001',
        userId: 'u1',
        turfId: 'turf-a',
        slotId: 's1',
        totalAmount: 250.0,
        advanceAmount: 100.0,
        remainingAmount: 150.0,
        status: BookingStatus.confirmed,
      );
      final ScheduleSlotItem bookedItem = ScheduleSlotItem(
        slot: slot,
        booking: booking,
        customerName: 'Team Alpha',
      );

      final Slot availableSlot = Slot(
        id: 's2',
        turfId: 'turf-a',
        slotDate: DateTime.now(),
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        status: SlotStatus.available,
      );
      final ScheduleSlotItem availableItem = ScheduleSlotItem(
        slot: availableSlot,
      );

      final cubit = ScheduleCubit(
        service: _StaticSlotsService([bookedItem, availableItem]),
        turfId: 'turf-a',
      );
      await cubit.load();

      expect(cubit.state.dayStats.bookingCount, 1);
      expect(cubit.state.dayStats.revenue, 250.0);
    });

    test('bookSlot converts available slot to booked', () async {
      final cubit = ScheduleCubit(service: fakeService, turfId: 'turf-a');
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
  });
}

/// Returns a fixed slot list from `getSchedule`, ignoring the booking flow
/// (used by the dayStats test, which only needs static data).
class _StaticSlotsService implements BookingService {
  _StaticSlotsService(this.slots);

  final List<ScheduleSlotItem> slots;

  @override
  Future<TurfSummary> getTurf(String turfId) async {
    return const TurfSummary(id: 'turf-a', name: 'Turf A');
  }

  @override
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) async {
    return slots;
  }

  @override
  Future<void> bookSlot({
    required String turfId,
    required String slotId,
    String? customerPhone,
  }) async {
    // Never called by the tests that use this service (dayStats only).
  }
}
