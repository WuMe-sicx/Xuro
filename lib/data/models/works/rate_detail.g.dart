// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RateDetailImpl _$$RateDetailImplFromJson(Map<String, dynamic> json) =>
    _$RateDetailImpl(
      reviewPoint: (json['review_point'] as num?)?.toInt(),
      count: (json['count'] as num?)?.toInt(),
      ratio: (json['ratio'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RateDetailImplToJson(_$RateDetailImpl instance) =>
    <String, dynamic>{
      'review_point': instance.reviewPoint,
      'count': instance.count,
      'ratio': instance.ratio,
    };
