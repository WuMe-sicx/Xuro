import 'package:xuro/common/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/widgets/sidebar/sidebar_menu.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/presentation/widgets/auth/login_dialog.dart';
import 'package:xuro/widgets/work_grid/enhanced_work_grid_view.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  late FavoritesViewModel _viewModel;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _viewModel = FavoritesViewModel(authViewModel);
      _viewModel.loadFavorites();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _promptLogin() async {
    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => const LoginDialog(),
    );
    if (!mounted) return;
    if (context.read<AuthViewModel>().isLoggedIn) {
      _viewModel.loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.favorites),
        ),
        drawer: const SidebarMenu(),
        body: Consumer<FavoritesViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Expanded(
                  child: EnhancedWorkGridView(
                    works: viewModel.works,
                    isLoading: viewModel.isLoading,
                    error: viewModel.error,
                    isLoginError: viewModel.isLoginError,
                    onLogin: _promptLogin,
                    onRetry: () => viewModel.loadFavorites(),
                    layoutStrategy: _layoutStrategy,
                    scrollController: _scrollController,
                    currentPage: viewModel.currentPage,
                    // 未知总页数按 1 兜底：与迁移前 PaginationControls 的显示一致。
                    totalPages: viewModel.totalPages ?? 1,
                    onPageChanged: viewModel.loadPage,
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
