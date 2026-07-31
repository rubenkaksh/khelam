// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlotDto _$SlotDtoFromJson(Map<String, dynamic> json) => _SlotDto(
  id: json['id'] as String,
  slotDate: DateTime.parse(json['slot_date'] as String),
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  status: json['status'] as String,
  isBooked: json['isBooked'] as bool,
  bookedBy: json['bookedBy'] as String?,
);

Map<String, dynamic> _$SlotDtoToJson(_SlotDto instance) => <String, dynamic>{
  'id': instance.id,
  'slot_date': instance.slotDate.toIso8601String(),
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'status': instance.status,
  'isBooked': instance.isBooked,
  'bookedBy': instance.bookedBy,
};
