// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'en_us.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EnUs _$EnUsFromJson(Map<String, dynamic> json) {
  return _EnUs.fromJson(json);
}

/// @nodoc
mixin _$EnUs {
  String? get name => throw _privateConstructorUsedError;
  List<dynamic>? get history => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EnUsCopyWith<EnUs> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnUsCopyWith<$Res> {
  factory $EnUsCopyWith(EnUs value, $Res Function(EnUs) then) =
      _$EnUsCopyWithImpl<$Res, EnUs>;
  @useResult
  $Res call({String? name, List<dynamic>? history});
}

/// @nodoc
class _$EnUsCopyWithImpl<$Res, $Val extends EnUs>
    implements $EnUsCopyWith<$Res> {
  _$EnUsCopyWithImpl(this._value, this._then);

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
abstract class _$$EnUsImplCopyWith<$Res> implements $EnUsCopyWith<$Res> {
  factory _$$EnUsImplCopyWith(
          _$EnUsImpl value, $Res Function(_$EnUsImpl) then) =
      __$$EnUsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, List<dynamic>? history});
}

/// @nodoc
class __$$EnUsImplCopyWithImpl<$Res>
    extends _$EnUsCopyWithImpl<$Res, _$EnUsImpl>
    implements _$$EnUsImplCopyWith<$Res> {
  __$$EnUsImplCopyWithImpl(_$EnUsImpl _value, $Res Function(_$EnUsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? history = freezed,
  }) {
    return _then(_$EnUsImpl(
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
class _$EnUsImpl implements _EnUs {
  _$EnUsImpl({this.name, final List<dynamic>? history}) : _history = history;

  factory _$EnUsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnUsImplFromJson(json);

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
    return 'EnUs(name: $name, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnUsImpl &&
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
  _$$EnUsImplCopyWith<_$EnUsImpl> get copyWith =>
      __$$EnUsImplCopyWithImpl<_$EnUsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnUsImplToJson(
      this,
    );
  }
}

abstract class _EnUs implements EnUs {
  factory _EnUs({final String? name, final List<dynamic>? history}) =
      _$EnUsImpl;

  factory _EnUs.fromJson(Map<String, dynamic> json) = _$EnUsImpl.fromJson;

  @override
  String? get name;
  @override
  List<dynamic>? get history;
  @override
  @JsonKey(ignore: true)
  _$$EnUsImplCopyWith<_$EnUsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
