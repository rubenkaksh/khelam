// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Slot _$SlotFromJson(Map<String, dynamic> json) => _Slot(
  id: json['id'] as String,
  turfId: json['turfId'] as String,
  slotDate: DateTime.parse(json['slotDate'] as String),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  status: $enumDecode(_$SlotStatusEnumMap, json['status']),
  lockedBy: json['lockedBy'] as String?,
  lockedAt: json['lockedAt'] == null
      ? null
      : DateTime.parse(json['lockedAt'] as String),
);

Map<String, dynamic> _$SlotToJson(_Slot instance) => <String, dynamic>{
  'id': instance.id,
  'turfId': instance.turfId,
  'slotDate': instance.slotDate.toIso8601String(),
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'status': _$SlotStatusEnumMap[instance.status]!,
  'lockedBy': instance.lockedBy,
  'lockedAt': instance.lockedAt?.toIso8601String(),
};

const _$SlotStatusEnumMap = {
  SlotStatus.available: 'available',
  SlotStatus.booked: 'booked',
  SlotStatus.locked: 'locked',
  SlotStatus.unavailable: 'unavailable',
};
