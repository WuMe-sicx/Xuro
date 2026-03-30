import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/recommend_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';
import 'package:asmrapp/widgets/filter/filter_with_keyword.dart';

class RecommendContent extends StatefulWidget {
  const RecommendContent({super.key});

  @override
  State<RecommendContent> createState() => _RecommendContentState();
}

class _RecommendContentState extends State<RecommendContent> with AutomaticKeepAliveClientMixin {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  void _onScroll() {
    if (_scrollController.position.pixels != _scrollController.position.minScrollExtent) {
      final viewModel = context.read<RecommendViewModel>();
      if (viewModel.filterPanelExpanded) {
        viewModel.closeFilterPanel();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 初始加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendViewModel>().loadRecommendations();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<RecommendViewModel>(
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
              onRefresh: () => viewModel.loadRecommendations(refresh: true),
              onRetry: () => viewModel.loadRecommendations(refresh: true),
              layoutStrategy: _layoutStrategy,
              scrollController: _scrollController,
            ),
            // 筛选面板
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                offset: Offset(0, viewModel.filterPanelExpanded ? 0 : -1),
                child: FilterWithKeyword(
                  hasSubtitle: viewModel.hasSubtitle,
                  onSubtitleChanged: (_) => viewModel.toggleSubtitleFilter(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 