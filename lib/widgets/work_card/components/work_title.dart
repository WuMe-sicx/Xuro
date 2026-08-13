/// work_title.dart：作品卡片标题——对齐设计稿网格标题（800 字重）。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/data/models/works/work.dart';

class WorkTitle extends StatelessWidget {
  final Work work;

  const WorkTitle({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      work.title ?? '',
      style: AppTextStyles.titleMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
