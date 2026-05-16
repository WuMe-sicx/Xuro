import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_spacing.dart';

/// 品牌标志锁定：波形图标 + 文字。规范 §2.1（侧边栏顶 / 关于页中部）。
///
/// 图标用 accent（三配色随之变化），文字用 onSurface。无外部资源依赖。
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.text = 'ASMR',
    this.iconSize = 28,
    this.fontSize = 22,
  });

  final String text;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.graphic_eq, size: iconSize, color: cs.primary),
        const SizedBox(width: AppSpacing.space8),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
