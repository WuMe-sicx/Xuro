import 'package:flutter/material.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'app_colors.dart';
import 'app_radius.dart';

/// 应用主题配置
class AppTheme {
  const AppTheme._();

  // 亮色主题
  static ThemeData light(ColorVariant variant) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: AppColors.lightSchemeFor(variant),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      );

  // 暗色主题
  static ThemeData dark(ColorVariant variant) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: AppColors.darkSchemeFor(variant),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      );
}
