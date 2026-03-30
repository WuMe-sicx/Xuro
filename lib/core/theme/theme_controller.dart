import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeController(this._prefs) {
    // 从持久化存储加载主题模式
    final savedThemeMode = _prefs.getString(_themeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;

  // 切换主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    // 保存到持久化存储
    await _prefs.setString(_themeKey, mode.toString());
  }

  // 切换到下一个主题模式
  Future<void> toggleThemeMode() async {
    const modes = ThemeMode.values;
    final currentIndex = modes.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    await setThemeMode(modes[nextIndex]);
  }
} 