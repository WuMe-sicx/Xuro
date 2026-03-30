// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return _Playlist.fromJson(json);
}

/// @nodoc
mixin _$Playlist {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String? get userName => throw _privateConstructorUsedError;
  int? get privacy => throw _privateConstructorUsedError;
  String? get locale => throw _privateConstructorUsedError;
  @JsonKey(name: 'playback_count')
  int? get playbackCount => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'works_count')
  int? get worksCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'latestWorkID')
  dynamic get latestWorkId => throw _privateConstructorUsedError;
  String? get mainCoverUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlaylistCopyWith<Playlist> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistCopyWith<$Res> {
  factory $PlaylistCopyWith(Playlist value, $Res Function(Playlist) then) =
      _$PlaylistCopyWithImpl<$Res, Playlist>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_name') String? userName,
      int? privacy,
      String? locale,
      @JsonKey(name: 'playback_count') int? playbackCount,
      String? name,
      String? description,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'works_count') int? worksCount,
      @JsonKey(name: 'latestWorkID') dynamic latestWorkId,
      String? mainCoverUrl});
}

/// @nodoc
class _$PlaylistCopyWithImpl<$Res, $Val extends Playlist>
    implements $PlaylistCopyWith<$Res> {
  _$PlaylistCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userName = freezed,
    Object? privacy = freezed,
    Object? locale = freezed,
    Object? playbackCount = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? worksCount = freezed,
    Object? latestWorkId = freezed,
    Object? mainCoverUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      privacy: freezed == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as int?,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
      playbackCount: freezed == playbackCount
          ? _value.playbackCount
          : playbackCount // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      worksCount: freezed == worksCount
          ? _value.worksCount
          : worksCount // ignore: cast_nullable_to_non_nullable
              as int?,
      latestWorkId: freezed == latestWorkId
          ? _value.latestWorkId
          : latestWorkId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      mainCoverUrl: freezed == mainCoverUrl
          ? _value.mainCoverUrl
          : mainCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistImplCopyWith<$Res>
    implements $PlaylistCopyWith<$Res> {
  factory _$$PlaylistImplCopyWith(
          _$PlaylistImpl value, $Res Function(_$PlaylistImpl) then) =
      __$$PlaylistImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_name') String? userName,
      int? privacy,
      String? locale,
      @JsonKey(name: 'playback_count') int? playbackCount,
      String? name,
      String? description,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'works_count') int? worksCount,
      @JsonKey(name: 'latestWorkID') dynamic latestWorkId,
      String? mainCoverUrl});
}

/// @nodoc
class __$$PlaylistImplCopyWithImpl<$Res>
    extends _$PlaylistCopyWithImpl<$Res, _$PlaylistImpl>
    implements _$$PlaylistImplCopyWith<$Res> {
  __$$PlaylistImplCopyWithImpl(
      _$PlaylistImpl _value, $Res Function(_$PlaylistImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userName = freezed,
    Object? privacy = freezed,
    Object? locale = freezed,
    Object? playbackCount = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? worksCount = freezed,
    Object? latestWorkId = freezed,
    Object? mainCoverUrl = freezed,
  }) {
    return _then(_$PlaylistImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      privacy: freezed == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as int?,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
      playbackCount: freezed == playbackCount
          ? _value.playbackCount
          : playbackCount // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      worksCount: freezed == worksCount
          ? _value.worksCount
          : worksCount // ignore: cast_nullable_to_non_nullable
              as int?,
      latestWorkId: freezed == latestWorkId
          ? _value.latestWorkId
          : latestWorkId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      mainCoverUrl: freezed == mainCoverUrl
          ? _value.mainCoverUrl
          : mainCoverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistImpl implements _Playlist {
  _$PlaylistImpl(
      {this.id,
      @JsonKey(name: 'user_name') this.userName,
      this.privacy,
      this.locale,
      @JsonKey(name: 'playback_count') this.playbackCount,
      this.name,
      this.description,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'works_count') this.worksCount,
      @JsonKey(name: 'latestWorkID') this.latestWorkId,
      this.mainCoverUrl});

  factory _$PlaylistImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_name')
  final String? userName;
  @override
  final int? privacy;
  @override
  final String? locale;
  @override
  @JsonKey(name: 'playback_count')
  final int? playbackCount;
  @override
  final String? name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  @JsonKey(name: 'works_count')
  final int? worksCount;
  @override
  @JsonKey(name: 'latestWorkID')
  final dynamic latestWorkId;
  @override
  final String? mainCoverUrl;

  @override
  String toString() {
    return 'Playlist(id: $id, userName: $userName, privacy: $privacy, locale: $locale, playbackCount: $playbackCount, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, worksCount: $worksCount, latestWorkId: $latestWorkId, mainCoverUrl: $mainCoverUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.playbackCount, playbackCount) ||
                other.playbackCount == playbackCount) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.worksCount, worksCount) ||
                other.worksCount == worksCount) &&
            const DeepCollectionEquality()
                .equals(other.latestWorkId, latestWorkId) &&
            (identical(other.mainCoverUrl, mainCoverUrl) ||
                other.mainCoverUrl == mainCoverUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userName,
      privacy,
      locale,
      playbackCount,
      name,
      description,
      createdAt,
      updatedAt,
      worksCount,
      const DeepCollectionEquality().hash(latestWorkId),
      mainCoverUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistImplCopyWith<_$PlaylistImpl> get copyWith =>
      __$$PlaylistImplCopyWithImpl<_$PlaylistImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistImplToJson(
      this,
    );
  }
}

abstract class _Playlist implements Playlist {
  factory _Playlist(
      {final String? id,
      @JsonKey(name: 'user_name') final String? userName,
      final int? privacy,
      final String? locale,
      @JsonKey(name: 'playback_count') final int? playbackCount,
      final String? name,
      final String? description,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      @JsonKey(name: 'works_count') final int? worksCount,
      @JsonKey(name: 'latestWorkID') final dynamic latestWorkId,
      final String? mainCoverUrl}) = _$PlaylistImpl;

  factory _Playlist.fromJson(Map<String, dynamic> json) =
      _$PlaylistImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'user_name')
  String? get userName;
  @override
  int? get privacy;
  @override
  String? get locale;
  @override
  @JsonKey(name: 'playback_count')
  int? get playbackCount;
  @override
  String? get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(name: 'works_count')
  int? get worksCount;
  @override
  @JsonKey(name: 'latestWorkID')
  dynamic get latestWorkId;
  @override
  String? get mainCoverUrl;
  @override
  @JsonKey(ignore: true)
  _$$PlaylistImplCopyWith<_$PlaylistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
