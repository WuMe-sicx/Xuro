import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/tags_viewmodel.dart';
import 'package:asmrapp/screens/browse/widgets/browse_search_bar.dart';
import 'package:asmrapp/screens/browse/widgets/browse_grid_item.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TagsViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('全部标签')),
        body: Consumer<TagsViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                BrowseSearchBar(
                  hintText: '搜索标签...',
                  onChanged: viewModel.search,
                ),
                Expanded(
                  child: _buildContent(context, viewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TagsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: viewModel.refresh,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (viewModel.tags.isEmpty) {
      return const Center(child: Text('暂无标签'));
    }
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: viewModel.tags.length,
        itemBuilder: (context, index) {
          final tag = viewModel.tags[index];
          final displayName = tag.i18n?.zhCn?.name ?? tag.name ?? '';
          final searchName = tag.name ?? '';
          return BrowseGridItem(
            name: displayName,
            count: tag.count ?? 0,
            onTap: searchName.isNotEmpty
                ? () => _onTagTap(context, searchName)
                : null,
          );
        },
      ),
    );
  }

  void _onTagTap(BuildContext context, String tagName) {
    Navigator.pushNamed(
      context,
      '/search',
      arguments: '\$tag:$tagName\$',
    );
  }
}
