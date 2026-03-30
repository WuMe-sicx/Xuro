// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circle_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CircleItem _$CircleItemFromJson(Map<String, dynamic> json) {
  return _CircleItem.fromJson(json);
}

/// @nodoc
mixin _$CircleItem {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;
  I18n? get i18n => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CircleItemCopyWith<CircleItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircleItemCopyWith<$Res> {
  factory $CircleItemCopyWith(
          CircleItem value, $Res Function(CircleItem) then) =
      _$CircleItemCopyWithImpl<$Res, CircleItem>;
  @useResult
  $Res call({int? id, String? name, int? count, I18n? i18n});

  $I18nCopyWith<$Res>? get i18n;
}

/// @nodoc
class _$CircleItemCopyWithImpl<$Res, $Val extends CircleItem>
    implements $CircleItemCopyWith<$Res> {
  _$CircleItemCopyWithImpl(this._value, this._then);

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
              as int?,
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
abstract class _$$CircleItemImplCopyWith<$Res>
    implements $CircleItemCopyWith<$Res> {
  factory _$$CircleItemImplCopyWith(
          _$CircleItemImpl value, $Res Function(_$CircleItemImpl) then) =
      __$$CircleItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name, int? count, I18n? i18n});

  @override
  $I18nCopyWith<$Res>? get i18n;
}

/// @nodoc
class __$$CircleItemImplCopyWithImpl<$Res>
    extends _$CircleItemCopyWithImpl<$Res, _$CircleItemImpl>
    implements _$$CircleItemImplCopyWith<$Res> {
  __$$CircleItemImplCopyWithImpl(
      _$CircleItemImpl _value, $Res Function(_$CircleItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? count = freezed,
    Object? i18n = freezed,
  }) {
    return _then(_$CircleItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
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
class _$CircleItemImpl implements _CircleItem {
  _$CircleItemImpl({this.id, this.name, this.count, this.i18n});

  factory _$CircleItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircleItemImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final int? count;
  @override
  final I18n? i18n;

  @override
  String toString() {
    return 'CircleItem(id: $id, name: $name, count: $count, i18n: $i18n)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircleItemImpl &&
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
  _$$CircleItemImplCopyWith<_$CircleItemImpl> get copyWith =>
      __$$CircleItemImplCopyWithImpl<_$CircleItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CircleItemImplToJson(
      this,
    );
  }
}

abstract class _CircleItem implements CircleItem {
  factory _CircleItem(
      {final int? id,
      final String? name,
      final int? count,
      final I18n? i18n}) = _$CircleItemImpl;

  factory _CircleItem.fromJson(Map<String, dynamic> json) =
      _$CircleItemImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  int? get count;
  @override
  I18n? get i18n;
  @override
  @JsonKey(ignore: true)
  _$$CircleItemImplCopyWith<_$CircleItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
