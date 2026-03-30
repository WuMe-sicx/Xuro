import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';

class WorkFooter extends StatelessWidget {
  final Work work;

  const WorkFooter({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          work.release ?? '',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
        ),
        Text(
          '销量 ${work.dlCount ?? 0}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
