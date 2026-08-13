import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/core/subtitle/i_subtitle_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import './i_audio_player_service.dart';
import './models/audio_track_info.dart';
import './models/playback_context.dart';
import './notification/audio_notification_service.dart';
import './utils/audio_error_handler.dart';
import './state/playback_state_manager.dart';
import './controllers/playback_controller.dart';
import './events/playback_event_hub.dart';
import 'package:xuro/core/audio/storage/playback_state_repository.dart';

class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  late final ConcatenatingAudioSource _playlist;
  late final PlaybackStateManager _stateManager;
  late final PlaybackController _playbackController;
  final PlaybackEventHub _eventHub;
  final PlaybackStateRepository _stateRepository;

  // 记忆化 Future 而非一次性 Completer：Completer 只能 complete 一次，
  // 首次初始化失败后整个 session 会永久卡在同一个 rejected future 上——
  // 对单例是致命的（音频功能不可恢复）。改成 database_service.dart 同款的
  // 「缓存 Future，失败清空」模式：下一次 `await ready` 会自动重新触发
  // `_init()`。
  Future<void>? _readyFuture;

  /// Await this before calling any public method to ensure init is complete.
  /// 失败后允许重试：见 [_init] 内失败分支对 [_readyFuture] 的清空。
  Future<void> get ready => _readyFuture ??= _init();

  // audio_service 包用 `assert(_cacheManager == null)` 守护"一个 isolate
  // 只能成功调用一次 AudioService.init()"——赋值发生在该断言之后、任何
  // await 之前，因此哪怕这次调用本身失败，也已经不可逆地占用了这个
  // 一次性名额。重试 _init() 时绝不能再调一次，否则 debug 下直接 assert
  // 炸，release 下污染包内部全局状态。代价：一旦尝试过，通知栏在本 session
  // 内永久降级为不可用，但播放功能本身不受影响（不依赖通知栏）。
  bool _notificationInitAttempted = false;

  // AudioPlayer/通知服务/播放列表/状态管理器/播放控制器都是 late final
  // 字段，只能赋值一次。构造它们本身是纯 Dart 对象操作、实际不会失败；
  // 真正会抛的是后面的 audio_session 配置和通知栏初始化（平台通道）。但
  // 一旦第一次成功构造过，重试 _init() 时必须跳过这一段，否则重新赋值
  // late final 字段会抛 LateInitializationError。
  bool _coreBuilt = false;

  AudioPlayerService._internal({
    required PlaybackEventHub eventHub,
    required PlaybackStateRepository stateRepository,
  })  : _eventHub = eventHub,
        _stateRepository = stateRepository {
    // 保持与今天一致的"构造即启动"时序：DI 解析到这个单例就立刻开始
    // 初始化，而不是等到第一次 `await ready`。
    _readyFuture = _init();
  }

  static AudioPlayerService? _instance;

  factory AudioPlayerService({
    required PlaybackEventHub eventHub,
    required PlaybackStateRepository stateRepository,
  }) {
    _instance ??= AudioPlayerService._internal(
      eventHub: eventHub,
      stateRepository: stateRepository,
    );
    return _instance!;
  }

  Future<void> _init() async {
    try {
      if (!_coreBuilt) {
        _player = AudioPlayer();
        _notificationService = AudioNotificationService(
          _player,
          _eventHub,
          GetIt.I<ISubtitleService>(),
        );
        _playlist = ConcatenatingAudioSource(children: []);

        _stateManager = PlaybackStateManager(
          player: _player,
          stateRepository: _stateRepository,
          eventHub: _eventHub,
        );

        _playbackController = PlaybackController(
          player: _player,
          stateManager: _stateManager,
          playlist: _playlist,
          eventHub: _eventHub,
        );
        _coreBuilt = true;
      }

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // 见 _notificationInitAttempted 字段注释：只允许尝试一次。
      if (!_notificationInitAttempted) {
        _notificationInitAttempted = true;
        await _notificationService.init();
      }

      _stateManager.initStateListeners();

      // 播放态恢复不再堵在 ready 闸门之前：改到首帧渲染后异步触发，用户
      // 按下任意作品的播放不必等这一轮磁盘 IO/DB 查询排完。此时 _init()
      // 即将成功返回（ready 即将 resolve），restorePlaybackState() 内部
      // 会自己 `await ready`，不构成自等待死锁。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restorePlaybackState().catchError((e, stack) {
          AppLogger.error('恢复播放状态失败（首帧后异步触发）', e, stack);
        });
      });
    } catch (e, stack) {
      // 清空记忆化 Future：下一次 `await ready` 会重新触发 _init() 而不是
      // 永远卡在这次失败的 Future 上（见 _readyFuture 字段注释）。
      _readyFuture = null;
      AudioErrorHandler.handleError(
        AudioErrorType.init,
        '音频播放器初始化',
        e,
        stack,
      );
      AudioErrorHandler.throwError(
        AudioErrorType.init,
        '音频播放器初始化',
        e,
      );
    }
  }

  // 基础播放控制
  @override
  Future<void> pause() async {
    await ready;
    await _playbackController.pause();
    // 暂停是用户离开/切后台的强信号，立即 flush 一次，避免依赖 20s 节流。
    await _stateManager.saveState();
  }

  @override
  Future<void> resume() async {
    await ready;
    // 通知权限的首次弹窗从启动期 init() 挪到这里（真正开始播放前）：
    // playWithContext() 末尾会调用 resume()，两个入口因此共享同一次
    // latch 调用，不需要各自单独 await 一次。
    await _notificationService.ensureNotificationPermission();
    await _playbackController.play();
  }

  @override
  Future<void> stop() async {
    await ready;
    await _playbackController.stop();
    _stateManager.clearState();
    // 停止 = 用户主动结束，清掉持久化，避免下次启动误恢复已停止内容。
    await _stateManager.clearSavedState();
  }

  @override
  Future<void> seek(Duration position) async {
    await ready;
    await _playbackController.seek(position);
  }

  @override
  Future<void> previous() async {
    await ready;
    await _playbackController.previous();
  }

  @override
  Future<void> next() async {
    await ready;
    await _playbackController.next();
  }

  // 上下文管理
  @override
  Future<void> playWithContext(PlaybackContext context) async {
    await ready;
    await _playbackController.setPlaybackContext(context);
    // 添加自动播放
    await resume();
  }

  // 状态访问
  @override
  AudioTrackInfo? get currentTrack => _stateManager.currentTrack;

  @override
  PlaybackContext? get currentContext => _stateManager.currentContext;

  // 状态持久化
  @override
  Future<void> savePlaybackState() => _stateManager.saveState();

  @override
  Future<void> restorePlaybackState() async {
    await ready;
    try {
      AppLogger.debug('开始恢复播放状态');
      final state = await _stateManager.loadState();

      if (state == null) {
        AppLogger.debug('没有可恢复的播放状态');
        return;
      }

      AppLogger.debug('已加载保存的状态: workId=${state.work.id}');

      final context = PlaybackContext(
        work: state.work,
        files: state.files,
        currentFile: state.currentFile,
        playMode: state.playMode,
      );

      AppLogger.debug(
          '播放列表信息: 长度=${context.playlist.length}, 索引=${context.currentIndex}');

      if (context.playlist.isEmpty) {
        AppLogger.debug('恢复的播放列表为空，跳过恢复');
        return;
      }

      try {
        await _playbackController.setPlaybackContext(
          context,
          initialPosition: Duration(milliseconds: state.position),
        );
        AppLogger.debug('播放状态恢复成功');
      } catch (e) {
        AppLogger.error('设置播放上下文失败，跳过状态恢复', e);
      }
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.init,
        '恢复播放状态',
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _stateManager.dispose();
    await _notificationService.dispose();
    await _player.dispose();
  }
}
