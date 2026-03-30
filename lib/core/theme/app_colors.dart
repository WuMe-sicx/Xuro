import 'package:flutter/material.dart';

/// 应用颜色配置
class AppColors {
  // 禁止实例化
  const AppColors._();

  // 亮色主题颜色
  static const ColorScheme lightColorScheme = ColorScheme.light(
    // 基础色调
    primary: Color(0xFF6750A4),
    onPrimary: Colors.white,
    
    // 表面颜色
    surface: Colors.white,
    onSurface: Colors.black87,
    surfaceContainerHighest: Color(0xFFE6E6E6),
    
    // 错误状态颜色
    error: Color(0xFFB3261E),
    errorContainer: Color(0xFFF9DEDC),
    onError: Colors.white,
  );

  // 暗色主题颜色
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    // 基础色调
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    
    // 表面颜色
    surface: Color(0xFF1C1B1F),
    onSurface: Colors.white,
    surfaceContainerHighest: Color(0xFF2B2B2B),
    
    // 错误状态颜色
    error: Color(0xFFF2B8B5),
    errorContainer: Color(0xFF8C1D18),
    onError: Color(0xFF601410),
  );

  // === Surface层级令牌 (Design Tokens) ===
  // Surface L1: 容器层、次级卡片（如迷你播放器背景）
  static const Color lightSurfaceL1 = Color(0xFFF7F2FA);
  static const Color darkSurfaceL1 = Color(0xFF25232A);

  // Surface L2: 侧边栏、搜索框、对话框背景
  static const Color lightSurfaceL2 = Color(0xFFF3EDF7);
  static const Color darkSurfaceL2 = Color(0xFF2B2930);

  /// 根据当前亮度获取 Surface L1 颜色
  static Color surfaceL1(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceL1 : darkSurfaceL1;

  /// 根据当前亮度获取 Surface L2 颜色
  static Color surfaceL2(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceL2 : darkSurfaceL2;
} 