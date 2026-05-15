import 'package:xuro/data/models/playlists_with_exist_statu/pagination.dart';
import 'package:xuro/data/models/playlists_with_exist_statu/playlist.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:xuro/data/models/files/files.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/core/audio/i_audio_player_service.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/core/audio/models/playback_context.dart';
import 'package:xuro/widgets/detail/playlist_selection_dialog.dart';
import 'package:xuro/data/models/mark_status.dart';
import 'package:xuro/widgets/detail/mark_selection_dialog.dart';
import 'package:xuro/data/models/works/work_info.dart';
import 'package:xuro/widgets/detail/work_folder_item.dart';
import 'package:xuro/core/audio/models/file_path.dart';
import 'package:xuro/core/subtitle/utils/subtitle_matcher.dart';
import 'package:dio/dio.dart';

/// 一条批量下载项：音频 + 同目录匹配到的字幕（可空）。
typedef DownloadPair = ({Child audio, Child? subtitle});

/// 批量下载结果汇总。
class BatchDownloadOutcome {
  final int ok;
  final int skipped;
  final int failed;
  final bool cancelled;
  const BatchDownloadOutcome({
    required this.ok,
    required this.skipped,
    required this.failed,
    required this.cancelled,
  });
}

class DetailViewModel extends ChangeNotifier {
  late final ApiService _apiService;
  late final IAudioPlayerService _audioService;
  late final DownloadService _downloadService;
  final Work work;

  static const _videoExtensions = {'mp4', 'mkv', 'mov', 'avi', 'webm', 'm4v'};

  Files? _files;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  WorkInfo? _workInfo;
  bool _isLoadingInfo = false;

  bool _hasRecommendations = false;
  bool _checkingRecommendations = false;

  // 收藏夹相关状态
  bool _loadingPlaylists = false;
  String? _playlistsError;
  List<Playlist>? _playlists;
  Pagination? _playlistsPagination;

  bool _loadingFavorite = false;
  bool get loadingFavorite => _loadingFavorite;

  MarkStatus? _currentMarkStatus;
  MarkStatus? get currentMarkStatus => _currentMarkStatus;

  bool _loadingMark = false;
  bool get loadingMark => _loadingMark;

  // 添加取消标记
  final _cancelToken = CancelToken();

  DetailViewModel({
    required this.work,
  }) {
    _audioService = GetIt.I<IAudioPlayerService>();
    _apiService = GetIt.I<ApiService>();
    _downloadService = GetIt.I<DownloadService>();
    _checkRecommendations();
  }

  Files? get files => _files;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRecommendations => _hasRecommendations;
  bool get checkingRecommendations => _checkingRecommendations;
  WorkInfo? get workInfo => _workInfo;
  bool get isLoadingInfo => _isLoadingInfo;

  // 收藏夹相关 getters
  bool get loadingPlaylists => _loadingPlaylists;
  String? get playlistsError => _playlistsError;
  List<Playlist>? get playlists => _playlists;
  int? get playlistsTotalPages => 
      _playlistsPagination?.totalCount != null && _playlistsPagination?.pageSize != null
          ? (_playlistsPagination!.totalCount! / _playlistsPagination!.pageSize!).ceil()
          : null;

  Future<void> _checkRecommendations() async {
    _checkingRecommendations = true;
    notifyListeners();

    try {
      final response = await _apiService.getItemNeighbors(
        itemId: work.id.toString(),
        page: 1,
      );
      _hasRecommendations = (response.pagination.totalCount ?? 0) > 0;
    } catch (e) {
      AppLogger.error('检查相关推荐失败', e);
      _hasRecommendations = false;
    } finally {
      if (!_disposed) {
        _checkingRecommendations = false;
        notifyListeners();
      }
    }
  }

  /// Batch-load files and work info with minimal notifyListeners calls.
  /// Called once from the screen instead of separate loadFiles + loadWorkInfo.
  Future<void> loadInitialData() async {
    _isLoading = true;
    _isLoadingInfo = true;
    _error = null;
    notifyListeners(); // Single notify for "loading started"

    // Run both fetches concurrently
    await Future.wait([
      _loadFilesInternal(),
      _loadWorkInfoInternal(),
    ]);

    if (!_disposed) {
      notifyListeners(); // Single notify for "loading complete"
    }
  }

