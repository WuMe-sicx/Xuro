// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RankInfoImpl _$$RankInfoImplFromJson(Map<String, dynamic> json) =>
    _$RankInfoImpl(
      term: json['term'] as String?,
      category: json['category'] as String?,
      rank: (json['rank'] as num?)?.toInt(),
      rankDate: json['rank_date'] as String?,
    );

Map<String, dynamic> _$$RankInfoImplToJson(_$RankInfoImpl instance) =>
    <String, dynamic>{
      'term': instance.term,
      'category': instance.category,
      'rank': instance.rank,
      'rank_date': instance.rankDate,
    };
