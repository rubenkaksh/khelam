// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  bookingCode: json['booking_code'] as String,
  userId: json['user_id'] as String,
  turfId: json['turf_id'] as String,
  slotId: json['slot_id'] as String,
  totalAmount: _amountToDouble(json['total_amount']),
  advanceAmount: _amountToDouble(json['advance_amount']),
  remainingAmount: _amountToDouble(json['remaining_amount']),
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  customerPhone: json['customerPhone'] as String?,
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'booking_code': instance.bookingCode,
  'user_id': instance.userId,
  'turf_id': instance.turfId,
  'slot_id': instance.slotId,
  'total_amount': instance.totalAmount,
  'advance_amount': instance.advanceAmount,
  'remaining_amount': instance.remainingAmount,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'customerPhone': instance.customerPhone,
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};
