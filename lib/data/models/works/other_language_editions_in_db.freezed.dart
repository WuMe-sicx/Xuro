// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'other_language_editions_in_db.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OtherLanguageEditionsInDb _$OtherLanguageEditionsInDbFromJson(
    Map<String, dynamic> json) {
  return _OtherLanguageEditionsInDb.fromJson(json);
}

/// @nodoc
mixin _$OtherLanguageEditionsInDb {
  int? get id => throw _privateConstructorUsedError;
  String? get lang => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_id')
  String? get sourceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_original')
  bool? get isOriginal => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_type')
  String? get sourceType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OtherLanguageEditionsInDbCopyWith<OtherLanguageEditionsInDb> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtherLanguageEditionsInDbCopyWith<$Res> {
  factory $OtherLanguageEditionsInDbCopyWith(OtherLanguageEditionsInDb value,
          $Res Function(OtherLanguageEditionsInDb) then) =
      _$OtherLanguageEditionsInDbCopyWithImpl<$Res, OtherLanguageEditionsInDb>;
  @useResult
  $Res call(
      {int? id,
      String? lang,
      String? title,
      @JsonKey(name: 'source_id') String? sourceId,
      @JsonKey(name: 'is_original') bool? isOriginal,
      @JsonKey(name: 'source_type') String? sourceType});
}

/// @nodoc
class _$OtherLanguageEditionsInDbCopyWithImpl<$Res,
        $Val extends OtherLanguageEditionsInDb>
    implements $OtherLanguageEditionsInDbCopyWith<$Res> {
  _$OtherLanguageEditionsInDbCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? lang = freezed,
    Object? title = freezed,
    Object? sourceId = freezed,
    Object? isOriginal = freezed,
    Object? sourceType = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: freezed == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOriginal: freezed == isOriginal
          ? _value.isOriginal
          : isOriginal // ignore: cast_nullable_to_non_nullable
              as bool?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtherLanguageEditionsInDbImplCopyWith<$Res>
    implements $OtherLanguageEditionsInDbCopyWith<$Res> {
  factory _$$OtherLanguageEditionsInDbImplCopyWith(
          _$OtherLanguageEditionsInDbImpl value,
          $Res Function(_$OtherLanguageEditionsInDbImpl) then) =
      __$$OtherLanguageEditionsInDbImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? lang,
      String? title,
      @JsonKey(name: 'source_id') String? sourceId,
      @JsonKey(name: 'is_original') bool? isOriginal,
      @JsonKey(name: 'source_type') String? sourceType});
}

/// @nodoc
class __$$OtherLanguageEditionsInDbImplCopyWithImpl<$Res>
    extends _$OtherLanguageEditionsInDbCopyWithImpl<$Res,
        _$OtherLanguageEditionsInDbImpl>
    implements _$$OtherLanguageEditionsInDbImplCopyWith<$Res> {
  __$$OtherLanguageEditionsInDbImplCopyWithImpl(
      _$OtherLanguageEditionsInDbImpl _value,
      $Res Function(_$OtherLanguageEditionsInDbImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? lang = freezed,
    Object? title = freezed,
    Object? sourceId = freezed,
    Object? isOriginal = freezed,
    Object? sourceType = freezed,
  }) {
    return _then(_$OtherLanguageEditionsInDbImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: freezed == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOriginal: freezed == isOriginal
          ? _value.isOriginal
          : isOriginal // ignore: cast_nullable_to_non_nullable
              as bool?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OtherLanguageEditionsInDbImpl implements _OtherLanguageEditionsInDb {
  _$OtherLanguageEditionsInDbImpl(
      {this.id,
      this.lang,
      this.title,
      @JsonKey(name: 'source_id') this.sourceId,
      @JsonKey(name: 'is_original') this.isOriginal,
      @JsonKey(name: 'source_type') this.sourceType});

  factory _$OtherLanguageEditionsInDbImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtherLanguageEditionsInDbImplFromJson(json);

  @override
  final int? id;
  @override
  final String? lang;
  @override
  final String? title;
  @override
  @JsonKey(name: 'source_id')
  final String? sourceId;
  @override
  @JsonKey(name: 'is_original')
  final bool? isOriginal;
  @override
  @JsonKey(name: 'source_type')
  final String? sourceType;

  @override
  String toString() {
    return 'OtherLanguageEditionsInDb(id: $id, lang: $lang, title: $title, sourceId: $sourceId, isOriginal: $isOriginal, sourceType: $sourceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtherLanguageEditionsInDbImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.isOriginal, isOriginal) ||
                other.isOriginal == isOriginal) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, lang, title, sourceId, isOriginal, sourceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OtherLanguageEditionsInDbImplCopyWith<_$OtherLanguageEditionsInDbImpl>
      get copyWith => __$$OtherLanguageEditionsInDbImplCopyWithImpl<
          _$OtherLanguageEditionsInDbImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtherLanguageEditionsInDbImplToJson(
      this,
    );
  }
}

abstract class _OtherLanguageEditionsInDb implements OtherLanguageEditionsInDb {
  factory _OtherLanguageEditionsInDb(
          {final int? id,
          final String? lang,
          final String? title,
          @JsonKey(name: 'source_id') final String? sourceId,
          @JsonKey(name: 'is_original') final bool? isOriginal,
          @JsonKey(name: 'source_type') final String? sourceType}) =
      _$OtherLanguageEditionsInDbImpl;

  factory _OtherLanguageEditionsInDb.fromJson(Map<String, dynamic> json) =
      _$OtherLanguageEditionsInDbImpl.fromJson;

  @override
  int? get id;
  @override
  String? get lang;
  @override
  String? get title;
  @override
  @JsonKey(name: 'source_id')
  String? get sourceId;
  @override
  @JsonKey(name: 'is_original')
  bool? get isOriginal;
  @override
  @JsonKey(name: 'source_type')
  String? get sourceType;
  @override
  @JsonKey(ignore: true)
  _$$OtherLanguageEditionsInDbImplCopyWith<_$OtherLanguageEditionsInDbImpl>
      get copyWith => throw _privateConstructorUsedError;
}
