import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xuro/core/image/cache/image_cache_manager.dart';
import 'package:xuro/widgets/common/skeleton_pulse.dart';

/// 播放器圆形封面 + 细环。规范 §2.2。
///
/// 图片加载与 [PlayerCover] 一致（`ImageCacheManager` + `SkeletonPulse`），
/// 但形状改为圆形并加 accent 细环；透明度用 `.withValues`（非 `withOpacity`）。
/// 调用方负责包 `Hero(tag:'mini-player-cover')`（保留现有过渡）。
class CircularCover extends StatelessWidget {
  const CircularCover({
    super.key,
    this.coverUrl,
    this.maxSize = 320,
  });

  final String? coverUrl;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surfaceContainerHighest,
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: coverUrl != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final dpr = MediaQuery.of(context).devicePixelRatio;
                    final w = constraints.maxWidth;
                    int? cacheWidth;
                    if (w.isFinite && w > 0) {
                      final p = (w * dpr).round();
                      cacheWidth = p < 1 ? 1 : p;
                    }
                    return CachedNetworkImage(
                      imageUrl: coverUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: cacheWidth,
                      fadeInDuration: const Duration(milliseconds: 150),
                      cacheManager: ImageCacheManager.instance,
                      placeholder: (context, url) => SkeletonPulse(
                        child: Container(color: cs.surfaceContainerHighest),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: cs.errorContainer,
                        child: Center(
                          child: Icon(Icons.error_outline,
                              size: 48, color: cs.error),
                        ),
                      ),
                    );
                  },
                )
              : Icon(Icons.music_note, size: 96, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
