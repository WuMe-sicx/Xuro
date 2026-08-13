import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/files/file_kind.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/utils/file_size_formatter.dart';

class WorkFileItem extends StatelessWidget {
  final Child file;
  final double indentation;
  final Function(Child file)? onFileTap;
  final Function(Child file)? onFileDownload;

  const WorkFileItem({
    super.key,
    required this.file,
    required this.indentation,
    this.onFileTap,
    this.onFileDownload,
  });

  @override
  Widget build(BuildContext context) {
    final FileKind kind = FileKinds.of(file);
    final bool isAudio = kind == FileKind.audio;
    final bool isVideo = kind == FileKind.video;
    final bool isSubtitle = kind == FileKind.subtitle;
    final bool tappable = isAudio || isVideo || isSubtitle;
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
          isAudio
              ? Icons.audio_file
              : isVideo
                  ? Icons.movie_outlined
                  : isSubtitle
                      ? Icons.subtitles_outlined
                      : Icons.insert_drive_file,
          color: isAudio
              ? Colors.green
              : isVideo
                  ? Colors.deepPurple
                  : isSubtitle
                      ? Colors.orange
                      : Colors.blue,
        ),
        trailing: isAudio && onFileDownload != null
            ? IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                tooltip: Strings.downloadToLocalTooltip,
                onPressed: () => onFileDownload!.call(file),
              )
            : isVideo
                ? const Icon(Icons.download_outlined, size: 20)
                : null,
        dense: true,
        onTap: tappable
            ? () {
                AppLogger.debug('点击文件: ${file.title} (${file.type})');
                onFileTap?.call(file);
              }
            : null,
      ),
    );
  }
}
