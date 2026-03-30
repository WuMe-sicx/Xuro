import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/playlists_with_exist_statu/playlist.dart';

class PlaylistSelectionDialog extends StatefulWidget {
  final List<Playlist>? playlists;
  final bool isLoading;
  final String? error;
  final Future<void> Function(Playlist playlist)? onPlaylistTap;
  final VoidCallback? onRetry;

  const PlaylistSelectionDialog({
    super.key,
    this.playlists,
    required this.isLoading,
    this.error,
    this.onPlaylistTap,
    this.onRetry,
  });

  @override
  State<PlaylistSelectionDialog> createState() => _PlaylistSelectionDialogState();
}

class _PlaylistSelectionDialogState extends State<PlaylistSelectionDialog> {
  final Map<String, _PlaylistItemState> _itemStates = {};

  @override
  void initState() {
    super.initState();
    _updateItemStates();
  }

  @override
  void didUpdateWidget(PlaylistSelectionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playlists != oldWidget.playlists) {
      _updateItemStates();
    }
  }

  void _updateItemStates() {
    if (widget.playlists == null) return;
    
    final newStates = <String, _PlaylistItemState>{};
    for (final playlist in widget.playlists!) {
      newStates[playlist.id!] = _PlaylistItemState(
        playlist: playlist,
        isLoading: _itemStates[playlist.id!]?.isLoading ?? false,
      );
    }
    _itemStates.clear();
    _itemStates.addAll(newStates);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加到收藏夹',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.error!),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.onRetry,
                child: const Text('重试'),
              ),
            ],
          ],
        ),
      );
    }

    if (widget.playlists == null || widget.playlists!.isEmpty) {
      return const Center(
        child: Text('暂无收藏夹'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.playlists!.length,
      itemBuilder: (context, index) {
        final playlist = widget.playlists![index];
        final state = _itemStates[playlist.id!]!;
        return _PlaylistItem(
          state: state,
          onTap: () => _handlePlaylistTap(state),
        );
      },
    );
  }

  Future<void> _handlePlaylistTap(_PlaylistItemState state) async {
    if (state.isLoading || widget.onPlaylistTap == null) return;

    setState(() {
      state.isLoading = true;
    });

    try {
      await widget.onPlaylistTap!(state.playlist);
      
      if (mounted) {
        final newPlaylist = state.playlist.copyWith(
          exist: !(state.playlist.exist ?? false),
        );
        
        _itemStates[state.playlist.id!] = _PlaylistItemState(
          playlist: newPlaylist,
          isLoading: false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${newPlaylist.exist! ? '添加成功' : '移除成功'}: ${_getDisplayName(newPlaylist.name)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.onSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() {
          state.isLoading = false;
        });
      }
    }
  }

  String _getDisplayName(String? name) {
    switch (name) {
      case '__SYS_PLAYLIST_MARKED':
        return '我标记的';
      case '__SYS_PLAYLIST_LIKED':
        return '我喜欢的';
      default:
        return name ?? '';
    }
  }
}

class _PlaylistItem extends StatelessWidget {
  final _PlaylistItemState state;
  final VoidCallback? onTap;

  const _PlaylistItem({
    required this.state,
    this.onTap,
  });

  String _getDisplayName(String? name) {
    switch (name) {
      case '__SYS_PLAYLIST_MARKED':
        return '我标记的';
      case '__SYS_PLAYLIST_LIKED':
        return '我喜欢的';
      default:
        return name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_getDisplayName(state.playlist.name)),
      subtitle: Text('${state.playlist.worksCount ?? 0} 个作品'),
      trailing: state.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Checkbox(
              value: state.playlist.exist ?? false,
              onChanged: (_) => onTap?.call(),
            ),
      onTap: onTap,
    );
  }
}

class _PlaylistItemState {
  final Playlist playlist;
  bool isLoading;
  
  _PlaylistItemState({
    required this.playlist,
    this.isLoading = false,
  });
} 