import 'package:xuro/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/presentation/viewmodels/search_viewmodel.dart';
import 'package:xuro/widgets/work_grid_view.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/widgets/pagination_controls.dart';

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

  void _onPageChanged(int page) async {
    final viewModel = context.read<SearchViewModel>();
    await viewModel.loadPage(page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: AppAnimations.medium,
        curve: AppAnimations.enter,
      );
    }
  }

  String _getOrderText(String order, String sort) {
    switch (order) {
      case 'create_date':
        return sort == 'desc' ? '最新收录' : '最早收录';
      case 'release':
        return sort == 'desc' ? '发售日期倒序' : '发售日期顺序';
      case 'dl_count':
        return sort == 'desc' ? '销量倒序' : '销量顺序';
      case 'price':
        return sort == 'desc' ? '价格倒序' : '价格顺序';
      case 'rate_average_2dp':
        return '评价倒序';
      case 'review_count':
        return '评论数量倒序';
      case 'id':
        return sort == 'desc' ? 'RJ号倒序' : 'RJ号顺序';
      case 'random':
        return '随机排序';
      default:
        return '排序';
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
                      hintText: '搜索...',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
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
                          label: const Text('字幕'),
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
                              child: Text('最新收录'),
                            ),
                            const PopupMenuItem(
                              value: ('release', 'desc'),
                              child: Text('发售日期倒序'),
                            ),
                            const PopupMenuItem(
                              value: ('release', 'asc'),
                              child: Text('发售日期顺序'),
                            ),
                            const PopupMenuItem(
                              value: ('dl_count', 'desc'),
                              child: Text('销量倒序'),
                            ),
                            const PopupMenuItem(
                              value: ('price', 'asc'),
                              child: Text('价格顺序'),
                            ),
                            const PopupMenuItem(
                              value: ('price', 'desc'),
                              child: Text('价格倒序'),
                            ),
                            const PopupMenuItem(
                              value: ('rate_average_2dp', 'desc'),
                              child: Text('评价倒序'),
                            ),
                            const PopupMenuItem(
                              value: ('review_count', 'desc'),
                              child: Text('评论数量倒序'),
                            ),
                            const PopupMenuItem(
                              value: ('id', 'desc'),
                              child: Text('RJ号倒序'),
                            ),
                            const PopupMenuItem(
                              value: ('id', 'asc'),
                              child: Text('RJ号顺序'),
                            ),
                            const PopupMenuItem(
                              value: ('random', 'desc'),
                              child: Text('随机排序'),
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
                Widget? emptyWidget;
                if (viewModel.works.isEmpty && viewModel.keyword.isEmpty) {
                  emptyWidget = const Center(
                    child: Text('输入关键词开始搜索'),
                  );
                } else if (viewModel.works.isEmpty) {
                  emptyWidget = const Center(
                    child: Text('没有找到相关结果'),
                  );
                }

                return WorkGridView(
                  works: viewModel.works,
                  isLoading: viewModel.isLoading,
                  error: viewModel.error,
                  onRetry: _onSearch,
                  customEmptyWidget: emptyWidget,
                  layoutStrategy: _layoutStrategy,
                  scrollController: _scrollController,
                  bottomWidget: viewModel.works.isNotEmpty
                      ? PaginationControls(
                          currentPage: viewModel.currentPage,
                          totalPages: viewModel.totalPages,
                          isLoading: viewModel.isLoading,
                          onPageChanged: _onPageChanged,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
