import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';

/// 标签的视觉基调。语义（社团/声优/字幕…）由调用方决定，颜色映射收在这里——
/// 此前调用方各自塞 Colors.orange/green/blue 字面色，三配色切换对详情页
/// chip 完全无效，且暗色下 Colors.blue[700] 实测约 2.7:1，不过 WCAG AA。
enum TagTone {
  /// 强调：随 ColorVariant 轮换的 primaryContainer，用于值得突出的标签
  /// （如"支持字幕"角标）。
  primary,

  /// 常规填充：中性 surfaceContainerHighest，不随配色轮换（surface 本就
  /// 该是无色相的），用于常驻元信息（如社团名）。
  neutral,

  /// 描边：透明底 + outlineVariant 边框，与 neutral 同级但视觉更轻，用于
  /// 需要与 filled 区分开的另一类常驻元信息（如声优名）。
  outline,
}

class TagChip extends StatelessWidget {
  final String text;
  final TagTone tone;
  final VoidCallback? onTap;

  /// 列表卡片一屏要塞下十几个标签，需要比详情页更紧的字号与内边距。
  final bool dense;

  const TagChip({
    super.key,
    required this.text,
    this.tone = TagTone.neutral,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color background, Color foreground, Color? borderColor) =
        switch (tone) {
      TagTone.primary => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          null,
        ),
      TagTone.neutral => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          null,
        ),
      TagTone.outline => (
          Colors.transparent,
          scheme.onSurfaceVariant,
          scheme.outlineVariant,
        ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Container(
        padding: dense
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.smAll,
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontSize: dense ? 10 : 13,
              ),
        ),
      ),
    );
  }
}
