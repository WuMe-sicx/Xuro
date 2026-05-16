import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/data/models/works/work.dart';
import 'work_title.dart';
import 'work_tags_panel.dart';
import 'work_footer.dart';

class WorkInfoSection extends StatelessWidget {
  final Work work;

  const WorkInfoSection({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    // 时长已移至封面左下角标（对齐参考图），此处不再重复展示，
    // 顺带修正旧的连续两个 SizedBox 草率写法。
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkTitle(work: work),
          const SizedBox(height: AppSpacing.space8),
          WorkTagsPanel(work: work),
          const SizedBox(height: AppSpacing.space12),
          WorkFooter(work: work),
        ],
      ),
    );
  }
}
