import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/presentation/models/load_failure.dart';
import 'package:xuro/widgets/work_grid/components/grid_content.dart';
import 'package:xuro/widgets/work_grid/components/grid_error.dart';
import 'package:xuro/widgets/work_grid/components/grid_empty.dart';
import 'package:xuro/widgets/work_grid/components/grid_loading.dart';

class EnhancedWorkGridView extends StatelessWidget {
  final List<Work> works;
  final bool isLoading;
  final LoadFailure? failure;
  final VoidCallback? onRetry;
  final VoidCallback? onLogin;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(int page)? onPageChanged;
  final int? currentPage;
  final int? totalPages;
  final String? emptyMessage;
  final WorkLayoutStrategy layoutStrategy;
  final ScrollController? scrollController;

  const EnhancedWorkGridView({
    super.key,
    required this.works,
    required this.isLoading,
    this.failure,
    this.onRetry,
    this.onLogin,
    this.onRefresh,
    this.onPageChanged,
    this.currentPage,
    this.totalPages,
    this.emptyMessage,
    this.layoutStrategy = const WorkLayoutStrategy(),
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && works.isEmpty) {
      return GridLoading(layoutStrategy: layoutStrategy);
    }

    // 陈旧内容优先于错误页：VM 的 catch 块不清空已加载的 works（见各 ViewModel），
    // 所以「已有数据 + 翻页失败」时应保留原内容，只有从未取到过数据才整屏切错误态。
    if (failure != null && works.isEmpty) {
      return GridError(
        failure: failure!,
        onRetry: onRetry,
        onLogin: onLogin,
      );
    }

    if (works.isEmpty) {
      return GridEmpty(message: emptyMessage);
    }

    Widget content = GridContent(
      works: works,
      isLoading: isLoading,
      layoutStrategy: layoutStrategy,
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      scrollController: scrollController,
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }
}
