import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/my_lists/my_playlists/playlist.dart';
import 'package:asmrapp/screens/contents/playlists/playlists_list_view.dart';
import 'package:asmrapp/screens/contents/playlists/playlist_works_view.dart';

class PlaylistsContent extends StatefulWidget {
  const PlaylistsContent({super.key});

  @override
  State<PlaylistsContent> createState() => _PlaylistsContentState();
}

class _PlaylistsContentState extends State<PlaylistsContent> with AutomaticKeepAliveClientMixin {
  Playlist? _selectedPlaylist;

  @override
  bool get wantKeepAlive => true;

  void _handlePlaylistSelected(Playlist playlist) {
    setState(() {
      _selectedPlaylist = playlist;
    });
  }

  void _handleBack() {
    setState(() {
      _selectedPlaylist = null;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedPlaylist != null) {
      _handleBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return PopScope(
      canPop: _selectedPlaylist == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: _selectedPlaylist != null
          ? PlaylistWorksView(
              playlist: _selectedPlaylist!,
              onBack: _handleBack,
            )
          : PlaylistsListView(
              onPlaylistSelected: _handlePlaylistSelected,
            ),
    );
  }
}