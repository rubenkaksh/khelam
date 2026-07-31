import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/domain/models/booking.dart';
import 'package:khelam/domain/models/booking_status.dart';

void main() {
  group('Booking.fromJson', () {
    // Booking row returned by the backend (bookings table, snake_case keys).
    final Map<String, dynamic> bookingJson = <String, dynamic>{
      'id': 'b1',
      'booking_code': 'BK-20260731-0001',
      'user_id': 'u-1',
      'turf_id': '44444444-4444-4444-4444-444444444441',
      'slot_id': 's1',
      'total_amount': '1000.00',
      'advance_amount': '200.00',
      'remaining_amount': '800.00',
      'status': 'pending',
    };

    test('parses a booking (snake_case keys, string Decimal amounts)', () {
      final Booking booking = Booking.fromJson(bookingJson);

      expect(booking.id, 'b1');
      expect(booking.bookingCode, 'BK-20260731-0001');
      expect(booking.userId, 'u-1');
      expect(booking.turfId, '44444444-4444-4444-4444-444444444441');
      expect(booking.slotId, 's1');
      expect(booking.totalAmount, 1000.0);
      expect(booking.advanceAmount, 200.0);
      expect(booking.remainingAmount, 800.0);
      expect(booking.status, BookingStatus.pending);
      expect(booking.customerPhone, isNull);
    });

    test('accepts numeric amounts as well as strings', () {
      final Map<String, dynamic> numericJson = <String, dynamic>{
        ...bookingJson,
        'total_amount': 1500,
        'advance_amount': 500,
        'remaining_amount': 1000,
        'status': 'confirmed',
      };

      final Booking booking = Booking.fromJson(numericJson);

      expect(booking.totalAmount, 1500.0);
      expect(booking.advanceAmount, 500.0);
      expect(booking.remainingAmount, 1000.0);
      expect(booking.status, BookingStatus.confirmed);
    });
  });
}
