// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Child _$ChildFromJson(Map<String, dynamic> json) {
  return _Child.fromJson(json);
}

/// @nodoc
mixin _$Child {
  String? get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  List<Child>? get children => throw _privateConstructorUsedError;
  String? get hash => throw _privateConstructorUsedError;
  Work? get work => throw _privateConstructorUsedError;
  String? get workTitle => throw _privateConstructorUsedError;
  String? get mediaStreamUrl => throw _privateConstructorUsedError;
  String? get mediaDownloadUrl => throw _privateConstructorUsedError;
  int? get size => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChildCopyWith<Child> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildCopyWith<$Res> {
  factory $ChildCopyWith(Child value, $Res Function(Child) then) =
      _$ChildCopyWithImpl<$Res, Child>;
  @useResult
  $Res call(
      {String? type,
      String? title,
      List<Child>? children,
      String? hash,
      Work? work,
      String? workTitle,
      String? mediaStreamUrl,
      String? mediaDownloadUrl,
      int? size});

  $WorkCopyWith<$Res>? get work;
}

/// @nodoc
class _$ChildCopyWithImpl<$Res, $Val extends Child>
    implements $ChildCopyWith<$Res> {
  _$ChildCopyWithImpl(this._value, this._then);

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
    Object? hash = freezed,
    Object? work = freezed,
    Object? workTitle = freezed,
    Object? mediaStreamUrl = freezed,
    Object? mediaDownloadUrl = freezed,
    Object? size = freezed,
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
      hash: freezed == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String?,
      work: freezed == work
          ? _value.work
          : work // ignore: cast_nullable_to_non_nullable
              as Work?,
      workTitle: freezed == workTitle
          ? _value.workTitle
          : workTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaStreamUrl: freezed == mediaStreamUrl
          ? _value.mediaStreamUrl
          : mediaStreamUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaDownloadUrl: freezed == mediaDownloadUrl
          ? _value.mediaDownloadUrl
          : mediaDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkCopyWith<$Res>? get work {
    if (_value.work == null) {
      return null;
    }

    return $WorkCopyWith<$Res>(_value.work!, (value) {
      return _then(_value.copyWith(work: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChildImplCopyWith<$Res> implements $ChildCopyWith<$Res> {
  factory _$$ChildImplCopyWith(
          _$ChildImpl value, $Res Function(_$ChildImpl) then) =
      __$$ChildImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? type,
      String? title,
      List<Child>? children,
      String? hash,
      Work? work,
      String? workTitle,
      String? mediaStreamUrl,
      String? mediaDownloadUrl,
      int? size});

  @override
  $WorkCopyWith<$Res>? get work;
}

/// @nodoc
class __$$ChildImplCopyWithImpl<$Res>
    extends _$ChildCopyWithImpl<$Res, _$ChildImpl>
    implements _$$ChildImplCopyWith<$Res> {
  __$$ChildImplCopyWithImpl(
      _$ChildImpl _value, $Res Function(_$ChildImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? title = freezed,
    Object? children = freezed,
    Object? hash = freezed,
    Object? work = freezed,
    Object? workTitle = freezed,
    Object? mediaStreamUrl = freezed,
    Object? mediaDownloadUrl = freezed,
    Object? size = freezed,
  }) {
    return _then(_$ChildImpl(
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
      hash: freezed == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String?,
      work: freezed == work
          ? _value.work
          : work // ignore: cast_nullable_to_non_nullable
              as Work?,
      workTitle: freezed == workTitle
          ? _value.workTitle
          : workTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaStreamUrl: freezed == mediaStreamUrl
          ? _value.mediaStreamUrl
          : mediaStreamUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaDownloadUrl: freezed == mediaDownloadUrl
          ? _value.mediaDownloadUrl
          : mediaDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildImpl implements _Child {
  _$ChildImpl(
      {this.type,
      this.title,
      final List<Child>? children,
      this.hash,
      this.work,
      this.workTitle,
      this.mediaStreamUrl,
      this.mediaDownloadUrl,
      this.size})
      : _children = children;

  factory _$ChildImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildImplFromJson(json);

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
  final String? hash;
  @override
  final Work? work;
  @override
  final String? workTitle;
  @override
  final String? mediaStreamUrl;
  @override
  final String? mediaDownloadUrl;
  @override
  final int? size;

  @override
  String toString() {
    return 'Child(type: $type, title: $title, children: $children, hash: $hash, work: $work, workTitle: $workTitle, mediaStreamUrl: $mediaStreamUrl, mediaDownloadUrl: $mediaDownloadUrl, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._children, _children) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.work, work) || other.work == work) &&
            (identical(other.workTitle, workTitle) ||
                other.workTitle == workTitle) &&
            (identical(other.mediaStreamUrl, mediaStreamUrl) ||
                other.mediaStreamUrl == mediaStreamUrl) &&
            (identical(other.mediaDownloadUrl, mediaDownloadUrl) ||
                other.mediaDownloadUrl == mediaDownloadUrl) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      title,
      const DeepCollectionEquality().hash(_children),
      hash,
      work,
      workTitle,
      mediaStreamUrl,
      mediaDownloadUrl,
      size);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildImplCopyWith<_$ChildImpl> get copyWith =>
      __$$ChildImplCopyWithImpl<_$ChildImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildImplToJson(
      this,
    );
  }
}

abstract class _Child implements Child {
  factory _Child(
      {final String? type,
      final String? title,
      final List<Child>? children,
      final String? hash,
      final Work? work,
      final String? workTitle,
      final String? mediaStreamUrl,
      final String? mediaDownloadUrl,
      final int? size}) = _$ChildImpl;

  factory _Child.fromJson(Map<String, dynamic> json) = _$ChildImpl.fromJson;

  @override
  String? get type;
  @override
  String? get title;
  @override
  List<Child>? get children;
  @override
  String? get hash;
  @override
  Work? get work;
  @override
  String? get workTitle;
  @override
  String? get mediaStreamUrl;
  @override
  String? get mediaDownloadUrl;
  @override
  int? get size;
  @override
  @JsonKey(ignore: true)
  _$$ChildImplCopyWith<_$ChildImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
