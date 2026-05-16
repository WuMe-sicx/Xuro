import 'package:flutter/widgets.dart';

/// 排版令牌。规范 §1.2。
///
/// 仅定义字号 / 字重 / 行高，**不含颜色**——颜色由使用处从
/// `Theme.of(context).colorScheme.*` 取，以维持三配色不变量
/// （同一组件三配色仅 accent 变化）。`height` 为 fontSize 的倍数。
class AppTextStyles {
  AppTextStyles._();

  /// 大标题
  static const TextStyle headlineMedium =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w500, height: 1.2);

  /// AppBar 标题 / 播放器曲名
  static const TextStyle titleLarge =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1.3);

  /// 列表标题 / 卡片标题 / 分区头
  static const TextStyle titleMedium =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5);

  /// 主要正文
  static const TextStyle bodyLarge =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  /// 次要描述 / 副标题
  static const TextStyle bodyMedium =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  /// 标签 / 按钮 / 小注
  static const TextStyle labelMedium =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3);

  /// 时间戳（如 30:45）/ 版权
  static const TextStyle caption =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w400, height: 1.2);
}
