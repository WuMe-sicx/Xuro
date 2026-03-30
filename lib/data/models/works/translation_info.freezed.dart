// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TranslationInfo _$TranslationInfoFromJson(Map<String, dynamic> json) {
  return _TranslationInfo.fromJson(json);
}

/// @nodoc
mixin _$TranslationInfo {
  String? get lang => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_child')
  bool? get isChild => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_parent')
  bool? get isParent => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_original')
  bool? get isOriginal => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_volunteer')
  bool? get isVolunteer => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_worknos')
  List<dynamic>? get childWorknos => throw _privateConstructorUsedError;
  @JsonKey(name: 'parent_workno')
  String? get parentWorkno => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_workno')
  String? get originalWorkno => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_translation_agree')
  bool? get isTranslationAgree => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'translation_bonus_langs',
      fromJson: _translationBonusLangsFromJson,
      toJson: _translationBonusLangsToJson)
  Map<String, TranslationBonusLang>? get translationBonusLangs =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'is_translation_bonus_child')
  bool? get isTranslationBonusChild => throw _privateConstructorUsedError;
  @JsonKey(name: 'production_trade_price_rate')
  int? get productionTradePriceRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TranslationInfoCopyWith<TranslationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationInfoCopyWith<$Res> {
  factory $TranslationInfoCopyWith(
          TranslationInfo value, $Res Function(TranslationInfo) then) =
      _$TranslationInfoCopyWithImpl<$Res, TranslationInfo>;
  @useResult
  $Res call(
      {String? lang,
      @JsonKey(name: 'is_child') bool? isChild,
      @JsonKey(name: 'is_parent') bool? isParent,
      @JsonKey(name: 'is_original') bool? isOriginal,
      @JsonKey(name: 'is_volunteer') bool? isVolunteer,
      @JsonKey(name: 'child_worknos') List<dynamic>? childWorknos,
      @JsonKey(name: 'parent_workno') String? parentWorkno,
      @JsonKey(name: 'original_workno') String? originalWorkno,
      @JsonKey(name: 'is_translation_agree') bool? isTranslationAgree,
      @JsonKey(
          name: 'translation_bonus_langs',
          fromJson: _translationBonusLangsFromJson,
          toJson: _translationBonusLangsToJson)
      Map<String, TranslationBonusLang>? translationBonusLangs,
      @JsonKey(name: 'is_translation_bonus_child')
      bool? isTranslationBonusChild,
      @JsonKey(name: 'production_trade_price_rate')
      int? productionTradePriceRate});
}

