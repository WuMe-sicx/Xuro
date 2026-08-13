/// playback_context_test.dart：播放列表推导与可播格式闸门。
///
/// 这个纯工厂此前零覆盖，而「.flac 点了报播放列表为空」的 bug 正住在这里——
/// 它是纯数据入参、无 DI，本来一直可测。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/audio/models/playback_context.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/data/models/files/files.dart';
import 'package:xuro/data/models/works/work.dart';

Child _audio(String title) =>
    Child(type: 'audio', title: title, mediaDownloadUrl: 'https://x/$title');

Child _folder(String title, List<Child> children) =>
    Child(type: 'folder', title: title, children: children);

Files _root(List<Child> children) =>
    Files(type: 'root', title: 'Root', children: children);

final _work = Work(id: 1, title: 'RJ000001');

PlaybackContext _ctx(Files files, Child current) =>
    PlaybackContext(work: _work, files: files, currentFile: current);

void main() {
  group('可播格式闸门', () {
    test('六种格式全部可以组出播放列表', () {
      for (final ext in ['mp3', 'flac', 'wav', 'opus', 'm4a', 'aac']) {
        final f = _audio('01.$ext');
        final ctx = _ctx(_root([f]), f);
        expect(ctx.playlist, hasLength(1), reason: ext);
        expect(ctx.currentIndex, 0, reason: ext);
      }
    });

    test('flac 不再落空——这是本次修复的那条', () {
      // 修复前：闸门写死 mp3/wav，.flac 在这里返回 []，
      // validate() 抛「播放列表为空」，用户只看到「播放失败」。
      final f = _audio('01.flac');
      expect(_ctx(_root([f]), f).playlist, isNotEmpty);
    });

    test('未知扩展名仍然落空', () {
      final f = _audio('01.ape');
      expect(_ctx(_root([f]), f).playlist, isEmpty);
    });

    test('无扩展名落空，不把整个文件名当扩展名', () {
      final f = _audio('mp3');
      expect(_ctx(_root([f]), f).playlist, isEmpty);
    });

    test('视频扩展名落空——错标成 type:audio 也不行', () {
      final f = Child(
          type: 'audio',
          title: '介绍视频.mp4',
          mediaDownloadUrl: 'https://x/v');
      expect(_ctx(_root([f]), f).playlist, isEmpty);
    });
  });

  group('同扩展名分组', () {
    // asmr.one 大量作品把同一套音频同时下发两种格式放在同一目录，
    // 合并成一个队列会让每首曲子连放两遍——所以只收同扩展名。
    final mixed = [
      _audio('01.mp3'),
      _audio('01.flac'),
      _audio('02.mp3'),
      _audio('02.flac'),
    ];

    test('点 flac 只得到 flac', () {
      final ctx = _ctx(_root(mixed), mixed[1]);
      expect(ctx.playlist.map((f) => f.title), ['01.flac', '02.flac']);
      expect(ctx.currentIndex, 0);
    });

    test('点 mp3 只得到 mp3', () {
      final ctx = _ctx(_root(mixed), mixed[2]);
      expect(ctx.playlist.map((f) => f.title), ['01.mp3', '02.mp3']);
      expect(ctx.currentIndex, 1);
    });

    test('大小写不影响分组', () {
      final files = [_audio('01.MP3'), _audio('02.mp3')];
      expect(_ctx(_root(files), files[0]).playlist, hasLength(2));
    });
  });

  group('目录范围', () {
    test('只收同级，不跨目录', () {
      final inner = _audio('01.mp3');
      final outer = _audio('99.mp3');
      final files = _root([
        outer,
        _folder('第一章', [inner, _audio('02.mp3')]),
      ]);
      final ctx = _ctx(files, inner);
      expect(ctx.playlist.map((f) => f.title), ['01.mp3', '02.mp3']);
      expect(ctx.playlist.any((f) => f.title == '99.mp3'), isFalse);
    });

    test('文件夹类型大小写不敏感——API 下发 "Folder" 也能穿过去', () {
      final inner = _audio('01.mp3');
      final files = _root([
        Child(type: 'Folder', title: '第一章', children: [inner]),
      ]);
      expect(_ctx(files, inner).playlist, hasLength(1));
    });
  });

  group('copyWithFile 不得重新推导播放列表', () {
    // 这一组是回归闸门。修复前 copyWithFile 走公开工厂重新推导，
    // PlaybackController 刚用 fromQueue 建立的过滤列表会在七行后
    // 被碾平；而 just_audio 队列仍是过滤后的，队列下标去索引更长的列表 →
    // 取到错位的 Child → 锁屏标题/字幕/持久化 currentFile 全错。
    final all = [_audio('01.mp3'), _audio('02.mp3'), _audio('03.mp3')];
    final files = _root(all);

    PlaybackContext filtered() => PlaybackContext.fromQueue(
          work: _work,
          files: files,
          // 02 音源构造失败被丢弃，队列只剩 [01, 03]
          playlist: [all[0], all[2]],
          currentIndex: 0,
        );

    test('过滤后的列表在切曲后必须存活', () {
      final next = filtered().copyWithFile(all[2]);
      expect(next.playlist.map((f) => f.title), ['01.mp3', '03.mp3']);
      expect(next.playlist, hasLength(2),
          reason: '被丢弃的 02.mp3 不得从完整文件树里回流');
    });

    test('游标落在过滤后列表的正确位置', () {
      final next = filtered().copyWithFile(all[2]);
      // 队列里 03 是第 1 项；若列表被还原成三项，这里会错成 2
      expect(next.currentIndex, 1);
      expect(next.currentFile.title, '03.mp3');
    });

    test('未过滤的上下文切曲后行为不变', () {
      final ctx = _ctx(files, all[0]);
      final next = ctx.copyWithFile(all[1]);
      expect(next.playlist.map((f) => f.title),
          ['01.mp3', '02.mp3', '03.mp3']);
      expect(next.currentIndex, 1);
    });

    test('目标不在列表中时保留原游标，不回退到 0', () {
      final ctx = filtered().copyWithFile(all[2]); // index 1
      final stray = ctx.copyWithFile(_audio('99.mp3'));
      expect(stray.currentIndex, 1);
      expect(stray.playlist, hasLength(2));
    });

    test('playMode 与源数据穿过切曲保持不变', () {
      final next = filtered().copyWithFile(all[2]);
      expect(next.work, _work);
      expect(next.files, files);
      expect(next.playMode, filtered().playMode);
    });
  });

  group('fromQueue —— 队列是权威', () {
    final all = [_audio('01.mp3'), _audio('02.mp3'), _audio('03.mp3')];

    test('原样采纳队列内容，不碰文件树', () {
      final ctx = PlaybackContext.fromQueue(
        work: _work,
        files: _root(all),
        playlist: [all[1]],
        currentIndex: 0,
      );
      expect(ctx.playlist, hasLength(1));
      expect(ctx.currentIndex, 0);
      expect(ctx.currentFile.title, '02.mp3');
    });

    test('currentFile 由队列下标推出，不按 title 反查', () {
      // 目标轨构造失败时播放器停在 remapIndex 给的槽位（原下标之后第一个
      // 存活的轨），不是 0。此前把 currentFile 猜成 loadedFiles.first，
      // 于是锁屏标题/字幕/持久化的 currentFile 全错。
      final ctx = PlaybackContext.fromQueue(
        work: _work,
        files: _root(all),
        playlist: [all[0], all[2]], // 02 被丢弃
        currentIndex: 1, // 播放器实际停在 03
      );
      expect(ctx.currentFile.title, '03.mp3');
      expect(ctx.currentIndex, 1);
    });

    test('同名文件不再有歧义——下标精确，title 反查会取到第一个', () {
      final dup = [_audio('01.mp3'), _audio('01.mp3')];
      final ctx = PlaybackContext.fromQueue(
        work: _work,
        files: _root(dup),
        playlist: dup,
        currentIndex: 1,
      );
      expect(ctx.currentIndex, 1);
      expect(identical(ctx.currentFile, dup[1]), isTrue);
    });

    test('越界下标 clamp 进范围', () {
      final ctx = PlaybackContext.fromQueue(
        work: _work,
        files: _root(all),
        playlist: [all[0], all[1]],
        currentIndex: 9,
      );
      expect(ctx.currentIndex, 1);
      expect(ctx.currentFile.title, '02.mp3');
    });
  });

  group('validate', () {
    test('空播放列表抛错', () {
      final f = _audio('01.ape');
      expect(() => _ctx(_root([f]), f).validate(), throwsA(anything));
    });

    test('正常上下文不抛', () {
      final f = _audio('01.flac');
      expect(() => _ctx(_root([f]), f).validate(), returnsNormally);
    });
  });
}
