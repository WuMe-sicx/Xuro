import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/tag.dart';

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
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        if (work.circle?.name != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              work.circle?.name ?? '',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange[700],
              ),
            ),
          ),
        ...?work.vas?.map((va) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                va['name'] ?? '',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[700],
                ),
              ),
            )),
        if (work.hasSubtitle == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '字幕',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[700],
              ),
            ),
          ),
        ...work.tags
                ?.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getLocalizedTagName(tag),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ))
                .toList() ??
            [],
      ],
    );
  }
}
