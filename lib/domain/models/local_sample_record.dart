import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_sample_record.freezed.dart';
part 'local_sample_record.g.dart';

@freezed
abstract class LocalSampleRecord with _$LocalSampleRecord {
  const factory LocalSampleRecord({
    required String key,
    required String value,
  }) = _LocalSampleRecord;

  factory LocalSampleRecord.fromJson(Map<String, dynamic> json) =>
      _$LocalSampleRecordFromJson(json);
}
