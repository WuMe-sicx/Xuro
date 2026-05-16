import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/voice_actors_viewmodel.dart';
import 'package:xuro/screens/browse/widgets/browse_search_bar.dart';
import 'package:xuro/screens/browse/widgets/browse_grid_item.dart';

class VoiceActorsScreen extends StatelessWidget {
  const VoiceActorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceActorsViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text(Strings.browseAllVoiceActors)),
        body: Consumer<VoiceActorsViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                BrowseSearchBar(
                  hintText: Strings.browseSearchVoiceActorsHint,
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
    if (viewModel.voiceActors.isEmpty) {
      return const Center(child: Text(Strings.browseEmptyVoiceActors));
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
