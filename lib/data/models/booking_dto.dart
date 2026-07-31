// JsonKey on freezed constructor parameters is copied onto the generated
// fields; the analyzer flags the source annotation target (see freezed docs).
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_dto.freezed.dart';
part 'booking_dto.g.dart';

/// Response of `POST /slots/:id/book`: the created booking plus the updated slot.
@freezed
abstract class BookingResponseDto with _$BookingResponseDto {
  const factory BookingResponseDto({
    required BookingDto booking,
    required BookedSlotDto slot,
  }) = _BookingResponseDto;

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseDtoFromJson(json);
}

/// A booking row as returned by the backend (snake_case keys).
///
/// Money fields are Prisma `Decimal`s which serialize as JSON strings
/// (e.g. `"1000.00"`); [_amountToDouble] accepts both string and number.
@freezed
abstract class BookingDto with _$BookingDto {
  const factory BookingDto({
    required String id,
    @JsonKey(name: 'booking_code') required String bookingCode,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'turf_id') required String turfId,
    @JsonKey(name: 'slot_id') required String slotId,
    @JsonKey(name: 'total_amount', fromJson: _amountToDouble)
    required double totalAmount,
    @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)
    required double advanceAmount,
    @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)
    required double remainingAmount,
    required String status,
  }) = _BookingDto;

  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);
}

double _amountToDouble(Object? value) =>
    value is num ? value.toDouble() : double.parse(value as String);

/// The updated slot portion of the book response.
@freezed
abstract class BookedSlotDto with _$BookedSlotDto {
  const factory BookedSlotDto({
    required String id,
    required String status,
  }) = _BookedSlotDto;

  factory BookedSlotDto.fromJson(Map<String, dynamic> json) =>
      _$BookedSlotDtoFromJson(json);
}
