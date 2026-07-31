// JsonKey on freezed constructor parameters is copied onto the generated
// fields; the analyzer flags the source annotation target (see freezed docs).
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'slot_status.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

@freezed
abstract class Slot with _$Slot {
  const factory Slot({
    required String id,
    @JsonKey(name: 'turf_id') required String turfId,
    @JsonKey(name: 'slot_date') required DateTime slotDate,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required SlotStatus status,
    String? lockedBy,
    DateTime? lockedAt,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
