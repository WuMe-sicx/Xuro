import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/audio_track_info.dart';
import '../models/playback_context.dart';
import '../utils/audio_error_handler.dart';
import '../utils/track_info_creator.dart';
import 'package:xuro/data/models/playback/playback_state.dart';
import '../events/playback_event.dart';
import '../events/playback_event_hub.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/core/audio/storage/playback_state_repository.dart';

class PlaybackStateManager {
  final AudioPlayer _player;
  final PlaybackEventHub _eventHub;
  final PlaybackStateRepository _stateRepository;

  AudioTrackInfo? _currentTrack;
  PlaybackContext? _currentContext;

  final List<StreamSubscription> _subscriptions = [];
  Timer? _saveDebounceTimer;
  static const _saveInterval = Duration(seconds: 20);

  // 持久化串行化 + tombstone：所有 save/clear 进同一条 Future 链，保证
  // stop() 的 remove 一定排在任何在途 save 之后；_persistSuppressed 让
  // stop 后、下一个非空播放上下文设置前的任何 save 变为 no-op，避免把
  // 已主动停止的内容写回 prefs。
  //
  // **不变量：`_persistSuppressed == true` 恒蕴含 `_currentContext == null`。**
  // 唯一置位处是 `clearSavedState()`，而它在全库唯一的调用点
  // （`audio_player_service.stop()`）紧跟在 `clearState()` 之后、中间无 await。
  // `updateTrackAndContext` 的同曲目守卫依赖这条：守卫只在 context 非空时才
  // 可能跳过 `updateContext`，而 context 非空即意味着抑制早已解除。若哪天把
  // `clearSavedState()` 从 stop() 里单拎出来用，这条不变量断裂，播放态会静默
  // 停止持久化——改这里之前先确认守卫仍然成立。
  Future<void> _persistChain = Future<void>.value();
  bool _persistSuppressed = false;

  PlaybackStateManager({
    required AudioPlayer player,
    required PlaybackEventHub eventHub,
    required PlaybackStateRepository stateRepository,
  })  : _player = player,
        _eventHub = eventHub,
        _stateRepository = stateRepository;

  // 初始化状态监听
  void initStateListeners() {
    // 监听播放器索引变化
    _subscriptions.add(
      _player.currentIndexStream.listen((index) {
        if (index != null && _currentContext != null) {
          if (index >= 0 && index < _currentContext!.playlist.length) {
            final newFile = _currentContext!.playlist[index];
            updateTrackAndContext(newFile, _currentContext!.work);
          }
        }
      }),
    );

    // 直接监听 AudioPlayer 的原始流
    _subscriptions.add(
      _player.playerStateStream.listen((state) async {
        final position = _player.position;
        final duration = _player.duration;

        // 转换并发送到 EventHub
        _eventHub.emit(PlaybackStateEvent(state, position, duration));

        if (state.processingState == ProcessingState.completed) {
          _onPlaybackCompleted();
        }
        _debounceSave();
      }),
    );

    _subscriptions.add(
      _player.positionStream.listen((position) {
        _eventHub
            .emit(PlaybackProgressEvent(position, _player.bufferedPosition));
      }),
    );

    // 监听播放器错误
    _subscriptions.add(
      _player.playbackEventStream.listen(
        (_) {},
        onError: (error, stackTrace) {
          _eventHub.emit(PlaybackErrorEvent('playerStream', error, stackTrace));
        },
      ),
    );

    _setupEventListeners();
  }

  void _debounceSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(_saveInterval, () {
      saveState();
    });
  }

  // 状态更新方法
  void updateContext(PlaybackContext? context) {
    _currentContext = context;
    if (context != null) {
      // 有新播放内容，解除 stop 设置的持久化抑制。
      _persistSuppressed = false;
      _eventHub.emit(PlaybackContextEvent(context));
    }
  }

  void updateTrackInfo(AudioTrackInfo track) {
    _currentTrack = track;
    if (_currentContext != null) {
      _eventHub.emit(TrackChangeEvent(
          track, _currentContext!.currentFile, _currentContext!.work));
    }
  }

  void updateTrackAndContext(Child file, Work work) {
    final context = _currentContext;
    // 曲目没变就不重发 PlaybackContextEvent：`setPlaybackContext` 会先
    // updateContext 建立上下文、再走到这里刷 trackInfo，两次发射同一份上下文
    // 会让 PlayerViewModel 把整套字幕解析（两次 DB 查询 + 磁盘 + 可能一次网络）
    // 跑第二遍。contextChange 是唯一没有 distinct 的 hub 流，挡不住重复。
    if (context != null && context.currentFile.title != file.title) {
      updateContext(context.copyWithFile(file));
    }

    updateTrackInfo(TrackInfoCreator.createFromFile(file, work));
  }

  void _onPlaybackCompleted() {
    if (_currentContext == null) return;
    saveState(); // Immediate save on completion
    _eventHub.emit(PlaybackCompletedEvent(_currentContext!));
  }

  // 状态访问
  AudioTrackInfo? get currentTrack => _currentTrack;
  PlaybackContext? get currentContext => _currentContext;

  void clearState() {
    _currentTrack = null;
    _currentContext = null;
    _eventHub.emit(PlaybackClearedEvent());
  }

  // 状态持久化（全部经 _persistChain 串行化，消除 save/clear 写入竞态）
  Future<void> saveState() {
    if (_persistSuppressed) return _persistChain;
    final context = _currentContext;
    if (context == null) return _persistChain;

    // 调用时刻就快照上下文与播放位置：链体执行时 _currentContext 可能已被
    // stop() 置空，快照保证写入的是请求那一刻的真实状态。
    final positionMs = _player.position.inMilliseconds;
    _persistChain = _persistChain.then((_) async {
      // 入链后、执行前若已 stop，丢弃本次写入。
      if (_persistSuppressed) return;
      try {
        final state = PlaybackState(
          work: context.work,
          files: context.files,
          currentFile: context.currentFile,
          playMode: context.playMode,
          position: positionMs,
          timestamp: DateTime.now().toIso8601String(),
        );
        await _stateRepository.saveState(state);
      } catch (e, stack) {
        AudioErrorHandler.handleError(
          AudioErrorType.state,
          '保存播放状态',
          e,
          stack,
        );
      }
    });
    return _persistChain;
  }

  Future<void> clearSavedState() {
    // 同步置位：此后调用的 saveState() 立即变 no-op；remove 排到链尾，
    // 必然晚于任何已入链的 save 完成，保证 remove 是最后一次写入。
    _persistSuppressed = true;
    _persistChain = _persistChain.then((_) async {
      try {
        await _stateRepository.clearState();
      } catch (e, stack) {
        AudioErrorHandler.handleError(
          AudioErrorType.state,
          '清除播放状态',
          e,
          stack,
        );
      }
    });
    return _persistChain;
  }

  Future<PlaybackState?> loadState() async {
    try {
      return await _stateRepository.loadState();
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.state,
        '加载播放状态',
        e,
        stack,
      );
      return null;
    }
  }

  void _setupEventListeners() {
    // 处理初始状态请求
    _subscriptions.add(
      _eventHub.requestInitialState.listen((_) {
        _eventHub.emit(InitialStateEvent(_currentTrack, _currentContext));
      }),
    );
  }

  void dispose() {
    // 取消 timer 前尽力把最后状态落盘（best-effort，dispose 不可 await）。
    if (_currentContext != null) {
      saveState();
    }
    _saveDebounceTimer?.cancel();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
