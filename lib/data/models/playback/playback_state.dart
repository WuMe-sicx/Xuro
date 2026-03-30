import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/files/files.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/core/audio/models/play_mode.dart';

part 'playback_state.freezed.dart';
part 'playback_state.g.dart';

@freezed
class PlaybackState with _$PlaybackState {
  const factory PlaybackState({
    required Work work,
    required Files files,
    required Child currentFile,
    required List<Child> playlist,
    required int currentIndex,
    required PlayMode playMode,
    required int position,  // 使用毫秒存储
    required String timestamp,  // ISO8601 格式
  }) = _PlaybackState;

  factory PlaybackState.fromJson(Map<String, dynamic> json) => 
      _$PlaybackStateFromJson(json);
} 