  Future<void> _loadFilesInternal() async {
    try {
      AppLogger.info('开始加载作品文件: ${work.id}');
      _files = await _apiService.getWorkFiles(
        work.id.toString(),
        cancelToken: _cancelToken,
      );
      WorkFolderItem.resetExpandState(); // Reset on new data load, not on every build
      AppLogger.info('文件加载成功: ${work.id}');
    } catch (e) {
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        AppLogger.info('加载文件失败');
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _loadWorkInfoInternal() async {
    try {
      final workId = _extractNumericId(work.sourceId) ?? work.id.toString();
      _workInfo = await _apiService.getWorkInfo(workId, cancelToken: _cancelToken);
      AppLogger.info('作品详情加载成功: ${work.id}');
    } catch (e) {
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        AppLogger.error('加载作品详情失败', e);
      }
    } finally {
      _isLoadingInfo = false;
    }
  }

  Future<void> loadWorkInfo() async {
    if (_isLoadingInfo) return;
    _isLoadingInfo = true;
    notifyListeners();
    await _loadWorkInfoInternal();
    if (!_disposed) notifyListeners();
  }

  Future<void> loadFiles() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _loadFilesInternal();
    if (!_disposed) notifyListeners();
  }

  /// 扩展名是否属已知视频集。**比 API `type` 更可靠**：asmr.one 实测会把
  /// "介绍视频.mp4"等下发成 `type:"audio"`，若信 `type` 会被当音频送进
  /// 播放管线、播放列表按扩展名过滤后为空 → "播放列表为空/播放失败"。
  static bool _hasVideoExtension(String? title) {
    final ext = title?.split('.').last.toLowerCase();
    return ext != null && _videoExtensions.contains(ext);
  }

  /// 该文件是否为视频（`type==video` 或视频扩展名）。视频不直接判为
  /// "无法打开"，而是引导下载到本地用外部查看器播放（见 detail_screen）。
  bool isVideoFile(Child file) =>
      (file.type ?? '').toLowerCase() == 'video' ||
      _hasVideoExtension(file.title);

  /// 静态纯判定：是音频且**不是**视频扩展名。视频扩展名优先于不可靠的
  /// API `type`，否则错标 `type:audio` 的 .mp4 会被当音频。
  static bool _isAudioChild(Child c) =>
      (c.type ?? '').toLowerCase() == 'audio' &&
      !_hasVideoExtension(c.title);

  bool isAudioFile(Child file) => _isAudioChild(file);

  static const _subtitleExtensions = {'vtt', 'lrc', 'srt', 'txt'};

  /// 该文件是否为可预览字幕（.vtt/.lrc/.srt/.txt）。
  bool isSubtitleFile(Child file) {
    final ext = file.title?.split('.').last.toLowerCase();
    return ext != null && _subtitleExtensions.contains(ext);
  }

  /// 纯函数：递归收集子树下所有音频，并就近（同目录同级）配对字幕。
  /// 字幕匹配只在该音频所在目录的兄弟节点中找（与 [SubtitleLoader]
  /// `findSubtitleFile` 的 `getSiblings` 语义一致）。
  static List<DownloadPair> collectAudioWithSubtitles(List<Child>? children) {
    final out = <DownloadPair>[];
    if (children == null) return out;
    for (final c in children) {
      if ((c.type ?? '').toLowerCase() == 'folder') {
        out.addAll(collectAudioWithSubtitles(c.children));
      } else if (_isAudioChild(c)) {
        final sub = c.title != null
            ? SubtitleMatcher.findMatchingSubtitle(c.title!, children)
            : null;
        out.add((audio: c, subtitle: sub));
      }
    }
    return out;
  }

  List<Child>? _nodeChildren(Child? folder) =>
      folder == null ? _files?.children : folder.children;

  /// 该节点（null=整部作品）子树下可下载音频数。
  int batchAudioCount(Child? folder) =>
      collectAudioWithSubtitles(_nodeChildren(folder)).length;

