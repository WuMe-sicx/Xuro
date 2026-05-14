import 'package:flutter/material.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

/// 应用颜色配置
///
/// Three accent variants × two brightness modes = six ColorScheme presets.
/// Surfaces stay neutral (white in light, near-black in dark) across all
/// variants — only the `primary` token (and a couple of derived tokens)
/// rotates. We hand-roll instead of using `ColorScheme.fromSeed` to keep the
/// "two color" simplification disciplined: fromSeed introduces secondary /
/// tertiary in a different hue, which violates the design intent.
class AppColors {
  const AppColors._();

  // === Per-variant accent palette ===
  // Each entry pairs the light-mode primary with the dark-mode primary.
  static const Map<ColorVariant, ({Color light, Color dark})> _accent = {
    ColorVariant.blue: (light: Color(0xFF0066FF), dark: Color(0xFF4D9AFF)),
    ColorVariant.mono: (light: Color(0xFF000000), dark: Color(0xFFFFFFFF)),
    ColorVariant.green: (light: Color(0xFF00A86B), dark: Color(0xFF4DD7A1)),
  };

  /// `onPrimary` (text/icon color drawn on top of `primary`). Hand-tuned per
  /// variant for AA contrast.
  static const Map<ColorVariant, ({Color light, Color dark})> _onAccent = {
    ColorVariant.blue: (light: Colors.white, dark: Colors.black),
    ColorVariant.mono: (light: Colors.white, dark: Colors.black),
    ColorVariant.green: (light: Colors.white, dark: Colors.black),
  };

  /// Soft accent container tone (used for chips, selected backgrounds, etc.).
  static const Map<ColorVariant, ({Color light, Color dark})> _accentContainer =
      {
    ColorVariant.blue: (light: Color(0xFFE3EEFF), dark: Color(0xFF1A2A4A)),
    ColorVariant.mono: (light: Color(0xFFEEEEEE), dark: Color(0xFF2A2A2A)),
    ColorVariant.green: (light: Color(0xFFD8F4E7), dark: Color(0xFF1A3A2A)),
  };

  /// Build the light-mode ColorScheme for [variant].
  static ColorScheme lightSchemeFor(ColorVariant variant) {
    final accent = _accent[variant]!.light;
    final onAccent = _onAccent[variant]!.light;
    final container = _accentContainer[variant]!.light;
    return ColorScheme.light(
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: container,
      onPrimaryContainer: Colors.black,

      surface: Colors.white,
      onSurface: Colors.black87,
      surfaceContainerHighest: const Color(0xFFE6E6E6),

      error: const Color(0xFFB3261E),
      errorContainer: const Color(0xFFF9DEDC),
      onError: Colors.white,

      onSurfaceVariant: const Color(0xFF49454F),
      outlineVariant: const Color(0xFFCAC4D0),
    );
  }

  /// Build the dark-mode ColorScheme for [variant].
  static ColorScheme darkSchemeFor(ColorVariant variant) {
    final accent = _accent[variant]!.dark;
    final onAccent = _onAccent[variant]!.dark;
    final container = _accentContainer[variant]!.dark;
    return ColorScheme.dark(
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: container,
      onPrimaryContainer: Colors.white,

      surface: const Color(0xFF1C1B1F),
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF2B2B2B),

      error: const Color(0xFFF2B8B5),
      errorContainer: const Color(0xFF8C1D18),
      onError: const Color(0xFF601410),

      onSurfaceVariant: const Color(0xFFCAC4D0),
      outlineVariant: const Color(0xFF49454F),
    );
  }

  // === Surface层级令牌 (Design Tokens) ===
  // Neutralized in the color-palette-simplification task: previous values
  // (#F7F2FA / #F3EDF7 / #25232A / #2B2930) had a subtle purple tint that
  // leaked into mono/green light mode. Replaced with hue-free neutrals so
  // surfaces stay neutral across all three accent variants.
  //
  // Surface L1: 容器层、次级卡片（如迷你播放器背景）
  static const Color lightSurfaceL1 = Color(0xFFF7F7F7);
  static const Color darkSurfaceL1 = Color(0xFF1F1F1F);

  // Surface L2: 侧边栏、搜索框、对话框背景
  static const Color lightSurfaceL2 = Color(0xFFF2F2F2);
  static const Color darkSurfaceL2 = Color(0xFF252525);

  /// 根据当前亮度获取 Surface L1 颜色
  static Color surfaceL1(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceL1 : darkSurfaceL1;

  /// 根据当前亮度获取 Surface L2 颜色
  static Color surfaceL2(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceL2 : darkSurfaceL2;
}
