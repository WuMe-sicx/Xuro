import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';

class FavoritesContent extends StatefulWidget {
  const FavoritesContent({super.key});

  @override
  State<FavoritesContent> createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<FavoritesContent>
    with AutomaticKeepAliveClientMixin {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
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
    return Consumer<FavoritesViewModel>(
      builder: (context, viewModel, child) {
        return EnhancedWorkGridView(
          works: viewModel.works,
          isLoading: viewModel.isLoading,
          error: viewModel.error,
          currentPage: viewModel.currentPage,
          totalPages: viewModel.totalPages,
          onPageChanged: (page) => viewModel.loadPage(page),
          onRefresh: () => viewModel.loadFavorites(refresh: true),
          onRetry: () => viewModel.loadFavorites(refresh: true),
          layoutStrategy: _layoutStrategy,
          scrollController: _scrollController,
        );
      },
    );
  }
}
