import 'package:asmrapp/core/theme/app_animations.dart';
import 'package:asmrapp/widgets/filter/filter_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/home_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with AutomaticKeepAliveClientMixin {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 添加滚动监听
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 当滚动开始时收起筛选面板
    if (_scrollController.position.pixels !=
        _scrollController.position.minScrollExtent) {
      final viewModel = context.read<HomeViewModel>();
      if (viewModel.filterPanelExpanded) {
        viewModel.closeFilterPanel(); // 需要在 ViewModel 中添加这个方法
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            // 作品列表
            EnhancedWorkGridView(
              works: viewModel.works,
              isLoading: viewModel.isLoading,
              error: viewModel.error,
              currentPage: viewModel.currentPage,
              totalPages: viewModel.totalPages,
              onPageChanged: (page) => viewModel.loadPage(page),
              onRefresh: () => viewModel.refresh(),
              onRetry: () => viewModel.refresh(),
              layoutStrategy: _layoutStrategy,
              scrollController: _scrollController,
            ),
            // 筛选面板
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                duration: AppAnimations.short,
                curve: AppAnimations.standard,
                offset: Offset(0, viewModel.filterPanelExpanded ? 0 : -1),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: FilterPanel(
                    hasSubtitle: viewModel.hasSubtitle,
                    onSubtitleChanged: viewModel.updateSubtitle,
                    orderField: viewModel.filterState.orderField,
                    isDescending: viewModel.filterState.isDescending,
                    onOrderFieldChanged: viewModel.updateOrderField,
                    onSortDirectionChanged: viewModel.updateSortDirection,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
