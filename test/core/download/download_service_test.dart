import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/core/download/models/download_entry.dart';
import 'package:xuro/data/models/files/child.dart';

void main() {
  Child mk({String? title, String? hash, String? url}) =>
      Child(title: title, hash: hash, mediaDownloadUrl: url);

  group('DownloadService.fileKey / diskFileName (pure, network-free)', () {
    test('hash takes precedence: same hash → same key (url/title differ)', () {
      expect(
        DownloadService.fileKey(mk(title: 'a.mp3', hash: 'H1', url: 'u1')),
        DownloadService.fileKey(mk(title: 'b.mp4', hash: 'H1', url: 'u2')),
      );
    });

    test('no hash: same title but different url → different key', () {
      expect(
        DownloadService.fileKey(mk(title: '01.mp3', url: 'https://x/1/01.mp3')),
        isNot(
          DownloadService.fileKey(mk(title: '01.mp3', url: 'https://x/2/01.mp3')),
        ),
      );
    });

    test('no hash: same url drives same key regardless of title', () {
      expect(
        DownloadService.fileKey(mk(title: '01.mp3', url: 'u')),
        DownloadService.fileKey(mk(title: 'zz.mp3', url: 'u')),
      );
    });

    test('diskFileName = sanitized original title (NOT a hash)', () {
      expect(
        DownloadService.diskFileName(mk(title: 'My Clip.mp4', hash: 'H')),
        'My Clip.mp4',
      );
    });

    test('diskFileName keeps no-extension title as-is', () {
      expect(
        DownloadService.diskFileName(mk(title: 'noext', hash: 'H')),
        'noext',
      );
    });

    test('diskFileName preserves CJK/Japanese title, sanitizes only FS-illegal',
        () {
      expect(
        DownloadService.diskFileName(mk(title: '【RJ01】① 耳かき.mp3', hash: 'H')),
        '【RJ01】① 耳かき.mp3',
      );
      expect(
        DownloadService.diskFileName(mk(title: 'そのまま/耳かき*.mp3', hash: 'H')),
        'そのまま_耳かき_.mp3',
      );
    });
  });

  group('DownloadService.sanitizeFileName (pure, network-free)', () {
    test('keeps safe chars, extension and spaces', () {
      expect(
        DownloadService.sanitizeFileName('My Video 01.mp4'),
        'My Video 01.mp4',
      );
    });

    test('replaces filesystem-unsafe chars with underscore', () {
      expect(
        DownloadService.sanitizeFileName('a/b\\c:d*e?.mkv'),
        'a_b_c_d_e_.mkv',
      );
    });

    test('falls back to "file" for an all-unsafe / empty name', () {
      expect(DownloadService.sanitizeFileName('//::'), 'file');
      expect(DownloadService.sanitizeFileName(''), 'file');
    });

    test('trims surrounding whitespace', () {
      expect(DownloadService.sanitizeFileName('  track.mp3  '), 'track.mp3');
    });

    test('preserves Unicode (Japanese/Chinese) letters', () {
      expect(
        DownloadService.sanitizeFileName('【RJ01】そのまま耳かき.mp3'),
        '【RJ01】そのまま耳かき.mp3',
      );
      expect(
        DownloadService.sanitizeFileName('音声/作品:01?.flac'),
        '音声_作品_01_.flac',
      );
    });

    test('strips trailing dots/spaces (FAT/Windows)', () {
      expect(DownloadService.sanitizeFileName('name. . '), 'name');
      expect(DownloadService.sanitizeFileName('...'), 'file');
    });

    test('clamps to <=180 UTF-8 bytes, keeps extension', () {
      final long = '${'あ' * 300}.mp3';
      final out = DownloadService.sanitizeFileName(long);
      expect(out.endsWith('.mp3'), isTrue);
      expect(utf8.encode(out).length <= 180, isTrue);
    });

    test('pathological long "extension" still clamped to <=180 bytes', () {
      final out = DownloadService.sanitizeFileName('name.${'x' * 400}');
      expect(utf8.encode(out).length <= 180, isTrue);
      expect(out.isNotEmpty, isTrue);
    });

    test('Windows reserved device names get an underscore prefix', () {
      expect(DownloadService.sanitizeFileName('CON.mp3'), '_CON.mp3');
      expect(DownloadService.sanitizeFileName('nul'), '_nul');
      expect(DownloadService.sanitizeFileName('Com1.flac'), '_Com1.flac');
      expect(DownloadService.sanitizeFileName('console.mp3'), 'console.mp3');
    });

    test('strips leading dots so it is not a hidden file', () {
      expect(DownloadService.sanitizeFileName('.hidden.txt'), 'hidden.txt');
      expect(DownloadService.sanitizeFileName('. . name.mp3'), 'name.mp3');
    });
  });

  group('DownloadService.pathsByFileKey (pure, no IO)', () {
    DownloadEntry mkEntry({
      required String workId,
      required String fileKey,
      required String filePath,
    }) =>
        DownloadEntry(
          workId: workId,
          fileKey: fileKey,
          fileName: 'name.mp3',
          filePath: filePath,
          mediaType: 'audio',
          sourceUrl: 'https://x/$fileKey',
          size: 1,
          createdAt: 0,
        );

    test('multiple rows map to fileKey -> filePath', () {
      final map = DownloadService.pathsByFileKey([
        mkEntry(workId: 'w1', fileKey: 'k1', filePath: '/p/a.mp3'),
        mkEntry(workId: 'w1', fileKey: 'k2', filePath: '/p/b.mp3'),
      ]);
      expect(map, {'k1': '/p/a.mp3', 'k2': '/p/b.mp3'});
    });

    test(
        'is workId-agnostic: caller must pre-filter (localPathsForWork does '
        'via listByWork) — rows from another work never leak in if excluded '
        'from the input list', () {
      // 模拟 localPathsForWork 已经用 listByWork(workId) 把行过滤到单个作品，
      // 这里只传入过滤后的子集，验证纯函数本身不做也不需要做二次过滤。
      final onlyWorkA = [
        mkEntry(workId: 'A', fileKey: 'kA', filePath: '/p/a.mp3'),
      ];
      final map = DownloadService.pathsByFileKey(onlyWorkA);
      expect(map, {'kA': '/p/a.mp3'});
      expect(map.containsKey('kB'), isFalse);
    });

    test('duplicate fileKey rows collapse idempotently (later row wins, '
        'mirrors DB UNIQUE(work_id, file_key))', () {
      final map = DownloadService.pathsByFileKey([
        mkEntry(workId: 'w1', fileKey: 'k1', filePath: '/old.mp3'),
        mkEntry(workId: 'w1', fileKey: 'k1', filePath: '/new.mp3'),
      ]);
      expect(map.length, 1);
      expect(map['k1'], '/new.mp3');
    });

    test('empty input -> empty map', () {
      expect(DownloadService.pathsByFileKey(const []), isEmpty);
    });
  });
}
