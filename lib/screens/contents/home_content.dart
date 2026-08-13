/// home_content.dart：底部导航「主页」tab 的发现首页——搜索入口、时段问候、
/// 继续播放卡片与作品网格。分页/筛选/滚动逻辑保持不变，只重排布局
/// （设计稿 01 发现首页）。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/core/theme/app_animations.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/models/filter_state.dart';
import 'package:xuro/presentation/models/load_failure.dart';
import 'package:xuro/presentation/viewmodels/home_viewmodel.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/presentation/widgets/auth/prompt_login.dart';
import 'package:xuro/screens/search_screen.dart';
import 'package:xuro/widgets/common/app_search_field.dart';
import 'package:xuro/widgets/filter/filter_panel.dart';
import 'package:xuro/widgets/home/continue_playing_card.dart';
import 'package:xuro/widgets/home/home_greeting.dart';
import 'package:xuro/widgets/work_card/work_card.dart';
import 'package:xuro/widgets/work_grid/enhanced_work_grid_view.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with AutomaticKeepAliveClientMixin {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  final _playerViewModel = GetIt.I<PlayerViewModel>();
  final _downloadService = GetIt.I<DownloadService>();

  // 在线/本地角标：整页 works 变化时批量查一次（见 DownloadedWorksScope 注释），
  // 不逐卡片查。identical() 守卫避免无关 setState 反复触发这次批量查询。
  List<Work>? _downloadCheckedFor;
  Set<int> _downloadedWorkIds = const {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().ensureFirstLoad();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      return;
    }
    context.read<HomeViewModel>().closeFilterPanel();
  }

  Future<void> _refreshDownloadBadges(List<Work> works) async {
    if (identical(works, _downloadCheckedFor)) return;
    _downloadCheckedFor = works;
    final ids = <int>{};
    await Future.wait(works.map((w) async {
      final id = w.id;
      if (id == null) return;
      final paths = await _downloadService.localPathsForWork(id.toString());
      if (paths.isNotEmpty) ids.add(id);
    }));
    // works 在等待期间可能已被下一页/刷新替换，此时结果作废，避免闪回旧角标。
    if (!mounted || !identical(works, _downloadCheckedFor)) return;
    setState(() => _downloadedWorkIds = ids);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final greeting = HomeGreeting.of(now);

    return Column(
      children: [
        // 稿子的首页顶栏是「品牌字 + 搜索图标」，但 MainScreen 的通用 AppBar
        // 已经提供标题（含作品总数）与搜索入口，且跨 4 个 tab 共用。再叠一层
        // 品牌栏会变成两层顶栏、两个搜索入口——故不加。Modernist 的性格由下方
        // 的 kicker + 800 字重大问候语承担，品牌字在侧边栏已有。
        //
        // 搜索框保留：它是既有能力（只读，点击进搜索页），比 AppBar 上的图标
        // 触达面积大得多。稿子只画了图标是因为它的顶栏是极简的，不构成删除依据。
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMobile,
            AppSpacing.space12,
            AppSpacing.pageMobile,
            0,
          ),
          child: AppSearchField(
            hintText: Strings.homeSearchHint,
            readOnly: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMobile,
            AppSpacing.space16,
            AppSpacing.pageMobile,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting.kicker(now),
                style: AppTextStyles.labelMedium.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                '${greeting.greetingLine1}\n${greeting.greetingLine2}',
                style:
                    AppTextStyles.headlineMedium.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
        // 没有上次播放态时该卡片自己渲染为空（SizedBox.shrink），不占位。
        ContinuePlayingCard(viewModel: _playerViewModel),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMobile,
            AppSpacing.space16,
            AppSpacing.pageMobile,
            AppSpacing.space8,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              Strings.todaysPicks,
              style: AppTextStyles.titleMedium.copyWith(color: cs.onSurface),
            ),
          ),
        ),
        Expanded(
          // 筛选面板收起时用 AnimatedSlide 向上平移出 Stack 顶部。首页上方现在
          // 有问候语与分区标题，不裁剪的话溢出的面板会盖住它们。
          child: ClipRect(
            child: Stack(
              children: [
                // Grid: only rebuilds when list data changes
                Selector<
                    HomeViewModel,
                    ({
                      List<Work> works,
                      bool isLoading,
                      LoadFailure? failure,
                      int currentPage,
                      int? totalPages
                    })>(
                  selector: (_, vm) => (
                    works: vm.works,
                    isLoading: vm.isLoading,
                    failure: vm.failure,
                    currentPage: vm.currentPage,
                    totalPages: vm.totalPages,
                  ),
                  builder: (context, data, child) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _refreshDownloadBadges(data.works),
                    );
                    return DownloadedWorksScope(
                      downloadedWorkIds: _downloadedWorkIds,
                      child: EnhancedWorkGridView(
                        works: data.works,
                        isLoading: data.isLoading,
                        failure: data.failure,
                        onLogin: () => promptLogin(
                          context,
                          onLoggedIn: () =>
                              context.read<HomeViewModel>().refresh(),
                        ),
                        currentPage: data.currentPage,
                        totalPages: data.totalPages,
                        onPageChanged: (page) =>
                            context.read<HomeViewModel>().loadPage(page),
                        onRefresh: () =>
                            context.read<HomeViewModel>().refresh(),
                        onRetry: () => context.read<HomeViewModel>().refresh(),
                        layoutStrategy: _layoutStrategy,
                        scrollController: _scrollController,
                      ),
                    );
                  },
                ),
                // Filter panel: only rebuilds when filter state changes
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Selector<
                      HomeViewModel,
                      ({
                        bool expanded,
                        bool hasSubtitle,
                        FilterState filterState
                      })>(
                    selector: (_, vm) => (
                      expanded: vm.filterPanelExpanded,
                      hasSubtitle: vm.hasSubtitle,
                      filterState: vm.filterState,
                    ),
                    builder: (context, data, child) {
                      return AnimatedSlide(
                        duration: AppAnimations.short,
                        curve: AppAnimations.standard,
                        offset: Offset(0, data.expanded ? 0 : -1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: FilterPanel(
                            hasSubtitle: data.hasSubtitle,
                            onSubtitleChanged:
                                context.read<HomeViewModel>().updateSubtitle,
                            orderField: data.filterState.orderField,
                            isDescending: data.filterState.isDescending,
                            onOrderFieldChanged:
                                context.read<HomeViewModel>().updateOrderField,
                            onSortDirectionChanged: context
                                .read<HomeViewModel>()
                                .updateSortDirection,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
