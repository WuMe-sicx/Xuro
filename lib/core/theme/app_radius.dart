import 'package:flutter/widgets.dart';

/// 圆角令牌。
///
/// Modernist 设计语言下四档**全部为 0**：层级由 2px 分隔线和留白表达，
/// 不由圆角和阴影表达。四个名字保留是为了让调用点继续声明「这是什么层级的
/// 元素」——将来若要整体回到圆角体系，改这一个文件即可，无需回访调用点。
///
/// `*All` 为 const [BorderRadius]，可直接用于 const 主题/装饰，零分配。
class AppRadius {
  AppRadius._();

  static const double sm = 0; // Chip / Tooltip
  static const double md = 0; // 作品卡片 / 列表项
  static const double lg = 0; // 播放器抽屉 / 底部面板 / 对话框
  static const double full = 0; // 搜索框 / 徽标（Modernist 无胶囊形）

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
