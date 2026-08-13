import 'package:flutter/material.dart';

/// 品牌字：字标 + accent 句点。
///
/// Modernist 的品牌处理是纯排版（设计系统 `.nav-brand`：800 字重、负字距），
/// 句点是唯一着色的字符——这也是「accent 只给一处」这条规则在品牌上的体现。
/// 字标本身取 `onSurface`，句点取 `primary`，因此多配色下只有句点变色。
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.text = 'Xuro',
    this.fontSize = 22,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 字距按设计系统的 -0.015em 换算：Flutter 的 letterSpacing 是逻辑像素。
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.015 * fontSize,
      height: 1.12,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text, style: style.copyWith(color: cs.onSurface)),
          TextSpan(text: '.', style: style.copyWith(color: cs.primary)),
        ],
      ),
    );
  }
}
