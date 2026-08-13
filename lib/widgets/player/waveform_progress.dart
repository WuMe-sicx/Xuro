import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

/// 播放器进度条：2px 直条 + 12x12 实心方块滑块（Modernist 改版，取代旧的
/// 装饰性波形条——零圆角/直线是这套设计语言的识别特征之一）。
///
/// seek / 时间显示**完全复用** `PlayerViewModel`（同 `seek`/position/duration），
/// 只换绘制；`Listenable.merge([viewModel, viewModel.positionListenable])`
/// 订阅方式不变——`positionListenable` 是独立 notifier，避免位置每 tick
/// 拖着整个 VM 重建（见 `PlayerViewModel` 字段注释）。
class WaveformProgress extends StatefulWidget {
  const WaveformProgress({super.key});

  /// 手势命中区域高度：比 2px 视觉线宽得多，保证拖拽/点击有可用的触控热区。
  static const double _touchHeight = 40;
  static const double _trackThickness = 2;
  static const double _thumbSize = 12;

  @override
  State<WaveformProgress> createState() => _WaveformProgressState();
}

class _WaveformProgressState extends State<WaveformProgress> {
  /// 拖动期间的目标位置比例。非 null 时滑块与左侧时间都以它为准，**不打 seek**。
  ///
  /// 曾经每个 `onHorizontalDragUpdate` 直通 `PlayerViewModel.seek()`，一次拖动
  /// 实测 53 次——每次都是 `await ready` + just_audio 平台通道往返，还会让音频
  /// 反复重新缓冲，这就是拖动卡顿的来源。改成抬手时只 seek 一次。
  double? _dragFraction;

  String _fmt(Duration? d) {
    if (d == null) return '--:--';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Duration _targetOf(double fraction, double durMs) =>
      Duration(milliseconds: (durMs * fraction).round());

  Future<void> _commitDrag(PlayerViewModel viewModel, double durMs) async {
    final fraction = _dragFraction;
    if (fraction == null) return;
    await viewModel.seek(_targetOf(fraction, durMs));
    // 等 seek 落地后再交还控制权：提前清掉会让滑块闪回 seek 前的旧 position，
    // 直到下一次 200ms 进度 tick 才跳到新位置。
    if (mounted) setState(() => _dragFraction = null);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    final cs = Theme.of(context).colorScheme;

    // duration 走 VM 的 notifyListeners()，position 走独立 notifier（见
    // PlayerViewModel 字段注释）；merge 两者，否则 duration 到达时进度条
    // 要等下一次 200ms 节流 tick 才刷新。
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.positionListenable]),
      builder: (context, _) {
        final posMs = viewModel.position?.inMilliseconds.toDouble() ?? 0;
        final durMs = viewModel.duration?.inMilliseconds.toDouble() ?? 1;
        final playedFraction =
            durMs <= 0 ? 0.0 : (posMs / durMs).clamp(0.0, 1.0);
        final fraction = _dragFraction ?? playedFraction;

        /// 返回 dx 对应的比例；宽度或时长无效时返回 null（此时既不重绘也不 seek）。
        double? fractionAt(double dx, double width) {
          if (width <= 0 || durMs <= 0) return null;
          return (dx / width).clamp(0.0, 1.0);
        }

        void updateDrag(double dx, double width) {
          final f = fractionAt(dx, width);
          if (f == null) return;
          setState(() => _dragFraction = f);
        }

        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Column(
              children: [
                SizedBox(
                  height: WaveformProgress._touchHeight,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final width = c.maxWidth;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        // 点击是单次操作，直接 seek——不存在高频问题。
                        onTapDown: (d) {
                          final f = fractionAt(d.localPosition.dx, width);
                          if (f != null) viewModel.seek(_targetOf(f, durMs));
                        },
                        onHorizontalDragStart: (d) =>
                            updateDrag(d.localPosition.dx, width),
                        onHorizontalDragUpdate: (d) =>
                            updateDrag(d.localPosition.dx, width),
                        onHorizontalDragEnd: (_) =>
                            _commitDrag(viewModel, durMs),
                        // 手势被竞技场其他 recognizer 抢走时必须清位，否则
                        // _dragFraction 永久卡住，进度条从此不再跟随播放。
                        onHorizontalDragCancel: () {
                          if (_dragFraction != null) {
                            setState(() => _dragFraction = null);
                          }
                        },
                        child: CustomPaint(
                          size: Size(width, WaveformProgress._touchHeight),
                          painter: LinearTrackPainter(
                            fraction: fraction,
                            playedColor: cs.primary,
                            trackColor: cs.outlineVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // 拖动中显示目标时间而非播放时间，否则数字不跟手。
                        _fmt(_dragFraction == null
                            ? viewModel.position
                            : _targetOf(_dragFraction!, durMs)),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      Text(
                        _fmt(viewModel.duration),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 2px 直条 + 方块滑块的绘制器。几何计算拆成 [trackRect]/[thumbRect] 两个
/// 纯函数（不碰 `Canvas`），供单测在没有 DI/Widget 环境下直接验证滑块位置
/// 随 `fraction` 变化——`WaveformProgress` 依赖 `GetIt.I<PlayerViewModel>()`，
/// 整个 Widget 走不了项目现有的无 DI harness 测试路线（见 CLAUDE.md 测试说明）。
class LinearTrackPainter extends CustomPainter {
  LinearTrackPainter({
    required this.fraction,
    required this.playedColor,
    required this.trackColor,
  });

  final double fraction;
  final Color playedColor;
  final Color trackColor;

  static const double trackThickness = WaveformProgress._trackThickness;
  static const double thumbSize = WaveformProgress._thumbSize;

  /// 底色直条（占满宽度）。
  static Rect trackRect(Size size) {
    final cy = size.height / 2;
    return Rect.fromLTWH(
        0, cy - trackThickness / 2, size.width, trackThickness);
  }

  /// 已播放段直条（宽度随 [fraction] 线性变化）。
  static Rect playedRect(Size size, double fraction) {
    final cy = size.height / 2;
    return Rect.fromLTWH(
        0, cy - trackThickness / 2, size.width * fraction, trackThickness);
  }

  /// 12x12 滑块，中心落在已播放位置。
  static Rect thumbRect(Size size, double fraction) {
    final cy = size.height / 2;
    return Rect.fromCenter(
      center: Offset(size.width * fraction, cy),
      width: thumbSize,
      height: thumbSize,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(trackRect(size), Paint()..color = trackColor);

    final playedX = size.width * fraction;
    if (playedX > 0) {
      canvas.drawRect(playedRect(size, fraction), Paint()..color = playedColor);
    }

    // 滑块：12x12 零圆角实心方块，居中于已播放位置——Modernist 稿子的方块
    // 滑块母题（取代常规圆点）。
    canvas.drawRect(thumbRect(size, fraction), Paint()..color = playedColor);
  }

  @override
  bool shouldRepaint(LinearTrackPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.playedColor != playedColor ||
      oldDelegate.trackColor != trackColor;
}
