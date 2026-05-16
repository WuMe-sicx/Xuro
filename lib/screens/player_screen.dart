import 'package:xuro/core/platform/lyric_overlay_manager.dart';
import 'package:xuro/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/widgets/player/player_controls.dart';
import 'package:xuro/widgets/player/waveform_progress.dart';
import 'package:xuro/widgets/player/circular_cover.dart';
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
                        child: CircularCover(
                          coverUrl: _viewModel.currentTrackInfo?.coverUrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space32),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'player-title',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                _viewModel.currentTrackInfo?.title ??
                                    Strings.notPlaying,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          if (_viewModel.currentTrackInfo?.artist != null)
                            Text(
                              _viewModel.currentTrackInfo!.artist,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    final lyricManager = GetIt.I<LyricOverlayManager>();
    final wakeLockController = GetIt.I<WakeLockController>();
    final sleepTimer = GetIt.I<SleepTimerController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          ListenableBuilder(
            listenable: sleepTimer,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  sleepTimer.isActive
                      ? Icons.bedtime
                      : Icons.bedtime_outlined,
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
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space12, 0, AppSpacing.space12, AppSpacing.space32),
              child: const Column(
                children: [
                  WaveformProgress(),
                  SizedBox(height: AppSpacing.space8),
                  PlayerControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
