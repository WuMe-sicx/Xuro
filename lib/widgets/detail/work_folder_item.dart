import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/widgets/detail/work_file_item.dart';
import 'package:xuro/core/audio/models/file_path.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

class WorkFolderItem extends StatelessWidget {
  final Child folder;
  final double indentation;
  final Function(Child file)? onFileTap;

  // 支持的音频格式列表，按优先级排序
  static List<String> get _audioFormats {
    try {
      return GetIt.I<AppSettingsService>().audioExtensions;
    } catch (_) {
      return ['.mp3', '.flac', '.wav', '.opus', '.m4a', '.aac'];
    }
  }

  // 静态变量用于跟踪第一个包含音频的文件夹的完整路径
  static List<String>? _audioFolderPath;

  // 静态方法用于重置展开状态
  static void resetExpandState() {
    _audioFolderPath = null;
  }

  const WorkFolderItem({
    super.key,
    required this.folder,
    required this.indentation,
    this.onFileTap,
  });

  bool _shouldExpandFolder(Child folder) {
    try {
      final settings = GetIt.I<AppSettingsService>();
      if (!settings.smartPathEnabled) return false;
    } catch (_) {
      // If settings not available, default to enabled
    }

    // 如果还没有找到第一个音频文件夹，就搜索并记录
    _audioFolderPath ??= FilePath.findFirstAudioFolderPath(
        [folder],
        formats: _audioFormats,
      );

    // 判断当前文件夹是否在音频文件夹的路径上
    return FilePath.isInPath(_audioFolderPath, folder.title);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldExpand = _shouldExpandFolder(folder);

    return Padding(
      padding: EdgeInsets.only(left: indentation),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          // 确保子组件也能继承正确的文字颜色
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
        ),
        child: ExpansionTile(
          title: Text(
            folder.title ?? '',
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
          leading: Icon(
            Icons.folder,
            color: colorScheme.primary,
          ),
          initiallyExpanded: shouldExpand,
          children: folder.children
                  ?.map((child) => child.type == 'folder'
                      ? WorkFolderItem(
                          folder: child,
                          indentation: indentation + 16.0,
                          onFileTap: onFileTap,
                        )
                      : WorkFileItem(
                          file: child,
                          indentation: indentation + 16.0,
                          onFileTap: onFileTap,
                        ))
                  .toList() ??
              [],
          onExpansionChanged: (expanded) {
            AppLogger.debug(
              '${expanded ? "展开" : "折叠"}文件夹: ${folder.title}',
            );
          },
        ),
      ),
    );
  }
}
