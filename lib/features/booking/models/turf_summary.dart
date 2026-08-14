// JsonKey on freezed constructor parameters is copied onto the generated
// fields; the analyzer flags the source annotation target (see freezed docs).
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'turf_summary.freezed.dart';
part 'turf_summary.g.dart';

@freezed
abstract class TurfSummary with _$TurfSummary {
  const factory TurfSummary({
    required String id,
    required String name,
    String? address,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'price_per_hour') double? pricePerHour,
    @JsonKey(name: 'advance_amount') double? advanceAmount,
    double? rating,
  }) = _TurfSummary;

  factory TurfSummary.fromJson(Map<String, dynamic> json) =>
      _$TurfSummaryFromJson(json);
}
