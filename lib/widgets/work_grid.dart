import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/widgets/work_row.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';

class WorkGrid extends StatelessWidget {
  final List<Work> works;
  final void Function(Work work)? onWorkTap;
  final WorkLayoutStrategy layoutStrategy;

  const WorkGrid({
    super.key,
    required this.works,
    this.onWorkTap,
    this.layoutStrategy = const WorkLayoutStrategy(),
  });

  @override
  Widget build(BuildContext context) {
    final columnsCount = layoutStrategy.getColumnsCount(context);
    final rows = layoutStrategy.groupWorksIntoRows(works, columnsCount);
    final rowSpacing = layoutStrategy.getRowSpacing(context);
    final columnSpacing = layoutStrategy.getColumnSpacing(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= rows.length) return null;
          return Padding(
            padding: EdgeInsets.only(
                bottom: index < rows.length - 1 ? rowSpacing : 0),
            child: WorkRow(
              works: rows[index],
              onWorkTap: onWorkTap,
              spacing: columnSpacing,
            ),
          );
        },
        childCount: rows.length,
      ),
    );
  }
}
