import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

/// 播放器控制行。主按钮改为 Modernist 的 72x72 accent 实底零圆角方块
/// （取代旧的圆形），上一曲/下一曲图标放大到 30px。快进/快退 10 秒是
/// 现有功能，设计稿的静态截图未画出（稿子未读过代码库，见迁移 TODO），
/// 不属于新增功能键，予以保留，仅整体套用新的 space-between 布局。
class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  static const _seekStep = Duration(seconds: 10);
  static const double _mainButtonSize = 72;
  static const double _mainIconSize = 28;
  static const double _sideIconSize = 30;
  static const double _seekIconSize = 28;

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
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                iconSize: _seekIconSize,
                icon: const Icon(Icons.replay_10),
                tooltip: Strings.playerSeekBack10,
                onPressed: () => _seekBy(viewModel, -_seekStep),
              ),
              IconButton(
                iconSize: _sideIconSize,
                icon: const Icon(Icons.skip_previous),
                tooltip: Strings.playerPrevTrack,
                onPressed: viewModel.previous,
              ),
              Container(
                width: _mainButtonSize,
                height: _mainButtonSize,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: AppRadius.mdAll,
                ),
                child: IconButton(
                  iconSize: _mainIconSize,
                  color: cs.onPrimary,
                  icon: Icon(
                    viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: viewModel.playPause,
                ),
              ),
              IconButton(
                iconSize: _sideIconSize,
                icon: const Icon(Icons.skip_next),
                tooltip: Strings.playerNextTrack,
                onPressed: viewModel.next,
              ),
              IconButton(
                iconSize: _seekIconSize,
                icon: const Icon(Icons.forward_10),
                tooltip: Strings.playerSeekForward10,
                onPressed: () => _seekBy(viewModel, _seekStep),
              ),
            ],
          ),
        );
      },
    );
  }
}
