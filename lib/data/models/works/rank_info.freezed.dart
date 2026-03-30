// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rank_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RankInfo _$RankInfoFromJson(Map<String, dynamic> json) {
  return _RankInfo.fromJson(json);
}

/// @nodoc
mixin _$RankInfo {
  String? get term => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  int? get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'rank_date')
  String? get rankDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RankInfoCopyWith<RankInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankInfoCopyWith<$Res> {
  factory $RankInfoCopyWith(RankInfo value, $Res Function(RankInfo) then) =
      _$RankInfoCopyWithImpl<$Res, RankInfo>;
  @useResult
  $Res call(
      {String? term,
      String? category,
      int? rank,
      @JsonKey(name: 'rank_date') String? rankDate});
}

/// @nodoc
class _$RankInfoCopyWithImpl<$Res, $Val extends RankInfo>
    implements $RankInfoCopyWith<$Res> {
  _$RankInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = freezed,
    Object? category = freezed,
    Object? rank = freezed,
    Object? rankDate = freezed,
  }) {
    return _then(_value.copyWith(
      term: freezed == term
          ? _value.term
          : term // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      rankDate: freezed == rankDate
          ? _value.rankDate
          : rankDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RankInfoImplCopyWith<$Res>
    implements $RankInfoCopyWith<$Res> {
  factory _$$RankInfoImplCopyWith(
          _$RankInfoImpl value, $Res Function(_$RankInfoImpl) then) =
      __$$RankInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? term,
      String? category,
      int? rank,
      @JsonKey(name: 'rank_date') String? rankDate});
}

/// @nodoc
class __$$RankInfoImplCopyWithImpl<$Res>
    extends _$RankInfoCopyWithImpl<$Res, _$RankInfoImpl>
    implements _$$RankInfoImplCopyWith<$Res> {
  __$$RankInfoImplCopyWithImpl(
      _$RankInfoImpl _value, $Res Function(_$RankInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = freezed,
    Object? category = freezed,
    Object? rank = freezed,
    Object? rankDate = freezed,
  }) {
    return _then(_$RankInfoImpl(
      term: freezed == term
          ? _value.term
          : term // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      rankDate: freezed == rankDate
          ? _value.rankDate
          : rankDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RankInfoImpl implements _RankInfo {
  _$RankInfoImpl(
      {this.term,
      this.category,
      this.rank,
      @JsonKey(name: 'rank_date') this.rankDate});

  factory _$RankInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RankInfoImplFromJson(json);

  @override
  final String? term;
  @override
  final String? category;
  @override
  final int? rank;
  @override
  @JsonKey(name: 'rank_date')
  final String? rankDate;

  @override
  String toString() {
    return 'RankInfo(term: $term, category: $category, rank: $rank, rankDate: $rankDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankInfoImpl &&
            (identical(other.term, term) || other.term == term) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.rankDate, rankDate) ||
                other.rankDate == rankDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, term, category, rank, rankDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RankInfoImplCopyWith<_$RankInfoImpl> get copyWith =>
      __$$RankInfoImplCopyWithImpl<_$RankInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RankInfoImplToJson(
      this,
    );
  }
}

abstract class _RankInfo implements RankInfo {
  factory _RankInfo(
      {final String? term,
      final String? category,
      final int? rank,
      @JsonKey(name: 'rank_date') final String? rankDate}) = _$RankInfoImpl;

  factory _RankInfo.fromJson(Map<String, dynamic> json) =
      _$RankInfoImpl.fromJson;

  @override
  String? get term;
  @override
  String? get category;
  @override
  int? get rank;
  @override
  @JsonKey(name: 'rank_date')
  String? get rankDate;
  @override
  @JsonKey(ignore: true)
  _$$RankInfoImplCopyWith<_$RankInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
