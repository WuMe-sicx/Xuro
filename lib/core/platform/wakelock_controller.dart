import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:asmrapp/utils/logger.dart';

class WakeLockController extends ChangeNotifier {
  static const _tag = 'WakeLock';
  static const _wakeLockKey = 'wakelock_enabled';
  final SharedPreferences _prefs;
  bool _enabled = false;

  WakeLockController(this._prefs) {
    _loadState();
  }

  bool get enabled => _enabled;

  Future<void> _loadState() async {
    try {
      _enabled = _prefs.getBool(_wakeLockKey) ?? false;
      if (_enabled) {
        await WakelockPlus.enable();
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('[$_tag] 加载状态失败', e);
    }
  }

  Future<void> toggle() async {
    try {
      _enabled = !_enabled;
      if (_enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
      await _prefs.setBool(_wakeLockKey, _enabled);
      notifyListeners();
    } catch (e) {
      AppLogger.error('[$_tag] 切换状态失败', e);
      // 恢复状态
      _enabled = !_enabled;
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      AppLogger.error('[$_tag] 释放失败', e);
    }
    super.dispose();
  }
} 