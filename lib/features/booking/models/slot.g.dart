// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Slot _$SlotFromJson(Map<String, dynamic> json) => _Slot(
  id: json['id'] as String,
  turfId: json['turf_id'] as String,
  slotDate: DateTime.parse(json['slot_date'] as String),
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  status: $enumDecode(_$SlotStatusEnumMap, json['status']),
  lockedBy: json['lockedBy'] as String?,
  lockedAt: json['lockedAt'] == null
      ? null
      : DateTime.parse(json['lockedAt'] as String),
);

Map<String, dynamic> _$SlotToJson(_Slot instance) => <String, dynamic>{
  'id': instance.id,
  'turf_id': instance.turfId,
  'slot_date': instance.slotDate.toIso8601String(),
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'status': _$SlotStatusEnumMap[instance.status]!,
  'lockedBy': instance.lockedBy,
  'lockedAt': instance.lockedAt?.toIso8601String(),
};

const _$SlotStatusEnumMap = {
  SlotStatus.available: 'available',
  SlotStatus.booked: 'booked',
  SlotStatus.locked: 'locked',
  SlotStatus.unavailable: 'unavailable',
  SlotStatus.reserved: 'reserved',
};
