// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaybackState _$PlaybackStateFromJson(Map<String, dynamic> json) {
  return _PlaybackState.fromJson(json);
}

/// @nodoc
mixin _$PlaybackState {
  Work get work => throw _privateConstructorUsedError;
  Files get files => throw _privateConstructorUsedError;
  Child get currentFile => throw _privateConstructorUsedError;
  List<Child> get playlist => throw _privateConstructorUsedError;
  int get currentIndex => throw _privateConstructorUsedError;
  PlayMode get playMode => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError; // 使用毫秒存储
  String get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlaybackStateCopyWith<PlaybackState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaybackStateCopyWith<$Res> {
  factory $PlaybackStateCopyWith(
          PlaybackState value, $Res Function(PlaybackState) then) =
      _$PlaybackStateCopyWithImpl<$Res, PlaybackState>;
  @useResult
  $Res call(
      {Work work,
      Files files,
      Child currentFile,
      List<Child> playlist,
      int currentIndex,
      PlayMode playMode,
      int position,
      String timestamp});

  $WorkCopyWith<$Res> get work;
  $FilesCopyWith<$Res> get files;
  $ChildCopyWith<$Res> get currentFile;
}

/// @nodoc
class _$PlaybackStateCopyWithImpl<$Res, $Val extends PlaybackState>
    implements $PlaybackStateCopyWith<$Res> {
  _$PlaybackStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? work = null,
    Object? files = null,
    Object? currentFile = null,
    Object? playlist = null,
    Object? currentIndex = null,
    Object? playMode = null,
    Object? position = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      work: null == work
          ? _value.work
          : work // ignore: cast_nullable_to_non_nullable
              as Work,
      files: null == files
          ? _value.files
          : files // ignore: cast_nullable_to_non_nullable
              as Files,
      currentFile: null == currentFile
          ? _value.currentFile
          : currentFile // ignore: cast_nullable_to_non_nullable
              as Child,
      playlist: null == playlist
          ? _value.playlist
          : playlist // ignore: cast_nullable_to_non_nullable
              as List<Child>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      playMode: null == playMode
          ? _value.playMode
          : playMode // ignore: cast_nullable_to_non_nullable
              as PlayMode,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkCopyWith<$Res> get work {
    return $WorkCopyWith<$Res>(_value.work, (value) {
      return _then(_value.copyWith(work: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $FilesCopyWith<$Res> get files {
    return $FilesCopyWith<$Res>(_value.files, (value) {
      return _then(_value.copyWith(files: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ChildCopyWith<$Res> get currentFile {
    return $ChildCopyWith<$Res>(_value.currentFile, (value) {
      return _then(_value.copyWith(currentFile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaybackStateImplCopyWith<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  factory _$$PlaybackStateImplCopyWith(
          _$PlaybackStateImpl value, $Res Function(_$PlaybackStateImpl) then) =
      __$$PlaybackStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Work work,
      Files files,
      Child currentFile,
      List<Child> playlist,
      int currentIndex,
      PlayMode playMode,
      int position,
      String timestamp});

  @override
  $WorkCopyWith<$Res> get work;
  @override
  $FilesCopyWith<$Res> get files;
  @override
  $ChildCopyWith<$Res> get currentFile;
}

/// @nodoc
class __$$PlaybackStateImplCopyWithImpl<$Res>
    extends _$PlaybackStateCopyWithImpl<$Res, _$PlaybackStateImpl>
    implements _$$PlaybackStateImplCopyWith<$Res> {
  __$$PlaybackStateImplCopyWithImpl(
      _$PlaybackStateImpl _value, $Res Function(_$PlaybackStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? work = null,
    Object? files = null,
    Object? currentFile = null,
    Object? playlist = null,
    Object? currentIndex = null,
    Object? playMode = null,
    Object? position = null,
    Object? timestamp = null,
  }) {
    return _then(_$PlaybackStateImpl(
      work: null == work
          ? _value.work
          : work // ignore: cast_nullable_to_non_nullable
              as Work,
      files: null == files
          ? _value.files
          : files // ignore: cast_nullable_to_non_nullable
              as Files,
      currentFile: null == currentFile
          ? _value.currentFile
          : currentFile // ignore: cast_nullable_to_non_nullable
              as Child,
      playlist: null == playlist
          ? _value._playlist
          : playlist // ignore: cast_nullable_to_non_nullable
              as List<Child>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      playMode: null == playMode
          ? _value.playMode
          : playMode // ignore: cast_nullable_to_non_nullable
              as PlayMode,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaybackStateImpl implements _PlaybackState {
  const _$PlaybackStateImpl(
      {required this.work,
      required this.files,
      required this.currentFile,
      required final List<Child> playlist,
      required this.currentIndex,
      required this.playMode,
      required this.position,
      required this.timestamp})
      : _playlist = playlist;

  factory _$PlaybackStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaybackStateImplFromJson(json);

  @override
  final Work work;
  @override
  final Files files;
  @override
  final Child currentFile;
  final List<Child> _playlist;
  @override
  List<Child> get playlist {
    if (_playlist is EqualUnmodifiableListView) return _playlist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playlist);
  }

  @override
  final int currentIndex;
  @override
  final PlayMode playMode;
  @override
  final int position;
// 使用毫秒存储
  @override
  final String timestamp;

  @override
  String toString() {
    return 'PlaybackState(work: $work, files: $files, currentFile: $currentFile, playlist: $playlist, currentIndex: $currentIndex, playMode: $playMode, position: $position, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaybackStateImpl &&
            (identical(other.work, work) || other.work == work) &&
            (identical(other.files, files) || other.files == files) &&
            (identical(other.currentFile, currentFile) ||
                other.currentFile == currentFile) &&
            const DeepCollectionEquality().equals(other._playlist, _playlist) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.playMode, playMode) ||
                other.playMode == playMode) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      work,
      files,
      currentFile,
      const DeepCollectionEquality().hash(_playlist),
      currentIndex,
      playMode,
      position,
      timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaybackStateImplCopyWith<_$PlaybackStateImpl> get copyWith =>
      __$$PlaybackStateImplCopyWithImpl<_$PlaybackStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaybackStateImplToJson(
      this,
    );
  }
}

abstract class _PlaybackState implements PlaybackState {
  const factory _PlaybackState(
      {required final Work work,
      required final Files files,
      required final Child currentFile,
      required final List<Child> playlist,
      required final int currentIndex,
      required final PlayMode playMode,
      required final int position,
      required final String timestamp}) = _$PlaybackStateImpl;

  factory _PlaybackState.fromJson(Map<String, dynamic> json) =
      _$PlaybackStateImpl.fromJson;

  @override
  Work get work;
  @override
  Files get files;
  @override
  Child get currentFile;
  @override
  List<Child> get playlist;
  @override
  int get currentIndex;
  @override
  PlayMode get playMode;
  @override
  int get position;
  @override // 使用毫秒存储
  String get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$PlaybackStateImplCopyWith<_$PlaybackStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
