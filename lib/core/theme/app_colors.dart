import 'package:flutter/material.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

/// 应用颜色配置——Modernist 体系。
///
/// 四个 accent × 明暗两档 = 八套 ColorScheme。表面恒中性（亮色为纸、暗色为墨），
/// 只有 `primary` 系轮换。手写而不用 `ColorScheme.fromSeed`：fromSeed 会派生出
/// 另一个色相的 secondary / tertiary，破坏「两种颜色」的克制。
///
/// **未赋值的 scheme token 是陷阱**：`secondary` / `secondaryContainer` /
/// `tertiary` 在此刻意留空，Flutter 会填入固定基线色、**不随 variant 轮换**。
/// 曾因此让底部导航的选中胶囊在所有配色下恒为薄荷绿（`NavigationBar` 的
/// indicator 默认吃 `secondaryContainer`）。要用这几个 token 之前，必须先在
/// 这里给八套 scheme 全部补齐赋值。
class AppColors {
  const AppColors._();

  // === Modernist 中性阶 ===
  // 单一墨色在共享明度轴上的九档，明暗两套共用——这是 Modernist 里「同一档的
  // 任意角色视觉重量相等」的来源。
  static const Color neutral100 = Color(0xFFF8F4F4);
  static const Color neutral200 = Color(0xFFEAE7E7);
  static const Color neutral300 = Color(0xFFD7D3D3);
  static const Color neutral400 = Color(0xFFBAB6B6);
  static const Color neutral500 = Color(0xFF9B9797);
  static const Color neutral600 = Color(0xFF7D7979);
  static const Color neutral700 = Color(0xFF605D5D);
  static const Color neutral800 = Color(0xFF444141);
  static const Color neutral900 = Color(0xFF2D2B2B);

  /// 纸（亮色地）与墨（暗色地 / 亮色字）。暗色档由纸墨互换推导——稿子只给了亮色。
  static const Color paper = Color(0xFFF3F2F2);
  static const Color ink = Color(0xFF201E1D);

  /// 分隔线：Modernist 用 2px 实线取代阴影和圆角来表达层级。
  static const double dividerThickness = 2;

  // === 每个 variant 的 accent（亮 / 暗）===
  static const Map<ColorVariant, ({Color light, Color dark})> _accent = {
    ColorVariant.blue: (light: Color(0xFF0066FF), dark: Color(0xFF4D9AFF)),
    ColorVariant.mono: (light: ink, dark: paper),
    ColorVariant.green: (light: Color(0xFF00A86B), dark: Color(0xFF4DD7A1)),
    // 设计稿的招牌红。暗色档提亮到 accent-500，否则压在墨底上对比不足。
    ColorVariant.still: (light: Color(0xFFEC3013), dark: Color(0xFFFF563C)),
  };

  /// `onPrimary`（画在 `primary` 之上的文字/图标），逐 variant 手调至 AA。
  static const Map<ColorVariant, ({Color light, Color dark})> _onAccent = {
    ColorVariant.blue: (light: paper, dark: ink),
    ColorVariant.mono: (light: paper, dark: ink),
    ColorVariant.green: (light: paper, dark: ink),
    ColorVariant.still: (light: paper, dark: ink),
  };

  /// 柔和 accent 容器（chip 底、选中态背景等）。
  static const Map<ColorVariant, ({Color light, Color dark})> _accentContainer =
      {
    ColorVariant.blue: (light: Color(0xFFE3EEFF), dark: Color(0xFF1A2A4A)),
    ColorVariant.mono: (light: neutral200, dark: neutral900),
    ColorVariant.green: (light: Color(0xFFD8F4E7), dark: Color(0xFF1A3A2A)),
    ColorVariant.still: (light: Color(0xFFFFE0D9), dark: Color(0xFF7C1405)),
  };

  /// 构建 [variant] 的亮色 ColorScheme。
  static ColorScheme lightSchemeFor(ColorVariant variant) {
    return ColorScheme.light(
      primary: _accent[variant]!.light,
      onPrimary: _onAccent[variant]!.light,
      primaryContainer: _accentContainer[variant]!.light,
      onPrimaryContainer: ink,
      surface: paper,
      onSurface: ink,
      surfaceContainerHighest: neutral200,
      error: const Color(0xFFAE1800),
      errorContainer: const Color(0xFFFFE0D9),
      onError: paper,
      onSurfaceVariant: neutral600,
      outlineVariant: neutral400,
    );
  }

  /// 构建 [variant] 的暗色 ColorScheme（纸墨互换，中性阶共用）。
  static ColorScheme darkSchemeFor(ColorVariant variant) {
    return ColorScheme.dark(
      primary: _accent[variant]!.dark,
      onPrimary: _onAccent[variant]!.dark,
      primaryContainer: _accentContainer[variant]!.dark,
      onPrimaryContainer: paper,
      surface: ink,
      onSurface: paper,
      surfaceContainerHighest: neutral900,
      error: const Color(0xFFFF9783),
      errorContainer: const Color(0xFF7C1405),
      onError: ink,
      onSurfaceVariant: neutral500,
      outlineVariant: neutral700,
    );
  }

  // === Surface 层级令牌 ===
  // Modernist 下两层几乎同色：层级由分隔线而非填充区分，这里只留极轻的差别
  // 供确实需要「另起一块」的容器（迷你播放器、对话框）使用。
  static const Color lightSurfaceL1 = Color(0xFFEAE9E9);
  static const Color darkSurfaceL1 = neutral900;

  static const Color lightSurfaceL2 = neutral200;
  static const Color darkSurfaceL2 = neutral800;

  /// 根据当前亮度获取 Surface L1 颜色
  static Color surfaceL1(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceL1 : darkSurfaceL1;

  /// 根据当前亮度获取 Surface L2 颜色
  static Color surfaceL2(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceL2 : darkSurfaceL2;
}
