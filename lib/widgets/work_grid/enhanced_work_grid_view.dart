import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/widgets/work_grid/components/grid_content.dart';
import 'package:xuro/widgets/work_grid/components/grid_error.dart';
import 'package:xuro/widgets/work_grid/components/grid_empty.dart';
import 'package:xuro/widgets/work_grid/components/grid_loading.dart';
import 'package:xuro/widgets/work_grid/models/grid_config.dart';

class EnhancedWorkGridView extends StatelessWidget {
  final List<Work> works;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(int page)? onPageChanged;
  final int? currentPage;
  final int? totalPages;
  final String? emptyMessage;
  final Widget? customEmptyWidget;
  final WorkLayoutStrategy layoutStrategy;
  final ScrollController? scrollController;
  final GridConfig? config;

  const EnhancedWorkGridView({
    super.key,
    required this.works,
    required this.isLoading,
    this.error,
    this.onRetry,
    this.onRefresh,
    this.onPageChanged,
    this.currentPage,
    this.totalPages,
    this.emptyMessage,
    this.customEmptyWidget,
    this.layoutStrategy = const WorkLayoutStrategy(),
    this.scrollController,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && works.isEmpty) {
      return const GridLoading();
    }

    if (error != null) {
      return GridError(
        error: error!,
        onRetry: onRetry,
      );
    }

    if (works.isEmpty) {
      return GridEmpty(
        message: emptyMessage,
        customWidget: customEmptyWidget,
      );
    }

    Widget content = GridContent(
      works: works,
      isLoading: isLoading,
      layoutStrategy: layoutStrategy,
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      scrollController: scrollController,
      config: config,
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