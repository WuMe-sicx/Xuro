import 'package:asmrapp/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid.dart';
import 'package:asmrapp/widgets/pagination_controls.dart';
import 'package:asmrapp/widgets/work_grid/models/grid_config.dart';
import 'package:asmrapp/screens/detail_screen.dart';

class GridContent extends StatelessWidget {
  final List<Work> works;
  final bool isLoading;
  final WorkLayoutStrategy layoutStrategy;
  final int? currentPage;
  final int? totalPages;
  final Future<void> Function(int page)? onPageChanged;
  final ScrollController? scrollController;
  final GridConfig? config;

  const GridContent({
    super.key,
    required this.works,
    required this.isLoading,
    required this.layoutStrategy,
    this.currentPage,
    this.totalPages,
    this.onPageChanged,
    this.scrollController,
    this.config,
  });

  void _scrollToTop() {
    if (scrollController?.hasClients ?? false) {
      scrollController!.animateTo(
        0,
        duration: config?.scrollDuration ?? AppAnimations.medium,
        curve: config?.scrollCurve ?? AppAnimations.enter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: config?.physics,
      slivers: [
        SliverPadding(
          padding: config?.padding ?? layoutStrategy.getPadding(context),
          sliver: WorkGrid(
            works: works,
            layoutStrategy: layoutStrategy,
            onWorkTap: (work) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(work: work),
                ),
              );
            },
          ),
        ),
        if (config?.enablePagination != false && 
            currentPage != null && 
            totalPages != null)
          SliverToBoxAdapter(
            child: PaginationControls(
              currentPage: currentPage!,
              totalPages: totalPages!,
              isLoading: isLoading,
              onPageChanged: (page) async {
                await onPageChanged?.call(page);
                if (!isLoading) {
                  _scrollToTop();
                }
              },
            ),
          ),
      ],
    );
  }
} 