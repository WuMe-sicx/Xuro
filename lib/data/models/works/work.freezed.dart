// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Work _$WorkFromJson(Map<String, dynamic> json) {
  return _Work.fromJson(json);
}

/// @nodoc
mixin _$Work {
  int? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'circle_id')
  int? get circleId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  bool? get nsfw => throw _privateConstructorUsedError;
  String? get release => throw _privateConstructorUsedError;
  @JsonKey(name: 'dl_count')
  int? get dlCount => throw _privateConstructorUsedError;
  int? get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'rate_count')
  int? get rateCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'rate_average_2dp')
  int? get rateAverage2dp => throw _privateConstructorUsedError;
  @JsonKey(name: 'rate_count_detail')
  List<dynamic>? get rateCountDetail => throw _privateConstructorUsedError;
  dynamic get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_subtitle')
  bool? get hasSubtitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_date')
  String? get createDate => throw _privateConstructorUsedError;
  List<dynamic>? get vas => throw _privateConstructorUsedError;
  List<Tag>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'language_editions')
  List<LanguageEdition>? get languageEditions =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'original_workno')
  String? get originalWorkno => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_language_editions_in_db')
  List<OtherLanguageEditionsInDb>? get otherLanguageEditionsInDb =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'translation_info')
  TranslationInfo? get translationInfo => throw _privateConstructorUsedError;
  @JsonKey(name: 'work_attributes')
  String? get workAttributes => throw _privateConstructorUsedError;
  @JsonKey(name: 'age_category_string')
  String? get ageCategoryString => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_type')
  String? get sourceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_id')
  String? get sourceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_url')
  String? get sourceUrl => throw _privateConstructorUsedError;
  dynamic get userRating => throw _privateConstructorUsedError;
  Circle? get circle => throw _privateConstructorUsedError;
  String? get samCoverUrl => throw _privateConstructorUsedError;
  String? get thumbnailCoverUrl => throw _privateConstructorUsedError;
  String? get mainCoverUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkCopyWith<Work> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkCopyWith<$Res> {
  factory $WorkCopyWith(Work value, $Res Function(Work) then) =
      _$WorkCopyWithImpl<$Res, Work>;
  @useResult
  $Res call(
      {int? id,
      String? title,
      @JsonKey(name: 'circle_id') int? circleId,
      String? name,
      bool? nsfw,
      String? release,
      @JsonKey(name: 'dl_count') int? dlCount,
      int? price,
      @JsonKey(name: 'review_count') int? reviewCount,
      @JsonKey(name: 'rate_count') int? rateCount,
      @JsonKey(name: 'rate_average_2dp') int? rateAverage2dp,
      @JsonKey(name: 'rate_count_detail') List<dynamic>? rateCountDetail,
      dynamic rank,
      @JsonKey(name: 'has_subtitle') bool? hasSubtitle,
      @JsonKey(name: 'create_date') String? createDate,
      List<dynamic>? vas,
      List<Tag>? tags,
      @JsonKey(name: 'language_editions')
      List<LanguageEdition>? languageEditions,
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
      String? mainCoverUrl});

  $TranslationInfoCopyWith<$Res>? get translationInfo;
  $CircleCopyWith<$Res>? get circle;
}

