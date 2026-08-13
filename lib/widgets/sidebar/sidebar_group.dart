import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 侧边栏分组：Modernist 扁平列表，层级由分隔线而非卡片/圆角表达。
/// 分区头改走 accent（`colorScheme.primary`），与 `SettingsGroup` 已落地的
/// 分区头一致——两处分区头统一使用同一套语义，不再各写一套中性/强调色。
/// 组内行之间插入 1px 细分隔线，与 [SidebarMenu] 组间的 2px 粗分隔线
/// 构成两级层级（呼应 `BrowseListItem`/`SettingsGroup` 已有的行/组两级）。
class SidebarGroup extends StatelessWidget {
  const SidebarGroup({super.key, required this.children, this.header});

  final List<Widget> children;
  final String? header;

  // 组内行分隔线厚度：比 `SidebarMenu` 组间分隔线（2px）细一半，与
  // `BrowseListItem.rowDividerThickness` 同一取舍——令牌层本轮锁定不新增
  // 分隔线档位，故就地声明。
  static const double _rowDividerThickness = 1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space12,
                AppSpacing.space8,
                0,
                AppSpacing.space4,
              ),
              child: Text(
                header!,
                style: AppTextStyles.labelMedium.copyWith(color: cs.primary),
              ),
            ),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: _rowDividerThickness,
                thickness: _rowDividerThickness,
                color: cs.outlineVariant,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
