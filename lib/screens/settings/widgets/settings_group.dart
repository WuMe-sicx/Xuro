import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

class SettingsGroup extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  // 分割线起点 = 左内边距(16) + leading 槽(40) + 文字间距(12)，对齐标题文字。
  static const double _dividerIndent = 68;

  const SettingsGroup({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.space16,
                bottom: AppSpacing.space8,
              ),
              child: Text(
                header!,
                style: AppTextStyles.labelMedium
                    .copyWith(color: colorScheme.primary),
              ),
            ),
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AppRadius.mdAll,
              ),
              child: Column(
                children: _buildChildrenWithSeparators(context),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.space16,
                top: AppSpacing.space8,
              ),
              child: Text(
                footer!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithSeparators(BuildContext context) {
    if (children.isEmpty) return [];
    final list = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      list.add(children[i]);
      if (i < children.length - 1) {
        list.add(Divider(
          height: 0.5,
          thickness: 0.5,
          indent: _dividerIndent,
          color: Theme.of(context).colorScheme.outlineVariant,
        ));
      }
    }
    return list;
  }
}
