import 'package:xuro/utils/logger.dart';
import 'package:just_audio/just_audio.dart';
import '../models/playback_context.dart';
import '../state/playback_state_manager.dart';
import '../utils/playlist_builder.dart';
import '../utils/audio_error_handler.dart';
import '../events/playback_event_hub.dart';
import '../events/playback_event.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/data/models/works/work.dart';

class PlaybackController {
  final AudioPlayer _player;
  final PlaybackStateManager _stateManager;
  final ConcatenatingAudioSource _playlist;
  final PlaybackEventHub _eventHub;

  PlaybackController({
    required AudioPlayer player,
    required PlaybackStateManager stateManager,
    required ConcatenatingAudioSource playlist,
    required PlaybackEventHub eventHub,
  })  : _player = player,
        _stateManager = stateManager,
        _playlist = playlist,
        _eventHub = eventHub;

  // 基础播放控制
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);

  // 播放列表控制
  Future<void> next() async {
    try {
      AppLogger.debug('尝试切换下一曲');
      if (_stateManager.currentContext == null) {
        AppLogger.debug('当前上下文为空，无法切换下一曲');
        return;
      }

      if (_player.hasNext) {
        AppLogger.debug('执行切换到下一曲');
        await _player.seekToNext();
      } else {
        AppLogger.debug('没有下一曲可切换');
      }
    } catch (e, stack) {
      AppLogger.error('切换下一曲失败', e, stack);
      _eventHub.emit(PlaybackErrorEvent('next', e, stack));
      AudioErrorHandler.handleError(
        AudioErrorType.playback,
        '切换下一曲',
        e,
        stack,
      );
    }
  }

  Future<void> previous() async {
    try {
      AppLogger.debug('尝试切换上一曲');
      if (_stateManager.currentContext == null) {
        AppLogger.debug('当前上下文为空，无法切换上一曲');
        return;
      }

      if (_player.hasPrevious) {
        AppLogger.debug('执行切换到上一曲');
        await _player.seekToPrevious();
      } else {
        AppLogger.debug('没有上一曲可切换');
      }
    } catch (e, stack) {
      AppLogger.error('切换上一曲失败', e, stack);
      _eventHub.emit(PlaybackErrorEvent('previous', e, stack));
      AudioErrorHandler.handleError(
        AudioErrorType.playback,
        '切换上一曲',
        e,
        stack,
      );
    }
  }

  // 播放上下文设置
  Future<void> setPlaybackContext(PlaybackContext originalContext,
      {Duration? initialPosition}) async {
    try {
      AppLogger.debug(
          '准备设置播放上下文: workId=${originalContext.work.id}, file=${originalContext.currentFile.title}');
      AppLogger.debug(
          '播放列表状态: 长度=${originalContext.playlist.length}, 当前索引=${originalContext.currentIndex}');

      // 验证上下文
      try {
        originalContext.validate();
      } catch (e) {
        AppLogger.error('播放上下文验证失败', e);
        rethrow;
      }

      // 1. 先停止当前播放
      AppLogger.debug('停止当前播放');
      await _player.stop();

      // 2. 换源。队列被替换到新上下文写入之间有一个窗口：期间 _currentContext
      // 描述的还是上一个作品的队列，而 currentIndexStream 已经在报新队列的
      // 下标，监听器会拿新下标去索引旧列表 → 发出错作品的事件，且
      // TrackInfoCreator 的 mediaDownloadUrl! 会在流监听器里抛、逃逸到 zone。
      // 静默置空让监听器在窗口内忽略索引事件（不发 PlaybackClearedEvent——
      // 这不是「停止播放」，UI 不该闪空）。
      _stateManager.updateContext(null);

      AppLogger.debug('设置播放源: 初始位置=${initialPosition?.inMilliseconds}ms');
      final List<Child> loadedFiles;
      final int queueIndex;
      try {
        (loadedFiles, queueIndex) = await PlaylistBuilder.setPlaylistSource(
          player: _player,
          playlist: _playlist,
          files: originalContext.playlist,
          initialIndex: originalContext.currentIndex,
          initialPosition: initialPosition ?? Duration.zero,
          workId: originalContext.work.id.toString(),
        );
      } catch (e, stack) {
        AppLogger.error('设置播放源失败', e, stack);
        rethrow;
      }

      // 3. 上下文一律按队列的真实内容与下标重建。
      // 此前只在「长度不等」时才重建，且把 currentFile 猜成 loadedFiles.first
      // ——目标轨构造失败时播放器实际停在 remapIndex 给的槽位（原下标之后第一个
      // 存活的轨），不是 0，于是锁屏标题/字幕/持久化的 currentFile 全错，
      // 且因 currentIndexStream 带 distinct、那次 emit 又落在 context 为空的
      // 窗口里不会重放，要错到下一次真正切曲才自愈。
      final context = PlaybackContext.fromQueue(
        work: originalContext.work,
        files: originalContext.files,
        playlist: loadedFiles,
        currentIndex: queueIndex,
        playMode: originalContext.playMode,
      );
      _stateManager.updateContext(context);

      // Set loop mode based on play mode
      await _player.setLoopMode(context.playMode.toLoopMode());

      // 4. 更新轨道信息
      AppLogger.debug('更新轨道信息');
      _updateTrackAndContext(context.currentFile, context.work);

      AppLogger.debug('播放上下文设置完成');
    } catch (e, stack) {
      // 换源已经把队列换掉了（updatePlaylist 在 setAudioSource 之前），而上下文
      // 停在换源窗口的 null 上。此时若只是返回，_currentTrack 仍是上一首 →
      // mini player 展示一首「next/previous 与持久化全部失效」的曲子，而
      // resume() → _player.play() 不受上下文门控，一按播放就会放出新队列的
      // 音频、顶着旧作品的元数据。归零才是诚实的状态。
      _stateManager.clearState();
      AppLogger.error('设置播放上下文失败', e, stack);
      _eventHub.emit(PlaybackErrorEvent('setPlaybackContext', e, stack));
      AudioErrorHandler.handleError(
        AudioErrorType.context,
        '设置播放上下文',
        e,
        stack,
      );
      rethrow;
    }
  }

  // 私有辅助方法
  void _updateTrackAndContext(Child file, Work work) {
    AppLogger.debug('更新轨道和上下文: file=${file.title}');
    _stateManager.updateTrackAndContext(file, work);
  }
}
