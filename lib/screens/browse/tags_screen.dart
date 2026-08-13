/// tags_screen.dart：分类屏——真实 `/tags/` 接口标签的编号列表。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/tags_viewmodel.dart';
import 'package:xuro/screens/browse/widgets/browse_list_item.dart';
import 'package:xuro/widgets/common/app_search_field.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TagsViewModel(),
      child: Scaffold(
        appBar: browseAppBar(context, Strings.browseAllTags),
        body: Consumer<TagsViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppSearchField(
                    hintText: Strings.browseSearchTagsHint,
                    onChanged: viewModel.search,
                    onClear: () => viewModel.search(''),
                  ),
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
            Text(Strings.loadFailed,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: viewModel.refresh,
              child: const Text(Strings.retry),
            ),
          ],
        ),
      );
    }
    if (viewModel.tags.isEmpty) {
      return const Center(child: Text(Strings.browseEmptyTags));
    }
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.separated(
        itemCount: viewModel.tags.length,
        separatorBuilder: (context, _) => Divider(
          height: BrowseListItem.rowDividerThickness,
          thickness: BrowseListItem.rowDividerThickness,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final tag = viewModel.tags[index];
          final displayName = tag.i18n?.zhCn?.name ?? tag.name ?? '';
          final searchName = tag.name ?? '';
          return BrowseListItem(
            index: index + 1,
            name: displayName,
            count: tag.count,
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
