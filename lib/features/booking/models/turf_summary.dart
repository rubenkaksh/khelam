import 'package:freezed_annotation/freezed_annotation.dart';

part 'turf_summary.freezed.dart';
part 'turf_summary.g.dart';

@freezed
abstract class TurfSummary with _$TurfSummary {
  const factory TurfSummary({
    required String id,
    required String name,
    String? address,
  }) = _TurfSummary;

  factory TurfSummary.fromJson(Map<String, dynamic> json) =>
      _$TurfSummaryFromJson(json);
}
