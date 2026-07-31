// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingResponseDto _$BookingResponseDtoFromJson(Map<String, dynamic> json) =>
    _BookingResponseDto(
      booking: BookingDto.fromJson(json['booking'] as Map<String, dynamic>),
      slot: BookedSlotDto.fromJson(json['slot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookingResponseDtoToJson(_BookingResponseDto instance) =>
    <String, dynamic>{'booking': instance.booking, 'slot': instance.slot};

_BookingDto _$BookingDtoFromJson(Map<String, dynamic> json) => _BookingDto(
  id: json['id'] as String,
  bookingCode: json['booking_code'] as String,
  userId: json['user_id'] as String,
  turfId: json['turf_id'] as String,
  slotId: json['slot_id'] as String,
  totalAmount: _amountToDouble(json['total_amount']),
  advanceAmount: _amountToDouble(json['advance_amount']),
  remainingAmount: _amountToDouble(json['remaining_amount']),
  status: json['status'] as String,
);

Map<String, dynamic> _$BookingDtoToJson(_BookingDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_code': instance.bookingCode,
      'user_id': instance.userId,
      'turf_id': instance.turfId,
      'slot_id': instance.slotId,
      'total_amount': instance.totalAmount,
      'advance_amount': instance.advanceAmount,
      'remaining_amount': instance.remainingAmount,
      'status': instance.status,
    };

_BookedSlotDto _$BookedSlotDtoFromJson(Map<String, dynamic> json) =>
    _BookedSlotDto(id: json['id'] as String, status: json['status'] as String);

Map<String, dynamic> _$BookedSlotDtoToJson(_BookedSlotDto instance) =>
    <String, dynamic>{'id': instance.id, 'status': instance.status};
