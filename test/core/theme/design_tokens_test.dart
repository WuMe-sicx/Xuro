import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 纯逻辑：锁定设计令牌与规范 §1.2–1.4 的契约值。
/// 任何对令牌数值的改动都会撞红这里——防止 Phase C 起组件令牌化后规范悄悄漂移。
void main() {
  group('AppSpacing — 4px 基准网格 (规范 §1.3)', () {
    test('十档间距值与规范一致', () {
      expect(AppSpacing.space4, 4);
      expect(AppSpacing.space8, 8);
      expect(AppSpacing.space12, 12);
      expect(AppSpacing.space16, 16);
      expect(AppSpacing.space20, 20);
      expect(AppSpacing.space24, 24);
      expect(AppSpacing.space32, 32);
      expect(AppSpacing.space40, 40);
      expect(AppSpacing.space48, 48);
      expect(AppSpacing.space64, 64);
    });

    test('全部为 4 的整数倍', () {
      for (final v in [
        AppSpacing.space4,
        AppSpacing.space8,
        AppSpacing.space12,
        AppSpacing.space16,
        AppSpacing.space20,
        AppSpacing.space24,
        AppSpacing.space32,
        AppSpacing.space40,
        AppSpacing.space48,
        AppSpacing.space64,
      ]) {
        expect(v % 4, 0, reason: '$v 不是 4 的倍数，违反基准网格');
      }
    });

    test('页面边距：移动端 16 / 平板桌面 24', () {
      expect(AppSpacing.pageMobile, 16);
      expect(AppSpacing.pageTabletDesktop, 24);
    });
  });

  group('AppRadius — 圆角令牌 (规范 §1.4)', () {
    test('标量值与规范一致', () {
      expect(AppRadius.sm, 8);
      expect(AppRadius.md, 12);
      expect(AppRadius.lg, 16);
      expect(AppRadius.full, 999);
    });

    test('*All 为对应半径的 BorderRadius（const 等价）', () {
      expect(AppRadius.smAll, BorderRadius.circular(8));
      expect(AppRadius.mdAll, BorderRadius.circular(12));
      expect(AppRadius.lgAll, BorderRadius.circular(16));
      expect(AppRadius.fullAll, BorderRadius.circular(999));
    });

    test('app_theme 卡片圆角接入点：md 必须仍是 12（视觉零变化保证）', () {
      // app_theme.dart 用 AppRadius.mdAll 替换原硬编码 Radius.circular(12)。
      // 若有人改了 md，卡片观感会变——此断言充当回归闸。
      expect(AppRadius.md, 12);
      expect(AppRadius.mdAll, const BorderRadius.all(Radius.circular(12)));
    });
  });

  group('AppTextStyles — 排版令牌 (规范 §1.2)', () {
    test('字号 / 字重 / 行高 与规范表一致', () {
      void check(TextStyle s, double size, FontWeight weight, double height) {
        expect(s.fontSize, size);
        expect(s.fontWeight, weight);
        expect(s.height, height);
      }

      check(AppTextStyles.headlineMedium, 28, FontWeight.w500, 1.2);
      check(AppTextStyles.titleLarge, 22, FontWeight.w500, 1.3);
      check(AppTextStyles.titleMedium, 16, FontWeight.w500, 1.5);
      check(AppTextStyles.bodyLarge, 16, FontWeight.w400, 1.5);
      check(AppTextStyles.bodyMedium, 14, FontWeight.w400, 1.5);
      check(AppTextStyles.labelMedium, 12, FontWeight.w500, 1.3);
      check(AppTextStyles.caption, 10, FontWeight.w400, 1.2);
    });

    test('令牌不绑定颜色（维持三配色不变量）', () {
      for (final s in [
        AppTextStyles.headlineMedium,
        AppTextStyles.titleLarge,
        AppTextStyles.titleMedium,
        AppTextStyles.bodyLarge,
        AppTextStyles.bodyMedium,
        AppTextStyles.labelMedium,
        AppTextStyles.caption,
      ]) {
        expect(s.color, isNull,
            reason: '排版令牌不应写死颜色，颜色须由使用处从 Theme 取');
      }
    });
  });
}
