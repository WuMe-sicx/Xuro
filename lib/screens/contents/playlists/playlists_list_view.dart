import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/presentation/viewmodels/playlists_viewmodel.dart';
import 'package:xuro/data/models/my_lists/my_playlists/playlist.dart';
import 'package:xuro/widgets/pagination_controls.dart';

class PlaylistsListView extends StatelessWidget {
  final Function(Playlist) onPlaylistSelected;

  const PlaylistsListView({
    super.key,
    required this.onPlaylistSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.playlists.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null && viewModel.playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(viewModel.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.refresh,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = viewModel.playlists[index];
                    return ListTile(
                      leading: const Icon(Icons.playlist_play),
                      title: Text(viewModel.getDisplayName(playlist.name)),
                      subtitle: Text('${playlist.worksCount ?? 0} 个作品'),
                      onTap: () => onPlaylistSelected(playlist),
                    );
                  },
                ),
              ),
              if (viewModel.playlists.isNotEmpty)
                PaginationControls(
                  currentPage: viewModel.currentPage,
                  totalPages: viewModel.totalPages ?? 1,
                  isLoading: viewModel.isLoading,
                  onPageChanged: (page) => viewModel.loadPlaylists(page: page),
                ),
            ],
          ),
        );
      },
    );
  }
} 