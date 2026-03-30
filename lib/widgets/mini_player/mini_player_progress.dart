import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/presentation/viewmodels/player_viewmodel.dart';

class MiniPlayerProgress extends StatelessWidget {
  const MiniPlayerProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final position = viewModel.position?.inMilliseconds.toDouble() ?? 0.0;
        final duration = viewModel.duration?.inMilliseconds.toDouble() ?? 0.0;
        final progress = duration > 0 ? position / duration : 0.0;

        return RepaintBoundary(
          child: SizedBox(
            height: 2,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
