// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_va.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkVA _$WorkVAFromJson(Map<String, dynamic> json) {
  return _WorkVA.fromJson(json);
}

/// @nodoc
mixin _$WorkVA {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkVACopyWith<WorkVA> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkVACopyWith<$Res> {
  factory $WorkVACopyWith(WorkVA value, $Res Function(WorkVA) then) =
      _$WorkVACopyWithImpl<$Res, WorkVA>;
  @useResult
  $Res call({String? id, String? name});
}

/// @nodoc
class _$WorkVACopyWithImpl<$Res, $Val extends WorkVA>
    implements $WorkVACopyWith<$Res> {
  _$WorkVACopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkVAImplCopyWith<$Res> implements $WorkVACopyWith<$Res> {
  factory _$$WorkVAImplCopyWith(
          _$WorkVAImpl value, $Res Function(_$WorkVAImpl) then) =
      __$$WorkVAImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String? name});
}

/// @nodoc
class __$$WorkVAImplCopyWithImpl<$Res>
    extends _$WorkVACopyWithImpl<$Res, _$WorkVAImpl>
    implements _$$WorkVAImplCopyWith<$Res> {
  __$$WorkVAImplCopyWithImpl(
      _$WorkVAImpl _value, $Res Function(_$WorkVAImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_$WorkVAImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkVAImpl implements _WorkVA {
  _$WorkVAImpl({this.id, this.name});

  factory _$WorkVAImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkVAImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;

  @override
  String toString() {
    return 'WorkVA(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkVAImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkVAImplCopyWith<_$WorkVAImpl> get copyWith =>
      __$$WorkVAImplCopyWithImpl<_$WorkVAImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkVAImplToJson(
      this,
    );
  }
}

abstract class _WorkVA implements WorkVA {
  factory _WorkVA({final String? id, final String? name}) = _$WorkVAImpl;

  factory _WorkVA.fromJson(Map<String, dynamic> json) = _$WorkVAImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$WorkVAImplCopyWith<_$WorkVAImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
