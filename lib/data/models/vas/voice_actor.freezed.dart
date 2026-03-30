// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_actor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VoiceActor _$VoiceActorFromJson(Map<String, dynamic> json) {
  return _VoiceActor.fromJson(json);
}

/// @nodoc
mixin _$VoiceActor {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;
  I18n? get i18n => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VoiceActorCopyWith<VoiceActor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceActorCopyWith<$Res> {
  factory $VoiceActorCopyWith(
          VoiceActor value, $Res Function(VoiceActor) then) =
      _$VoiceActorCopyWithImpl<$Res, VoiceActor>;
  @useResult
  $Res call({String? id, String? name, int? count, I18n? i18n});

  $I18nCopyWith<$Res>? get i18n;
}

/// @nodoc
class _$VoiceActorCopyWithImpl<$Res, $Val extends VoiceActor>
    implements $VoiceActorCopyWith<$Res> {
  _$VoiceActorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? count = freezed,
    Object? i18n = freezed,
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
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      i18n: freezed == i18n
          ? _value.i18n
          : i18n // ignore: cast_nullable_to_non_nullable
              as I18n?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $I18nCopyWith<$Res>? get i18n {
    if (_value.i18n == null) {
      return null;
    }

    return $I18nCopyWith<$Res>(_value.i18n!, (value) {
      return _then(_value.copyWith(i18n: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VoiceActorImplCopyWith<$Res>
    implements $VoiceActorCopyWith<$Res> {
  factory _$$VoiceActorImplCopyWith(
          _$VoiceActorImpl value, $Res Function(_$VoiceActorImpl) then) =
      __$$VoiceActorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String? name, int? count, I18n? i18n});

  @override
  $I18nCopyWith<$Res>? get i18n;
}

/// @nodoc
class __$$VoiceActorImplCopyWithImpl<$Res>
    extends _$VoiceActorCopyWithImpl<$Res, _$VoiceActorImpl>
    implements _$$VoiceActorImplCopyWith<$Res> {
  __$$VoiceActorImplCopyWithImpl(
      _$VoiceActorImpl _value, $Res Function(_$VoiceActorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? count = freezed,
    Object? i18n = freezed,
  }) {
    return _then(_$VoiceActorImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      i18n: freezed == i18n
          ? _value.i18n
          : i18n // ignore: cast_nullable_to_non_nullable
              as I18n?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceActorImpl implements _VoiceActor {
  _$VoiceActorImpl({this.id, this.name, this.count, this.i18n});

  factory _$VoiceActorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceActorImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final int? count;
  @override
  final I18n? i18n;

  @override
  String toString() {
    return 'VoiceActor(id: $id, name: $name, count: $count, i18n: $i18n)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceActorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.i18n, i18n) || other.i18n == i18n));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, count, i18n);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceActorImplCopyWith<_$VoiceActorImpl> get copyWith =>
      __$$VoiceActorImplCopyWithImpl<_$VoiceActorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceActorImplToJson(
      this,
    );
  }
}

abstract class _VoiceActor implements VoiceActor {
  factory _VoiceActor(
      {final String? id,
      final String? name,
      final int? count,
      final I18n? i18n}) = _$VoiceActorImpl;

  factory _VoiceActor.fromJson(Map<String, dynamic> json) =
      _$VoiceActorImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  int? get count;
  @override
  I18n? get i18n;
  @override
  @JsonKey(ignore: true)
  _$$VoiceActorImplCopyWith<_$VoiceActorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
