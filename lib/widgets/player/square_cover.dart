import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xuro/core/image/cache/image_cache_manager.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/widgets/common/skeleton_pulse.dart';

/// 播放器方形大封面。Modernist 改版（原 `CircularCover` 已废弃，取消其
/// 圆形 + accent 细环，改为零圆角方形 + 1px 中性描边，无阴影——Modernist
/// 用分隔线表达层级、不用阴影，见 `app_theme.dart`）。
///
/// 图片加载与旧实现一致（`ImageCacheManager` + `SkeletonPulse`）。
/// 调用方负责包 `Hero(tag:'mini-player-cover')`（保留现有过渡）。
///
/// 无封面时的回退图标刻意染 accent 色（而非中性色）：这是本组件里
/// 唯一随配色轮换的元素，用于验证三配色不变量（见同名测试）。
class SquareCover extends StatelessWidget {
  const SquareCover({
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
          borderRadius: AppRadius.mdAll,
          color: cs.surfaceContainerHighest,
          border: Border.all(color: cs.outlineVariant, width: 1),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.mdAll,
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
              : Icon(Icons.music_note, size: 96, color: cs.primary),
        ),
      ),
    );
  }
}
