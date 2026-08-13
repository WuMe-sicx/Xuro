/// voice_actors_screen.dart：分类屏——真实 `/vas/` 接口声优的编号列表。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/voice_actors_viewmodel.dart';
import 'package:xuro/screens/browse/widgets/browse_list_item.dart';
import 'package:xuro/widgets/common/app_search_field.dart';

class VoiceActorsScreen extends StatelessWidget {
  const VoiceActorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceActorsViewModel(),
      child: Scaffold(
        appBar: browseAppBar(context, Strings.browseAllVoiceActors),
        body: Consumer<VoiceActorsViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppSearchField(
                    hintText: Strings.browseSearchVoiceActorsHint,
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
      child: ListView.separated(
        itemCount: viewModel.voiceActors.length,
        separatorBuilder: (context, _) => Divider(
          height: BrowseListItem.rowDividerThickness,
          thickness: BrowseListItem.rowDividerThickness,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final va = viewModel.voiceActors[index];
          final name = va.name ?? '';
          return BrowseListItem(
            index: index + 1,
            name: name,
            count: va.count,
            onTap: name.isNotEmpty ? () => _onVATap(context, name) : null,
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
