// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turf_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TurfSummary _$TurfSummaryFromJson(Map<String, dynamic> json) => _TurfSummary(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  coverImageUrl: json['cover_image_url'] as String?,
  pricePerHour: (json['price_per_hour'] as num?)?.toDouble(),
  advanceAmount: (json['advance_amount'] as num?)?.toDouble(),
  rating: (json['rating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TurfSummaryToJson(_TurfSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'cover_image_url': instance.coverImageUrl,
      'price_per_hour': instance.pricePerHour,
      'advance_amount': instance.advanceAmount,
      'rating': instance.rating,
    };
