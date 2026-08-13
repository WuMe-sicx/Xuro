import 'package:flutter/material.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// 应用主题配置——Modernist 体系。
class AppTheme {
  const AppTheme._();

  /// Archivo 只有拉丁字形，中日文由 Flutter 自动回退到系统字体。
  /// 因此它实际作用于品牌字、数字、时长、RJ 号——设计稿里的中文同样是回退渲染。
  static const String _fontFamily = 'Archivo';

  // 亮色主题
  static ThemeData light(ColorVariant variant) {
    final scheme = AppColors.lightSchemeFor(variant);
    return _base(scheme, Brightness.light);
  }

  // 暗色主题
  static ThemeData dark(ColorVariant variant) {
    final scheme = AppColors.darkSchemeFor(variant);
    return _base(scheme, Brightness.dark);
  }

  /// 明暗两档只有 scheme 与 surface 层级取值不同，其余结构完全一致——
  /// 抽出来避免两份定义漂移（此前 dialogTheme/chipTheme 就是各写一遍的）。
  static ThemeData _base(ColorScheme scheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      // Modernist 用 2px 实线表达层级，取代阴影与圆角。
      dividerTheme: DividerThemeData(
        thickness: AppColors.dividerThickness,
        space: AppColors.dividerThickness,
        color: scheme.outlineVariant,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceL2(brightness),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceL2(brightness),
        selectedColor: scheme.primary,
        checkmarkColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      navigationBarTheme: _navigationBarTheme(scheme),
      // M3 的按钮默认形状是 StadiumBorder（全圆角），**不读 AppRadius**——
      // 不显式覆盖的话，零圆角这条设计语言在全 App 的按钮上会整体失效。
      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle()),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle().copyWith(
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: _buttonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle().copyWith(
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),
      // 输入框同样默认带圆角边框，且 Modernist 的输入框是「实底 + 1px 描边」。
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceL2(brightness),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        backgroundColor: scheme.onSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: scheme.surface,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
    );
  }

  /// Modernist 按钮：零圆角、800 字重、矮而宽的内边距（见设计系统 `.btn`）。
  static ButtonStyle _buttonStyle() => const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      );

  /// `NavigationBar` 的选中指示器与图标默认取 `secondaryContainer` /
  /// `onSecondaryContainer`，而 `AppColors` 刻意不赋值 secondary 系
  /// （见 `app_colors.dart`）——未赋值的 token 会落到 Flutter 基线色，
  /// 结果是底部导航的选中态在所有配色下恒为同一颜色、不随 accent 轮换。
  /// 因此显式钉到已赋值的 primaryContainer 系上。
  static NavigationBarThemeData _navigationBarTheme(ColorScheme scheme) {
    return NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          )),
    );
  }
}
