// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'i18n.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

I18n _$I18nFromJson(Map<String, dynamic> json) {
  return _I18n.fromJson(json);
}

/// @nodoc
mixin _$I18n {
  @JsonKey(name: 'en-us')
  EnUs? get enUs => throw _privateConstructorUsedError;
  @JsonKey(name: 'ja-jp')
  JaJp? get jaJp => throw _privateConstructorUsedError;
  @JsonKey(name: 'zh-cn')
  ZhCn? get zhCn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $I18nCopyWith<I18n> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $I18nCopyWith<$Res> {
  factory $I18nCopyWith(I18n value, $Res Function(I18n) then) =
      _$I18nCopyWithImpl<$Res, I18n>;
  @useResult
  $Res call(
      {@JsonKey(name: 'en-us') EnUs? enUs,
      @JsonKey(name: 'ja-jp') JaJp? jaJp,
      @JsonKey(name: 'zh-cn') ZhCn? zhCn});

  $EnUsCopyWith<$Res>? get enUs;
  $JaJpCopyWith<$Res>? get jaJp;
  $ZhCnCopyWith<$Res>? get zhCn;
}

/// @nodoc
class _$I18nCopyWithImpl<$Res, $Val extends I18n>
    implements $I18nCopyWith<$Res> {
  _$I18nCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enUs = freezed,
    Object? jaJp = freezed,
    Object? zhCn = freezed,
  }) {
    return _then(_value.copyWith(
      enUs: freezed == enUs
          ? _value.enUs
          : enUs // ignore: cast_nullable_to_non_nullable
              as EnUs?,
      jaJp: freezed == jaJp
          ? _value.jaJp
          : jaJp // ignore: cast_nullable_to_non_nullable
              as JaJp?,
      zhCn: freezed == zhCn
          ? _value.zhCn
          : zhCn // ignore: cast_nullable_to_non_nullable
              as ZhCn?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EnUsCopyWith<$Res>? get enUs {
    if (_value.enUs == null) {
      return null;
    }

    return $EnUsCopyWith<$Res>(_value.enUs!, (value) {
      return _then(_value.copyWith(enUs: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $JaJpCopyWith<$Res>? get jaJp {
    if (_value.jaJp == null) {
      return null;
    }

    return $JaJpCopyWith<$Res>(_value.jaJp!, (value) {
      return _then(_value.copyWith(jaJp: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ZhCnCopyWith<$Res>? get zhCn {
    if (_value.zhCn == null) {
      return null;
    }

    return $ZhCnCopyWith<$Res>(_value.zhCn!, (value) {
      return _then(_value.copyWith(zhCn: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$I18nImplCopyWith<$Res> implements $I18nCopyWith<$Res> {
  factory _$$I18nImplCopyWith(
          _$I18nImpl value, $Res Function(_$I18nImpl) then) =
      __$$I18nImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'en-us') EnUs? enUs,
      @JsonKey(name: 'ja-jp') JaJp? jaJp,
      @JsonKey(name: 'zh-cn') ZhCn? zhCn});

  @override
  $EnUsCopyWith<$Res>? get enUs;
  @override
  $JaJpCopyWith<$Res>? get jaJp;
  @override
  $ZhCnCopyWith<$Res>? get zhCn;
}

/// @nodoc
class __$$I18nImplCopyWithImpl<$Res>
    extends _$I18nCopyWithImpl<$Res, _$I18nImpl>
    implements _$$I18nImplCopyWith<$Res> {
  __$$I18nImplCopyWithImpl(_$I18nImpl _value, $Res Function(_$I18nImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enUs = freezed,
    Object? jaJp = freezed,
    Object? zhCn = freezed,
  }) {
    return _then(_$I18nImpl(
      enUs: freezed == enUs
          ? _value.enUs
          : enUs // ignore: cast_nullable_to_non_nullable
              as EnUs?,
      jaJp: freezed == jaJp
          ? _value.jaJp
          : jaJp // ignore: cast_nullable_to_non_nullable
              as JaJp?,
      zhCn: freezed == zhCn
          ? _value.zhCn
          : zhCn // ignore: cast_nullable_to_non_nullable
              as ZhCn?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$I18nImpl implements _I18n {
  _$I18nImpl(
      {@JsonKey(name: 'en-us') this.enUs,
      @JsonKey(name: 'ja-jp') this.jaJp,
      @JsonKey(name: 'zh-cn') this.zhCn});

  factory _$I18nImpl.fromJson(Map<String, dynamic> json) =>
      _$$I18nImplFromJson(json);

  @override
  @JsonKey(name: 'en-us')
  final EnUs? enUs;
  @override
  @JsonKey(name: 'ja-jp')
  final JaJp? jaJp;
  @override
  @JsonKey(name: 'zh-cn')
  final ZhCn? zhCn;

  @override
  String toString() {
    return 'I18n(enUs: $enUs, jaJp: $jaJp, zhCn: $zhCn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$I18nImpl &&
            (identical(other.enUs, enUs) || other.enUs == enUs) &&
            (identical(other.jaJp, jaJp) || other.jaJp == jaJp) &&
            (identical(other.zhCn, zhCn) || other.zhCn == zhCn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, enUs, jaJp, zhCn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$I18nImplCopyWith<_$I18nImpl> get copyWith =>
      __$$I18nImplCopyWithImpl<_$I18nImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$I18nImplToJson(
      this,
    );
  }
}

abstract class _I18n implements I18n {
  factory _I18n(
      {@JsonKey(name: 'en-us') final EnUs? enUs,
      @JsonKey(name: 'ja-jp') final JaJp? jaJp,
      @JsonKey(name: 'zh-cn') final ZhCn? zhCn}) = _$I18nImpl;

  factory _I18n.fromJson(Map<String, dynamic> json) = _$I18nImpl.fromJson;

  @override
  @JsonKey(name: 'en-us')
  EnUs? get enUs;
  @override
  @JsonKey(name: 'ja-jp')
  JaJp? get jaJp;
  @override
  @JsonKey(name: 'zh-cn')
  ZhCn? get zhCn;
  @override
  @JsonKey(ignore: true)
  _$$I18nImplCopyWith<_$I18nImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
