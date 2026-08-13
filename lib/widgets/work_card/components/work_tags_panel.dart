import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/tag.dart';
import 'package:xuro/widgets/common/tag_chip.dart';

class WorkTagsPanel extends StatelessWidget {
  final Work work;

  const WorkTagsPanel({
    super.key,
    required this.work,
  });

  String _getLocalizedTagName(Tag tag) {
    final zhName = tag.i18n?.zhCn?.name;
    if (zhName != null) return zhName;
    final jaName = tag.i18n?.jaJp?.name;
    if (jaName != null) return jaName;
    return tag.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // 基调与详情页 WorkInfoHeader 保持一致：字幕是唯一值得强调的角标走 accent，
    // 声优用描边与填充的社团/普通标签区分开。
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        if (work.circle?.name != null)
          TagChip(
            text: work.circle!.name!,
            tone: TagTone.neutral,
            dense: true,
          ),
        ...?work.vas?.map((va) => TagChip(
              text: va['name'] ?? '',
              tone: TagTone.outline,
              dense: true,
            )),
        if (work.hasSubtitle == true)
          const TagChip(
            text: Strings.subtitleChip,
            tone: TagTone.primary,
            dense: true,
          ),
        ...?work.tags?.map((tag) => TagChip(
              text: _getLocalizedTagName(tag),
              tone: TagTone.neutral,
              dense: true,
            )),
      ],
    );
  }
}
