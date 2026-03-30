// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'works.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Works _$WorksFromJson(Map<String, dynamic> json) {
  return _Works.fromJson(json);
}

/// @nodoc
mixin _$Works {
  List<Work>? get works => throw _privateConstructorUsedError;
  Pagination? get pagination => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorksCopyWith<Works> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorksCopyWith<$Res> {
  factory $WorksCopyWith(Works value, $Res Function(Works) then) =
      _$WorksCopyWithImpl<$Res, Works>;
  @useResult
  $Res call({List<Work>? works, Pagination? pagination});

  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class _$WorksCopyWithImpl<$Res, $Val extends Works>
    implements $WorksCopyWith<$Res> {
  _$WorksCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? works = freezed,
    Object? pagination = freezed,
  }) {
    return _then(_value.copyWith(
      works: freezed == works
          ? _value.works
          : works // ignore: cast_nullable_to_non_nullable
              as List<Work>?,
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
abstract class _$$WorksImplCopyWith<$Res> implements $WorksCopyWith<$Res> {
  factory _$$WorksImplCopyWith(
          _$WorksImpl value, $Res Function(_$WorksImpl) then) =
      __$$WorksImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Work>? works, Pagination? pagination});

  @override
  $PaginationCopyWith<$Res>? get pagination;
}

/// @nodoc
class __$$WorksImplCopyWithImpl<$Res>
    extends _$WorksCopyWithImpl<$Res, _$WorksImpl>
    implements _$$WorksImplCopyWith<$Res> {
  __$$WorksImplCopyWithImpl(
      _$WorksImpl _value, $Res Function(_$WorksImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? works = freezed,
    Object? pagination = freezed,
  }) {
    return _then(_$WorksImpl(
      works: freezed == works
          ? _value._works
          : works // ignore: cast_nullable_to_non_nullable
              as List<Work>?,
      pagination: freezed == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorksImpl implements _Works {
  _$WorksImpl({final List<Work>? works, this.pagination}) : _works = works;

  factory _$WorksImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorksImplFromJson(json);

  final List<Work>? _works;
  @override
  List<Work>? get works {
    final value = _works;
    if (value == null) return null;
    if (_works is EqualUnmodifiableListView) return _works;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Pagination? pagination;

  @override
  String toString() {
    return 'Works(works: $works, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorksImpl &&
            const DeepCollectionEquality().equals(other._works, _works) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_works), pagination);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorksImplCopyWith<_$WorksImpl> get copyWith =>
      __$$WorksImplCopyWithImpl<_$WorksImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorksImplToJson(
      this,
    );
  }
}

abstract class _Works implements Works {
  factory _Works({final List<Work>? works, final Pagination? pagination}) =
      _$WorksImpl;

  factory _Works.fromJson(Map<String, dynamic> json) = _$WorksImpl.fromJson;

  @override
  List<Work>? get works;
  @override
  Pagination? get pagination;
  @override
  @JsonKey(ignore: true)
  _$$WorksImplCopyWith<_$WorksImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
