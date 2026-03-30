import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';

class WorkTitle extends StatelessWidget {
  final Work work;

  const WorkTitle({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      work.title ?? '',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 14,
          ),
    );
  }
}
