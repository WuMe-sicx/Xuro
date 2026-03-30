// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkTagImpl _$$WorkTagImplFromJson(Map<String, dynamic> json) =>
    _$WorkTagImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      i18n: json['i18n'] == null
          ? null
          : I18n.fromJson(json['i18n'] as Map<String, dynamic>),
      upvote: (json['upvote'] as num?)?.toInt(),
      downvote: (json['downvote'] as num?)?.toInt(),
      voteRank: (json['voteRank'] as num?)?.toInt(),
      voteStatus: (json['voteStatus'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WorkTagImplToJson(_$WorkTagImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'i18n': instance.i18n,
      'upvote': instance.upvote,
      'downvote': instance.downvote,
      'voteRank': instance.voteRank,
      'voteStatus': instance.voteStatus,
    };
