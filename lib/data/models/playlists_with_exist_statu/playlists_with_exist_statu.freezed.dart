// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlists_with_exist_statu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaylistsWithExistStatu _$PlaylistsWithExistStatuFromJson(
    Map<String, dynamic> json) {
  return _PlaylistsWithExistStatu.fromJson(json);
}

/// @nodoc
mixin _$PlaylistsWithExistStatu {
  List<Playlist>? get playlists => throw _privateConstructorUsedError;
  Pagination? get pagination => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlaylistsWithExistStatuCopyWith<PlaylistsWithExistStatu> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistsWithExistStatuCopyWith<$Res> {
  factory $PlaylistsWithExistStatuCopyWith(PlaylistsWithExistStatu value,
          $Res Function(PlaylistsWithExistStatu) then) =
      _$PlaylistsWithExistStatuCopyWithImpl<$Res, PlaylistsWithExistStatu>;
  @useResult
  $Res call({List<Playlist>? playlists, Pagination? pagination});

  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class _$PlaylistsWithExistStatuCopyWithImpl<$Res,
        $Val extends PlaylistsWithExistStatu>
    implements $PlaylistsWithExistStatuCopyWith<$Res> {
  _$PlaylistsWithExistStatuCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playlists = freezed,
    Object? pagination = freezed,
  }) {
    return _then(_value.copyWith(
      playlists: freezed == playlists
          ? _value.playlists
          : playlists // ignore: cast_nullable_to_non_nullable
              as List<Playlist>?,
      pagination: freezed == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PaginationCopyWith<$Res>? get pagination {
    if (_value.pagination == null) {
      return null;
    }

    return $PaginationCopyWith<$Res>(_value.pagination!, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaylistsWithExistStatuImplCopyWith<$Res>
    implements $PlaylistsWithExistStatuCopyWith<$Res> {
  factory _$$PlaylistsWithExistStatuImplCopyWith(
          _$PlaylistsWithExistStatuImpl value,
          $Res Function(_$PlaylistsWithExistStatuImpl) then) =
      __$$PlaylistsWithExistStatuImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Playlist>? playlists, Pagination? pagination});

  @override
  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class __$$PlaylistsWithExistStatuImplCopyWithImpl<$Res>
    extends _$PlaylistsWithExistStatuCopyWithImpl<$Res,
        _$PlaylistsWithExistStatuImpl>
    implements _$$PlaylistsWithExistStatuImplCopyWith<$Res> {
  __$$PlaylistsWithExistStatuImplCopyWithImpl(
      _$PlaylistsWithExistStatuImpl _value,
      $Res Function(_$PlaylistsWithExistStatuImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playlists = freezed,
    Object? pagination = freezed,
  }) {
    return _then(_$PlaylistsWithExistStatuImpl(
      playlists: freezed == playlists
          ? _value._playlists
          : playlists // ignore: cast_nullable_to_non_nullable
              as List<Playlist>?,
      pagination: freezed == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistsWithExistStatuImpl implements _PlaylistsWithExistStatu {
  _$PlaylistsWithExistStatuImpl(
      {final List<Playlist>? playlists, this.pagination})
      : _playlists = playlists;

  factory _$PlaylistsWithExistStatuImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistsWithExistStatuImplFromJson(json);

  final List<Playlist>? _playlists;
  @override
  List<Playlist>? get playlists {
    final value = _playlists;
    if (value == null) return null;
    if (_playlists is EqualUnmodifiableListView) return _playlists;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Pagination? pagination;

  @override
  String toString() {
    return 'PlaylistsWithExistStatu(playlists: $playlists, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistsWithExistStatuImpl &&
            const DeepCollectionEquality()
                .equals(other._playlists, _playlists) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_playlists), pagination);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistsWithExistStatuImplCopyWith<_$PlaylistsWithExistStatuImpl>
      get copyWith => __$$PlaylistsWithExistStatuImplCopyWithImpl<
          _$PlaylistsWithExistStatuImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistsWithExistStatuImplToJson(
      this,
    );
  }
}

abstract class _PlaylistsWithExistStatu implements PlaylistsWithExistStatu {
  factory _PlaylistsWithExistStatu(
      {final List<Playlist>? playlists,
      final Pagination? pagination}) = _$PlaylistsWithExistStatuImpl;

  factory _PlaylistsWithExistStatu.fromJson(Map<String, dynamic> json) =
      _$PlaylistsWithExistStatuImpl.fromJson;

  @override
  List<Playlist>? get playlists;
  @override
  Pagination? get pagination;
  @override
  @JsonKey(ignore: true)
  _$$PlaylistsWithExistStatuImplCopyWith<_$PlaylistsWithExistStatuImpl>
      get copyWith => throw _privateConstructorUsedError;
}
