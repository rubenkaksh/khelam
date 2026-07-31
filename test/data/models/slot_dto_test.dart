import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/data/models/slot_dto.dart';

void main() {
  group('SlotDto.fromJson', () {
    // Shape documented in lib/ui/features/schedule/data/dummy.dart and
    // returned by GET /slots on the backend.
    final Map<String, dynamic> availableJson = <String, dynamic>{
      'id': '9ded7792-74cf-4dd5-bd32-06ea445547d8',
      'slot_date': '2026-07-31T00:00:00.000Z',
      'start_time': '1970-01-01T06:00:00.000Z',
      'end_time': '1970-01-01T07:00:00.000Z',
      'status': 'available',
      'isBooked': false,
      'bookedBy': null,
    };

    test('parses an available slot (snake + camel keys)', () {
      final SlotDto dto = SlotDto.fromJson(availableJson);

      expect(dto.id, '9ded7792-74cf-4dd5-bd32-06ea445547d8');
      expect(dto.slotDate, DateTime.utc(2026, 7, 31));
      expect(dto.startTime, DateTime.utc(1970, 1, 1, 6));
      expect(dto.endTime, DateTime.utc(1970, 1, 1, 7));
      expect(dto.status, 'available');
      expect(dto.isBooked, isFalse);
      expect(dto.bookedBy, isNull);
    });

    test('parses a booked slot with the booker name', () {
      final Map<String, dynamic> bookedJson = <String, dynamic>{
        ...availableJson,
        'status': 'booked',
        'isBooked': true,
        'bookedBy': 'Rahul Sharma',
      };

      final SlotDto dto = SlotDto.fromJson(bookedJson);

      expect(dto.status, 'booked');
      expect(dto.isBooked, isTrue);
      expect(dto.bookedBy, 'Rahul Sharma');
    });
  });
}
