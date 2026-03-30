// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zh_cn.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ZhCn _$ZhCnFromJson(Map<String, dynamic> json) {
  return _ZhCn.fromJson(json);
}

/// @nodoc
mixin _$ZhCn {
  String? get name => throw _privateConstructorUsedError;
  List<dynamic>? get history => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ZhCnCopyWith<ZhCn> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZhCnCopyWith<$Res> {
  factory $ZhCnCopyWith(ZhCn value, $Res Function(ZhCn) then) =
      _$ZhCnCopyWithImpl<$Res, ZhCn>;
  @useResult
  $Res call({String? name, List<dynamic>? history});
}

/// @nodoc
class _$ZhCnCopyWithImpl<$Res, $Val extends ZhCn>
    implements $ZhCnCopyWith<$Res> {
  _$ZhCnCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? history = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      history: freezed == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ZhCnImplCopyWith<$Res> implements $ZhCnCopyWith<$Res> {
  factory _$$ZhCnImplCopyWith(
          _$ZhCnImpl value, $Res Function(_$ZhCnImpl) then) =
      __$$ZhCnImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, List<dynamic>? history});
}

/// @nodoc
class __$$ZhCnImplCopyWithImpl<$Res>
    extends _$ZhCnCopyWithImpl<$Res, _$ZhCnImpl>
    implements _$$ZhCnImplCopyWith<$Res> {
  __$$ZhCnImplCopyWithImpl(_$ZhCnImpl _value, $Res Function(_$ZhCnImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? history = freezed,
  }) {
    return _then(_$ZhCnImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      history: freezed == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ZhCnImpl implements _ZhCn {
  _$ZhCnImpl({this.name, final List<dynamic>? history}) : _history = history;

  factory _$ZhCnImpl.fromJson(Map<String, dynamic> json) =>
      _$$ZhCnImplFromJson(json);

  @override
  final String? name;
  final List<dynamic>? _history;
  @override
  List<dynamic>? get history {
    final value = _history;
    if (value == null) return null;
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ZhCn(name: $name, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZhCnImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_history));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ZhCnImplCopyWith<_$ZhCnImpl> get copyWith =>
      __$$ZhCnImplCopyWithImpl<_$ZhCnImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ZhCnImplToJson(
      this,
    );
  }
}

abstract class _ZhCn implements ZhCn {
  factory _ZhCn({final String? name, final List<dynamic>? history}) =
      _$ZhCnImpl;

  factory _ZhCn.fromJson(Map<String, dynamic> json) = _$ZhCnImpl.fromJson;

  @override
  String? get name;
  @override
  List<dynamic>? get history;
  @override
  @JsonKey(ignore: true)
  _$$ZhCnImplCopyWith<_$ZhCnImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
