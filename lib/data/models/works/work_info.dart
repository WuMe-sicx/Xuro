import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asmrapp/data/models/works/circle.dart';
import 'package:asmrapp/data/models/works/language_edition.dart';
import 'package:asmrapp/data/models/works/other_language_editions_in_db.dart';
import 'package:asmrapp/data/models/works/translation_info.dart';
import 'package:asmrapp/data/models/works/rate_detail.dart';
import 'package:asmrapp/data/models/works/rank_info.dart';
import 'package:asmrapp/data/models/works/work_va.dart';
import 'package:asmrapp/data/models/works/work_tag.dart';

part 'work_info.freezed.dart';
part 'work_info.g.dart';

@freezed
class WorkInfo with _$WorkInfo {
  factory WorkInfo({
    int? id,
    String? title,
    @JsonKey(name: 'circle_id') int? circleId,
    String? name,
    bool? nsfw,
    String? release,
    @JsonKey(name: 'dl_count') int? dlCount,
    int? price,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'rate_count') int? rateCount,
    @JsonKey(name: 'rate_average_2dp') double? rateAverage2dp,
    @JsonKey(name: 'rate_count_detail') List<RateDetail>? rateCountDetail,
    List<RankInfo>? rank,
    @JsonKey(name: 'has_subtitle') bool? hasSubtitle,
    @JsonKey(name: 'create_date') String? createDate,
    List<WorkVA>? vas,
    List<WorkTag>? tags,
    @JsonKey(name: 'language_editions') List<LanguageEdition>? languageEditions,
    @JsonKey(name: 'original_workno') String? originalWorkno,
    @JsonKey(name: 'other_language_editions_in_db')
    List<OtherLanguageEditionsInDb>? otherLanguageEditionsInDb,
    @JsonKey(name: 'translation_info') TranslationInfo? translationInfo,
    @JsonKey(name: 'work_attributes') String? workAttributes,
    @JsonKey(name: 'age_category_string') String? ageCategoryString,
    int? duration,
    @JsonKey(name: 'source_type') String? sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    @JsonKey(name: 'source_url') String? sourceUrl,
    dynamic userRating,
    Circle? circle,
    String? samCoverUrl,
    String? thumbnailCoverUrl,
    String? mainCoverUrl,
  }) = _WorkInfo;

  factory WorkInfo.fromJson(Map<String, dynamic> json) => _$WorkInfoFromJson(json);
}
