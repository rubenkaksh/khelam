import 'package:freezed_annotation/freezed_annotation.dart';

import 'slot_status.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

@freezed
abstract class Slot with _$Slot {
  const factory Slot({
    required String id,
    required String turfId,
    required DateTime slotDate,
    required DateTime startTime,
    required DateTime endTime,
    required SlotStatus status,
    String? lockedBy,
    DateTime? lockedAt,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
