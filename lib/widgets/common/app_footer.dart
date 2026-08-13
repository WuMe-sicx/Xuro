import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 版权页脚（关于页）。规范 §2.2。文案由调用方传入（走 Strings）。
class AppFooter extends StatelessWidget {
  const AppFooter({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space24),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