  /// 单个音频下载：下完音频后顺带把同目录匹配字幕也下了（best-effort，
  /// 字幕失败/无字幕都不影响音频结果）。UI 负责确认弹窗与进度展示。
  /// 视频文件无字幕配对，行为与原先一致。
  Future<DownloadResult> downloadFile(
    Child file, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final result = await _downloadService.download(
      workId: work.id.toString(),
      file: file,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    if (result.isPlayable &&
        isAudioFile(file) &&
        !(cancelToken?.isCancelled ?? false)) {
      final sub = _matchedSubtitle(file);
      if (sub != null) {
        try {
          await _downloadService.download(
            workId: work.id.toString(),
            file: sub,
            cancelToken: cancelToken,
          );
        } catch (e) {
          AppLogger.warning('配对字幕下载失败（不影响音频）: $e');
        }
      }
    }
    return result;
  }

  Child? _matchedSubtitle(Child audio) {
    if (_files == null || audio.title == null) return null;
    final siblings = FilePath.getSiblings(audio, _files!);
    return SubtitleMatcher.findMatchingSubtitle(audio.title!, siblings);
  }

  /// 顺序批量下载 [folder]（null=整部作品）子树下所有音频 + 匹配字幕。
  /// 幂等去重由 `DownloadService.download` 保证；字幕 best-effort。
  /// [onProgress]：(已处理序号 1-based, 总数, 当前音频名, 当前文件进度 0~1)。
  Future<BatchDownloadOutcome> downloadFolder({
    Child? folder,
    required void Function(int index, int total, String name, double progress)
        onProgress,
    CancelToken? cancelToken,
  }) async {
    final items = collectAudioWithSubtitles(_nodeChildren(folder));
    var ok = 0, skipped = 0, failed = 0;
    var cancelled = false;
    for (var i = 0; i < items.length; i++) {
      if (cancelToken?.isCancelled ?? false) {
        cancelled = true;
        break;
      }
      final audio = items[i].audio;
      final sub = items[i].subtitle;
      final name = audio.title ?? '';
      onProgress(i + 1, items.length, name, 0);
      final r = await _downloadService.download(
        workId: work.id.toString(),
        file: audio,
        cancelToken: cancelToken,
        onProgress: (p) => onProgress(i + 1, items.length, name, p),
      );
      switch (r.status) {
        case DownloadStatus.success:
          ok++;
        case DownloadStatus.alreadyExists:
          skipped++;
        case DownloadStatus.cancelled:
          cancelled = true;
        case DownloadStatus.networkError:
        case DownloadStatus.ioError:
          failed++;
      }
      if (cancelled) break;
      if (sub != null && !(cancelToken?.isCancelled ?? false)) {
        try {
          final sr = await _downloadService.download(
            workId: work.id.toString(),
            file: sub,
            cancelToken: cancelToken,
          );
          // 字幕下载被取消也要让整批标记 cancelled（否则末项音频带
          // 字幕、用户在字幕阶段取消时，循环自然结束会误报"完成"）。
          if (sr.status == DownloadStatus.cancelled) {
            cancelled = true;
            break;
          }
          // 字幕网络/IO 失败属 best-effort，仅记日志、不计入 failed。
        } catch (e) {
          AppLogger.warning('配对字幕下载失败（不影响音频）: $e');
        }
      }
      // 末项之后无循环顶部检查，这里兜底捕获取消。
      if (cancelToken?.isCancelled ?? false) {
        cancelled = true;
        break;
      }
    }
    return BatchDownloadOutcome(
      ok: ok,
      skipped: skipped,
      failed: failed,
      cancelled: cancelled,
    );
  }

  Future<void> playFile(Child file, BuildContext context) async {
    // 用统一分类：错标 type=audio 的视频在这里被挡下，给清晰错误，
    // 而不是放进播放管线产生"播放列表为空"的误导性失败。
    if (!isAudioFile(file)) {
      throw Exception('不支持的文件类型（疑似视频）: ${file.title}');
    }

    if (file.mediaDownloadUrl == null) {
      throw Exception('无法播放：文件URL不存在');
    }

    if (_files == null) {
      throw Exception('文件列表未加载');
    }

    try {
      final playbackContext = PlaybackContext(
        work: work,
        files: _files!,
        currentFile: file,
      );

      await _audioService.playWithContext(playbackContext);
    } catch (e) {
      if (!_disposed) {
        AppLogger.error('播放失败', e);
      }
      rethrow;
    }
  }

  /// 加载收藏夹列表
  Future<void> loadPlaylists({int page = 1}) async {
    if (_loadingPlaylists) return;

    _loadingPlaylists = true;
    _playlistsError = null;
    notifyListeners();

    try {
      final response = await _apiService.getWorkExistStatusInPlaylists(
        workId: work.id.toString(),
        page: page,
      );
      
      _playlists = response.playlists;
      _playlistsPagination = response.pagination;
      AppLogger.info('收藏夹列表加载成功: ${_playlists?.length ?? 0}个收藏夹');
    } catch (e) {
      AppLogger.error('加载收藏夹列表失败', e);
      _playlistsError = e.toString();
    } finally {
      _loadingPlaylists = false;
      notifyListeners();
    }
  }

  Future<void> showPlaylistsDialog(BuildContext context) async {
    _loadingFavorite = true;
    notifyListeners();
    
    try {
      await loadPlaylists();
      _loadingFavorite = false;
      notifyListeners();
      
      if (!context.mounted) return;
      
      await showDialog(
        context: context,
        builder: (context) => PlaylistSelectionDialog(
          playlists: playlists,
          isLoading: loadingPlaylists,
          error: playlistsError,
          onRetry: () => loadPlaylists(),
          onPlaylistTap: (playlist) async {
            try {
              await togglePlaylistWork(playlist);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('操作失败: $e')),
                );
              }
            }
          },
        ),
      );
    } catch (e) {
      _loadingFavorite = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> togglePlaylistWork(Playlist playlist) async {
    try {
      if (playlist.exist ?? false) {
        await _apiService.removeWorkFromPlaylist(
          playlistId: playlist.id!,
          workId: work.id.toString(),
        );
      } else {
        await _apiService.addWorkToPlaylist(
          playlistId: playlist.id!,
          workId: work.id.toString(),
        );
      }
      
      // 更新本地收藏夹状态
      final index = _playlists?.indexWhere((p) => p.id == playlist.id);
      if (index != null && index != -1) {
        _playlists = List<Playlist>.from(_playlists!)
          ..[index] = playlist.copyWith(exist: !(playlist.exist ?? false));
        notifyListeners();
      }
      
      final action = (playlist.exist ?? false) ? '移除' : '添加';
      AppLogger.info('$action收藏成功: ${playlist.name}');
    } catch (e) {
      AppLogger.error('切换收藏状态失败', e);
      rethrow;
    }
  }

  Future<void> updateMarkStatus(MarkStatus status) async {
    _loadingMark = true;
    notifyListeners();

    try {
      await _apiService.updateWorkMarkStatus(
        work.id.toString(),
        _apiService.convertMarkStatusToApi(status),
      );
      
      _currentMarkStatus = status;
      AppLogger.info('更新标记状态成功: ${status.label}');
    } catch (e) {
      AppLogger.error('更新标记状态失败', e);
      rethrow;
    } finally {
      _loadingMark = false;
      notifyListeners();
    }
  }

  void showMarkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MarkSelectionDialog(
        currentStatus: _currentMarkStatus,
        loading: _loadingMark,
        onMarkSelected: (status) async {
          try {
            await updateMarkStatus(status);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已标记为${status.label}'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('标记失败: $e')),
              );
            }
          }
        },
      ),
    );
  }

  String? _extractNumericId(String? sourceId) {
    if (sourceId == null) return null;
    final match = RegExp(r'\d+').firstMatch(sourceId);
    return match?.group(0);
  }

  @override
  void dispose() {
    // 取消所有正在进行的请求
    _cancelToken.cancel('ViewModel disposed');
    _disposed = true;
    super.dispose();
  }
}
