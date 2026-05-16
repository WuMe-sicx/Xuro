import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 分区标题 + 可选「更多 >」动作。规范 §2.1 复用矩阵（首页/设置/关于）。
///
/// 文案由调用方传入（不内嵌中文），accent 取自 Theme（三配色不变量）。
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(color: cs.onSurface),
            ),
          ),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppSpacing.space8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space8,
                  vertical: AppSpacing.space4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style:
                          AppTextStyles.labelMedium.copyWith(color: cs.primary),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: cs.primary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
