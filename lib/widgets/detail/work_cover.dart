import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xuro/core/image/cache/image_cache_manager.dart';
import 'package:xuro/presentation/layouts/work_layout_config.dart';

class WorkCover extends StatelessWidget {
  final String imageUrl;
  final int workId;
  final String sourceId;
  final String? releaseDate;
  final String? heroTag;

  const WorkCover({
    super.key,
    required this.imageUrl,
    required this.workId,
    required this.sourceId,
    this.releaseDate,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        AspectRatio(
          aspectRatio: 195 / 146,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dpr = MediaQuery.of(context).devicePixelRatio;
              final w = constraints.maxWidth;
              int? cacheWidth;
              if (w.isFinite && w > 0) {
                final p = (w * dpr).round();
                cacheWidth = p < 1 ? 1 : p;
              }
              // 详情页按整宽解码，与网格那份（按卡片宽度解码）是**不同的**
              // ImageCache 条目，所以从列表点进来必然要重新解码一份。这段
              // 窗口里原先什么都不画 → 空白闪一下。用网格那份已在缓存里的
              // 低清图打底：宽度相同即 key 相同、同步命中，肉眼无空窗。
              final media = MediaQuery.of(context);
              final previewWidth = WorkLayoutConfig.gridCoverCacheWidth(
                media.size.width,
                media.devicePixelRatio,
              );
              Widget lowRes(BuildContext context, String url) =>
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: previewWidth,
                    // 打底图必须立刻出现，再淡入就失去意义了。
                    fadeInDuration: Duration.zero,
                    cacheManager: ImageCacheManager.instance,
                  );

              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                memCacheWidth: cacheWidth,
                fadeInDuration: const Duration(milliseconds: 150),
                cacheManager: ImageCacheManager.instance,
                placeholder: lowRes,
                // 高清图失败时保留低清图，而不是回到空白——原先无 errorWidget
                // 时这里是永久空白。
                errorWidget: (context, url, error) => lowRes(context, url),
              );
            },
          ),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              sourceId,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
            ),
          ),
        ),
        if (releaseDate != null)
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                releaseDate!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
              ),
            ),
          ),
      ],
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: content,
      );
    }

    return content;
  }
}
