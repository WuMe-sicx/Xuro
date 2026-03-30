// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Circle _$CircleFromJson(Map<String, dynamic> json) {
  return _Circle.fromJson(json);
}

/// @nodoc
mixin _$Circle {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_id')
  String? get sourceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_type')
  String? get sourceType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CircleCopyWith<Circle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleCopyWith<$Res> {
  factory $CircleCopyWith(Circle value, $Res Function(Circle) then) =
      _$CircleCopyWithImpl<$Res, Circle>;
  @useResult
  $Res call(
      {int? id,
      String? name,
      @JsonKey(name: 'source_id') String? sourceId,
      @JsonKey(name: 'source_type') String? sourceType});
}

/// @nodoc
class _$CircleCopyWithImpl<$Res, $Val extends Circle>
    implements $CircleCopyWith<$Res> {
  _$CircleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? sourceId = freezed,
    Object? sourceType = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: freezed == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CircleImplCopyWith<$Res> implements $CircleCopyWith<$Res> {
  factory _$$CircleImplCopyWith(
          _$CircleImpl value, $Res Function(_$CircleImpl) then) =
      __$$CircleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? name,
      @JsonKey(name: 'source_id') String? sourceId,
      @JsonKey(name: 'source_type') String? sourceType});
}

/// @nodoc
class __$$CircleImplCopyWithImpl<$Res>
    extends _$CircleCopyWithImpl<$Res, _$CircleImpl>
    implements _$$CircleImplCopyWith<$Res> {
  __$$CircleImplCopyWithImpl(
      _$CircleImpl _value, $Res Function(_$CircleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? sourceId = freezed,
    Object? sourceType = freezed,
  }) {
    return _then(_$CircleImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: freezed == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceType: freezed == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CircleImpl implements _Circle {
  _$CircleImpl(
      {this.id,
      this.name,
      @JsonKey(name: 'source_id') this.sourceId,
      @JsonKey(name: 'source_type') this.sourceType});

  factory _$CircleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'source_id')
  final String? sourceId;
  @override
  @JsonKey(name: 'source_type')
  final String? sourceType;

  @override
  String toString() {
    return 'Circle(id: $id, name: $name, sourceId: $sourceId, sourceType: $sourceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, sourceId, sourceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CircleImplCopyWith<_$CircleImpl> get copyWith =>
      __$$CircleImplCopyWithImpl<_$CircleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleImplToJson(
      this,
    );
  }
}

abstract class _Circle implements Circle {
  factory _Circle(
      {final int? id,
      final String? name,
      @JsonKey(name: 'source_id') final String? sourceId,
      @JsonKey(name: 'source_type') final String? sourceType}) = _$CircleImpl;

  factory _Circle.fromJson(Map<String, dynamic> json) = _$CircleImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  @JsonKey(name: 'source_id')
  String? get sourceId;
  @override
  @JsonKey(name: 'source_type')
  String? get sourceType;
  @override
  @JsonKey(ignore: true)
  _$$CircleImplCopyWith<_$CircleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
