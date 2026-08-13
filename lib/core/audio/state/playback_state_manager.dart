import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/audio_track_info.dart';
import '../models/playback_context.dart';
import '../utils/audio_error_handler.dart';
import '../utils/track_info_creator.dart';
import 'package:xuro/data/models/playback/playback_state.dart';
import '../storage/i_playback_state_repository.dart';
import '../events/playback_event.dart';
import '../events/playback_event_hub.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/data/models/works/work.dart';

class PlaybackStateManager {
  final AudioPlayer _player;
  final PlaybackEventHub _eventHub;
  final IPlaybackStateRepository _stateRepository;

  AudioTrackInfo? _currentTrack;
  PlaybackContext? _currentContext;

  final List<StreamSubscription> _subscriptions = [];
  Timer? _saveDebounceTimer;
  static const _saveInterval = Duration(seconds: 20);

  // 持久化串行化 + tombstone：所有 save/clear 进同一条 Future 链，保证
  // stop() 的 remove 一定排在任何在途 save 之后；_persistSuppressed 让
  // stop 后、下一个非空播放上下文设置前的任何 save 变为 no-op，避免把
  // 已主动停止的内容写回 prefs。
  Future<void> _persistChain = Future<void>.value();
  bool _persistSuppressed = false;

  PlaybackStateManager({
    required AudioPlayer player,
    required PlaybackEventHub eventHub,
    required IPlaybackStateRepository stateRepository,
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
    if (_currentContext != null) {
      final newContext = _currentContext!.copyWithFile(file);
      updateContext(newContext);
    }

    final trackInfo = TrackInfoCreator.createFromFile(file, work);
    updateTrackInfo(trackInfo);
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
