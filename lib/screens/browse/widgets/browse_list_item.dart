/// browse_list_item.dart：分类三屏（标签/社团/声优）共用的编号列表行 + 顶栏。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/common/constants/strings.dart';

/// 分类屏（标签/社团/声优）共用的编号列表行——取代旧版网格卡片。
/// Modernist 用编号 + 分隔线分层，零圆角、无卡片、无阴影。
///
/// 三屏内容不同（标签名/社团名/声优名）、行的视觉规格完全相同，
/// 抽成一个组件避免三份写法漂移，同源于设计稿 04 分类屏。
class BrowseListItem extends StatelessWidget {
  // 56 不在 AppSpacing 网格上，是设计稿给定的行最小高度；
  // 沿用 SidebarTile._kRowMinHeight 的处理先例（具名常量 + 注明来源）。
  static const double _kRowMinHeight = 56;

  // 18 / 14 同样是设计稿明确给定、不在 4px 网格上的行内边距与元素间距，
  // 处理方式同上。
  static const double _kRowVerticalPadding = 18;
  static const double _kIndexGap = 14;

  /// 行间分隔线厚度。刻意比 [AppColors.dividerThickness]（页面级 2px）细一半——
  /// 设计稿区分「行间 1px / 页面级 2px」两级分隔线，令牌层本轮锁定不扩展新档，
  /// 故在此就地声明，供三屏的 `ListView.separated` 复用。
  static const double rowDividerThickness = 1;

  const BrowseListItem({
    super.key,
    required this.index,
    required this.name,
    this.count,
    this.onTap,
  });

  /// 1-based 显示序号，渲染为两位数「01」「02」……
  final int index;

  final String name;

  /// 该分类下的作品数。接口未返回（模型字段为 null）时不编数字，只显示箭头——
  /// 避免把「没有数据」误显示成「0 条」。
  final int? count;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _kRowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space20,
              vertical: _kRowVerticalPadding,
            ),
            child: Row(
              children: [
                Text(
                  index.toString().padLeft(2, '0'),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(width: _kIndexGap),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                if (count != null) ...[
                  Text(
                    Strings.browseItemCountLabel(count!),
                    style: AppTextStyles.caption.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                ],
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 分类三屏共用顶栏：24px/w800 标题 + 底部 2px 分隔线（设计稿 04 规格）。
/// 三屏标题文案不同（各自读 `Strings.browseAllXxx`），视觉规格相同。
PreferredSizeWidget browseAppBar(BuildContext context, String title) {
  final cs = Theme.of(context).colorScheme;
  return AppBar(
    title: Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(color: cs.onSurface),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(AppColors.dividerThickness),
      child: Container(
        height: AppColors.dividerThickness,
        color: cs.outlineVariant,
      ),
    ),
  );
}
