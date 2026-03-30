import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/works/tag.dart';
import 'package:asmrapp/data/models/works/work_info.dart' as model;
import 'package:asmrapp/widgets/common/tag_chip.dart';
import 'package:asmrapp/widgets/detail/work_info_header.dart';
import 'package:asmrapp/utils/logger.dart';

class WorkInfo extends StatelessWidget {
  final Work work;
  final model.WorkInfo? workInfo;

  const WorkInfo({
    super.key,
    required this.work,
    this.workInfo,
  });

  String _getLocalizedTagName(Tag tag) {
    final zhName = tag.i18n?.zhCn?.name;
    if (zhName != null) return zhName;
    final jaName = tag.i18n?.jaJp?.name;
    if (jaName != null) return jaName;
    return tag.name ?? '';
  }

  void _onTagTap(BuildContext context, Tag tag) {
    final keyword = tag.name ?? '';
    if (keyword.isEmpty) return;

    AppLogger.debug('点击标签: $keyword');
    Navigator.pushNamed(
      context,
      '/search',
      arguments: keyword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkInfoHeader(work: work, workInfo: workInfo),
          const SizedBox(height: 8),
          if (work.tags != null && work.tags!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: work.tags!
                  .map((tag) => TagChip(
                        text: _getLocalizedTagName(tag),
                        onTap: () => _onTagTap(context, tag),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
