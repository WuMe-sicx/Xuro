/// file_kind.dart：作品文件树节点（[Child]）的种类判定，全库唯一出处。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
library;

import 'package:xuro/data/models/files/child.dart';

/// 文件树节点的种类。互斥，由 [FileKinds.of] 按固定优先级判定。
enum FileKind { folder, audio, video, subtitle, other }

/// 文件种类判定。**纯函数，不依赖 DI**——这是它能被直接单测的前提，
/// 别为了读用户设置把 `GetIt` 引进来（可播格式请走参数，见 [isPlayable]）。
class FileKinds {
  const FileKinds._();

  /// 已知视频扩展名。**故意不含 `m4a` 等音频扩展名**。
  static const videoExtensions = {'mp4', 'mkv', 'mov', 'avi', 'webm', 'm4v'};

  /// 可**预览**的字幕扩展名。比 [pairableSubtitleExtensions] 宽是有意的：
  /// 预览是只读的，解析失败会回退成纯文本展示，多收几种格式不会有坏后果。
  static const previewableSubtitleExtensions = {'vtt', 'lrc', 'srt', 'txt'};

  /// 可被**自动配对下载 / 播放期自动加载**的字幕扩展名。
  ///
  /// 必须是 `SubtitleParserFactory` 真能解析的格式。放宽它有两个真实后果：
  /// 批量下载会给每个音频多拖一个文件（改变磁盘占用与批量汇总计数）；
  /// 播放期 `SubtitleLoader` 会抛「不支持的字幕格式」，而用户原本只是没有字幕。
  static const pairableSubtitleExtensions = {'vtt', 'lrc'};

  /// 播放管线默认接受的音频扩展名。调用方可用 [isPlayable] 的 `extensions`
  /// 覆盖它（例如跟随用户在设置里排的格式顺序）。
  static const defaultPlayableExtensions = {
    'mp3',
    'flac',
    'wav',
    'opus',
    'm4a',
    'aac'
  };

  /// 取小写扩展名；没有点号时返回 `null`。
  ///
  /// 不用 `split('.').last`：那个写法对无点文件名会把整个文件名当扩展名，
  /// 于是一个名叫 `mp3` 的文件会被判成音频，而按 `endsWith('.mp3')` 判定的
  /// 兄弟代码不会——同一个文件两套答案。
  static String? extensionOf(String? title) {
    if (title == null) return null;
    final dot = title.lastIndexOf('.');
    if (dot < 0 || dot == title.length - 1) return null;
    return title.substring(dot + 1).toLowerCase();
  }

  /// 是否文件夹。全库统一大小写不敏感——此前 8 处大小写敏感、1 处不敏感，
  /// 若 API 下发 `"Folder"`，批量下载会进去而 UI 把它画成叶子文件。
  static bool isFolder(Child child) =>
      (child.type ?? '').toLowerCase() == 'folder';

  /// 判定节点种类。优先级：文件夹 → 视频 → 音频 → 字幕 → 其它。
  ///
  /// **扩展名压过 API `type`**：asmr.one 会把「介绍视频.mp4」之类下发成
  /// `type:"audio"`，若信 `type` 会被送进音频播放管线，播放列表按扩展名过滤后
  /// 为空 → 用户看到「播放失败」且既不能播也不能下。所以已知视频扩展名一律按
  /// 视频处理，不管 `type` 说什么。
  static FileKind of(Child child) {
    if (isFolder(child)) return FileKind.folder;

    final type = (child.type ?? '').toLowerCase();
    final ext = extensionOf(child.title);

    if (type == 'video' || (ext != null && videoExtensions.contains(ext))) {
      return FileKind.video;
    }
    if (type == 'audio') return FileKind.audio;
    if (ext != null && previewableSubtitleExtensions.contains(ext)) {
      return FileKind.subtitle;
    }
    return FileKind.other;
  }

  static bool isAudio(Child child) => of(child) == FileKind.audio;

  static bool isVideo(Child child) => of(child) == FileKind.video;

  /// 是否可在只读预览页打开。注意与 [isPairableSubtitle] 的区别见两个集合的注释。
  static bool isPreviewableSubtitle(Child child) =>
      of(child) == FileKind.subtitle;

  /// 是否可作为自动配对/自动加载的字幕。
  ///
  /// 只看扩展名、不看种类：字幕文件的 API `type` 是 `"text"`，而 [of] 会把
  /// 它判成 [FileKind.subtitle]；但调用方（`SubtitleMatcher`）拿到的常常是
  /// 裸文件名而非 [Child]，所以这里提供按名判定的重载 [isPairableSubtitleName]。
  static bool isPairableSubtitle(Child child) =>
      isPairableSubtitleName(child.title);

  static bool isPairableSubtitleName(String? title) {
    final ext = extensionOf(title);
    return ext != null && pairableSubtitleExtensions.contains(ext);
  }

  /// 该文件能否进入播放管线。
  ///
  /// `extensions` 默认取 [defaultPlayableExtensions]；调用方可传入用户设置里的
  /// 格式表。**注意这只回答「不该被拦下来」，不保证 just_audio 在当前设备上
  /// 解得了这个编码**——解不了会在播放期报错，而不是在这里。
  static bool isPlayable(
    Child child, {
    Set<String> extensions = defaultPlayableExtensions,
  }) {
    if (of(child) != FileKind.audio) return false;
    final ext = extensionOf(child.title);
    return ext != null && extensions.contains(ext);
  }
}
