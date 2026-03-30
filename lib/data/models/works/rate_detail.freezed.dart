// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RateDetail _$RateDetailFromJson(Map<String, dynamic> json) {
  return _RateDetail.fromJson(json);
}

/// @nodoc
mixin _$RateDetail {
  @JsonKey(name: 'review_point')
  int? get reviewPoint => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;
  double? get ratio => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RateDetailCopyWith<RateDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateDetailCopyWith<$Res> {
  factory $RateDetailCopyWith(
          RateDetail value, $Res Function(RateDetail) then) =
      _$RateDetailCopyWithImpl<$Res, RateDetail>;
  @useResult
  $Res call(
      {@JsonKey(name: 'review_point') int? reviewPoint,
      int? count,
      double? ratio});
}

/// @nodoc
class _$RateDetailCopyWithImpl<$Res, $Val extends RateDetail>
    implements $RateDetailCopyWith<$Res> {
  _$RateDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reviewPoint = freezed,
    Object? count = freezed,
    Object? ratio = freezed,
  }) {
    return _then(_value.copyWith(
      reviewPoint: freezed == reviewPoint
          ? _value.reviewPoint
          : reviewPoint // ignore: cast_nullable_to_non_nullable
              as int?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      ratio: freezed == ratio
          ? _value.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RateDetailImplCopyWith<$Res>
    implements $RateDetailCopyWith<$Res> {
  factory _$$RateDetailImplCopyWith(
          _$RateDetailImpl value, $Res Function(_$RateDetailImpl) then) =
      __$$RateDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'review_point') int? reviewPoint,
      int? count,
      double? ratio});
}

/// @nodoc
class __$$RateDetailImplCopyWithImpl<$Res>
    extends _$RateDetailCopyWithImpl<$Res, _$RateDetailImpl>
    implements _$$RateDetailImplCopyWith<$Res> {
  __$$RateDetailImplCopyWithImpl(
      _$RateDetailImpl _value, $Res Function(_$RateDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reviewPoint = freezed,
    Object? count = freezed,
    Object? ratio = freezed,
  }) {
    return _then(_$RateDetailImpl(
      reviewPoint: freezed == reviewPoint
          ? _value.reviewPoint
          : reviewPoint // ignore: cast_nullable_to_non_nullable
              as int?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      ratio: freezed == ratio
          ? _value.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RateDetailImpl implements _RateDetail {
  _$RateDetailImpl(
      {@JsonKey(name: 'review_point') this.reviewPoint,
      this.count,
      this.ratio});

  factory _$RateDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$RateDetailImplFromJson(json);

  @override
  @JsonKey(name: 'review_point')
  final int? reviewPoint;
  @override
  final int? count;
  @override
  final double? ratio;

  @override
  String toString() {
    return 'RateDetail(reviewPoint: $reviewPoint, count: $count, ratio: $ratio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateDetailImpl &&
            (identical(other.reviewPoint, reviewPoint) ||
                other.reviewPoint == reviewPoint) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.ratio, ratio) || other.ratio == ratio));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, reviewPoint, count, ratio);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RateDetailImplCopyWith<_$RateDetailImpl> get copyWith =>
      __$$RateDetailImplCopyWithImpl<_$RateDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RateDetailImplToJson(
      this,
    );
  }
}

abstract class _RateDetail implements RateDetail {
  factory _RateDetail(
      {@JsonKey(name: 'review_point') final int? reviewPoint,
      final int? count,
      final double? ratio}) = _$RateDetailImpl;

  factory _RateDetail.fromJson(Map<String, dynamic> json) =
      _$RateDetailImpl.fromJson;

  @override
  @JsonKey(name: 'review_point')
  int? get reviewPoint;
  @override
  int? get count;
  @override
  double? get ratio;
  @override
  @JsonKey(ignore: true)
  _$$RateDetailImplCopyWith<_$RateDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
