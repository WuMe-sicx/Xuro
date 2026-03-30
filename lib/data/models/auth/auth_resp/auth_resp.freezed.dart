// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthResp _$AuthRespFromJson(Map<String, dynamic> json) {
  return _AuthResp.fromJson(json);
}

/// @nodoc
mixin _$AuthResp {
  User? get user => throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthRespCopyWith<AuthResp> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthRespCopyWith<$Res> {
  factory $AuthRespCopyWith(AuthResp value, $Res Function(AuthResp) then) =
      _$AuthRespCopyWithImpl<$Res, AuthResp>;
  @useResult
  $Res call({User? user, String? token});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$AuthRespCopyWithImpl<$Res, $Val extends AuthResp>
    implements $AuthRespCopyWith<$Res> {
  _$AuthRespCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? token = freezed,
  }) {
    return _then(_value.copyWith(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthRespImplCopyWith<$Res>
    implements $AuthRespCopyWith<$Res> {
  factory _$$AuthRespImplCopyWith(
          _$AuthRespImpl value, $Res Function(_$AuthRespImpl) then) =
      __$$AuthRespImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({User? user, String? token});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AuthRespImplCopyWithImpl<$Res>
    extends _$AuthRespCopyWithImpl<$Res, _$AuthRespImpl>
    implements _$$AuthRespImplCopyWith<$Res> {
  __$$AuthRespImplCopyWithImpl(
      _$AuthRespImpl _value, $Res Function(_$AuthRespImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? token = freezed,
  }) {
    return _then(_$AuthRespImpl(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthRespImpl implements _AuthResp {
  _$AuthRespImpl({this.user, this.token});

  factory _$AuthRespImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthRespImplFromJson(json);

  @override
  final User? user;
  @override
  final String? token;

  @override
  String toString() {
    return 'AuthResp(user: $user, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthRespImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, user, token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthRespImplCopyWith<_$AuthRespImpl> get copyWith =>
      __$$AuthRespImplCopyWithImpl<_$AuthRespImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthRespImplToJson(
      this,
    );
  }
}

abstract class _AuthResp implements AuthResp {
  factory _AuthResp({final User? user, final String? token}) = _$AuthRespImpl;

  factory _AuthResp.fromJson(Map<String, dynamic> json) =
      _$AuthRespImpl.fromJson;

  @override
  User? get user;
  @override
  String? get token;
  @override
  @JsonKey(ignore: true)
  _$$AuthRespImplCopyWith<_$AuthRespImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
