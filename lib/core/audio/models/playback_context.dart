import 'package:xuro/core/audio/utils/audio_error_handler.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/files/files.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/core/audio/models/play_mode.dart';
import 'package:xuro/core/audio/models/file_path.dart';

class PlaybackContext {
  final Work work;
  final Files files;
  final Child currentFile;
  final List<Child> playlist;
  final int currentIndex;
  final PlayMode playMode;

  void validate() {
    if (playlist.isEmpty) {
      throw AudioError(
        AudioErrorType.state,
        '无效的播放列表状态：播放列表为空',
      );
    }

    if (currentIndex < 0 || currentIndex >= playlist.length) {
      throw AudioError(
        AudioErrorType.state,
        '无效的播放列表索引：$currentIndex，列表长度：${playlist.length}',
      );
    }

    if (!playlist.contains(currentFile)) {
      throw AudioError(
        AudioErrorType.state,
        '当前文件不在播放列表中',
      );
    }
  }

  // 私有构造函数
  const PlaybackContext._({
    required this.work,
    required this.files,
    required this.currentFile,
    required this.playlist,
    required this.currentIndex,
    this.playMode = PlayMode.sequence,
  });

  // 公开的工厂构造函数，只需要基本参数
  factory PlaybackContext({
    required Work work,
    required Files files,
    required Child currentFile,
    PlayMode playMode = PlayMode.sequence,
  }) {
    final playlist = _getPlaylistFromSameDirectory(currentFile, files);
    final currentIndex =
        playlist.indexWhere((file) => file.title == currentFile.title);

    return PlaybackContext._(
      work: work,
      files: files,
      currentFile: currentFile,
      playlist: playlist,
      currentIndex: currentIndex,
      playMode: playMode,
    );
  }

  // 获取同级文件列表
  static List<Child> _getPlaylistFromSameDirectory(
      Child currentFile, Files files) {
    // AppLogger.debug('开始获取播放列表...');
    // AppLogger.debug('当前文件: ${currentFile.title}');
    // AppLogger.debug('当前文件类型: ${currentFile.type}');

    // 获取当前文件的扩展名
    final extension = currentFile.title?.split('.').last.toLowerCase();
    // AppLogger.debug('当前文件扩展名: $extension');

    if (extension != 'mp3' && extension != 'wav') {
      AppLogger.debug('不支持的文件类型: $extension');
      return [];
    }

    // 使用 FilePath 获取同级文件
    final siblings = FilePath.getSiblings(currentFile, files);

    // 过滤出相同扩展名的文件
    final playlist = siblings
        .where((file) =>
            file.title?.toLowerCase().endsWith('.$extension') ?? false)
        .toList();

    // AppLogger.debug('找到 ${playlist.length} 个可播放文件:');
    // for (var file in playlist) {
    //   AppLogger.debug('- [${file.type}] ${file.title} (URL: ${file.mediaDownloadUrl != null ? '有' : '无'})');
    // }

    return playlist;
  }

  /// Create a context with a pre-filtered playlist (e.g. after skipping failed audio sources).
  /// `playlist` must be a subset of the original and `currentFile` must be in it.
  factory PlaybackContext.withFilteredPlaylist({
    required Work work,
    required Files files,
    required Child currentFile,
    required List<Child> playlist,
    PlayMode playMode = PlayMode.sequence,
  }) {
    final currentIndex =
        playlist.indexWhere((f) => f.title == currentFile.title);
    return PlaybackContext._(
      work: work,
      files: files,
      currentFile: currentFile,
      playlist: playlist,
      currentIndex: currentIndex >= 0 ? currentIndex : 0,
      playMode: playMode,
    );
  }

  /// 切曲时重建上下文。构造函数会据 `files` + `newFile` 重新推导
  /// playlist/currentIndex，所以这里只传源数据，不传派生字段。
  PlaybackContext copyWithFile(Child newFile) {
    return PlaybackContext(
      work: work,
      files: files,
      currentFile: newFile,
      playMode: playMode,
    );
  }
}
