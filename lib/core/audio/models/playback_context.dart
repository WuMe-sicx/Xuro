import 'package:xuro/core/audio/utils/audio_error_handler.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/files/files.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/core/audio/models/play_mode.dart';
import 'package:xuro/core/audio/models/file_path.dart';
import 'package:xuro/core/files/file_kind.dart';

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

  /// 同目录、同扩展名的兄弟文件构成播放列表。
  ///
  /// **只收同扩展名是有意的**：asmr.one 大量作品会把同一套音频同时下发
  /// mp3 与 wav/flac 两份放在同一目录，合并成一个队列会让每首曲子连放两遍。
  static List<Child> _getPlaylistFromSameDirectory(
      Child currentFile, Files files) {
    final extension = FileKinds.extensionOf(currentFile.title);

    // 此前这里硬编码 `!= 'mp3' && != 'wav'`，而设置页向用户承诺六种格式、
    // 详情页也让 .flac/.opus/.m4a/.aac 可点——点下去在这里被判空，用户看到
    // 「播放失败」，且冷启动的播放恢复也会因列表为空而静默放弃。
    if (extension == null ||
        !FileKinds.defaultPlayableExtensions.contains(extension)) {
      AppLogger.debug('不支持的文件类型: $extension');
      return [];
    }

    final siblings = FilePath.getSiblings(currentFile, files);
    return siblings
        .where((file) =>
            file.title?.toLowerCase().endsWith('.$extension') ?? false)
        .toList();
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
