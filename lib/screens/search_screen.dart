import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/presentation/viewmodels/search_viewmodel.dart';
import 'package:xuro/widgets/work_grid/enhanced_work_grid_view.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/utils/logger.dart';

class SearchScreen extends StatelessWidget {
  final String? initialKeyword;

  const SearchScreen({
    super.key,
    this.initialKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: SearchScreenContent(initialKeyword: initialKeyword),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  final String? initialKeyword;

  const SearchScreenContent({
    super.key,
    this.initialKeyword,
  });

  @override
  State<SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  late final TextEditingController _searchController;
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword);

    // 如果有初始关键词，自动执行搜索
    if (widget.initialKeyword?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    AppLogger.debug('执行搜索: $keyword');
    context.read<SearchViewModel>().search(keyword);
  }

  String _getOrderText(String order, String sort) {
    switch (order) {
      case 'create_date':
        return sort == 'desc' ? Strings.sortLatest : Strings.sortOldest;
      case 'release':
        return sort == 'desc'
            ? Strings.sortReleaseDesc
            : Strings.sortReleaseAsc;
      case 'dl_count':
        return sort == 'desc' ? Strings.sortSalesDesc : Strings.sortSalesAsc;
      case 'price':
        return sort == 'desc' ? Strings.sortPriceDesc : Strings.sortPriceAsc;
      case 'rate_average_2dp':
        return Strings.sortRatingDesc;
      case 'review_count':
        return Strings.sortReviewDesc;
      case 'id':
        return sort == 'desc' ? Strings.sortRjDesc : Strings.sortRjAsc;
      case 'random':
        return Strings.sortRandom;
      default:
        return Strings.sortLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: Strings.searchInputHint,
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.lgAll,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchViewModel>().clear();
                              },
                            )
                          : null,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // 字幕选项
                      Consumer<SearchViewModel>(
                        builder: (context, viewModel, _) => FilterChip(
                          label: const Text(Strings.subtitleChip),
                          selected: viewModel.hasSubtitle,
                          onSelected: (_) => viewModel.toggleSubtitle(),
                          showCheckmark: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 排序选项
                      Consumer<SearchViewModel>(
                        builder: (context, viewModel, _) =>
                            PopupMenuButton<(String, String)>(
                          child: Chip(
                            label: Text(
                                _getOrderText(viewModel.order, viewModel.sort)),
                            deleteIcon:
                                const Icon(Icons.arrow_drop_down, size: 18),
                            onDeleted: null,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: ('create_date', 'desc'),
                              child: Text(Strings.sortLatest),
                            ),
                            const PopupMenuItem(
                              value: ('release', 'desc'),
                              child: Text(Strings.sortReleaseDesc),
                            ),
                            const PopupMenuItem(
                              value: ('release', 'asc'),
                              child: Text(Strings.sortReleaseAsc),
                            ),
                            const PopupMenuItem(
                              value: ('dl_count', 'desc'),
                              child: Text(Strings.sortSalesDesc),
                            ),
                            const PopupMenuItem(
                              value: ('price', 'asc'),
                              child: Text(Strings.sortPriceAsc),
                            ),
                            const PopupMenuItem(
                              value: ('price', 'desc'),
                              child: Text(Strings.sortPriceDesc),
                            ),
                            const PopupMenuItem(
                              value: ('rate_average_2dp', 'desc'),
                              child: Text(Strings.sortRatingDesc),
                            ),
                            const PopupMenuItem(
                              value: ('review_count', 'desc'),
                              child: Text(Strings.sortReviewDesc),
                            ),
                            const PopupMenuItem(
                              value: ('id', 'desc'),
                              child: Text(Strings.sortRjDesc),
                            ),
                            const PopupMenuItem(
                              value: ('id', 'asc'),
                              child: Text(Strings.sortRjAsc),
                            ),
                            const PopupMenuItem(
                              value: ('random', 'desc'),
                              child: Text(Strings.sortRandom),
                            ),
                          ],
                          onSelected: (value) =>
                              viewModel.setOrder(value.$1, value.$2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                // 两个空态差异只是文案：未输入关键词 vs 已搜索但无结果。
                final emptyMessage = viewModel.keyword.isEmpty
                    ? Strings.searchEmptyPrompt
                    : Strings.searchNoResults;

                return EnhancedWorkGridView(
                  works: viewModel.works,
                  isLoading: viewModel.isLoading,
                  error: viewModel.error,
                  onRetry: _onSearch,
                  emptyMessage: emptyMessage,
                  layoutStrategy: _layoutStrategy,
                  scrollController: _scrollController,
                  currentPage: viewModel.currentPage,
                  totalPages: viewModel.totalPages,
                  onPageChanged: viewModel.loadPage,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