/// @nodoc
class _$WorkCopyWithImpl<$Res, $Val extends Work>
    implements $WorkCopyWith<$Res> {
  _$WorkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? circleId = freezed,
    Object? name = freezed,
    Object? nsfw = freezed,
    Object? release = freezed,
    Object? dlCount = freezed,
    Object? price = freezed,
    Object? reviewCount = freezed,
    Object? rateCount = freezed,
    Object? rateAverage2dp = freezed,
    Object? rateCountDetail = freezed,
    Object? rank = freezed,
    Object? hasSubtitle = freezed,
    Object? createDate = freezed,
    Object? vas = freezed,
    Object? tags = freezed,
    Object? languageEditions = freezed,
    Object? originalWorkno = freezed,
    Object? otherLanguageEditionsInDb = freezed,
    Object? translationInfo = freezed,
    Object? workAttributes = freezed,
    Object? ageCategoryString = freezed,
    Object? duration = freezed,
    Object? sourceType = freezed,
    Object? sourceId = freezed,
    Object? sourceUrl = freezed,
    Object? userRating = freezed,
    Object? circle = freezed,
    Object? samCoverUrl = freezed,
    Object? thumbnailCoverUrl = freezed,
    Object? mainCoverUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      circleId: freezed == circleId
          ? _value.circleId
          : circleId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      nsfw: freezed == nsfw
          ? _value.nsfw
          : nsfw // ignore: cast_nullable_to_non_nullable
              as bool?,
      release: freezed == release
          ? _value.release
          : release // ignore: cast_nullable_to_non_nullable
              as String?,
      dlCount: freezed == dlCount
          ? _value.dlCount
          : dlCount // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int?,
      reviewCount: freezed == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      rateCount: freezed == rateCount
          ? _value.rateCount
          : rateCount // ignore: cast_nullable_to_non_nullable
              as int?,
      rateAverage2dp: freezed == rateAverage2dp
          ? _value.rateAverage2dp
          : rateAverage2dp // ignore: cast_nullable_to_non_nullable
              as int?,
      rateCountDetail: freezed == rateCountDetail
          ? _value.rateCountDetail
          : rateCountDetail // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as dynamic,
      hasSubtitle: freezed == hasSubtitle
          ? _value.hasSubtitle
          : hasSubtitle // ignore: cast_nullable_to_non_nullable
              as bool?,
      createDate: freezed == createDate
          ? _value.createDate
          : createDate // ignore: cast_nullable_to_non_nullable
              as String?,
      vas: freezed == vas
          ? _value.vas
          : vas // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>?,
      languageEditions: freezed == languageEditions
          ? _value.languageEditions
          : languageEditions // ignore: cast_nullable_to_non_nullable
              as List<LanguageEdition>?,
      originalWorkno: freezed == originalWorkno
          ? _value.originalWorkno
          : originalWorkno // ignore: cast_nullable_to_non_nullable
              as String?,
      otherLanguageEditionsInDb: freezed == otherLanguageEditionsInDb
          ? _value.otherLanguageEditionsInDb
          : otherLanguageEditionsInDb // ignore: cast_nullable_to_non_nullable
              as List<OtherLanguageEditionsInDb>?,
      translationInfo: freezed == translationInfo
          ? _value.translationInfo
          : translationInfo // ignore: cast_nullable_to_non_nullable
              as TranslationInfo?,
      workAttributes: freezed == workAttributes
          ? _value.workAttributes
          : workAttributes // ignore: cast_nullable_to_non_nullable
              as String?,
      ageCategoryString: freezed == ageCategoryString
          ? _value.ageCategoryString
          : ageCategoryString // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: freezed == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceUrl: freezed == sourceUrl
          ? _value.sourceUrl
          : sourceUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userRating: freezed == userRating
          ? _value.userRating
          : userRating // ignore: cast_nullable_to_non_nullable
              as dynamic,
      circle: freezed == circle
          ? _value.circle
          : circle // ignore: cast_nullable_to_non_nullable
              as Circle?,
      samCoverUrl: freezed == samCoverUrl
          ? _value.samCoverUrl
          : samCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailCoverUrl: freezed == thumbnailCoverUrl
          ? _value.thumbnailCoverUrl
          : thumbnailCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mainCoverUrl: freezed == mainCoverUrl
          ? _value.mainCoverUrl
          : mainCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TranslationInfoCopyWith<$Res>? get translationInfo {
    if (_value.translationInfo == null) {
      return null;
    }

    return $TranslationInfoCopyWith<$Res>(_value.translationInfo!, (value) {
      return _then(_value.copyWith(translationInfo: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CircleCopyWith<$Res>? get circle {
    if (_value.circle == null) {
      return null;
    }

    return $CircleCopyWith<$Res>(_value.circle!, (value) {
      return _then(_value.copyWith(circle: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkImplCopyWith<$Res> implements $WorkCopyWith<$Res> {
  factory _$$WorkImplCopyWith(
          _$WorkImpl value, $Res Function(_$WorkImpl) then) =
      __$$WorkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? title,
      @JsonKey(name: 'circle_id') int? circleId,
      String? name,
      bool? nsfw,
      String? release,
      @JsonKey(name: 'dl_count') int? dlCount,
      int? price,
      @JsonKey(name: 'review_count') int? reviewCount,
      @JsonKey(name: 'rate_count') int? rateCount,
      @JsonKey(name: 'rate_average_2dp') int? rateAverage2dp,
      @JsonKey(name: 'rate_count_detail') List<dynamic>? rateCountDetail,
      dynamic rank,
      @JsonKey(name: 'has_subtitle') bool? hasSubtitle,
      @JsonKey(name: 'create_date') String? createDate,
      List<dynamic>? vas,
      List<Tag>? tags,
      @JsonKey(name: 'language_editions')
      List<LanguageEdition>? languageEditions,
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
      String? mainCoverUrl});

  @override
  $TranslationInfoCopyWith<$Res>? get translationInfo;
  @override
  $CircleCopyWith<$Res>? get circle;
}

/// @nodoc
class __$$WorkImplCopyWithImpl<$Res>
    extends _$WorkCopyWithImpl<$Res, _$WorkImpl>
    implements _$$WorkImplCopyWith<$Res> {
  __$$WorkImplCopyWithImpl(_$WorkImpl _value, $Res Function(_$WorkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? circleId = freezed,
    Object? name = freezed,
    Object? nsfw = freezed,
    Object? release = freezed,
    Object? dlCount = freezed,
    Object? price = freezed,
    Object? reviewCount = freezed,
    Object? rateCount = freezed,
    Object? rateAverage2dp = freezed,
    Object? rateCountDetail = freezed,
    Object? rank = freezed,
    Object? hasSubtitle = freezed,
    Object? createDate = freezed,
    Object? vas = freezed,
    Object? tags = freezed,
    Object? languageEditions = freezed,
    Object? originalWorkno = freezed,
    Object? otherLanguageEditionsInDb = freezed,
    Object? translationInfo = freezed,
    Object? workAttributes = freezed,
    Object? ageCategoryString = freezed,
    Object? duration = freezed,
    Object? sourceType = freezed,
    Object? sourceId = freezed,
    Object? sourceUrl = freezed,
    Object? userRating = freezed,
    Object? circle = freezed,
    Object? samCoverUrl = freezed,
    Object? thumbnailCoverUrl = freezed,
    Object? mainCoverUrl = freezed,
  }) {
    return _then(_$WorkImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      circleId: freezed == circleId
          ? _value.circleId
          : circleId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      nsfw: freezed == nsfw
          ? _value.nsfw
          : nsfw // ignore: cast_nullable_to_non_nullable
              as bool?,
      release: freezed == release
          ? _value.release
          : release // ignore: cast_nullable_to_non_nullable
              as String?,
      dlCount: freezed == dlCount
          ? _value.dlCount
          : dlCount // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int?,
      reviewCount: freezed == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      rateCount: freezed == rateCount
          ? _value.rateCount
          : rateCount // ignore: cast_nullable_to_non_nullable
              as int?,
      rateAverage2dp: freezed == rateAverage2dp
          ? _value.rateAverage2dp
          : rateAverage2dp // ignore: cast_nullable_to_non_nullable
              as int?,
      rateCountDetail: freezed == rateCountDetail
          ? _value._rateCountDetail
          : rateCountDetail // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as dynamic,
      hasSubtitle: freezed == hasSubtitle
          ? _value.hasSubtitle
          : hasSubtitle // ignore: cast_nullable_to_non_nullable
              as bool?,
      createDate: freezed == createDate
          ? _value.createDate
          : createDate // ignore: cast_nullable_to_non_nullable
              as String?,
      vas: freezed == vas
          ? _value._vas
          : vas // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>?,
      languageEditions: freezed == languageEditions
          ? _value._languageEditions
          : languageEditions // ignore: cast_nullable_to_non_nullable
              as List<LanguageEdition>?,
      originalWorkno: freezed == originalWorkno
          ? _value.originalWorkno
          : originalWorkno // ignore: cast_nullable_to_non_nullable
              as String?,
      otherLanguageEditionsInDb: freezed == otherLanguageEditionsInDb
          ? _value._otherLanguageEditionsInDb
          : otherLanguageEditionsInDb // ignore: cast_nullable_to_non_nullable
              as List<OtherLanguageEditionsInDb>?,
      translationInfo: freezed == translationInfo
          ? _value.translationInfo
          : translationInfo // ignore: cast_nullable_to_non_nullable
              as TranslationInfo?,
      workAttributes: freezed == workAttributes
          ? _value.workAttributes
          : workAttributes // ignore: cast_nullable_to_non_nullable
              as String?,
      ageCategoryString: freezed == ageCategoryString
          ? _value.ageCategoryString
          : ageCategoryString // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: freezed == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceUrl: freezed == sourceUrl
          ? _value.sourceUrl
          : sourceUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userRating: freezed == userRating
          ? _value.userRating
          : userRating // ignore: cast_nullable_to_non_nullable
              as dynamic,
      circle: freezed == circle
          ? _value.circle
          : circle // ignore: cast_nullable_to_non_nullable
              as Circle?,
      samCoverUrl: freezed == samCoverUrl
          ? _value.samCoverUrl
          : samCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailCoverUrl: freezed == thumbnailCoverUrl
          ? _value.thumbnailCoverUrl
          : thumbnailCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mainCoverUrl: freezed == mainCoverUrl
          ? _value.mainCoverUrl
          : mainCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkImpl implements _Work {
  _$WorkImpl(
      {this.id,
      this.title,
      @JsonKey(name: 'circle_id') this.circleId,
      this.name,
      this.nsfw,
      this.release,
      @JsonKey(name: 'dl_count') this.dlCount,
      this.price,
      @JsonKey(name: 'review_count') this.reviewCount,
      @JsonKey(name: 'rate_count') this.rateCount,
      @JsonKey(name: 'rate_average_2dp') this.rateAverage2dp,
      @JsonKey(name: 'rate_count_detail') final List<dynamic>? rateCountDetail,
      this.rank,
      @JsonKey(name: 'has_subtitle') this.hasSubtitle,
      @JsonKey(name: 'create_date') this.createDate,
      final List<dynamic>? vas,
      final List<Tag>? tags,
      @JsonKey(name: 'language_editions')
      final List<LanguageEdition>? languageEditions,
      @JsonKey(name: 'original_workno') this.originalWorkno,
      @JsonKey(name: 'other_language_editions_in_db')
      final List<OtherLanguageEditionsInDb>? otherLanguageEditionsInDb,
      @JsonKey(name: 'translation_info') this.translationInfo,
      @JsonKey(name: 'work_attributes') this.workAttributes,
      @JsonKey(name: 'age_category_string') this.ageCategoryString,
      this.duration,
      @JsonKey(name: 'source_type') this.sourceType,
      @JsonKey(name: 'source_id') this.sourceId,
      @JsonKey(name: 'source_url') this.sourceUrl,
      this.userRating,
      this.circle,
      this.samCoverUrl,
      this.thumbnailCoverUrl,
      this.mainCoverUrl})
      : _rateCountDetail = rateCountDetail,
        _vas = vas,
        _tags = tags,
        _languageEditions = languageEditions,
        _otherLanguageEditionsInDb = otherLanguageEditionsInDb;

  factory _$WorkImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkImplFromJson(json);

  @override
  final int? id;
  @override
  final String? title;
  @override
  @JsonKey(name: 'circle_id')
  final int? circleId;
  @override
  final String? name;
  @override
  final bool? nsfw;
  @override
  final String? release;
  @override
  @JsonKey(name: 'dl_count')
  final int? dlCount;
  @override
  final int? price;
  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @override
  @JsonKey(name: 'rate_count')
  final int? rateCount;
  @override
  @JsonKey(name: 'rate_average_2dp')
  final int? rateAverage2dp;
  final List<dynamic>? _rateCountDetail;
  @override
  @JsonKey(name: 'rate_count_detail')
  List<dynamic>? get rateCountDetail {
    final value = _rateCountDetail;
    if (value == null) return null;
    if (_rateCountDetail is EqualUnmodifiableListView) return _rateCountDetail;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final dynamic rank;
  @override
  @JsonKey(name: 'has_subtitle')
  final bool? hasSubtitle;
  @override
  @JsonKey(name: 'create_date')
  final String? createDate;
  final List<dynamic>? _vas;
  @override
  List<dynamic>? get vas {
    final value = _vas;
    if (value == null) return null;
    if (_vas is EqualUnmodifiableListView) return _vas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Tag>? _tags;
  @override
  List<Tag>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<LanguageEdition>? _languageEditions;
  @override
  @JsonKey(name: 'language_editions')
  List<LanguageEdition>? get languageEditions {
    final value = _languageEditions;
    if (value == null) return null;
    if (_languageEditions is EqualUnmodifiableListView)
      return _languageEditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'original_workno')
  final String? originalWorkno;
  final List<OtherLanguageEditionsInDb>? _otherLanguageEditionsInDb;
  @override
  @JsonKey(name: 'other_language_editions_in_db')
  List<OtherLanguageEditionsInDb>? get otherLanguageEditionsInDb {
    final value = _otherLanguageEditionsInDb;
    if (value == null) return null;
    if (_otherLanguageEditionsInDb is EqualUnmodifiableListView)
      return _otherLanguageEditionsInDb;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'translation_info')
  final TranslationInfo? translationInfo;
  @override
  @JsonKey(name: 'work_attributes')
  final String? workAttributes;
  @override
  @JsonKey(name: 'age_category_string')
  final String? ageCategoryString;
  @override
  final int? duration;
  @override
  @JsonKey(name: 'source_type')
  final String? sourceType;
  @override
  @JsonKey(name: 'source_id')
  final String? sourceId;
  @override
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @override
  final dynamic userRating;
  @override
  final Circle? circle;
  @override
  final String? samCoverUrl;
  @override
  final String? thumbnailCoverUrl;
  @override
  final String? mainCoverUrl;

  @override
  String toString() {
    return 'Work(id: $id, title: $title, circleId: $circleId, name: $name, nsfw: $nsfw, release: $release, dlCount: $dlCount, price: $price, reviewCount: $reviewCount, rateCount: $rateCount, rateAverage2dp: $rateAverage2dp, rateCountDetail: $rateCountDetail, rank: $rank, hasSubtitle: $hasSubtitle, createDate: $createDate, vas: $vas, tags: $tags, languageEditions: $languageEditions, originalWorkno: $originalWorkno, otherLanguageEditionsInDb: $otherLanguageEditionsInDb, translationInfo: $translationInfo, workAttributes: $workAttributes, ageCategoryString: $ageCategoryString, duration: $duration, sourceType: $sourceType, sourceId: $sourceId, sourceUrl: $sourceUrl, userRating: $userRating, circle: $circle, samCoverUrl: $samCoverUrl, thumbnailCoverUrl: $thumbnailCoverUrl, mainCoverUrl: $mainCoverUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.circleId, circleId) ||
                other.circleId == circleId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nsfw, nsfw) || other.nsfw == nsfw) &&
            (identical(other.release, release) || other.release == release) &&
            (identical(other.dlCount, dlCount) || other.dlCount == dlCount) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.rateCount, rateCount) ||
                other.rateCount == rateCount) &&
            (identical(other.rateAverage2dp, rateAverage2dp) ||
                other.rateAverage2dp == rateAverage2dp) &&
            const DeepCollectionEquality()
                .equals(other._rateCountDetail, _rateCountDetail) &&
            const DeepCollectionEquality().equals(other.rank, rank) &&
            (identical(other.hasSubtitle, hasSubtitle) ||
                other.hasSubtitle == hasSubtitle) &&
            (identical(other.createDate, createDate) ||
                other.createDate == createDate) &&
            const DeepCollectionEquality().equals(other._vas, _vas) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._languageEditions, _languageEditions) &&
            (identical(other.originalWorkno, originalWorkno) ||
                other.originalWorkno == originalWorkno) &&
            const DeepCollectionEquality().equals(
                other._otherLanguageEditionsInDb, _otherLanguageEditionsInDb) &&
            (identical(other.translationInfo, translationInfo) ||
                other.translationInfo == translationInfo) &&
            (identical(other.workAttributes, workAttributes) ||
                other.workAttributes == workAttributes) &&
            (identical(other.ageCategoryString, ageCategoryString) ||
                other.ageCategoryString == ageCategoryString) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            const DeepCollectionEquality()
                .equals(other.userRating, userRating) &&
            (identical(other.circle, circle) || other.circle == circle) &&
            (identical(other.samCoverUrl, samCoverUrl) ||
                other.samCoverUrl == samCoverUrl) &&
            (identical(other.thumbnailCoverUrl, thumbnailCoverUrl) ||
                other.thumbnailCoverUrl == thumbnailCoverUrl) &&
            (identical(other.mainCoverUrl, mainCoverUrl) ||
                other.mainCoverUrl == mainCoverUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        circleId,
        name,
        nsfw,
        release,
        dlCount,
        price,
        reviewCount,
        rateCount,
        rateAverage2dp,
        const DeepCollectionEquality().hash(_rateCountDetail),
        const DeepCollectionEquality().hash(rank),
        hasSubtitle,
        createDate,
        const DeepCollectionEquality().hash(_vas),
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_languageEditions),
        originalWorkno,
        const DeepCollectionEquality().hash(_otherLanguageEditionsInDb),
        translationInfo,
        workAttributes,
        ageCategoryString,
        duration,
        sourceType,
        sourceId,
        sourceUrl,
        const DeepCollectionEquality().hash(userRating),
        circle,
        samCoverUrl,
        thumbnailCoverUrl,
        mainCoverUrl
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkImplCopyWith<_$WorkImpl> get copyWith =>
      __$$WorkImplCopyWithImpl<_$WorkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkImplToJson(
      this,
    );
  }
}

abstract class _Work implements Work {
  factory _Work(
      {final int? id,
      final String? title,
      @JsonKey(name: 'circle_id') final int? circleId,
      final String? name,
      final bool? nsfw,
      final String? release,
      @JsonKey(name: 'dl_count') final int? dlCount,
      final int? price,
      @JsonKey(name: 'review_count') final int? reviewCount,
      @JsonKey(name: 'rate_count') final int? rateCount,
      @JsonKey(name: 'rate_average_2dp') final int? rateAverage2dp,
      @JsonKey(name: 'rate_count_detail') final List<dynamic>? rateCountDetail,
      final dynamic rank,
      @JsonKey(name: 'has_subtitle') final bool? hasSubtitle,
      @JsonKey(name: 'create_date') final String? createDate,
      final List<dynamic>? vas,
      final List<Tag>? tags,
      @JsonKey(name: 'language_editions')
      final List<LanguageEdition>? languageEditions,
      @JsonKey(name: 'original_workno') final String? originalWorkno,
      @JsonKey(name: 'other_language_editions_in_db')
      final List<OtherLanguageEditionsInDb>? otherLanguageEditionsInDb,
      @JsonKey(name: 'translation_info') final TranslationInfo? translationInfo,
      @JsonKey(name: 'work_attributes') final String? workAttributes,
      @JsonKey(name: 'age_category_string') final String? ageCategoryString,
      final int? duration,
      @JsonKey(name: 'source_type') final String? sourceType,
      @JsonKey(name: 'source_id') final String? sourceId,
      @JsonKey(name: 'source_url') final String? sourceUrl,
      final dynamic userRating,
      final Circle? circle,
      final String? samCoverUrl,
      final String? thumbnailCoverUrl,
      final String? mainCoverUrl}) = _$WorkImpl;

  factory _Work.fromJson(Map<String, dynamic> json) = _$WorkImpl.fromJson;

  @override
  int? get id;
  @override
  String? get title;
  @override
  @JsonKey(name: 'circle_id')
  int? get circleId;
  @override
  String? get name;
  @override
  bool? get nsfw;
  @override
  String? get release;
  @override
  @JsonKey(name: 'dl_count')
  int? get dlCount;
  @override
  int? get price;
  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'rate_count')
  int? get rateCount;
  @override
  @JsonKey(name: 'rate_average_2dp')
  int? get rateAverage2dp;
  @override
  @JsonKey(name: 'rate_count_detail')
  List<dynamic>? get rateCountDetail;
  @override
  dynamic get rank;
  @override
  @JsonKey(name: 'has_subtitle')
  bool? get hasSubtitle;
  @override
  @JsonKey(name: 'create_date')
  String? get createDate;
  @override
  List<dynamic>? get vas;
  @override
  List<Tag>? get tags;
  @override
  @JsonKey(name: 'language_editions')
  List<LanguageEdition>? get languageEditions;
  @override
  @JsonKey(name: 'original_workno')
  String? get originalWorkno;
  @override
  @JsonKey(name: 'other_language_editions_in_db')
  List<OtherLanguageEditionsInDb>? get otherLanguageEditionsInDb;
  @override
  @JsonKey(name: 'translation_info')
  TranslationInfo? get translationInfo;
  @override
  @JsonKey(name: 'work_attributes')
  String? get workAttributes;
  @override
  @JsonKey(name: 'age_category_string')
  String? get ageCategoryString;
  @override
  int? get duration;
  @override
  @JsonKey(name: 'source_type')
  String? get sourceType;
  @override
  @JsonKey(name: 'source_id')
  String? get sourceId;
  @override
  @JsonKey(name: 'source_url')
  String? get sourceUrl;
  @override
  dynamic get userRating;
  @override
  Circle? get circle;
  @override
  String? get samCoverUrl;
  @override
  String? get thumbnailCoverUrl;
  @override
  String? get mainCoverUrl;
  @override
  @JsonKey(ignore: true)
  _$$WorkImplCopyWith<_$WorkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
