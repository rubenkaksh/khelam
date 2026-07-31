import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/domain/models/slot.dart';
import 'package:khelam/domain/models/slot_status.dart';

void main() {
  group('Slot.fromJson', () {
    // Shape returned by GET /slots (see
    // lib/ui/features/schedule/data/dummy.dart). The client completes the
    // payload with `turf_id`, which the list endpoint omits per row.
    final Map<String, dynamic> availableJson = <String, dynamic>{
      'id': '9ded7792-74cf-4dd5-bd32-06ea445547d8',
      'turf_id': '44444444-4444-4444-4444-444444444441',
      'slot_date': '2026-07-31T00:00:00.000Z',
      'start_time': '1970-01-01T06:00:00.000Z',
      'end_time': '1970-01-01T07:00:00.000Z',
      'status': 'available',
      'isBooked': false,
      'bookedBy': null,
    };

    test('parses an available slot (snake_case API keys)', () {
      final Slot slot = Slot.fromJson(availableJson);

      expect(slot.id, '9ded7792-74cf-4dd5-bd32-06ea445547d8');
      expect(slot.turfId, '44444444-4444-4444-4444-444444444441');
      expect(slot.slotDate, DateTime.utc(2026, 7, 31));
      expect(slot.startTime, DateTime.utc(1970, 1, 1, 6));
      expect(slot.endTime, DateTime.utc(1970, 1, 1, 7));
      expect(slot.status, SlotStatus.available);
      expect(slot.lockedBy, isNull);
      expect(slot.lockedAt, isNull);
    });

    test('parses a booked slot (status string maps to the enum)', () {
      final Map<String, dynamic> bookedJson = <String, dynamic>{
        ...availableJson,
        'status': 'booked',
        'isBooked': true,
        'bookedBy': 'Rahul Sharma',
      };

      final Slot slot = Slot.fromJson(bookedJson);

      expect(slot.status, SlotStatus.booked);
    });
  });
}
