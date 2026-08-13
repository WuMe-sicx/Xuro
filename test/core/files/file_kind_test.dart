/// file_kind_test.dart：文件种类判定的规则级测试。
///
/// 断言的是规则本身，不是某个调用点——此前这套规则散在 43 个判定点里，
/// 只有 `detail_viewmodel_collect_test.dart` 间接钉住了其中一条。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/files/file_kind.dart';
import 'package:xuro/data/models/files/child.dart';

Child _c({String? type, String? title}) => Child(type: type, title: title);

void main() {
  group('extensionOf', () {
    test('取最后一个点之后的部分并转小写', () {
      expect(FileKinds.extensionOf('01.MP3'), 'mp3');
      expect(FileKinds.extensionOf('a.b.vtt'), 'vtt');
    });

    test('无点号返回 null——不能把整个文件名当扩展名', () {
      // 旧写法 split('.').last 会让名叫 `mp3` 的文件被判成音频，
      // 而按 endsWith('.mp3') 判定的兄弟代码不会。
      expect(FileKinds.extensionOf('mp3'), isNull);
      expect(FileKinds.extensionOf('README'), isNull);
    });

    test('点号结尾、null 返回 null', () {
      expect(FileKinds.extensionOf('trailing.'), isNull);
      expect(FileKinds.extensionOf(null), isNull);
    });
  });

  group('isFolder 大小写不敏感', () {
    test('folder / Folder / FOLDER 都算', () {
      for (final t in ['folder', 'Folder', 'FOLDER']) {
        expect(FileKinds.isFolder(_c(type: t, title: '第一章')), isTrue,
            reason: t);
      }
    });

    test('type 为空不算文件夹', () {
      expect(FileKinds.isFolder(_c(title: '第一章')), isFalse);
    });
  });

  group('of —— 扩展名压过 API type', () {
    test('被错标成 audio 的 .mp4 判为视频（这是整条规则存在的理由）', () {
      final child = _c(type: 'audio', title: 'ver2.0免费更新！_介绍视频.mp4');
      expect(FileKinds.of(child), FileKind.video);
      expect(FileKinds.isAudio(child), isFalse);
    });

    test('全部已知视频扩展名都压过 type:audio', () {
      for (final ext in FileKinds.videoExtensions) {
        expect(FileKinds.of(_c(type: 'audio', title: 'x.$ext')), FileKind.video,
            reason: ext);
      }
    });

    test('m4a 是音频，不因为长得像 m4v 就被当视频', () {
      expect(FileKinds.of(_c(type: 'audio', title: 'x.m4a')), FileKind.audio);
    });

    test('type:video 即便扩展名未知也判为视频', () {
      expect(FileKinds.of(_c(type: 'video', title: 'x.rmvb')), FileKind.video);
    });
  });

  group('of —— 优先级与边界', () {
    test('文件夹优先于一切', () {
      expect(FileKinds.of(_c(type: 'folder', title: '花絮.mp4')), FileKind.folder);
    });

    test('type:audio 且非视频扩展名 → 音频', () {
      for (final ext in ['mp3', 'flac', 'wav', 'opus', 'aac']) {
        expect(FileKinds.of(_c(type: 'audio', title: '01.$ext')), FileKind.audio,
            reason: ext);
      }
    });

    test('.mp3 但 type 为空 → other，不是音频', () {
      // 保留既有行为：判定音频要求 type=='audio'。此处单独钉住，是因为
      // 文件夹自动展开那条路径只看扩展名，两者对同一文件答案不同。
      expect(FileKinds.of(_c(title: '01.mp3')), FileKind.other);
    });

    test('字幕扩展名且非音视频 → 字幕', () {
      for (final ext in FileKinds.previewableSubtitleExtensions) {
        expect(FileKinds.of(_c(type: 'text', title: '01.$ext')),
            FileKind.subtitle,
            reason: ext);
      }
    });

    test('type:audio 的 .txt 判为音频——type 只被视频扩展名压过', () {
      expect(FileKinds.of(_c(type: 'audio', title: '01.txt')), FileKind.audio);
    });

    test('未知扩展名、无标题 → other', () {
      expect(FileKinds.of(_c(type: 'image', title: 'cover.jpg')),
          FileKind.other);
      expect(FileKinds.of(_c(type: 'text')), FileKind.other);
    });
  });

  group('两套字幕定义必须保持不同', () {
    test('srt/txt 可预览，但不可自动配对', () {
      for (final ext in ['srt', 'txt']) {
        final child = _c(type: 'text', title: '01.$ext');
        expect(FileKinds.isPreviewableSubtitle(child), isTrue, reason: ext);
        expect(FileKinds.isPairableSubtitle(child), isFalse, reason: ext);
      }
    });

    test('vtt/lrc 两者皆可', () {
      for (final ext in ['vtt', 'lrc']) {
        final child = _c(type: 'text', title: '01.$ext');
        expect(FileKinds.isPreviewableSubtitle(child), isTrue, reason: ext);
        expect(FileKinds.isPairableSubtitle(child), isTrue, reason: ext);
      }
    });

    test('可配对集合是可预览集合的真子集', () {
      expect(
        FileKinds.pairableSubtitleExtensions
            .difference(FileKinds.previewableSubtitleExtensions),
        isEmpty,
      );
      expect(
        FileKinds.previewableSubtitleExtensions.length >
            FileKinds.pairableSubtitleExtensions.length,
        isTrue,
      );
    });

    test('按名判定接受大小写与无扩展名', () {
      expect(FileKinds.isPairableSubtitleName('01.VTT'), isTrue);
      expect(FileKinds.isPairableSubtitleName('vtt'), isFalse);
      expect(FileKinds.isPairableSubtitleName(null), isFalse);
    });
  });

  group('isPlayable', () {
    test('默认表接受六种格式', () {
      for (final ext in FileKinds.defaultPlayableExtensions) {
        expect(FileKinds.isPlayable(_c(type: 'audio', title: '01.$ext')), isTrue,
            reason: ext);
      }
    });

    test('非音频一律不可播——错标的 .mp4 不会溜进播放管线', () {
      expect(FileKinds.isPlayable(_c(type: 'audio', title: 'x.mp4')), isFalse);
      expect(FileKinds.isPlayable(_c(type: 'text', title: 'x.vtt')), isFalse);
      expect(FileKinds.isPlayable(_c(type: 'folder', title: 'x')), isFalse);
    });

    test('可用调用方传入的格式表收窄', () {
      final child = _c(type: 'audio', title: '01.flac');
      expect(FileKinds.isPlayable(child), isTrue);
      expect(FileKinds.isPlayable(child, extensions: const {'mp3', 'wav'}),
          isFalse);
    });

    test('未知扩展名的音频不可播', () {
      expect(FileKinds.isPlayable(_c(type: 'audio', title: '01.ape')), isFalse);
      expect(FileKinds.isPlayable(_c(type: 'audio', title: 'noext')), isFalse);
    });
  });
}
