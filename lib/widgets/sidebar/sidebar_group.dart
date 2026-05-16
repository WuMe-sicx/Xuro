import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 侧边栏分组：扁平、无玻璃卡（对齐参考图清爽列表）。
/// 分区头为静默标签（`onSurfaceVariant`），不引入 accent——三配色一致。
class SidebarGroup extends StatelessWidget {
  const SidebarGroup({super.key, required this.children, this.header});

  final List<Widget> children;
  final String? header;

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
                style: AppTextStyles.labelMedium.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}
