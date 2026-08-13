import 'package:xuro/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/widgets/work_grid.dart';
import 'package:xuro/widgets/pagination_controls.dart';
import 'package:xuro/screens/detail_screen.dart';

class GridContent extends StatelessWidget {
  final List<Work> works;
  final bool isLoading;
  final WorkLayoutStrategy layoutStrategy;
  final int? currentPage;
  final int? totalPages;
  final Future<void> Function(int page)? onPageChanged;
  final ScrollController? scrollController;

  const GridContent({
    super.key,
    required this.works,
    required this.isLoading,
    required this.layoutStrategy,
    this.currentPage,
    this.totalPages,
    this.onPageChanged,
    this.scrollController,
  });

  void _scrollToTop() {
    if (scrollController?.hasClients ?? false) {
      scrollController!.animateTo(
        0,
        duration: AppAnimations.medium,
        curve: AppAnimations.enter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: layoutStrategy.getPadding(context),
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
        if (currentPage != null && totalPages != null)
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
