import 'package:xuro/data/models/mark_status.dart';
import 'package:flutter/material.dart';

class WorkActionButtons extends StatelessWidget {
  final VoidCallback onRecommendationsTap;
  final bool hasRecommendations;
  final bool checkingRecommendations;
  final VoidCallback onFavoriteTap;
  final bool loadingFavorite;
  final VoidCallback onMarkTap;
  final MarkStatus? currentMarkStatus;
  final bool loadingMark;

  const WorkActionButtons({
    super.key,
    required this.onRecommendationsTap,
    required this.hasRecommendations,
    required this.checkingRecommendations,
    required this.onFavoriteTap,
    this.loadingFavorite = false,
    required this.onMarkTap,
    this.currentMarkStatus,
    this.loadingMark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.favorite_border,
            label: '收藏',
            onTap: onFavoriteTap,
            loading: loadingFavorite,
          ),
          _ActionButton(
            icon: Icons.bookmark_border,
            label: currentMarkStatus?.label ?? '标记',
            onTap: onMarkTap,
            loading: loadingMark,
          ),
          _ActionButton(
            icon: Icons.star_border,
            label: '评分',
            onTap: () {
              // TODO: 实现评分功能
            },
          ),
          _ActionButton(
            icon: Icons.recommend,
            label: checkingRecommendations ? '检查中' : (hasRecommendations ? '相关推荐' : '暂无推荐'),
            onTap: hasRecommendations ? onRecommendationsTap : null,
            loading: checkingRecommendations,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onTap == null && !loading;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Icon(
                icon,
                color: disabled 
                    ? theme.colorScheme.onSurface.withOpacity(0.38)
                    : null,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: disabled
                    ? theme.colorScheme.onSurface.withOpacity(0.38)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 