/// work_card.dart：作品网格卡片——方形封面 + 标题/标签/副标题。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'components/work_cover_image.dart';
import 'components/work_info_section.dart';

class WorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const WorkCard({
    super.key,
    required this.work,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 没有 Scope（收藏/推荐/热门/搜索等尚未接入批量下载状态查询的网格）时
    // 为 null——WorkCoverImage 据此完全不显示角标，见 DownloadedWorksScope 注释。
    final downloadedIds = DownloadedWorksScope.maybeOf(context);
    final isDownloaded = downloadedIds?.contains(work.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1,
      color: isDark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            WorkCoverImage(
              imageUrl: work.mainCoverUrl ?? '',
              workId: work.id ?? 0,
              sourceId: work.sourceId ?? '',
              durationSeconds: work.duration,
              isDownloaded: isDownloaded,
            ),
            WorkInfoSection(work: work),
          ],
        ),
      ),
    );
  }
}

/// 把「本页已确认下载完成的作品 id 集合」挂到组件树上，供 [WorkCard] 判定
/// 封面左上角的在线/本地角标。
///
/// 为什么用 InheritedWidget 而不是加构造参数一路透传：[WorkCard] 唯一的
/// 调用方 `WorkRow`（连同它的上游 `WorkGrid`/`GridContent`/
/// `EnhancedWorkGridView`）是已收敛好的分页/滚动基础设施，本轮改动范围不含
/// 这几层，也没有「按作品透传额外数据」的插槽。InheritedWidget 能跨过这些
/// 中间层，由祖先（目前只有发现首页）直接喂给 [WorkCard]。
///
/// [maybeOf] 在没有这层 Scope 的树里（收藏/推荐/热门/搜索等仍是通用网格，
/// 尚未接入按作品批量查下载状态）返回 `null`——[WorkCard] 据此完全不显示
/// 角标，而不是猜一个可能出错的默认值（比如误显示「在线」掩盖已下载的事实）。
class DownloadedWorksScope extends InheritedWidget {
  const DownloadedWorksScope({
    super.key,
    required this.downloadedWorkIds,
    required super.child,
  });

  final Set<int> downloadedWorkIds;

  static Set<int>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DownloadedWorksScope>()
        ?.downloadedWorkIds;
  }

  @override
  bool updateShouldNotify(DownloadedWorksScope oldWidget) =>
      !identical(downloadedWorkIds, oldWidget.downloadedWorkIds);
}
