import 'package:xuro/core/platform/lyric_overlay_manager.dart';
import 'package:xuro/core/theme/app_animations.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/audio/models/playback_context.dart';
import 'package:xuro/core/download/download_service.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/widgets/player/player_controls.dart';
import 'package:xuro/widgets/player/waveform_progress.dart';
import 'package:xuro/widgets/player/square_cover.dart';
import 'package:xuro/screens/detail_screen.dart';
import 'package:xuro/widgets/lyrics/components/player_lyric_view.dart';
import 'package:xuro/widgets/player/player_work_info.dart';
import 'package:xuro/core/platform/wakelock_controller.dart';
import 'package:xuro/core/platform/sleep_timer_controller.dart';
import 'package:xuro/screens/settings/sleep_timer_dialog.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/subtitle/subtitle_import_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _LyricOverlayAction extends StatefulWidget {
  const _LyricOverlayAction({required this.manager});

  final LyricOverlayManager manager;

  @override
  State<_LyricOverlayAction> createState() => _LyricOverlayActionState();
}

class _LyricOverlayActionState extends State<_LyricOverlayAction> {
  Future<void> _onTap() async {
    await widget.manager.toggle(context);
    if (mounted) setState(() {});
  }

  Future<void> _onLongPress() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!widget.manager.isShowing) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(Strings.lyricOverlayEnterFirstHint),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await widget.manager.toggleEditable();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(widget.manager.isEditable
            ? Strings.lyricOverlayEditEntered
            : Strings.lyricOverlayEditExited),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.manager;
    final theme = Theme.of(context);
    final iconColor = manager.isEditable ? theme.colorScheme.primary : null;
    final tooltipMsg = manager.isShowing
        ? (manager.isEditable
            ? Strings.lyricOverlayTooltipExitEdit
            : Strings.lyricOverlayTooltipLongPressHint)
        : Strings.lyricOverlayTooltipEnable;
    return Tooltip(
      message: tooltipMsg,
      child: InkResponse(
        radius: 24,
        onTap: _onTap,
        onLongPress: _onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: Icon(
            manager.isShowing ? Icons.lyrics : Icons.lyrics_outlined,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// 顶栏右侧「在线 / 本地」角标：按下载表判定当前曲目是否已离线可用。
/// 拿不到判定结果（未在播放 / 查询异常）时不渲染任何东西——不能写死成
/// 「在线」，那会在下载表查询失败时给用户一个错误的离线状态承诺。
class _DownloadStatusBadge extends StatefulWidget {
  const _DownloadStatusBadge({required this.context});

  final PlaybackContext? context;

  @override
  State<_DownloadStatusBadge> createState() => _DownloadStatusBadgeState();
}

class _DownloadStatusBadgeState extends State<_DownloadStatusBadge> {
  bool? _isLocal;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _DownloadStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.context?.currentFile != widget.context?.currentFile ||
        oldWidget.context?.work.id != widget.context?.work.id) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final ctx = widget.context;
    final workId = ctx?.work.id?.toString();
    if (ctx == null || workId == null) {
      if (mounted) setState(() => _isLocal = null);
      return;
    }
    try {
      final path = await GetIt.I<DownloadService>()
          .localPathIfDownloaded(workId, ctx.currentFile);
      if (!mounted) return;
      setState(() => _isLocal = path != null);
    } catch (_) {
      // 下载表查询失败：宁可不显示角标，也不能误导用户「在线」。
      if (mounted) setState(() => _isLocal = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocal == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant, width: 1),
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        _isLocal! ? Strings.playerLocal : Strings.playerOnline,
        style: AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showLyrics = false;
  bool _canSwitchView = true;
  late final PlayerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I<PlayerViewModel>();
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: AppAnimations.long,
      switchInCurve: AppAnimations.smoothScroll,
      switchOutCurve: AppAnimations.exit,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isLyrics = (child as dynamic).key == const ValueKey('lyrics');

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, isLyrics ? 0.1 : -0.1),
              end: Offset.zero,
            ).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: _showLyrics
          ? LayoutBuilder(
              key: const ValueKey('lyrics'),
              builder: (context, constraints) {
                return PlayerLyricView(
                  onScrollStateChanged: (canSwitch) {
                    setState(() {
                      _canSwitchView = canSwitch;
                    });
                  },
                );
              },
            )
          : ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final cs = Theme.of(context).colorScheme;
                final trackInfo = _viewModel.currentTrackInfo;
                final kicker = trackInfo?.artist ?? '';
                return Column(
                  key: const ValueKey('cover'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.space32),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space32),
                      child: Hero(
                        tag: 'mini-player-cover',
                        child: SquareCover(
                          coverUrl: trackInfo?.coverUrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space32),
                      child: Column(
                        children: [
                          // kicker：社团名，Modernist 三段式曲目信息
                          // （kicker/曲名/副标）的第一段，accent 色。
                          if (kicker.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.space8),
                              child: Text(
                                kicker,
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: cs.primary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Hero(
                            tag: 'player-title',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                trackInfo?.title ?? Strings.notPlaying,
                                style: AppTextStyles.headlineMedium
                                    .copyWith(color: cs.onSurface),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PlayerWorkInfo(context: _viewModel.currentContext),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSleepTimerFooter(SleepTimerController sleepTimer) {
    return ListenableBuilder(
      listenable: sleepTimer,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        final minutes = sleepTimer.minutes;
        return Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space24,
                AppSpacing.space16,
                AppSpacing.space24,
                0,
              ),
              child: Row(
                children: [
                  Icon(Icons.bedtime_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: Text(
                      minutes != null
                          ? Strings.playerSleepTimerActive(minutes)
                          : Strings.playerSleepTimerInactive,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: cs.onSurface),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => SleepTimerDialog(controller: sleepTimer),
                    ),
                    child: Text(
                      Strings.playerSleepTimerChange,
                      style:
                          AppTextStyles.labelMedium.copyWith(color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lyricManager = GetIt.I<LyricOverlayManager>();
    final wakeLockController = GetIt.I<WakeLockController>();
    final sleepTimer = GetIt.I<SleepTimerController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          Strings.nowPlaying.toUpperCase(),
          style: AppTextStyles.labelMedium
              .copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
        ),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) =>
                _DownloadStatusBadge(context: _viewModel.currentContext),
          ),
          ListenableBuilder(
            listenable: sleepTimer,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  sleepTimer.isActive ? Icons.bedtime : Icons.bedtime_outlined,
                  color: sleepTimer.isActive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                tooltip: Strings.sleepTimer,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SleepTimerDialog(controller: sleepTimer),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              final currentWork = _viewModel.currentContext?.work;
              if (currentWork != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      work: currentWork,
                      fromPlayer: true,
                    ),
                  ),
                );
              }
            },
          ),
          // Subtitle import menu
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.subtitles,
                  color: _viewModel.isUserImportedSubtitle
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onSelected: (value) async {
                  if (value == 'import') {
                    final result = await _viewModel.importSubtitle();
                    if (!context.mounted) return;
                    final message = switch (result) {
                      ImportResult.success => Strings.importSuccess,
                      ImportResult.cancelled => null,
                      ImportResult.invalidFormat => Strings.importInvalidFormat,
                      ImportResult.fileTooLarge => Strings.importFileTooLarge,
                      ImportResult.parseFailed => Strings.importParseFailed,
                      ImportResult.ioError => Strings.importIoError,
                    };
                    if (message != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  } else if (value == 'remove') {
                    await _viewModel.removeImportedSubtitle();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(Strings.subtitleRemoved)),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'import',
                    child: Text(Strings.importSubtitle),
                  ),
                  if (_viewModel.isUserImportedSubtitle)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text(Strings.removeImportedSubtitle),
                    ),
                ],
              );
            },
          ),
          _LyricOverlayAction(manager: lyricManager),
          ListenableBuilder(
            listenable: wakeLockController,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  wakeLockController.enabled
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
                ),
                tooltip: wakeLockController.enabled
                    ? Strings.screenAwakeOff
                    : Strings.screenAwakeOn,
                onPressed: () => wakeLockController.toggle(),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_canSwitchView) {
                    setState(() {
                      _showLyrics = !_showLyrics;
                    });
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: _buildContent(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space32),
              child: Column(
                children: [
                  const WaveformProgress(),
                  const SizedBox(height: AppSpacing.space16),
                  const PlayerControls(),
                  const SizedBox(height: AppSpacing.space20),
                  _buildSleepTimerFooter(sleepTimer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
