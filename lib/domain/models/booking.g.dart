// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  bookingCode: json['bookingCode'] as String,
  userId: json['userId'] as String,
  turfId: json['turfId'] as String,
  slotId: json['slotId'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  advanceAmount: (json['advanceAmount'] as num).toDouble(),
  remainingAmount: (json['remainingAmount'] as num).toDouble(),
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'bookingCode': instance.bookingCode,
  'userId': instance.userId,
  'turfId': instance.turfId,
  'slotId': instance.slotId,
  'totalAmount': instance.totalAmount,
  'advanceAmount': instance.advanceAmount,
  'remainingAmount': instance.remainingAmount,
  'status': _$BookingStatusEnumMap[instance.status]!,
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};
