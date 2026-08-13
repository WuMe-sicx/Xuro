import 'package:flutter/material.dart';

/// 设备类型
enum DeviceType {
  mobile,
  tablet,
  desktop;

  /// 根据屏幕宽度获取设备类型
  static DeviceType fromWidth(double width) {
    if (width >= WorkLayoutConfig.desktopBreakpoint) return DeviceType.desktop;
    if (width >= WorkLayoutConfig.tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }
}

/// 作品布局配置
class WorkLayoutConfig {
  // 断点
  static const double desktopBreakpoint = 1200;
  static const double tabletBreakpoint = 800;

  // 列数
  static const int desktopColumns = 4;
  static const int tabletColumns = 3;
  static const int mobileColumns = 2;

  // 间距
  static const double desktopSpacing = 16;
  static const double tabletSpacing = 12;
  static const double mobileSpacing = 8;

  // 内边距
  static const EdgeInsets desktopPadding = EdgeInsets.all(16);
  static const EdgeInsets tabletPadding = EdgeInsets.all(12);
  static const EdgeInsets mobilePadding = EdgeInsets.all(8);

  const WorkLayoutConfig._();

  /// 根据设备类型获取列数
  static int getColumnsCount(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.mobile:
        return mobileColumns;
    }
  }

  /// 根据设备类型获取间距
  static double getSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopSpacing;
      case DeviceType.tablet:
        return tabletSpacing;
      case DeviceType.mobile:
        return mobileSpacing;
    }
  }

  /// Material `Card` 未在 `CardThemeData` 里设 margin，用的是默认
  /// `EdgeInsets.all(4)`，左右各占 4——卡片内的封面比单元格窄 8。
  static const double _cardMarginHorizontal = 8;

  /// 网格封面在给定屏宽下的实际解码宽度（物理像素）。
  ///
  /// 详情页据此算出与网格**完全相同**的 `memCacheWidth`：`CachedNetworkImage`
  /// 在 `memCacheWidth` 非空时会把 provider 包进 `ResizeImage`，而 `ResizeImage`
  /// 把宽度算进相等性，所以宽度差一个像素就是另一个缓存条目、要重新解码。
  /// 详情页拿它作低清 placeholder 才能同步命中网格已解码的那份，不出现空窗。
  ///
  /// 之所以能由屏宽单独算出：`WorkRow` 恒为两列（硬编码 `works[0]`/`works[1]`，
  /// 不读 `getColumnsCount`），链路是
  /// `SliverPadding(getPadding) → Row[Expanded, SizedBox(getSpacing), Expanded]
  /// → Card(默认 margin) → WorkCoverImage`。
  ///
  /// **这个公式复刻的是别处的布局，不是它自己的真相来源**——布局一改就会悄悄
  /// 脱钩、placeholder 命不中缓存而修复静默失效。
  /// `test/widgets/work_card/cover_cache_key_test.dart` 挂真实网格断言两者相等，
  /// 改布局时以那个测试为准。
  static int gridCoverCacheWidth(double screenWidth, double devicePixelRatio) {
    final deviceType = DeviceType.fromWidth(screenWidth);
    final available = screenWidth - getPadding(deviceType).horizontal;
    final cellWidth = (available - getSpacing(deviceType)) / 2;
    final coverWidth = cellWidth - _cardMarginHorizontal;
    final physical = (coverWidth * devicePixelRatio).round();
    return physical < 1 ? 1 : physical;
  }

  /// 根据设备类型获取内边距
  static EdgeInsets getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopPadding;
      case DeviceType.tablet:
        return tabletPadding;
      case DeviceType.mobile:
        return mobilePadding;
    }
  }
}
