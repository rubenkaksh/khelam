import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking.dart';
import 'slot.dart';

part 'schedule_slot_item.freezed.dart';
part 'schedule_slot_item.g.dart';

@freezed
abstract class ScheduleSlotItem with _$ScheduleSlotItem {
  const factory ScheduleSlotItem({
    required Slot slot,
    Booking? booking,
    String? customerName,
    String? bookedByContact,
  }) = _ScheduleSlotItem;

  factory ScheduleSlotItem.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotItemFromJson(json);
}
