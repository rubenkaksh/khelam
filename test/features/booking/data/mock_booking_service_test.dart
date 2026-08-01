import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/booking/data/mock_booking_service.dart';
import 'package:khelam/features/booking/models/slot_status.dart';

void main() {
  group('MockBookingService', () {
    final DateTime date = DateTime(2026, 8, 1);

    test('getTurf returns the demo turf', () async {
      final MockBookingService service = MockBookingService();

      final turf = await service.getTurf('any-turf-id');

      expect(turf.id, 'turf-a');
      expect(turf.name, 'Turf A');
    });

    test('getSchedule returns one slot per open hour (07:00–22:00)', () async {
      final MockBookingService service = MockBookingService();

      final items = await service.getSchedule(turfId: 'turf-a', date: date);

      expect(items, hasLength(15));
      expect(items.first.slot.startTime.hour, 7);
      expect(items.last.slot.endTime.hour, 22);
      expect(items.every((item) => item.slot.slotDate == date), isTrue);
    });

    test('bookSlot marks the slot booked on the next refetch', () async {
      final MockBookingService service = MockBookingService();

      final items = await service.getSchedule(turfId: 'turf-a', date: date);
      final target = items.firstWhere(
        (item) => item.slot.status == SlotStatus.available,
      );

      await service.bookSlot(turfId: 'turf-a', slotId: target.slot.id);

      final refetched = await service.getSchedule(turfId: 'turf-a', date: date);
      final updated = refetched.firstWhere(
        (item) => item.slot.id == target.slot.id,
      );
      expect(updated.slot.status, SlotStatus.booked);
      expect(updated.customerName, isNotNull);
    });
  });
}
