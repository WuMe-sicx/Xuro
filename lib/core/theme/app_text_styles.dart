import 'package:flutter/widgets.dart';

/// 排版令牌——Modernist 体系。
///
/// 标题一律 800 字重 + 负字距（-0.015em），小号标签用 800 + 正字距（0.1em）
/// 拉开，正文保持 400。这套对比（极重的标题 vs 克制的正文）是 Modernist 的
/// 主要识别特征之一，比颜色更承担观感。
///
/// 仅定义字号 / 字重 / 字距 / 行高，**不含颜色**——颜色由使用处从
/// `Theme.of(context).colorScheme.*` 取，以维持「同一组件多配色仅 accent
/// 变化」的不变量。`height` 为 fontSize 的倍数。
///
/// 字距用 `letterSpacing`（逻辑像素）而非 em：Flutter 无 em 单位，取值为
/// 设计稿 em 值 × 字号后取整。
class AppTextStyles {
  AppTextStyles._();

  /// 大标题（首页问候语 / 播放器曲名）
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.12,
    letterSpacing: -0.42,
  );

  /// AppBar 标题 / 分区大标题
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.12,
    letterSpacing: -0.33,
  );

  /// 列表标题 / 卡片标题
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  /// 主要正文
  static const TextStyle bodyLarge =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.55);

  /// 次要描述 / 副标题
  static const TextStyle bodyMedium =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);

  /// 分区小标题 / 强调标签（稿中的 accent kicker，使用处自行决定是否大写——
  /// 令牌不做 `toUpperCase`，中日文没有大小写）
  static const TextStyle labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    height: 1.3,
    letterSpacing: 1.1,
  );

  /// 时间戳（如 30:45）/ 版权 / 角标
  static const TextStyle caption =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.2);
}
