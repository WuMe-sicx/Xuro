import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  static const _seekStep = Duration(seconds: 10);

  void _seekBy(PlayerViewModel vm, Duration delta) {
    final position = vm.position;
    if (position == null) return;
    var target = position + delta;
    if (target < Duration.zero) target = Duration.zero;
    final duration = vm.duration;
    if (duration != null && target > duration) target = duration;
    vm.seek(target);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.replay_10),
              tooltip: Strings.playerSeekBack10,
              onPressed: () => _seekBy(viewModel, -_seekStep),
            ),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.skip_previous),
              tooltip: Strings.playerPrevTrack,
              onPressed: viewModel.previous,
            ),
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
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.skip_next),
              tooltip: Strings.playerNextTrack,
              onPressed: viewModel.next,
            ),
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.forward_10),
              tooltip: Strings.playerSeekForward10,
              onPressed: () => _seekBy(viewModel, _seekStep),
            ),
          ],
        );
      },
    );
  }
}
