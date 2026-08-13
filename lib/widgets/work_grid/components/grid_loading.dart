import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';
import 'package:xuro/widgets/common/skeleton_pulse.dart';

class GridLoading extends StatelessWidget {
  final WorkLayoutStrategy layoutStrategy;

  const GridLoading({
    super.key,
    this.layoutStrategy = const WorkLayoutStrategy(),
  });

  @override
  Widget build(BuildContext context) {
    // 骨架列数须跟随真实布局策略：写死 2 列会在平板/桌面出现
    // 「2 列骨架 → 3/4 列内容」的加载态跳变。
    final columnsCount = layoutStrategy.getColumnsCount(context);
    return SkeletonPulse(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.space16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnsCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppSpacing.space16,
          mainAxisSpacing: AppSpacing.space16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.mdAll,
            ),
          );
        },
      ),
    );
  }
}
