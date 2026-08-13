/// work_cover_image.dart：作品卡片封面——Modernist 方形封面 + 三枚角标
/// （左上在线/本地、右上 RJ 号、左下时长）。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xuro/widgets/common/skeleton_pulse.dart';
import 'package:xuro/core/image/cache/image_cache_manager.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/common/constants/strings.dart';

class WorkCoverImage extends StatelessWidget {
  final String imageUrl;
  final int workId;
  final String sourceId;

  /// 作品时长（秒）。非空时在封面左下角显示时长角标（对齐参考图）。
  final int? durationSeconds;

  /// 该作品是否已下载到本地。`null` = 未接入判定的网格（不显示角标），
  /// 见 [DownloadedWorksScope] 注释——目前只有发现首页接了这份数据。
  final bool? isDownloaded;

  // Modernist：封面统一方形（设计稿 01「aspect-ratio: 1」），取代旧版 195/146。
  static const double _aspectRatio = 1;

  const WorkCoverImage({
    super.key,
    required this.imageUrl,
    required this.workId,
    required this.sourceId,
    this.durationSeconds,
    this.isDownloaded,
  });

  static String _fmtDuration(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = sec.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Stack(
        children: [
          Hero(
            tag: 'work-cover-$workId',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dpr = MediaQuery.of(context).devicePixelRatio;
                final w = constraints.maxWidth;
                int? cacheWidth;
                if (w.isFinite && w > 0) {
                  final p = (w * dpr).round();
                  cacheWidth = p < 1 ? 1 : p;
                }
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  memCacheWidth: cacheWidth,
                  fadeInDuration: const Duration(milliseconds: 150),
                  cacheManager: ImageCacheManager.instance,
                  placeholder: (context, url) => SkeletonPulse(
                    child: Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isDownloaded != null)
            Positioned(
              left: AppSpacing.space8,
              top: AppSpacing.space8,
              child: _CoverBadge(
                text:
                    isDownloaded! ? Strings.playerLocal : Strings.playerOnline,
                solid: true,
              ),
            ),
          if (sourceId.isNotEmpty)
            Positioned(
              right: AppSpacing.space8,
              top: AppSpacing.space8,
              child: _CoverBadge(text: sourceId),
            ),
          if (durationSeconds != null && durationSeconds! > 0)
            Positioned(
              left: AppSpacing.space8,
              bottom: AppSpacing.space8,
              child: _CoverBadge(text: _fmtDuration(durationSeconds!)),
            ),
        ],
      ),
    );
  }
}

/// 封面角标。默认「ink 半透明底 + paper 字」——ink/paper 是 Modernist 里不随
/// 三配色轮换的绝对黑白锚点，专门用于叠在任意照片上都需要保证可读的场景
/// （RJ 号/时长）。[solid] 时改成主题化的 `surface` 实底（在线/本地状态角标，
/// 随三配色/明暗轮换，对齐设计稿「surface 实底」规格）。零圆角：不设
/// borderRadius（Container 默认直角）。
class _CoverBadge extends StatelessWidget {
  const _CoverBadge({required this.text, this.solid = false});
  final String text;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space4,
      ),
      color: solid ? cs.surface : AppColors.ink.withValues(alpha: 0.7),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: solid ? cs.onSurface : AppColors.paper,
        ),
      ),
    );
  }
}
