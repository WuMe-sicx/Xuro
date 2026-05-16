import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 实心 accent 胶囊：侧边栏选中项 / 「关注」 / 主行动按钮。规范 §2.2。
///
/// 底色 = `colorScheme.primary`，文字/图标 = `onPrimary`——三配色仅此变化。
class AccentPill extends StatelessWidget {
  const AccentPill({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  /// 紧凑尺寸（如「关注」小药丸）。
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hPad = dense ? AppSpacing.space12 : AppSpacing.space16;
    final vPad = dense ? AppSpacing.space4 : AppSpacing.space8;
    return Material(
      color: cs.primary,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: dense ? 14 : 18, color: cs.onPrimary),
                const SizedBox(width: AppSpacing.space8),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: cs.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
