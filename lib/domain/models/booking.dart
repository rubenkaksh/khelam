// JsonKey on freezed constructor parameters is copied onto the generated
// fields; the analyzer flags the source annotation target (see freezed docs).
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking_status.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    @JsonKey(name: 'booking_code') required String bookingCode,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'turf_id') required String turfId,
    @JsonKey(name: 'slot_id') required String slotId,
    // Money fields are Prisma `Decimal`s which serialize as JSON strings
    // (e.g. `"1000.00"`); [_amountToDouble] accepts both string and number.
    @JsonKey(name: 'total_amount', fromJson: _amountToDouble)
    required double totalAmount,
    @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)
    required double advanceAmount,
    @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)
    required double remainingAmount,
    required BookingStatus status,
    String? customerPhone,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

double _amountToDouble(Object? value) =>
    value is num ? value.toDouble() : double.parse(value as String);
