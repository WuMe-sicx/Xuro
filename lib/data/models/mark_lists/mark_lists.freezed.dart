// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mark_lists.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MarkLists _$MarkListsFromJson(Map<String, dynamic> json) {
  return _MarkLists.fromJson(json);
}

/// @nodoc
mixin _$MarkLists {
  List<Playlist>? get playlists => throw _privateConstructorUsedError;
  Pagination? get pagination => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MarkListsCopyWith<MarkLists> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarkListsCopyWith<$Res> {
  factory $MarkListsCopyWith(MarkLists value, $Res Function(MarkLists) then) =
      _$MarkListsCopyWithImpl<$Res, MarkLists>;
  @useResult
  $Res call({List<Playlist>? playlists, Pagination? pagination});

  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class _$MarkListsCopyWithImpl<$Res, $Val extends MarkLists>
    implements $MarkListsCopyWith<$Res> {
  _$MarkListsCopyWithImpl(this._value, this._then);

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
abstract class _$$MarkListsImplCopyWith<$Res>
    implements $MarkListsCopyWith<$Res> {
  factory _$$MarkListsImplCopyWith(
          _$MarkListsImpl value, $Res Function(_$MarkListsImpl) then) =
      __$$MarkListsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Playlist>? playlists, Pagination? pagination});

  @override
  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class __$$MarkListsImplCopyWithImpl<$Res>
    extends _$MarkListsCopyWithImpl<$Res, _$MarkListsImpl>
    implements _$$MarkListsImplCopyWith<$Res> {
  __$$MarkListsImplCopyWithImpl(
      _$MarkListsImpl _value, $Res Function(_$MarkListsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playlists = freezed,
    Object? pagination = freezed,
  }) {
    return _then(_$MarkListsImpl(
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
class _$MarkListsImpl implements _MarkLists {
  _$MarkListsImpl({final List<Playlist>? playlists, this.pagination})
      : _playlists = playlists;

  factory _$MarkListsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarkListsImplFromJson(json);

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
    return 'MarkLists(playlists: $playlists, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarkListsImpl &&
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
  _$$MarkListsImplCopyWith<_$MarkListsImpl> get copyWith =>
      __$$MarkListsImplCopyWithImpl<_$MarkListsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarkListsImplToJson(
      this,
    );
  }
}

abstract class _MarkLists implements MarkLists {
  factory _MarkLists(
      {final List<Playlist>? playlists,
      final Pagination? pagination}) = _$MarkListsImpl;

  factory _MarkLists.fromJson(Map<String, dynamic> json) =
      _$MarkListsImpl.fromJson;

  @override
  List<Playlist>? get playlists;
  @override
  Pagination? get pagination;
  @override
  @JsonKey(ignore: true)
  _$$MarkListsImplCopyWith<_$MarkListsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
