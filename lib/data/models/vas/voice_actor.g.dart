// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_actor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceActorImpl _$$VoiceActorImplFromJson(Map<String, dynamic> json) =>
    _$VoiceActorImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt(),
      i18n: json['i18n'] == null
          ? null
          : I18n.fromJson(json['i18n'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VoiceActorImplToJson(_$VoiceActorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'count': instance.count,
      'i18n': instance.i18n,
    };
