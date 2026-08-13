// playlist_builder_test.dart：覆盖 PlaylistBuilder 的纯函数 remapIndex，以及
// buildAudioSources 批量解析本地下载路径的「N 次查询收敛为 1 次」回归闸门。
//
// @author  Elvis Juan (thanhtran0606en@gmail.com)
// @created 2026-08-13

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:xuro/core/audio/utils/playlist_builder.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/data/models/files/child.dart';

void main() {
  group('PlaylistBuilder.remapIndex (pure, no IO)', () {
    test('exact hit: target track survived, keep its index', () {
      expect(PlaylistBuilder.remapIndex([0, 1, 2, 3], 2), 2);
    });

    test('target track dropped, survivors exist after it: snap to next survivor', () {
      // 原始 3 号轨被丢弃，队列里存活的是 [0,1,2,4]；退化取"排在 3 之后
      // 第一个仍存活的原始下标" 4，对应队列内下标 3。
      expect(PlaylistBuilder.remapIndex([0, 1, 2, 4], 3), 3);
    });

    test('tracks before target dropped, target itself survives: exact hit at shifted index', () {
      // 原始 0/1 号轨被丢弃，2 号轨（目标）存活在队列下标 0。
      expect(PlaylistBuilder.remapIndex([2, 3, 4], 2), 0);
    });

    test('target and everything after it dropped: degrade to 0', () {
      expect(PlaylistBuilder.remapIndex([0, 1], 5), 0);
    });

    test('all tracks dropped: degrade to 0 without throwing', () {
      expect(PlaylistBuilder.remapIndex(const [], 0), 0);
    });
  });

  group('PlaylistBuilder.buildAudioSources N->1 batch resolve', () {
    Child mkFile(int i) => Child(
          title: 'track$i.mp3',
          hash: 'hash$i',
          mediaDownloadUrl: 'https://example.com/$i.mp3',
        );

    test('50 files with workId: resolveLocalPaths is called exactly once, '
        'all resolve to local Uri.file sources', () async {
      final files = List.generate(50, mkFile);
      final localPaths = {
        for (final f in files) DownloadService.fileKey(f): '/local/${f.title}',
      };

      var callCount = 0;
      final (sources, originalIndices) = await PlaylistBuilder.buildAudioSources(
        files,
        workId: 'work-1',
        resolveLocalPaths: (workId) async {
          callCount++;
          expect(workId, 'work-1');
          return localPaths;
        },
      );

      // 回归闸门：不管播放列表有多少轨，本地下载路径的批量解析函数只应
      // 被调用一次——这正是本轮把"循环内逐轨查询"收敛成"循环外一次查询"
      // 要守住的行为。
      expect(callCount, 1);
      expect(sources.length, 50);
      expect(originalIndices, List.generate(50, (i) => i));
      for (var i = 0; i < sources.length; i++) {
        final source = sources[i] as UriAudioSource;
        expect(source.uri.scheme, 'file');
        expect(source.uri.toFilePath(), '/local/${files[i].title}');
      }
    });

    test('files without a local match still get a source via the network '
        'fallback path (title==null skips the lookup instead of colliding '
        'on the degenerate fileKey)', () async {
      final withTitle = mkFile(0);
      final noTitle = Child(mediaDownloadUrl: 'https://example.com/no-title.mp3');
      final files = [withTitle, noTitle];

      final (sources, originalIndices) = await PlaylistBuilder.buildAudioSources(
        files,
        workId: 'work-1',
        // 刻意让这个 fake 对任何 key（包括退化的 md5('file')）都命中，
        // 验证 noTitle 文件因为 title==null 被短路、根本不会去查表。
        resolveLocalPaths: (_) async => {
          DownloadService.fileKey(withTitle): '/local/hit.mp3',
          DownloadService.fileKey(noTitle): '/local/should-not-be-used.mp3',
        },
      );

      expect(originalIndices, [0, 1]);
      expect((sources[0] as UriAudioSource).uri.toFilePath(), '/local/hit.mp3');
      // noTitle 没走本地命中，只能落到 AudioCacheManager.createAudioSource
      // 的降级分支（真实环境里会做磁盘 IO，这里平台通道不可用会抛出，
      // createAudioSource 自身兜底为 ProgressiveAudioSource 指回原始 URL）。
      final fallback = sources[1] as UriAudioSource;
      expect(fallback.uri.toString(), noTitle.mediaDownloadUrl);
    });

    test('no workId: resolver is never invoked', () async {
      final files = [mkFile(0), mkFile(1)];
      var callCount = 0;
      await PlaylistBuilder.buildAudioSources(
        files,
        resolveLocalPaths: (_) async {
          callCount++;
          return const {};
        },
      );
      expect(callCount, 0);
    });
  });
}
