import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.skip_previous),
              onPressed: viewModel.previous,
            ),
            const SizedBox(width: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: IconButton(
                iconSize: 32,
                color: Colors.white,
                icon: Icon(
                  viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: viewModel.playPause,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.skip_next),
              onPressed: viewModel.next,
            ),
          ],
        );
      },
    );
  }
} 