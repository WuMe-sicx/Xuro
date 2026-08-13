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

  /// 切曲：在**已确定的播放列表上移动游标**，不重新推导列表。
  ///
  /// 这里曾经走公开工厂重新推导，结果是：`PlaybackController` 在部分音源
  /// 构造失败时用 [withFilteredPlaylist] 建立的过滤列表，会在七行之后被这个
  /// 方法碾平回完整文件树的推导结果——而 just_audio 的队列仍是过滤后的。
  /// 于是队列下标被拿去索引一个更长的列表，取到错位的 `Child`，锁屏标题、
  /// 字幕、持久化的 currentFile 全部跟着错；更糟的是错位往往精确落回那个
  /// 因 `mediaDownloadUrl == null` 而被丢弃的文件，`TrackInfoCreator` 的
  /// 强解包便在 `currentIndexStream` 的监听器里抛出、逃逸到 zone。
  ///
  /// 唯一活的调用方是 `PlaybackStateManager` 的 `currentIndexStream` 监听器，
  /// 它传的 `newFile` 字面取自 `playlist[index]`，构造上必然命中。
  /// （`PlaybackController` 那条路径因同曲目守卫已到不了这里。）
  /// 未命中时保留原游标而不是回退到 0。
  ///
  /// 已知不精确：这里按 `title` 反查下标，而监听器手上本就有精确的队列下标。
  /// 同名文件会取到第一个——但旧实现同样按 title 反查，净差异为零，故未改
  /// 签名去接那个下标。真要消除，得让监听器把 index 带进来。
  PlaybackContext copyWithFile(Child newFile) {
    final index = playlist.indexWhere((f) => f.title == newFile.title);
    return PlaybackContext._(
      work: work,
      files: files,
      currentFile: newFile,
      playlist: playlist,
      currentIndex: index >= 0 ? index : currentIndex,
      playMode: playMode,
    );
  }
}
