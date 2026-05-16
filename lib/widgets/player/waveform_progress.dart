import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

/// 波形进度条（对齐参考图），`PlayerProgress` 的视觉替代——拖拽/点击 seek
/// 与时间绑定**完全复用** `PlayerViewModel`（同 `seek`/position/duration）。
///
/// 说明：波形条高是确定性母题（流式客户端无逐轨真实振幅数据，参考图同理），
/// 属装饰；已播放比例 / 拖拽定位是真实数据。已播放段染 accent，余下中性。
class WaveformProgress extends StatelessWidget {
  const WaveformProgress({super.key});

  static const double _height = 40;
  static const int _bars = 56;

  String _fmt(Duration? d) {
    if (d == null) return '--:--';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final posMs = viewModel.position?.inMilliseconds.toDouble() ?? 0;
        final durMs = viewModel.duration?.inMilliseconds.toDouble() ?? 1;
        final fraction =
            durMs <= 0 ? 0.0 : (posMs / durMs).clamp(0.0, 1.0);

        void seekToDx(double dx, double width) {
          if (width <= 0 || durMs <= 0) return;
          final f = (dx / width).clamp(0.0, 1.0);
          viewModel.seek(Duration(milliseconds: (durMs * f).round()));
        }

        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4),
            child: Column(
              children: [
                SizedBox(
                  height: _height,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final width = c.maxWidth;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) =>
                            seekToDx(d.localPosition.dx, width),
                        onHorizontalDragUpdate: (d) =>
                            seekToDx(d.localPosition.dx, width),
                        child: CustomPaint(
                          size: Size(width, _height),
                          painter: _WaveformPainter(
                            fraction: fraction,
                            playedColor: cs.primary,
                            restColor:
                                cs.onSurfaceVariant.withValues(alpha: 0.35),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(viewModel.position),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        _fmt(viewModel.duration),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
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

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.fraction,
    required this.playedColor,
    required this.restColor,
  });

  final double fraction;
  final Color playedColor;
  final Color restColor;

  @override
  void paint(Canvas canvas, Size size) {
    const n = WaveformProgress._bars;
    final slot = size.width / n;
    final barW = slot * 0.5;
    final cy = size.height / 2;
    final playedX = size.width * fraction;

    final played = Paint()
      ..color = playedColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barW;
    final rest = Paint()
      ..color = restColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barW;

    for (var i = 0; i < n; i++) {
      // 确定性波形母题：两组不同频率正弦叠加，看起来像波形又不抖动。
      final t = i.toDouble();
      final amp = 0.18 +
          0.82 *
              ((math.sin(t * 0.9) + 1) / 2 * 0.6 +
                  (math.sin(t * 0.27 + 1.3) + 1) / 2 * 0.4);
      final h = amp * size.height;
      final x = slot * i + slot / 2;
      canvas.drawLine(
        Offset(x, cy - h / 2),
        Offset(x, cy + h / 2),
        x <= playedX ? played : rest,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.fraction != fraction ||
      old.playedColor != playedColor ||
      old.restColor != restColor;
}
