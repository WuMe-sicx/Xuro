/// continue_playing_card.dart：发现首页「继续播放」卡片——展示上次/当前播放的
/// 曲目（标题、演唱者/社团、进度），数据完全来自已恢复的播放态
/// （`PlayerViewModel.currentTrackInfo`/`position`/`duration`，见
/// `AudioPlayerService.restorePlaybackState`）。没有可展示的播放态时不渲染
/// 任何内容——不占位、不造假数据（设计稿 01）。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xuro/core/image/cache/image_cache_manager.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';
import 'package:xuro/screens/player_screen.dart';
import 'package:xuro/widgets/common/skeleton_pulse.dart';

class ContinuePlayingCard extends StatelessWidget {
  const ContinuePlayingCard({super.key, required this.viewModel});

  /// 显式注入而非内部 `GetIt.I<PlayerViewModel>()`——本卡片只有
  /// `home_content.dart` 一个调用方，构造参数化换来单测无需搭一整套 DI。
  final PlayerViewModel viewModel;

  static const double _coverSize = 56;

  @override
  Widget build(BuildContext context) {
    // position 走独立 ValueNotifier（PlayerViewModel 高频字段，见该文件字段注释），
    // 与低频字段（title/duration/isPlaying走 notifyListeners()）合并监听。
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.positionListenable]),
      builder: (context, _) {
        final track = viewModel.currentTrackInfo;
        if (track == null) return const SizedBox.shrink();

        final cs = Theme.of(context).colorScheme;
        final positionMs = viewModel.position?.inMilliseconds ?? 0;
        final durationMs = viewModel.duration?.inMilliseconds ?? 0;
        final progress =
            durationMs > 0 ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageMobile,
                vertical: AppSpacing.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.continuePlaying,
                    style:
                        AppTextStyles.labelMedium.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlayerScreen()),
                    ),
                    child: Row(
                      children: [
                        _Cover(url: track.coverUrl),
                        const SizedBox(width: AppSpacing.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                track.title,
                                style: AppTextStyles.titleMedium
                                    .copyWith(color: cs.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.space4),
                              Text(
                                track.artist,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.55),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.space8),
                              SizedBox(
                                height: 2,
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(cs.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            viewModel.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: cs.onSurface,
                          ),
                          onPressed: viewModel.playPause,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (url.isEmpty) {
      return Container(
        width: ContinuePlayingCard._coverSize,
        height: ContinuePlayingCard._coverSize,
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.music_note, color: cs.onSurfaceVariant),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: ContinuePlayingCard._coverSize,
      height: ContinuePlayingCard._coverSize,
      fit: BoxFit.cover,
      cacheManager: ImageCacheManager.instance,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => SkeletonPulse(
        child: Container(
          width: ContinuePlayingCard._coverSize,
          height: ContinuePlayingCard._coverSize,
          color: cs.surfaceContainerHighest,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: ContinuePlayingCard._coverSize,
        height: ContinuePlayingCard._coverSize,
        color: cs.errorContainer,
      ),
    );
  }
}
