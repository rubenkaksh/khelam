import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/data/models/booking_dto.dart';

void main() {
  group('BookingResponseDto.fromJson', () {
    final Map<String, dynamic> responseJson = <String, dynamic>{
      'booking': <String, dynamic>{
        'id': 'b1',
        'booking_code': 'BK-20260731-0001',
        'user_id': 'u-1',
        'turf_id': '44444444-4444-4444-4444-444444444441',
        'slot_id': 's1',
        'total_amount': '1000.00',
        'advance_amount': '200.00',
        'remaining_amount': '800.00',
        'status': 'confirmed',
      },
      'slot': <String, dynamic>{'id': 's1', 'status': 'booked'},
    };

    test('parses the booking and updated slot', () {
      final BookingResponseDto dto = BookingResponseDto.fromJson(responseJson);

      expect(dto.booking.id, 'b1');
      expect(dto.booking.bookingCode, 'BK-20260731-0001');
      expect(dto.booking.userId, 'u-1');
      expect(dto.booking.turfId, '44444444-4444-4444-4444-444444444441');
      expect(dto.booking.slotId, 's1');
      expect(dto.booking.status, 'confirmed');
      expect(dto.slot.id, 's1');
      expect(dto.slot.status, 'booked');
    });

    test('parses Prisma Decimal amounts serialized as strings', () {
      final BookingResponseDto dto = BookingResponseDto.fromJson(responseJson);

      expect(dto.booking.totalAmount, 1000.0);
      expect(dto.booking.advanceAmount, 200.0);
      expect(dto.booking.remainingAmount, 800.0);
    });

    test('accepts numeric amounts as well as strings', () {
      final Map<String, dynamic> numericJson = <String, dynamic>{
        ...responseJson,
        'booking': <String, dynamic>{
          ...responseJson['booking']! as Map<String, dynamic>,
          'total_amount': 1500,
          'advance_amount': 500,
          'remaining_amount': 1000,
        },
      };

      final BookingResponseDto dto = BookingResponseDto.fromJson(numericJson);

      expect(dto.booking.totalAmount, 1500.0);
      expect(dto.booking.advanceAmount, 500.0);
      expect(dto.booking.remainingAmount, 1000.0);
    });
  });
}
