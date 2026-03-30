import 'package:xuro/core/theme/app_animations.dart';
import 'package:xuro/widgets/filter/filter_with_keyword.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/viewmodels/similar_works_viewmodel.dart';
import 'package:xuro/widgets/work_grid_view.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/widgets/pagination_controls.dart';

class SimilarWorksScreen extends StatefulWidget {
  final Work work;

  const SimilarWorksScreen({
    super.key,
    required this.work,
  });

  @override
  State<SimilarWorksScreen> createState() => _SimilarWorksScreenState();
}

class _SimilarWorksScreenState extends State<SimilarWorksScreen> {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  late SimilarWorksViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SimilarWorksViewModel(widget.work);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels != _scrollController.position.minScrollExtent) {
      if (_viewModel.filterPanelExpanded) {
        _viewModel.closeFilterPanel();
      }
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: AppAnimations.medium,
        curve: AppAnimations.enter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('相关推荐'),
          actions: [
            Consumer<SimilarWorksViewModel>(
              builder: (context, viewModel, _) => IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: viewModel.toggleFilterPanel,
              ),
            ),
          ],
        ),
        body: Consumer<SimilarWorksViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: WorkGridView(
                        works: viewModel.works,
                        isLoading: viewModel.isLoading,
                        error: viewModel.error,
                        onRetry: () => viewModel.loadSimilarWorks(),
                        layoutStrategy: _layoutStrategy,
                        scrollController: _scrollController,
                        bottomWidget: viewModel.works.isNotEmpty
                            ? PaginationControls(
                                currentPage: viewModel.currentPage,
                                totalPages: viewModel.totalPages ?? 1,
                                onPageChanged: (page) {
                                  viewModel.loadPage(page);
                                  _scrollToTop();
                                },
                                isLoading: viewModel.isLoading,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    duration: AppAnimations.short,
                    curve: AppAnimations.standard,
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
        ),
      ),
    );
  }
} 