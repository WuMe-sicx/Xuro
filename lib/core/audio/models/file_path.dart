import 'package:xuro/data/models/files/files.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';

/// 文件路径工具类
/// 用于在文件树中定位文件和获取同级文件
class FilePath {
  static const separator = '/';

  /// 获取文件的完整路径
  /// 返回类似 /folder1/folder2/file.mp3 的路径
  static String? getPath(Child targetFile, Files root) {
    AppLogger.debug('开始查找文件路径: ${targetFile.title}');
    final segments = _findPathSegments(root.children, targetFile);
    
    if (segments == null) {
      AppLogger.debug('未找到文件路径');
      return null;
    }

    final path = separator + segments.join(separator);
    AppLogger.debug('找到文件路径: $path');
    return path;
  }

  /// 递归查找文件路径段
  static List<String>? _findPathSegments(List<Child>? children, Child targetFile, [List<String> currentPath = const []]) {
    if (children == null) return null;

    for (final child in children) {
      if (child.title == targetFile.title && 
          child.mediaDownloadUrl == targetFile.mediaDownloadUrl && 
          child.type == targetFile.type &&
          child.size == targetFile.size) {  // size 作为额外验证
        return [...currentPath, child.title!];
      }

      if (child.type == 'folder' && child.children != null) {
        final result = _findPathSegments(
          child.children, 
          targetFile, 
          [...currentPath, child.title!]
        );
        if (result != null) return result;
      }
    }

    return null;
  }

  /// 获取同级文件列表
  /// 返回与目标文件在同一目录下的所有文件
  static List<Child> getSiblings(Child targetFile, Files root) {
    AppLogger.debug('开始获取同级文件: ${targetFile.title}');
    
    // 获取目标文件的路径
    final path = getPath(targetFile, root);
    if (path == null) {
      AppLogger.debug('无法获取文件路径，返回空列表');
      return [];
    }

    // 获取父目录路径
    final lastSeparator = path.lastIndexOf(separator);
    final parentPath = lastSeparator > 0 ? path.substring(0, lastSeparator) : separator;
    AppLogger.debug('父目录路径: $parentPath');

    // 查找父目录内容
    List<Child>? siblings;
    if (parentPath == separator) {
      // 如果是根目录，直接使用 root.children
      AppLogger.debug('文件位于根目录，使用根目录文件列表');
      siblings = root.children;
    } else {
      // 否则查找父目录
      siblings = _findDirectoryByPath(root.children, parentPath);
    }

    if (siblings == null) {
      AppLogger.debug('未找到父目录内容，返回空列表');
      return [];
    }

    AppLogger.debug('找到同级文件数量: ${siblings.length}');
    return siblings;
  }

  /// 根据路径查找目录内容
  static List<Child>? _findDirectoryByPath(List<Child>? children, String path) {
    if (children == null || path.isEmpty) return null;

    // 如果是根路径，直接返回
    if (path == separator) return children;

    // 分割路径
    final segments = path.split(separator)
      ..removeWhere((s) => s.isEmpty);
    
    List<Child>? current = children;
    
    // 逐级查找目录
    for (final segment in segments) {
      final nextDir = current?.firstWhere(
        (child) => child.title == segment && child.type == 'folder',
        orElse: () => Child(),
      );
      
      if (nextDir?.title == null) return null;
      current = nextDir?.children;
    }

    return current;
  }

  /// 查找第一个包含音频文件的目录路径
  /// 返回从根目录到目标目录的完整路径数组
  static List<String>? findFirstAudioFolderPath(
    List<Child>? children, {
    List<String> formats = const ['.mp3', '.wav'],
  }) {
    if (children == null) return null;

    List<String>? audioFolderPath;
    
    void findPath(Child folder, List<String> currentPath) {
      if (audioFolderPath != null) return;

      if (folder.children != null) {
        // 首先检查当前��录是否直接包含音频文件
        bool hasDirectAudio = folder.children!.any((child) {
          if (child.type != 'folder') {
            final fileName = child.title?.toLowerCase() ?? '';
            return formats.any((format) => fileName.endsWith(format));
          }
          return false;
        });

        // 如果当前目录包含音频文件，记录完整路径
        if (hasDirectAudio) {
          audioFolderPath = currentPath;
          return;
        }

        // 如果当前目录没有音频文件，递归检查子目录
        for (final child in folder.children!) {
          if (child.type == 'folder') {
            List<String> newPath = List.from(currentPath)..add(child.title ?? '');
            findPath(child, newPath);
          }
        }
      }
    }

    // 遍历根目录下的所有文件夹
    for (final child in children) {
      if (child.type == 'folder') {
        findPath(child, [child.title ?? '']);
        if (audioFolderPath != null) break;
      }
    }

    return audioFolderPath;
  }

  /// 检查路径是否包含指定的目录名
  /// 用于判断某个目录是否在音频文件夹的路径上
  static bool isInPath(List<String>? path, String? folderName) {
    if (path == null || folderName == null) return false;
    return path.contains(folderName);
  }
} 