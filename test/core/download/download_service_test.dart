import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/download/download_service.dart';
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

    test('diskFileName = fileKey + original extension', () {
      final f = mk(title: 'My Clip.mp4', hash: 'H');
      expect(
        DownloadService.diskFileName(f),
        '${DownloadService.fileKey(f)}.mp4',
      );
    });

    test('diskFileName has no extension when title has none', () {
      final f = mk(title: 'noext', hash: 'H');
      expect(DownloadService.diskFileName(f), DownloadService.fileKey(f));
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
  });
}
