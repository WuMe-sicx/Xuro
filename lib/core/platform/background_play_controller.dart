import 'package:flutter/widgets.dart';

import 'package:xuro/core/audio/i_audio_player_service.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/utils/logger.dart';

/// 后台播放开关的执行端：监听应用生命周期，当用户**关闭**后台播放
/// 且应用切到后台时自动暂停播放。
///
/// 默认 [AppSettingsService.backgroundPlayEnabled] = `true`，即保持现有
/// 「始终后台播放」行为——只有用户显式关闭后此控制器才介入。
/// 刻意**只暂停、不自动恢复**（前台返回不抢占用户意图，行为可预期）。
/// 不重构 `audio_service`/前台服务，只调既有公共 `pause()`。
class BackgroundPlayController with WidgetsBindingObserver {
  static const _tag = 'BackgroundPlay';

  final AppSettingsService _settings;
  final IAudioPlayerService _audioService;

  bool _initialized = false;

  BackgroundPlayController({
    required AppSettingsService settings,
    required IAudioPlayerService audioService,
  })  : _settings = settings,
        _audioService = audioService;

  /// 注册为生命周期观察者（幂等，镜像 CacheLifecycleManager）。
  void initialize() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    if (_settings.backgroundPlayEnabled) return;
    _audioService.pause().catchError(
      (Object e) => AppLogger.error('[$_tag] 切后台暂停失败', e),
    );
  }
}
