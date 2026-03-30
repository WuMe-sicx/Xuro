import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/work_info.dart';
import 'package:xuro/widgets/common/tag_chip.dart';
import 'package:xuro/widgets/detail/work_stats_info.dart';
import 'package:xuro/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkInfoHeader extends StatelessWidget {
  final Work work;
  final WorkInfo? workInfo;

  const WorkInfoHeader({
    super.key,
    required this.work,
    this.workInfo,
  });

  void _onTagTap(BuildContext context, String keyword) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          work.title ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        WorkStatsInfo(work: work),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (work.circle?.name != null)
              TagChip(
                text: work.circle?.name ?? '',
                backgroundColor: Colors.orange.withOpacity(0.2),
                textColor: Colors.orange[700],
                onTap: () => _onTagTap(context, work.circle?.name ?? ''),
              ),
            ..._buildVaChips(context),
            if (work.hasSubtitle == true)
              TagChip(
                text: '字幕',
                backgroundColor: Colors.blue.withOpacity(0.2),
                textColor: Colors.blue[700],
              ),
          ],
        ),
        if (workInfo != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              if (workInfo!.price != null)
                Text(
                  '${workInfo!.price} JPY',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (workInfo!.sourceUrl != null)
                GestureDetector(
                  onTap: () => _launchUrl(workInfo!.sourceUrl!),
                  child: Text(
                    'DLsite',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _buildVaChips(BuildContext context) {
    if (workInfo?.vas != null && workInfo!.vas!.isNotEmpty) {
      return workInfo!.vas!.map(
        (va) => TagChip(
          text: va.name ?? '',
          backgroundColor: Colors.green.withOpacity(0.2),
          textColor: Colors.green[700],
          onTap: () => _onTagTap(context, va.name ?? ''),
        ),
      ).toList();
    }
    return work.vas?.map(
      (va) => TagChip(
        text: va['name'] ?? '',
        backgroundColor: Colors.green.withOpacity(0.2),
        textColor: Colors.green[700],
        onTap: () => _onTagTap(context, va['name'] ?? ''),
      ),
    ).toList() ?? [];
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
} 