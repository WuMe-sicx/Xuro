// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'files.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Files _$FilesFromJson(Map<String, dynamic> json) {
  return _Files.fromJson(json);
}

/// @nodoc
mixin _$Files {
  String? get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  List<Child>? get children => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FilesCopyWith<Files> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FilesCopyWith<$Res> {
  factory $FilesCopyWith(Files value, $Res Function(Files) then) =
      _$FilesCopyWithImpl<$Res, Files>;
  @useResult
  $Res call({String? type, String? title, List<Child>? children});
}

/// @nodoc
class _$FilesCopyWithImpl<$Res, $Val extends Files>
    implements $FilesCopyWith<$Res> {
  _$FilesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? title = freezed,
    Object? children = freezed,
  }) {
    return _then(_value.copyWith(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      children: freezed == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<Child>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FilesImplCopyWith<$Res> implements $FilesCopyWith<$Res> {
  factory _$$FilesImplCopyWith(
          _$FilesImpl value, $Res Function(_$FilesImpl) then) =
      __$$FilesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? type, String? title, List<Child>? children});
}

/// @nodoc
class __$$FilesImplCopyWithImpl<$Res>
    extends _$FilesCopyWithImpl<$Res, _$FilesImpl>
    implements _$$FilesImplCopyWith<$Res> {
  __$$FilesImplCopyWithImpl(
      _$FilesImpl _value, $Res Function(_$FilesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? title = freezed,
    Object? children = freezed,
  }) {
    return _then(_$FilesImpl(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      children: freezed == children
          ? _value._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<Child>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FilesImpl implements _Files {
  _$FilesImpl({this.type, this.title, final List<Child>? children})
      : _children = children;

  factory _$FilesImpl.fromJson(Map<String, dynamic> json) =>
      _$$FilesImplFromJson(json);

  @override
  final String? type;
  @override
  final String? title;
  final List<Child>? _children;
  @override
  List<Child>? get children {
    final value = _children;
    if (value == null) return null;
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Files(type: $type, title: $title, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilesImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, title, const DeepCollectionEquality().hash(_children));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FilesImplCopyWith<_$FilesImpl> get copyWith =>
      __$$FilesImplCopyWithImpl<_$FilesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FilesImplToJson(
      this,
    );
  }
}

abstract class _Files implements Files {
  factory _Files(
      {final String? type,
      final String? title,
      final List<Child>? children}) = _$FilesImpl;

  factory _Files.fromJson(Map<String, dynamic> json) = _$FilesImpl.fromJson;

  @override
  String? get type;
  @override
  String? get title;
  @override
  List<Child>? get children;
  @override
  @JsonKey(ignore: true)
  _$$FilesImplCopyWith<_$FilesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
