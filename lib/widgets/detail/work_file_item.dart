import 'package:flutter/material.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/utils/file_size_formatter.dart';

class WorkFileItem extends StatelessWidget {
  final Child file;
  final double indentation;
  final Function(Child file)? onFileTap;

  const WorkFileItem({
    super.key,
    required this.file,
    required this.indentation,
    this.onFileTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAudio = file.type?.toLowerCase() == 'audio';
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(left: indentation),
      child: ListTile(
        title: Text(
          file.title ?? '',
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          FileSizeFormatter.format(file.size),
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        leading: Icon(
          isAudio ? Icons.audio_file : Icons.insert_drive_file,
          color: isAudio ? Colors.green : Colors.blue,
        ),
        dense: true,
        onTap: isAudio ? () {
          AppLogger.debug('点击音频文件: ${file.title}');
          onFileTap?.call(file);
        } : null,
      ),
    );
  }
}
