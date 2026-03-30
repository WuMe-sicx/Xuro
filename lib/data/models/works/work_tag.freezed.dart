// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkTag _$WorkTagFromJson(Map<String, dynamic> json) {
  return _WorkTag.fromJson(json);
}

/// @nodoc
mixin _$WorkTag {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  I18n? get i18n => throw _privateConstructorUsedError;
  int? get upvote => throw _privateConstructorUsedError;
  int? get downvote => throw _privateConstructorUsedError;
  int? get voteRank => throw _privateConstructorUsedError;
  int? get voteStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkTagCopyWith<WorkTag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkTagCopyWith<$Res> {
  factory $WorkTagCopyWith(WorkTag value, $Res Function(WorkTag) then) =
      _$WorkTagCopyWithImpl<$Res, WorkTag>;
  @useResult
  $Res call(
      {int? id,
      String? name,
      I18n? i18n,
      int? upvote,
      int? downvote,
      int? voteRank,
      int? voteStatus});

  $I18nCopyWith<$Res>? get i18n;
}

/// @nodoc
class _$WorkTagCopyWithImpl<$Res, $Val extends WorkTag>
    implements $WorkTagCopyWith<$Res> {
  _$WorkTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? i18n = freezed,
    Object? upvote = freezed,
    Object? downvote = freezed,
    Object? voteRank = freezed,
    Object? voteStatus = freezed,
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
      i18n: freezed == i18n
          ? _value.i18n
          : i18n // ignore: cast_nullable_to_non_nullable
              as I18n?,
      upvote: freezed == upvote
          ? _value.upvote
          : upvote // ignore: cast_nullable_to_non_nullable
              as int?,
      downvote: freezed == downvote
          ? _value.downvote
          : downvote // ignore: cast_nullable_to_non_nullable
              as int?,
      voteRank: freezed == voteRank
          ? _value.voteRank
          : voteRank // ignore: cast_nullable_to_non_nullable
              as int?,
      voteStatus: freezed == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as int?,
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
abstract class _$$WorkTagImplCopyWith<$Res> implements $WorkTagCopyWith<$Res> {
  factory _$$WorkTagImplCopyWith(
          _$WorkTagImpl value, $Res Function(_$WorkTagImpl) then) =
      __$$WorkTagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? name,
      I18n? i18n,
      int? upvote,
      int? downvote,
      int? voteRank,
      int? voteStatus});

  @override
  $I18nCopyWith<$Res>? get i18n;
}

/// @nodoc
class __$$WorkTagImplCopyWithImpl<$Res>
    extends _$WorkTagCopyWithImpl<$Res, _$WorkTagImpl>
    implements _$$WorkTagImplCopyWith<$Res> {
  __$$WorkTagImplCopyWithImpl(
      _$WorkTagImpl _value, $Res Function(_$WorkTagImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? i18n = freezed,
    Object? upvote = freezed,
    Object? downvote = freezed,
    Object? voteRank = freezed,
    Object? voteStatus = freezed,
  }) {
    return _then(_$WorkTagImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      i18n: freezed == i18n
          ? _value.i18n
          : i18n // ignore: cast_nullable_to_non_nullable
              as I18n?,
      upvote: freezed == upvote
          ? _value.upvote
          : upvote // ignore: cast_nullable_to_non_nullable
              as int?,
      downvote: freezed == downvote
          ? _value.downvote
          : downvote // ignore: cast_nullable_to_non_nullable
              as int?,
      voteRank: freezed == voteRank
          ? _value.voteRank
          : voteRank // ignore: cast_nullable_to_non_nullable
              as int?,
      voteStatus: freezed == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkTagImpl implements _WorkTag {
  _$WorkTagImpl(
      {this.id,
      this.name,
      this.i18n,
      this.upvote,
      this.downvote,
      this.voteRank,
      this.voteStatus});

  factory _$WorkTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkTagImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final I18n? i18n;
  @override
  final int? upvote;
  @override
  final int? downvote;
  @override
  final int? voteRank;
  @override
  final int? voteStatus;

  @override
  String toString() {
    return 'WorkTag(id: $id, name: $name, i18n: $i18n, upvote: $upvote, downvote: $downvote, voteRank: $voteRank, voteStatus: $voteStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkTagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.i18n, i18n) || other.i18n == i18n) &&
            (identical(other.upvote, upvote) || other.upvote == upvote) &&
            (identical(other.downvote, downvote) ||
                other.downvote == downvote) &&
            (identical(other.voteRank, voteRank) ||
                other.voteRank == voteRank) &&
            (identical(other.voteStatus, voteStatus) ||
                other.voteStatus == voteStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, i18n, upvote, downvote, voteRank, voteStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkTagImplCopyWith<_$WorkTagImpl> get copyWith =>
      __$$WorkTagImplCopyWithImpl<_$WorkTagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkTagImplToJson(
      this,
    );
  }
}

abstract class _WorkTag implements WorkTag {
  factory _WorkTag(
      {final int? id,
      final String? name,
      final I18n? i18n,
      final int? upvote,
      final int? downvote,
      final int? voteRank,
      final int? voteStatus}) = _$WorkTagImpl;

  factory _WorkTag.fromJson(Map<String, dynamic> json) = _$WorkTagImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  I18n? get i18n;
  @override
  int? get upvote;
  @override
  int? get downvote;
  @override
  int? get voteRank;
  @override
  int? get voteStatus;
  @override
  @JsonKey(ignore: true)
  _$$WorkTagImplCopyWith<_$WorkTagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
