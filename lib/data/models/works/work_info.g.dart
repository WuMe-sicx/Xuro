// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkInfoImpl _$$WorkInfoImplFromJson(Map<String, dynamic> json) =>
    _$WorkInfoImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      circleId: (json['circle_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      nsfw: json['nsfw'] as bool?,
      release: json['release'] as String?,
      dlCount: (json['dl_count'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toInt(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      rateCount: (json['rate_count'] as num?)?.toInt(),
      rateAverage2dp: (json['rate_average_2dp'] as num?)?.toDouble(),
      rateCountDetail: (json['rate_count_detail'] as List<dynamic>?)
          ?.map((e) => RateDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      rank: (json['rank'] as List<dynamic>?)
          ?.map((e) => RankInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasSubtitle: json['has_subtitle'] as bool?,
      createDate: json['create_date'] as String?,
      vas: (json['vas'] as List<dynamic>?)
          ?.map((e) => WorkVA.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => WorkTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      languageEditions: (json['language_editions'] as List<dynamic>?)
          ?.map((e) => LanguageEdition.fromJson(e as Map<String, dynamic>))
          .toList(),
      originalWorkno: json['original_workno'] as String?,
      otherLanguageEditionsInDb:
          (json['other_language_editions_in_db'] as List<dynamic>?)
              ?.map((e) =>
                  OtherLanguageEditionsInDb.fromJson(e as Map<String, dynamic>))
              .toList(),
      translationInfo: json['translation_info'] == null
          ? null
          : TranslationInfo.fromJson(
              json['translation_info'] as Map<String, dynamic>),
      workAttributes: json['work_attributes'] as String?,
      ageCategoryString: json['age_category_string'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
      sourceUrl: json['source_url'] as String?,
      userRating: json['userRating'],
      circle: json['circle'] == null
          ? null
          : Circle.fromJson(json['circle'] as Map<String, dynamic>),
      samCoverUrl: json['samCoverUrl'] as String?,
      thumbnailCoverUrl: json['thumbnailCoverUrl'] as String?,
      mainCoverUrl: json['mainCoverUrl'] as String?,
    );

Map<String, dynamic> _$$WorkInfoImplToJson(_$WorkInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'circle_id': instance.circleId,
      'name': instance.name,
      'nsfw': instance.nsfw,
      'release': instance.release,
      'dl_count': instance.dlCount,
      'price': instance.price,
      'review_count': instance.reviewCount,
      'rate_count': instance.rateCount,
      'rate_average_2dp': instance.rateAverage2dp,
      'rate_count_detail': instance.rateCountDetail,
      'rank': instance.rank,
      'has_subtitle': instance.hasSubtitle,
      'create_date': instance.createDate,
      'vas': instance.vas,
      'tags': instance.tags,
      'language_editions': instance.languageEditions,
      'original_workno': instance.originalWorkno,
      'other_language_editions_in_db': instance.otherLanguageEditionsInDb,
      'translation_info': instance.translationInfo,
      'work_attributes': instance.workAttributes,
      'age_category_string': instance.ageCategoryString,
      'duration': instance.duration,
      'source_type': instance.sourceType,
      'source_id': instance.sourceId,
      'source_url': instance.sourceUrl,
      'userRating': instance.userRating,
      'circle': instance.circle,
      'samCoverUrl': instance.samCoverUrl,
      'thumbnailCoverUrl': instance.thumbnailCoverUrl,
      'mainCoverUrl': instance.mainCoverUrl,
    };
