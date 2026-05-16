import 'package:flutter/widgets.dart';

/// 圆角令牌。规范 §1.4。
///
/// `*All` 为 const [BorderRadius]，可直接用于 const 主题/装饰，零分配。
/// 圆形封面（`CircularCover`）用 `BoxShape.circle`，不在此列。
class AppRadius {
  AppRadius._();

  static const double sm = 8; // Chip / Tooltip
  static const double md = 12; // 作品卡片 / 列表项
  static const double lg = 16; // 播放器抽屉 / 底部面板 / 对话框
  static const double full = 999; // 胶囊按钮 / 搜索框 / 头像 / AccentPill

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
