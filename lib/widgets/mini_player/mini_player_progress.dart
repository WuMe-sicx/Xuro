import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

class MiniPlayerProgress extends StatelessWidget {
  const MiniPlayerProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    // duration 走 VM 的 notifyListeners()，position 走独立 notifier（见
    // PlayerViewModel 字段注释）；merge 两者，否则 duration 到达时进度条
    // 要等下一次 200ms 节流 tick 才刷新。
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.positionListenable]),
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
