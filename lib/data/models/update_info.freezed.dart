// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UpdateInfo {
  String get tagName => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  String get releaseNotes => throw _privateConstructorUsedError;
  String get htmlUrl => throw _privateConstructorUsedError;
  String? get apkDownloadUrl => throw _privateConstructorUsedError;
  String get publishedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UpdateInfoCopyWith<UpdateInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateInfoCopyWith<$Res> {
  factory $UpdateInfoCopyWith(
          UpdateInfo value, $Res Function(UpdateInfo) then) =
      _$UpdateInfoCopyWithImpl<$Res, UpdateInfo>;
  @useResult
  $Res call(
      {String tagName,
      String version,
      String releaseNotes,
      String htmlUrl,
      String? apkDownloadUrl,
      String publishedAt});
}

/// @nodoc
class _$UpdateInfoCopyWithImpl<$Res, $Val extends UpdateInfo>
    implements $UpdateInfoCopyWith<$Res> {
  _$UpdateInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagName = null,
    Object? version = null,
    Object? releaseNotes = null,
    Object? htmlUrl = null,
    Object? apkDownloadUrl = freezed,
    Object? publishedAt = null,
  }) {
    return _then(_value.copyWith(
      tagName: null == tagName
          ? _value.tagName
          : tagName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      releaseNotes: null == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as String,
      htmlUrl: null == htmlUrl
          ? _value.htmlUrl
          : htmlUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apkDownloadUrl: freezed == apkDownloadUrl
          ? _value.apkDownloadUrl
          : apkDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: null == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateInfoImplCopyWith<$Res>
    implements $UpdateInfoCopyWith<$Res> {
  factory _$$UpdateInfoImplCopyWith(
          _$UpdateInfoImpl value, $Res Function(_$UpdateInfoImpl) then) =
      __$$UpdateInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tagName,
      String version,
      String releaseNotes,
      String htmlUrl,
      String? apkDownloadUrl,
      String publishedAt});
}

/// @nodoc
class __$$UpdateInfoImplCopyWithImpl<$Res>
    extends _$UpdateInfoCopyWithImpl<$Res, _$UpdateInfoImpl>
    implements _$$UpdateInfoImplCopyWith<$Res> {
  __$$UpdateInfoImplCopyWithImpl(
      _$UpdateInfoImpl _value, $Res Function(_$UpdateInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagName = null,
    Object? version = null,
    Object? releaseNotes = null,
    Object? htmlUrl = null,
    Object? apkDownloadUrl = freezed,
    Object? publishedAt = null,
  }) {
    return _then(_$UpdateInfoImpl(
      tagName: null == tagName
          ? _value.tagName
          : tagName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      releaseNotes: null == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as String,
      htmlUrl: null == htmlUrl
          ? _value.htmlUrl
          : htmlUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apkDownloadUrl: freezed == apkDownloadUrl
          ? _value.apkDownloadUrl
          : apkDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: null == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UpdateInfoImpl implements _UpdateInfo {
  const _$UpdateInfoImpl(
      {required this.tagName,
      required this.version,
      required this.releaseNotes,
      required this.htmlUrl,
      this.apkDownloadUrl,
      required this.publishedAt});

  @override
  final String tagName;
  @override
  final String version;
  @override
  final String releaseNotes;
  @override
  final String htmlUrl;
  @override
  final String? apkDownloadUrl;
  @override
  final String publishedAt;

  @override
  String toString() {
    return 'UpdateInfo(tagName: $tagName, version: $version, releaseNotes: $releaseNotes, htmlUrl: $htmlUrl, apkDownloadUrl: $apkDownloadUrl, publishedAt: $publishedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateInfoImpl &&
            (identical(other.tagName, tagName) || other.tagName == tagName) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.releaseNotes, releaseNotes) ||
                other.releaseNotes == releaseNotes) &&
            (identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl) &&
            (identical(other.apkDownloadUrl, apkDownloadUrl) ||
                other.apkDownloadUrl == apkDownloadUrl) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tagName, version, releaseNotes,
      htmlUrl, apkDownloadUrl, publishedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateInfoImplCopyWith<_$UpdateInfoImpl> get copyWith =>
      __$$UpdateInfoImplCopyWithImpl<_$UpdateInfoImpl>(this, _$identity);
}

abstract class _UpdateInfo implements UpdateInfo {
  const factory _UpdateInfo(
      {required final String tagName,
      required final String version,
      required final String releaseNotes,
      required final String htmlUrl,
      final String? apkDownloadUrl,
      required final String publishedAt}) = _$UpdateInfoImpl;

  @override
  String get tagName;
  @override
  String get version;
  @override
  String get releaseNotes;
  @override
  String get htmlUrl;
  @override
  String? get apkDownloadUrl;
  @override
  String get publishedAt;
  @override
  @JsonKey(ignore: true)
  _$$UpdateInfoImplCopyWith<_$UpdateInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
