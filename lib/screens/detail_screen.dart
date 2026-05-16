import 'package:xuro/core/theme/app_animations.dart';
import 'package:xuro/widgets/mini_player/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/widgets/detail/work_cover.dart';
import 'package:xuro/widgets/detail/work_info.dart';
import 'package:xuro/widgets/detail/work_files_list.dart';
import 'package:xuro/widgets/detail/work_files_skeleton.dart';
import 'package:xuro/presentation/viewmodels/detail_viewmodel.dart';
import 'package:xuro/widgets/detail/work_action_buttons.dart';
import 'package:xuro/widgets/detail/media_download_dialog.dart';
import 'package:xuro/widgets/detail/batch_download_dialog.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/screens/similar_works_screen.dart';
import 'package:xuro/screens/subtitle_preview_screen.dart';
import 'package:open_filex/open_filex.dart';

class DetailScreen extends StatelessWidget {
  final Work work;
  final bool fromPlayer;

  const DetailScreen({
    super.key,
    required this.work,
    this.fromPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailViewModel(
        work: work,
      )..loadInitialData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(work.sourceId ?? ''),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: MiniPlayer.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkCover(
                imageUrl: work.mainCoverUrl ?? '',
                workId: work.id ?? 0,
                sourceId: work.sourceId ?? '',
                releaseDate: work.release,
                heroTag: 'work-cover-${work.id}',
              ),
              Consumer<DetailViewModel>(
                builder: (context, viewModel, _) => WorkInfo(
                  work: work,
                  workInfo: viewModel.workInfo,
                ),
              ),
              Consumer<DetailViewModel>(
                builder: (context, viewModel, _) => WorkActionButtons(
                  hasRecommendations: viewModel.hasRecommendations,
                  checkingRecommendations: viewModel.checkingRecommendations,
                  onRecommendationsTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SimilarWorksScreen(work: work),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = AppAnimations.standard;
                          var tween = Tween(begin: begin, end: end).chain(
                            CurveTween(curve: curve),
                          );
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  onFavoriteTap: () => viewModel.showPlaylistsDialog(context),
                  loadingFavorite: viewModel.loadingFavorite,
                  onMarkTap: () => viewModel.showMarkDialog(context),
                  currentMarkStatus: viewModel.currentMarkStatus,
                  loadingMark: viewModel.loadingMark,
                ),
              ),
              Consumer<DetailViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const WorkFilesSkeleton();
                  }

                  if (viewModel.error != null) {
                    return Center(
                      child: Text(
                        viewModel.error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  }

                  if (viewModel.files != null) {
                    // 确认弹窗 → 下载（带进度/取消）→ 结果提示。
                    // [openOnDone]=true（视频）完成后用外部查看器打开；
                    // false（音频离线下载）仅提示完成。
                    Future<void> runDownload(
                      Child file, {
                      required bool openOnDone,
                      required String title,
                      required String prompt,
                    }) async {
                      final result = await showDialog<DownloadResult>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => MediaDownloadDialog(
                          fileName: file.title ?? '',
                          titleText: title,
                          promptText: prompt,
                          download: (ct, onP) => viewModel.downloadFile(
                            file,
                            cancelToken: ct,
                            onProgress: onP,
                          ),
                        ),
                      );
                      // 拒绝（确认阶段取消）→ no-op
                      if (result == null || !context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      if (result.isPlayable && result.localPath != null) {
                        if (openOnDone) {
                          final open =
                              await OpenFilex.open(result.localPath!);
                          if (open.type != ResultType.done) {
                            messenger.showSnackBar(const SnackBar(
                              content: Text(Strings.downloadOpenFailed),
                            ));
                          }
                        } else {
                          messenger.showSnackBar(const SnackBar(
                            content: Text(Strings.downloadSuccess),
                          ));
                        }
                      } else if (result.status == DownloadStatus.cancelled) {
                        messenger.showSnackBar(const SnackBar(
                          content: Text(Strings.downloadCancelled),
                        ));
                      } else if (result.status ==
                          DownloadStatus.networkError) {
                        messenger.showSnackBar(const SnackBar(
                          content: Text(Strings.downloadNetworkError),
                        ));
                      } else {
                        messenger.showSnackBar(const SnackBar(
                          content: Text(Strings.downloadIoError),
                        ));
                      }
                    }

                    Future<void> runBatch(Child? folderNode) async {
                      final outcome = await showDialog<BatchDownloadOutcome>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => BatchDownloadDialog(
                          audioCount: viewModel.batchAudioCount(folderNode),
                          download: (ct, onP) => viewModel.downloadFolder(
                            folder: folderNode,
                            onProgress: onP,
                            cancelToken: ct,
                          ),
                        ),
                      );
                      if (outcome == null || !context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(SnackBar(
                        content: Text(outcome.cancelled
                            ? Strings.batchDownloadCancelled
                            : Strings.batchDownloadSummary(
                                outcome.ok,
                                outcome.skipped,
                                outcome.failed,
                              )),
                      ));
                    }

                    return WorkFilesList(
                      files: viewModel.files!,
                      onFolderDownload: runBatch,
                      onFileTap: (file) async {
                        // 视频判断前置：视频扩展名优先于不可靠的 API
                        // `type`（会把视频错标 audio）。视频走下载+外部
                        // 播放，绝不进音频播放管线（否则"播放列表为空"）。
                        if (viewModel.isVideoFile(file)) {
                          await runDownload(
                            file,
                            openOnDone: true,
                            title: Strings.videoNeedsDownloadTitle,
                            prompt: Strings.videoNeedsDownloadPrompt,
                          );
                          return;
                        }
                        if (viewModel.isAudioFile(file)) {
                          try {
                            await viewModel.playFile(file, context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(Strings.playFailed(e))),
                              );
                            }
                          }
                          return;
                        }
                        if (viewModel.isSubtitleFile(file)) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SubtitlePreviewScreen(
                                workId: work.id?.toString(),
                                file: file,
                              ),
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(Strings.unsupportedFileType),
                          ),
                        );
                      },
                      onFileDownload: (file) => runDownload(
                        file,
                        openOnDone: false,
                        title: Strings.audioDownloadTitle,
                        prompt: Strings.audioDownloadPrompt,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        bottomSheet: const MiniPlayer(),
      ),
    );
  }
}
