import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 图标 + 标签分类芯片（首页「热门分类」）。规范 §2.1。
///
/// 软底用 `primaryContainer`、图标用 `primary`——三配色随 accent 变化；
/// 文字保持中性 `onSurface`。与详情页用的 [TagChip]（纯文本）是不同语义，
/// 不复用。
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: AppRadius.smAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space12,
            vertical: AppSpacing.space8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: AppSpacing.space8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: cs.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
