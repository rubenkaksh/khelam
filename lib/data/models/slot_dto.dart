// JsonKey on freezed constructor parameters is copied onto the generated
// fields; the analyzer flags the source annotation target (see freezed docs).
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'slot_dto.freezed.dart';
part 'slot_dto.g.dart';

/// A slot row as returned by `GET /slots` on the backend.
///
/// Mirrors the API shape exactly (snake_case keys):
/// - `slot_date` is the calendar date (`2026-07-31T00:00:00.000Z`)
/// - `start_time` / `end_time` carry only the time-of-day with a dummy date
///   (`1970-01-01T06:00:00.000Z`), matching Postgres `TIME` via Prisma
/// - `status` is a raw string (`available`, `booked`, ...)
@freezed
abstract class SlotDto with _$SlotDto {
  const factory SlotDto({
    required String id,
    @JsonKey(name: 'slot_date') required DateTime slotDate,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required String status,
    @JsonKey(name: 'isBooked') required bool isBooked,
    String? bookedBy,
  }) = _SlotDto;

  factory SlotDto.fromJson(Map<String, dynamic> json) => _$SlotDtoFromJson(json);
}
