/// work_footer.dart：作品卡片副标题——对齐设计稿「类型 · 播放次数」的视觉节奏，
/// 用接口真实字段替换（无播放次数字段，见任务范围说明）：发售日期 · 销量。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/models/works/work.dart';

class WorkFooter extends StatelessWidget {
  final Work work;

  const WorkFooter({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (work.release != null && work.release!.isNotEmpty) work.release!,
      Strings.salesCountLabel(work.dlCount ?? 0),
    ];
    return Text(
      parts.join(' · '),
      style: AppTextStyles.bodyMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
