// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SampleStatus _$SampleStatusFromJson(Map<String, dynamic> json) =>
    _SampleStatus(
      id: json['id'] as String,
      message: json['message'] as String,
      isHealthy: json['isHealthy'] as bool,
    );

Map<String, dynamic> _$SampleStatusToJson(_SampleStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'isHealthy': instance.isHealthy,
    };
