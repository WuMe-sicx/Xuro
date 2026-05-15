import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/core/audio/cache/audio_cache_manager.dart';
import 'package:xuro/utils/logger.dart';

class PlaylistBuilder {
  /// Build audio sources with per-item error handling.
  /// Returns a record of (sources, originalIndices) to maintain index mapping.
  ///
  /// 若提供 [workId] 且该文件已有完整本地下载，则直接用本地文件源（离线可放），
  /// 否则回退到原有的 `LockCachingAudioSource` 流式+缓存路径。
  static Future<(List<AudioSource>, List<int>)> buildAudioSources(
    List<Child> files, {
    String? workId,
  }) async {
    final sources = <AudioSource>[];
    final originalIndices = <int>[];
    // 用 GetIt.I 直取（与 audio_player_service 中 GetIt.I<ISubtitleService>()
    // 同一模式），避免 import service_locator 造成 core/audio↔core/di 文件环。
    final downloadService =
        workId != null ? GetIt.I<DownloadService>() : null;

    for (var i = 0; i < files.length; i++) {
      try {
        AudioSource? source;
        if (downloadService != null) {
          final localPath =
              await downloadService.localPathIfDownloaded(workId!, files[i]);
          if (localPath != null) {
            source = AudioSource.uri(Uri.file(localPath));
          }
        }
        source ??= await AudioCacheManager.createAudioSource(
          files[i].mediaDownloadUrl!,
          hash: files[i].hash,
        );
        sources.add(source);
        originalIndices.add(i);
      } catch (e) {
        AppLogger.error('创建音频源失败,跳过: ${files[i].title}', e);
      }
    }
    return (sources, originalIndices);
  }

  static Future<void> updatePlaylist(
    ConcatenatingAudioSource playlist,
    List<AudioSource> sources,
  ) async {
    await playlist.clear();
    await playlist.addAll(sources);
  }

  /// Returns the list of files that were successfully loaded (matching the player queue order).
  static Future<List<Child>> setPlaylistSource({
    required AudioPlayer player,
    required ConcatenatingAudioSource playlist,
    required List<Child> files,
    required int initialIndex,
    required Duration initialPosition,
    String? workId,
  }) async {
    final (sources, originalIndices) =
        await buildAudioSources(files, workId: workId);

    // Guard: empty playlist
    if (sources.isEmpty) {
      AppLogger.error('所有音频源创建失败,无法播放');
      throw Exception('无可用的音频源');
    }

    await updatePlaylist(playlist, sources);

    // Build filtered files list matching actual player queue
    final loadedFiles = originalIndices.map((i) => files[i]).toList();

    // Remap initialIndex: find the new index corresponding to the original
    var remappedIndex = originalIndices.indexOf(initialIndex);
    if (remappedIndex < 0) {
      // Original track failed to load, use closest available
      remappedIndex = 0;
      for (var i = 0; i < originalIndices.length; i++) {
        if (originalIndices[i] >= initialIndex) {
          remappedIndex = i;
          break;
        }
      }
      AppLogger.warning('原始索引 $initialIndex 不可用,使用替代索引 $remappedIndex');
    }

    await player.setAudioSource(
      playlist,
      initialIndex: remappedIndex,
      initialPosition: initialPosition,
    );

    return loadedFiles;
  }
}
