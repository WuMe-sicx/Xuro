import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 侧边栏菜单项：Modernist 干净行 + 中性线性图标；标题走 `titleMedium`
/// （16/w800），与 `BrowseListItem` 已落地的行标题同规格，避免另起一套。
/// `selected` 时整行为实心 accent 色块（`primary`/`onPrimary`，零圆角），
/// 未选中透明 + 涟漪；层级分隔改由 [SidebarGroup] 的行间 1px 分隔线承担，
/// 不再靠圆角/阴影/白色硬编码区分。
class SidebarTile extends StatelessWidget {
  // spec §2.3：单行列表项 56dp。与 SettingsTile._kRowMinHeight 一致，
  // 使侧边栏列表节奏与设置统一（56 不在 AppSpacing 网格，沿用具名常量先例）。
  static const double _kRowMinHeight = 56;

  const SidebarTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  /// 自定义尾部组件；为 null 且未选中时显示淡箭头。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onPrimary : cs.onSurface;
    final iconColor = selected ? cs.onPrimary : cs.onSurfaceVariant;

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: selected ? cs.primary : Colors.transparent,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _kRowMinHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
                vertical: AppSpacing.space12,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: iconColor),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(color: fg),
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (!selected)
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
