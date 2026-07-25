import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_status.freezed.dart';
part 'sample_status.g.dart';

@freezed
abstract class SampleStatus with _$SampleStatus {
  const factory SampleStatus({
    required String id,
    required String message,
    required bool isHealthy,
  }) = _SampleStatus;

  factory SampleStatus.fromJson(Map<String, dynamic> json) =>
      _$SampleStatusFromJson(json);
}
