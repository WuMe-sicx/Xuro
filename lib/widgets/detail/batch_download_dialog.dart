import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/detail_viewmodel.dart';

/// 文件夹 / 整部作品"下载全部"对话框：
/// 阶段 1 = 确认（共 [audioCount] 个音频，含匹配字幕）；[audioCount]==0 时
/// 只显示"无可下载音频"并以 null pop。
/// 阶段 2 = 聚合进度（i/N + 当前文件名 + 当前文件进度条）+ 取消。
/// 完成/取消时以 [BatchDownloadOutcome] pop；确认阶段取消 → pop(null)。
class BatchDownloadDialog extends StatefulWidget {
  final int audioCount;
  final Future<BatchDownloadOutcome> Function(
    CancelToken cancelToken,
    void Function(int index, int total, String name, double progress)
        onProgress,
  ) download;

  const BatchDownloadDialog({
    super.key,
    required this.audioCount,
    required this.download,
  });

  @override
  State<BatchDownloadDialog> createState() => _BatchDownloadDialogState();
}

class _BatchDownloadDialogState extends State<BatchDownloadDialog> {
  bool _downloading = false;
  int _index = 0;
  int _total = 0;
  String _name = '';
  double _progress = 0;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    // 弹窗/详情页被程序化移除（非点取消）时兜底中断，
    // 否则批量下载会在后台继续写盘。token 已驱动 downloadFolder 循环。
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final cancelToken = CancelToken();
    setState(() {
      _downloading = true;
      _total = widget.audioCount;
      _cancelToken = cancelToken;
    });

    BatchDownloadOutcome outcome;
    try {
      outcome = await widget.download(cancelToken, (i, n, name, p) {
        if (mounted) {
          setState(() {
            _index = i;
            _total = n;
            _name = name;
            _progress = p;
          });
        }
      });
    } catch (_) {
      // 最后防线：极端未捕获时以失败结果 pop，避免批量进度弹窗卡死。
      outcome = BatchDownloadOutcome(
        ok: 0,
        skipped: 0,
        failed: widget.audioCount,
        cancelled: false,
      );
    }

    if (mounted) Navigator.of(context).pop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    if (!_downloading) {
      if (widget.audioCount == 0) {
        return AlertDialog(
          title: const Text(Strings.batchDownloadTitle),
          content: const Text(Strings.batchDownloadEmpty),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(Strings.confirm),
            ),
          ],
        );
      }
      return AlertDialog(
        title: const Text(Strings.batchDownloadTitle),
        content: Text(Strings.batchDownloadConfirm(widget.audioCount)),
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
        title: const Text(Strings.batchDownloadTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.batchDownloadProgress(_index, _total, _name),
              maxLines: 2,
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
