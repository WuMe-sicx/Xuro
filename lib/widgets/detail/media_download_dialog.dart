import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/download/download_service.dart';

/// 媒体"下载到本地磁盘"对话框：
/// 阶段 1 = 确认（[promptText]，视频默认为固定文案
/// 「打开该视频需要下载到本地磁盘，是否同意？」）；
/// 阶段 2 = 下载进度 + 取消。完成/取消/失败时以 [DownloadResult] pop。
///
/// 拒绝（确认阶段点取消 / 关闭）→ pop(null)，调用方按 no-op 处理。
class MediaDownloadDialog extends StatefulWidget {
  final String fileName;
  final String titleText;
  final String promptText;
  final Future<DownloadResult> Function(
    CancelToken cancelToken,
    void Function(double progress) onProgress,
  ) download;

  const MediaDownloadDialog({
    super.key,
    required this.fileName,
    required this.download,
    this.titleText = Strings.videoNeedsDownloadTitle,
    this.promptText = Strings.videoNeedsDownloadPrompt,
  });

  @override
  State<MediaDownloadDialog> createState() => _MediaDownloadDialogState();
}

class _MediaDownloadDialogState extends State<MediaDownloadDialog> {
  bool _downloading = false;
  double _progress = 0;
  CancelToken? _cancelToken;

  Future<void> _start() async {
    final cancelToken = CancelToken();
    setState(() {
      _downloading = true;
      _progress = 0;
      _cancelToken = cancelToken;
    });

    DownloadResult result;
    try {
      result = await widget.download(cancelToken, (p) {
        if (mounted) setState(() => _progress = p);
      });
    } catch (_) {
      // 最后防线：服务已把前置失败收敛为 ioError，此处兜底极端未捕获，
      // 避免进度弹窗（PopScope canPop:false）卡死无法关闭。
      result = const DownloadResult(DownloadStatus.ioError);
    }

    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    if (!_downloading) {
      return AlertDialog(
        title: Text(widget.titleText),
        content: Text(widget.promptText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.downloadCancel),
          ),
          TextButton(
            onPressed: _start,
            child: const Text(Strings.downloadConfirm),
          ),
        ],
      );
    }

    final pct = (_progress * 100).clamp(0, 100).toStringAsFixed(0);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text(Strings.downloading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
            ),
            const SizedBox(height: 8),
            Text('$pct%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _cancelToken?.cancel(),
            child: const Text(Strings.downloadCancel),
          ),
        ],
      ),
    );
  }
}
