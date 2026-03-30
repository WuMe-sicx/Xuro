// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CircleItemImpl _$$CircleItemImplFromJson(Map<String, dynamic> json) =>
    _$CircleItemImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt(),
      i18n: json['i18n'] == null
          ? null
          : I18n.fromJson(json['i18n'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CircleItemImplToJson(_$CircleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'count': instance.count,
      'i18n': instance.i18n,
    };
