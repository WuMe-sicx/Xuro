import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/voice_actors_viewmodel.dart';
import 'package:asmrapp/screens/browse/widgets/browse_search_bar.dart';
import 'package:asmrapp/screens/browse/widgets/browse_grid_item.dart';

class VoiceActorsScreen extends StatelessWidget {
  const VoiceActorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceActorsViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('全部声优')),
        body: Consumer<VoiceActorsViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                BrowseSearchBar(
                  hintText: '搜索声优...',
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

  Widget _buildContent(BuildContext context, VoiceActorsViewModel viewModel) {
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
    if (viewModel.voiceActors.isEmpty) {
      return const Center(child: Text('暂无声优'));
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
        itemCount: viewModel.voiceActors.length,
        itemBuilder: (context, index) {
          final va = viewModel.voiceActors[index];
          final name = va.name ?? '';
          return BrowseGridItem(
            name: name,
            count: va.count ?? 0,
            onTap: name.isNotEmpty
                ? () => _onVATap(context, name)
                : null,
          );
        },
      ),
    );
  }

  void _onVATap(BuildContext context, String vaName) {
    Navigator.pushNamed(
      context,
      '/search',
      arguments: '\$va:$vaName\$',
    );
  }
}
