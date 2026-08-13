/// circles_screen.dart：分类屏——真实 `/circles/` 接口社团的编号列表。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/circles_viewmodel.dart';
import 'package:xuro/screens/browse/widgets/browse_list_item.dart';
import 'package:xuro/widgets/common/app_search_field.dart';

class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CirclesViewModel(),
      child: Scaffold(
        appBar: browseAppBar(context, Strings.browseAllCircles),
        body: Consumer<CirclesViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppSearchField(
                    hintText: Strings.browseSearchCirclesHint,
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

  Widget _buildContent(BuildContext context, CirclesViewModel viewModel) {
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
    if (viewModel.circles.isEmpty) {
      return const Center(child: Text(Strings.browseEmptyCircles));
    }
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.separated(
        itemCount: viewModel.circles.length,
        separatorBuilder: (context, _) => Divider(
          height: BrowseListItem.rowDividerThickness,
          thickness: BrowseListItem.rowDividerThickness,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final circle = viewModel.circles[index];
          final name = circle.name ?? '';
          return BrowseListItem(
            index: index + 1,
            name: name,
            count: circle.count,
            onTap: name.isNotEmpty ? () => _onCircleTap(context, name) : null,
          );
        },
      ),
    );
  }

  void _onCircleTap(BuildContext context, String circleName) {
    Navigator.pushNamed(
      context,
      '/search',
      arguments: '\$circle:$circleName\$',
    );
  }
}
