import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

class PlayerSeekControls extends StatelessWidget {
  const PlayerSeekControls({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 后退30s
        IconButton(
          icon: const Icon(Icons.replay_30),
          iconSize: 24,
          onPressed: () {
            final position = viewModel.position;
            if (position != null) {
              viewModel.seek(position - const Duration(seconds: 30));
            }
          },
        ),
        // 后退5s
        IconButton(
          icon: const Icon(Icons.replay_5),
          iconSize: 24,
          onPressed: () {
            final position = viewModel.position;
            if (position != null) {
              viewModel.seek(position - const Duration(seconds: 5));
            }
          },
        ),
        // 上一句歌词
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 24,
          onPressed: () => viewModel.seekToPreviousLyric(),
        ),
        // 下一句歌词
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 24,
          onPressed: () => viewModel.seekToNextLyric(),
        ),
        // 快进5s
        IconButton(
          icon: const Icon(Icons.forward_5),
          iconSize: 24,
          onPressed: () {
            final position = viewModel.position;
            if (position != null) {
              viewModel.seek(position + const Duration(seconds: 5));
            }
          },
        ),
        // 快进30s
        IconButton(
          icon: const Icon(Icons.forward_30),
          iconSize: 24,
          onPressed: () {
            final position = viewModel.position;
            if (position != null) {
              viewModel.seek(position + const Duration(seconds: 30));
            }
          },
        ),
      ],
    );
  }
} 