/// 间距令牌（4px 基准网格）。规范 §1.3。
///
/// 命名按像素值，便于机械替换与规范对照；业务代码禁止再写裸数字间距。
class AppSpacing {
  AppSpacing._();

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  /// 布局边距：移动端 16，平板/桌面 24（规范 §1.3 / §5）。
  static const double pageMobile = space16;
  static const double pageTabletDesktop = space24;
}