/// @nodoc
class _$TranslationInfoCopyWithImpl<$Res, $Val extends TranslationInfo>
    implements $TranslationInfoCopyWith<$Res> {
  _$TranslationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lang = freezed,
    Object? isChild = freezed,
    Object? isParent = freezed,
    Object? isOriginal = freezed,
    Object? isVolunteer = freezed,
    Object? childWorknos = freezed,
    Object? parentWorkno = freezed,
    Object? originalWorkno = freezed,
    Object? isTranslationAgree = freezed,
    Object? translationBonusLangs = freezed,
    Object? isTranslationBonusChild = freezed,
    Object? productionTradePriceRate = freezed,
  }) {
    return _then(_value.copyWith(
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      isChild: freezed == isChild
          ? _value.isChild
          : isChild // ignore: cast_nullable_to_non_nullable
              as bool?,
      isParent: freezed == isParent
          ? _value.isParent
          : isParent // ignore: cast_nullable_to_non_nullable
              as bool?,
      isOriginal: freezed == isOriginal
          ? _value.isOriginal
          : isOriginal // ignore: cast_nullable_to_non_nullable
              as bool?,
      isVolunteer: freezed == isVolunteer
          ? _value.isVolunteer
          : isVolunteer // ignore: cast_nullable_to_non_nullable
              as bool?,
      childWorknos: freezed == childWorknos
          ? _value.childWorknos
          : childWorknos // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      parentWorkno: freezed == parentWorkno
          ? _value.parentWorkno
          : parentWorkno // ignore: cast_nullable_to_non_nullable
              as String?,
      originalWorkno: freezed == originalWorkno
          ? _value.originalWorkno
          : originalWorkno // ignore: cast_nullable_to_non_nullable
              as String?,
      isTranslationAgree: freezed == isTranslationAgree
          ? _value.isTranslationAgree
          : isTranslationAgree // ignore: cast_nullable_to_non_nullable
              as bool?,
      translationBonusLangs: freezed == translationBonusLangs
          ? _value.translationBonusLangs
          : translationBonusLangs // ignore: cast_nullable_to_non_nullable
              as Map<String, TranslationBonusLang>?,
      isTranslationBonusChild: freezed == isTranslationBonusChild
          ? _value.isTranslationBonusChild
          : isTranslationBonusChild // ignore: cast_nullable_to_non_nullable
              as bool?,
      productionTradePriceRate: freezed == productionTradePriceRate
          ? _value.productionTradePriceRate
          : productionTradePriceRate // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranslationInfoImplCopyWith<$Res>
    implements $TranslationInfoCopyWith<$Res> {
  factory _$$TranslationInfoImplCopyWith(_$TranslationInfoImpl value,
          $Res Function(_$TranslationInfoImpl) then) =
      __$$TranslationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? lang,
      @JsonKey(name: 'is_child') bool? isChild,
      @JsonKey(name: 'is_parent') bool? isParent,
      @JsonKey(name: 'is_original') bool? isOriginal,
      @JsonKey(name: 'is_volunteer') bool? isVolunteer,
      @JsonKey(name: 'child_worknos') List<dynamic>? childWorknos,
      @JsonKey(name: 'parent_workno') String? parentWorkno,
      @JsonKey(name: 'original_workno') String? originalWorkno,
      @JsonKey(name: 'is_translation_agree') bool? isTranslationAgree,
      @JsonKey(
          name: 'translation_bonus_langs',
          fromJson: _translationBonusLangsFromJson,
          toJson: _translationBonusLangsToJson)
      Map<String, TranslationBonusLang>? translationBonusLangs,
      @JsonKey(name: 'is_translation_bonus_child')
      bool? isTranslationBonusChild,
      @JsonKey(name: 'production_trade_price_rate')
      int? productionTradePriceRate});
}

/// @nodoc
class __$$TranslationInfoImplCopyWithImpl<$Res>
    extends _$TranslationInfoCopyWithImpl<$Res, _$TranslationInfoImpl>
    implements _$$TranslationInfoImplCopyWith<$Res> {
  __$$TranslationInfoImplCopyWithImpl(
      _$TranslationInfoImpl _value, $Res Function(_$TranslationInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lang = freezed,
    Object? isChild = freezed,
    Object? isParent = freezed,
    Object? isOriginal = freezed,
    Object? isVolunteer = freezed,
    Object? childWorknos = freezed,
    Object? parentWorkno = freezed,
    Object? originalWorkno = freezed,
    Object? isTranslationAgree = freezed,
    Object? translationBonusLangs = freezed,
    Object? isTranslationBonusChild = freezed,
    Object? productionTradePriceRate = freezed,
  }) {
    return _then(_$TranslationInfoImpl(
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      isChild: freezed == isChild
          ? _value.isChild
          : isChild // ignore: cast_nullable_to_non_nullable
              as bool?,
      isParent: freezed == isParent
          ? _value.isParent
          : isParent // ignore: cast_nullable_to_non_nullable
              as bool?,
      isOriginal: freezed == isOriginal
          ? _value.isOriginal
          : isOriginal // ignore: cast_nullable_to_non_nullable
              as bool?,
      isVolunteer: freezed == isVolunteer
          ? _value.isVolunteer
          : isVolunteer // ignore: cast_nullable_to_non_nullable
              as bool?,
      childWorknos: freezed == childWorknos
          ? _value._childWorknos
          : childWorknos // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      parentWorkno: freezed == parentWorkno
          ? _value.parentWorkno
          : parentWorkno // ignore: cast_nullable_to_non_nullable
              as String?,
      originalWorkno: freezed == originalWorkno
          ? _value.originalWorkno
          : originalWorkno // ignore: cast_nullable_to_non_nullable
              as String?,
      isTranslationAgree: freezed == isTranslationAgree
          ? _value.isTranslationAgree
          : isTranslationAgree // ignore: cast_nullable_to_non_nullable
              as bool?,
      translationBonusLangs: freezed == translationBonusLangs
          ? _value._translationBonusLangs
          : translationBonusLangs // ignore: cast_nullable_to_non_nullable
              as Map<String, TranslationBonusLang>?,
      isTranslationBonusChild: freezed == isTranslationBonusChild
          ? _value.isTranslationBonusChild
          : isTranslationBonusChild // ignore: cast_nullable_to_non_nullable
              as bool?,
      productionTradePriceRate: freezed == productionTradePriceRate
          ? _value.productionTradePriceRate
          : productionTradePriceRate // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TranslationInfoImpl implements _TranslationInfo {
  _$TranslationInfoImpl(
      {this.lang,
      @JsonKey(name: 'is_child') this.isChild,
      @JsonKey(name: 'is_parent') this.isParent,
      @JsonKey(name: 'is_original') this.isOriginal,
      @JsonKey(name: 'is_volunteer') this.isVolunteer,
      @JsonKey(name: 'child_worknos') final List<dynamic>? childWorknos,
      @JsonKey(name: 'parent_workno') this.parentWorkno,
      @JsonKey(name: 'original_workno') this.originalWorkno,
      @JsonKey(name: 'is_translation_agree') this.isTranslationAgree,
      @JsonKey(
          name: 'translation_bonus_langs',
          fromJson: _translationBonusLangsFromJson,
          toJson: _translationBonusLangsToJson)
      final Map<String, TranslationBonusLang>? translationBonusLangs,
      @JsonKey(name: 'is_translation_bonus_child') this.isTranslationBonusChild,
      @JsonKey(name: 'production_trade_price_rate')
      this.productionTradePriceRate})
      : _childWorknos = childWorknos,
        _translationBonusLangs = translationBonusLangs;

  factory _$TranslationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranslationInfoImplFromJson(json);

  @override
  final String? lang;
  @override
  @JsonKey(name: 'is_child')
  final bool? isChild;
  @override
  @JsonKey(name: 'is_parent')
  final bool? isParent;
  @override
  @JsonKey(name: 'is_original')
  final bool? isOriginal;
  @override
  @JsonKey(name: 'is_volunteer')
  final bool? isVolunteer;
  final List<dynamic>? _childWorknos;
  @override
  @JsonKey(name: 'child_worknos')
  List<dynamic>? get childWorknos {
    final value = _childWorknos;
    if (value == null) return null;
    if (_childWorknos is EqualUnmodifiableListView) return _childWorknos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'parent_workno')
  final String? parentWorkno;
  @override
  @JsonKey(name: 'original_workno')
  final String? originalWorkno;
  @override
  @JsonKey(name: 'is_translation_agree')
  final bool? isTranslationAgree;
  final Map<String, TranslationBonusLang>? _translationBonusLangs;
  @override
  @JsonKey(
      name: 'translation_bonus_langs',
      fromJson: _translationBonusLangsFromJson,
      toJson: _translationBonusLangsToJson)
  Map<String, TranslationBonusLang>? get translationBonusLangs {
    final value = _translationBonusLangs;
    if (value == null) return null;
    if (_translationBonusLangs is EqualUnmodifiableMapView)
      return _translationBonusLangs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'is_translation_bonus_child')
  final bool? isTranslationBonusChild;
  @override
  @JsonKey(name: 'production_trade_price_rate')
  final int? productionTradePriceRate;

  @override
  String toString() {
    return 'TranslationInfo(lang: $lang, isChild: $isChild, isParent: $isParent, isOriginal: $isOriginal, isVolunteer: $isVolunteer, childWorknos: $childWorknos, parentWorkno: $parentWorkno, originalWorkno: $originalWorkno, isTranslationAgree: $isTranslationAgree, translationBonusLangs: $translationBonusLangs, isTranslationBonusChild: $isTranslationBonusChild, productionTradePriceRate: $productionTradePriceRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationInfoImpl &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.isChild, isChild) || other.isChild == isChild) &&
            (identical(other.isParent, isParent) ||
                other.isParent == isParent) &&
            (identical(other.isOriginal, isOriginal) ||
                other.isOriginal == isOriginal) &&
            (identical(other.isVolunteer, isVolunteer) ||
                other.isVolunteer == isVolunteer) &&
            const DeepCollectionEquality()
                .equals(other._childWorknos, _childWorknos) &&
            (identical(other.parentWorkno, parentWorkno) ||
                other.parentWorkno == parentWorkno) &&
            (identical(other.originalWorkno, originalWorkno) ||
                other.originalWorkno == originalWorkno) &&
            (identical(other.isTranslationAgree, isTranslationAgree) ||
                other.isTranslationAgree == isTranslationAgree) &&
            const DeepCollectionEquality()
                .equals(other._translationBonusLangs, _translationBonusLangs) &&
            (identical(
                    other.isTranslationBonusChild, isTranslationBonusChild) ||
                other.isTranslationBonusChild == isTranslationBonusChild) &&
            (identical(
                    other.productionTradePriceRate, productionTradePriceRate) ||
                other.productionTradePriceRate == productionTradePriceRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      lang,
      isChild,
      isParent,
      isOriginal,
      isVolunteer,
      const DeepCollectionEquality().hash(_childWorknos),
      parentWorkno,
      originalWorkno,
      isTranslationAgree,
      const DeepCollectionEquality().hash(_translationBonusLangs),
      isTranslationBonusChild,
      productionTradePriceRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationInfoImplCopyWith<_$TranslationInfoImpl> get copyWith =>
      __$$TranslationInfoImplCopyWithImpl<_$TranslationInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TranslationInfoImplToJson(
      this,
    );
  }
}

abstract class _TranslationInfo implements TranslationInfo {
  factory _TranslationInfo(
      {final String? lang,
      @JsonKey(name: 'is_child') final bool? isChild,
      @JsonKey(name: 'is_parent') final bool? isParent,
      @JsonKey(name: 'is_original') final bool? isOriginal,
      @JsonKey(name: 'is_volunteer') final bool? isVolunteer,
      @JsonKey(name: 'child_worknos') final List<dynamic>? childWorknos,
      @JsonKey(name: 'parent_workno') final String? parentWorkno,
      @JsonKey(name: 'original_workno') final String? originalWorkno,
      @JsonKey(name: 'is_translation_agree') final bool? isTranslationAgree,
      @JsonKey(
          name: 'translation_bonus_langs',
          fromJson: _translationBonusLangsFromJson,
          toJson: _translationBonusLangsToJson)
      final Map<String, TranslationBonusLang>? translationBonusLangs,
      @JsonKey(name: 'is_translation_bonus_child')
      final bool? isTranslationBonusChild,
      @JsonKey(name: 'production_trade_price_rate')
      final int? productionTradePriceRate}) = _$TranslationInfoImpl;

  factory _TranslationInfo.fromJson(Map<String, dynamic> json) =
      _$TranslationInfoImpl.fromJson;

  @override
  String? get lang;
  @override
  @JsonKey(name: 'is_child')
  bool? get isChild;
  @override
  @JsonKey(name: 'is_parent')
  bool? get isParent;
  @override
  @JsonKey(name: 'is_original')
  bool? get isOriginal;
  @override
  @JsonKey(name: 'is_volunteer')
  bool? get isVolunteer;
  @override
  @JsonKey(name: 'child_worknos')
  List<dynamic>? get childWorknos;
  @override
  @JsonKey(name: 'parent_workno')
  String? get parentWorkno;
  @override
  @JsonKey(name: 'original_workno')
  String? get originalWorkno;
  @override
  @JsonKey(name: 'is_translation_agree')
  bool? get isTranslationAgree;
  @override
  @JsonKey(
      name: 'translation_bonus_langs',
      fromJson: _translationBonusLangsFromJson,
      toJson: _translationBonusLangsToJson)
  Map<String, TranslationBonusLang>? get translationBonusLangs;
  @override
  @JsonKey(name: 'is_translation_bonus_child')
  bool? get isTranslationBonusChild;
  @override
  @JsonKey(name: 'production_trade_price_rate')
  int? get productionTradePriceRate;
  @override
  @JsonKey(ignore: true)
  _$$TranslationInfoImplCopyWith<_$TranslationInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
