import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/core/subtitle/subtitle_loader.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';

/// 只读字幕预览：已下载则读本地文件（离线可用），否则拉
/// `mediaDownloadUrl`（带缓存）。能按时间轴解析就逐行列出，
/// 不支持的格式（.srt/.txt 等）回退显示原始文本。
class SubtitlePreviewScreen extends StatefulWidget {
  final String? workId;
  final Child file;

  const SubtitlePreviewScreen({
    super.key,
    required this.workId,
    required this.file,
  });

  @override
  State<SubtitlePreviewScreen> createState() => _SubtitlePreviewScreenState();
}

class _SubtitlePreviewScreenState extends State<SubtitlePreviewScreen> {
  final _loader = GetIt.I<SubtitleLoader>();
  final _downloadService = GetIt.I<DownloadService>();

  bool _loading = true;
  String? _error;
  SubtitleList? _parsed; // 解析成功 → 时间轴列表
  String? _raw; // 解析失败 → 原文兜底

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _parsed = null;
      _raw = null;
    });
    try {
      String? localPath;
      if (widget.workId != null) {
        localPath = await _downloadService.localPathIfDownloaded(
          widget.workId!,
          widget.file,
        );
      }
      final content = await _loader.loadRawContent(
        localPath: localPath,
        url: widget.file.mediaDownloadUrl,
      );
      final parsed = _loader.parseOrNull(content);
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (parsed != null) {
          _parsed = parsed;
        } else {
          _raw = content;
        }
      });
    } catch (e) {
      AppLogger.error('字幕预览加载失败', e);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = Strings.subtitlePreviewError;
      });
    }
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final t = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s.$t' : '$m:$s.$t';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.subtitlePreviewTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.file.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(Strings.subtitlePreviewLoading),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text(Strings.retry)),
          ],
        ),
      );
    }

    final parsed = _parsed;
    if (parsed != null) {
      if (parsed.subtitles.isEmpty) {
        return const Center(child: Text(Strings.subtitlePreviewEmpty));
      }
      final colorScheme = Theme.of(context).colorScheme;
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: parsed.subtitles.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (_, i) {
          final sub = parsed.subtitles[i];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  _fmt(sub.start),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(sub.text)),
            ],
          );
        },
      );
    }

    // 原文兜底（.srt/.txt 等无法按时间轴解析）
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            Strings.subtitlePreviewRawNotice,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SelectableText(_raw ?? Strings.subtitlePreviewEmpty),
      ],
    );
  }
}
