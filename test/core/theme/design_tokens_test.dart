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

  group('AppRadius — 圆角令牌（Modernist：全档为 0）', () {
    test('四档全部为 0', () {
      expect(AppRadius.sm, 0);
      expect(AppRadius.md, 0);
      expect(AppRadius.lg, 0);
      expect(AppRadius.full, 0);
    });

    test('*All 均为 BorderRadius.zero（const 等价）', () {
      expect(AppRadius.smAll, BorderRadius.zero);
      expect(AppRadius.mdAll, BorderRadius.zero);
      expect(AppRadius.lgAll, BorderRadius.zero);
      expect(AppRadius.fullAll, BorderRadius.zero);
    });

    test('零圆角是设计语言的硬约束，不是巧合', () {
      // Modernist 用 2px 分隔线与留白表达层级，不用圆角和阴影。
      // 任何一档变回非 0 都会让该层级的元素与其余界面脱节——此断言充当回归闸。
      // 若将来整体切回圆角体系，改 AppRadius 一个文件并同步改这里。
      for (final r in [
        AppRadius.sm,
        AppRadius.md,
        AppRadius.lg,
        AppRadius.full,
      ]) {
        expect(r, 0, reason: 'Modernist 不允许圆角；层级请用分隔线表达');
      }
    });
  });

  group('AppTextStyles — 排版令牌（Modernist）', () {
    test('字号 / 字重 / 行高 与设计系统一致', () {
      void check(TextStyle s, double size, FontWeight weight, double height) {
        expect(s.fontSize, size);
        expect(s.fontWeight, weight);
        expect(s.height, height);
      }

      check(AppTextStyles.headlineMedium, 28, FontWeight.w800, 1.12);
      check(AppTextStyles.titleLarge, 22, FontWeight.w800, 1.12);
      check(AppTextStyles.titleMedium, 16, FontWeight.w800, 1.2);
      check(AppTextStyles.bodyLarge, 15, FontWeight.w400, 1.55);
      check(AppTextStyles.bodyMedium, 13, FontWeight.w400, 1.5);
      check(AppTextStyles.labelMedium, 11, FontWeight.w800, 1.3);
      check(AppTextStyles.caption, 10, FontWeight.w600, 1.2);
    });

    test('标题走 800 字重 + 负字距（Modernist 的主要识别特征）', () {
      // 极重标题 vs 克制正文的对比，比颜色更承担这套语言的观感。
      for (final s in [
        AppTextStyles.headlineMedium,
        AppTextStyles.titleLarge,
      ]) {
        expect(s.fontWeight, FontWeight.w800);
        expect(s.letterSpacing, isNotNull);
        expect(s.letterSpacing!, lessThan(0));
      }
    });

    test('令牌不绑定颜色（维持多配色不变量）', () {
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
