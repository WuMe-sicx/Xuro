// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'language_edition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LanguageEdition _$LanguageEditionFromJson(Map<String, dynamic> json) {
  return _LanguageEdition.fromJson(json);
}

/// @nodoc
mixin _$LanguageEdition {
  String? get lang => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  String? get workno => throw _privateConstructorUsedError;
  @JsonKey(name: 'edition_id')
  int? get editionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'edition_type')
  String? get editionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_order')
  int? get displayOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LanguageEditionCopyWith<LanguageEdition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguageEditionCopyWith<$Res> {
  factory $LanguageEditionCopyWith(
          LanguageEdition value, $Res Function(LanguageEdition) then) =
      _$LanguageEditionCopyWithImpl<$Res, LanguageEdition>;
  @useResult
  $Res call(
      {String? lang,
      String? label,
      String? workno,
      @JsonKey(name: 'edition_id') int? editionId,
      @JsonKey(name: 'edition_type') String? editionType,
      @JsonKey(name: 'display_order') int? displayOrder});
}

/// @nodoc
class _$LanguageEditionCopyWithImpl<$Res, $Val extends LanguageEdition>
    implements $LanguageEditionCopyWith<$Res> {
  _$LanguageEditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lang = freezed,
    Object? label = freezed,
    Object? workno = freezed,
    Object? editionId = freezed,
    Object? editionType = freezed,
    Object? displayOrder = freezed,
  }) {
    return _then(_value.copyWith(
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      workno: freezed == workno
          ? _value.workno
          : workno // ignore: cast_nullable_to_non_nullable
              as String?,
      editionId: freezed == editionId
          ? _value.editionId
          : editionId // ignore: cast_nullable_to_non_nullable
              as int?,
      editionType: freezed == editionType
          ? _value.editionType
          : editionType // ignore: cast_nullable_to_non_nullable
              as String?,
      displayOrder: freezed == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LanguageEditionImplCopyWith<$Res>
    implements $LanguageEditionCopyWith<$Res> {
  factory _$$LanguageEditionImplCopyWith(_$LanguageEditionImpl value,
          $Res Function(_$LanguageEditionImpl) then) =
      __$$LanguageEditionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? lang,
      String? label,
      String? workno,
      @JsonKey(name: 'edition_id') int? editionId,
      @JsonKey(name: 'edition_type') String? editionType,
      @JsonKey(name: 'display_order') int? displayOrder});
}

/// @nodoc
class __$$LanguageEditionImplCopyWithImpl<$Res>
    extends _$LanguageEditionCopyWithImpl<$Res, _$LanguageEditionImpl>
    implements _$$LanguageEditionImplCopyWith<$Res> {
  __$$LanguageEditionImplCopyWithImpl(
      _$LanguageEditionImpl _value, $Res Function(_$LanguageEditionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lang = freezed,
    Object? label = freezed,
    Object? workno = freezed,
    Object? editionId = freezed,
    Object? editionType = freezed,
    Object? displayOrder = freezed,
  }) {
    return _then(_$LanguageEditionImpl(
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      workno: freezed == workno
          ? _value.workno
          : workno // ignore: cast_nullable_to_non_nullable
              as String?,
      editionId: freezed == editionId
          ? _value.editionId
          : editionId // ignore: cast_nullable_to_non_nullable
              as int?,
      editionType: freezed == editionType
          ? _value.editionType
          : editionType // ignore: cast_nullable_to_non_nullable
              as String?,
      displayOrder: freezed == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LanguageEditionImpl implements _LanguageEdition {
  _$LanguageEditionImpl(
      {this.lang,
      this.label,
      this.workno,
      @JsonKey(name: 'edition_id') this.editionId,
      @JsonKey(name: 'edition_type') this.editionType,
      @JsonKey(name: 'display_order') this.displayOrder});

  factory _$LanguageEditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LanguageEditionImplFromJson(json);

  @override
  final String? lang;
  @override
  final String? label;
  @override
  final String? workno;
  @override
  @JsonKey(name: 'edition_id')
  final int? editionId;
  @override
  @JsonKey(name: 'edition_type')
  final String? editionType;
  @override
  @JsonKey(name: 'display_order')
  final int? displayOrder;

  @override
  String toString() {
    return 'LanguageEdition(lang: $lang, label: $label, workno: $workno, editionId: $editionId, editionType: $editionType, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanguageEditionImpl &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.workno, workno) || other.workno == workno) &&
            (identical(other.editionId, editionId) ||
                other.editionId == editionId) &&
            (identical(other.editionType, editionType) ||
                other.editionType == editionType) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, lang, label, workno, editionId, editionType, displayOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LanguageEditionImplCopyWith<_$LanguageEditionImpl> get copyWith =>
      __$$LanguageEditionImplCopyWithImpl<_$LanguageEditionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LanguageEditionImplToJson(
      this,
    );
  }
}

abstract class _LanguageEdition implements LanguageEdition {
  factory _LanguageEdition(
          {final String? lang,
          final String? label,
          final String? workno,
          @JsonKey(name: 'edition_id') final int? editionId,
          @JsonKey(name: 'edition_type') final String? editionType,
          @JsonKey(name: 'display_order') final int? displayOrder}) =
      _$LanguageEditionImpl;

  factory _LanguageEdition.fromJson(Map<String, dynamic> json) =
      _$LanguageEditionImpl.fromJson;

  @override
  String? get lang;
  @override
  String? get label;
  @override
  String? get workno;
  @override
  @JsonKey(name: 'edition_id')
  int? get editionId;
  @override
  @JsonKey(name: 'edition_type')
  String? get editionType;
  @override
  @JsonKey(name: 'display_order')
  int? get displayOrder;
  @override
  @JsonKey(ignore: true)
  _$$LanguageEditionImplCopyWith<_$LanguageEditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
