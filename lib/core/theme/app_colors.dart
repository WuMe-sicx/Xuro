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
} 