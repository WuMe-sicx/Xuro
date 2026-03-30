// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ja_jp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

JaJp _$JaJpFromJson(Map<String, dynamic> json) {
  return _JaJp.fromJson(json);
}

/// @nodoc
mixin _$JaJp {
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JaJpCopyWith<JaJp> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JaJpCopyWith<$Res> {
  factory $JaJpCopyWith(JaJp value, $Res Function(JaJp) then) =
      _$JaJpCopyWithImpl<$Res, JaJp>;
  @useResult
  $Res call({String? name});
}

/// @nodoc
class _$JaJpCopyWithImpl<$Res, $Val extends JaJp>
    implements $JaJpCopyWith<$Res> {
  _$JaJpCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JaJpImplCopyWith<$Res> implements $JaJpCopyWith<$Res> {
  factory _$$JaJpImplCopyWith(
          _$JaJpImpl value, $Res Function(_$JaJpImpl) then) =
      __$$JaJpImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name});
}

/// @nodoc
class __$$JaJpImplCopyWithImpl<$Res>
    extends _$JaJpCopyWithImpl<$Res, _$JaJpImpl>
    implements _$$JaJpImplCopyWith<$Res> {
  __$$JaJpImplCopyWithImpl(_$JaJpImpl _value, $Res Function(_$JaJpImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_$JaJpImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JaJpImpl implements _JaJp {
  _$JaJpImpl({this.name});

  factory _$JaJpImpl.fromJson(Map<String, dynamic> json) =>
      _$$JaJpImplFromJson(json);

  @override
  final String? name;

  @override
  String toString() {
    return 'JaJp(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JaJpImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$JaJpImplCopyWith<_$JaJpImpl> get copyWith =>
      __$$JaJpImplCopyWithImpl<_$JaJpImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JaJpImplToJson(
      this,
    );
  }
}

abstract class _JaJp implements JaJp {
  factory _JaJp({final String? name}) = _$JaJpImpl;

  factory _JaJp.fromJson(Map<String, dynamic> json) = _$JaJpImpl.fromJson;

  @override
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$JaJpImplCopyWith<_$JaJpImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
