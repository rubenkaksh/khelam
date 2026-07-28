import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking_status.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

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

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}
