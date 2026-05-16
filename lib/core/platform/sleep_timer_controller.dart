import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:xuro/core/audio/i_audio_player_service.dart';
import 'package:xuro/utils/logger.dart';

/// 睡眠定时器：选定时长后到点自动 **暂停** 播放（用 `pause()` 而非
/// `stop()`——`stop()` 会清空持久化播放态，睡眠场景需可恢复）。
///
/// 刻意 **不持久化**：这是会话级控制，重启后静默重新计时是坏 UX，
/// 也避开 `playback_state` 持久化不变量。
class SleepTimerController extends ChangeNotifier {
  static const _tag = 'SleepTimer';

  /// 可选时长档（分钟）。`null` 即对话框里的「关闭」。
  static const List<int> presetMinutes = [15, 30, 45, 60, 90];

  final IAudioPlayerService _audioService;

  Timer? _timer;
  int? _minutes;

  SleepTimerController(this._audioService);

  /// 当前选定时长（分钟）；`null` = 未设置/已关闭。
  int? get minutes => _minutes;

  bool get isActive => _timer != null;

  /// 设置定时时长。`null` 或 `<= 0` = 取消。重复设置会先取消旧 Timer。
  void setMinutes(int? minutes) {
    _timer?.cancel();
    _timer = null;

    if (minutes == null || minutes <= 0) {
      if (_minutes != null) {
        _minutes = null;
        notifyListeners();
      }
      return;
    }

    _minutes = minutes;
    _timer = Timer(Duration(minutes: minutes), _onExpire);
    notifyListeners();
  }

  void cancel() => setMinutes(null);

  void _onExpire() {
    _timer = null;
    _minutes = null;
    notifyListeners();
    _audioService.pause().catchError(
      (Object e) => AppLogger.error('[$_tag] 到点暂停失败', e),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
