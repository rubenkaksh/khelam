// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_slot_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleSlotItem _$ScheduleSlotItemFromJson(Map<String, dynamic> json) =>
    _ScheduleSlotItem(
      slot: Slot.fromJson(json['slot'] as Map<String, dynamic>),
      booking: json['booking'] == null
          ? null
          : Booking.fromJson(json['booking'] as Map<String, dynamic>),
      customerName: json['customerName'] as String?,
      bookedByContact: json['bookedByContact'] as String?,
    );

Map<String, dynamic> _$ScheduleSlotItemToJson(_ScheduleSlotItem instance) =>
    <String, dynamic>{
      'slot': instance.slot,
      'booking': instance.booking,
      'customerName': instance.customerName,
      'bookedByContact': instance.bookedByContact,
    };
