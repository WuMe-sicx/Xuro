import './models/audio_track_info.dart';
import './models/playback_context.dart';

abstract class IAudioPlayerService {
  // 基础播放控制
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> previous();
  Future<void> next();
  Future<void> dispose();

  // 上下文管理
  Future<void> playWithContext(PlaybackContext context);

  // 状态访问
  AudioTrackInfo? get currentTrack;
  PlaybackContext? get currentContext;

  // 状态持久化
  Future<void> savePlaybackState();
  Future<void> restorePlaybackState();
}
