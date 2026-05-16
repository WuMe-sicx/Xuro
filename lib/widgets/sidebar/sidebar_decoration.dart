import 'package:flutter/material.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

/// 侧边栏底部装饰水印（对齐参考图）。规范 §2.2。
///
/// 变体感知：mono 配色画「弦月 + 远山」（呼应 [_DrawerBackground] 对 mono
/// 的纯黑特例与参考图黑白侧边栏的月山母题），blue/green 画叶片。
/// 全部用 accent 低透明度，是玻璃拟态背景上的安静水印——不抢内容、可点穿。
class SidebarDecoration extends StatelessWidget {
  const SidebarDecoration({super.key, required this.variant, this.height = 150});

  final ColorVariant variant;
  final double height;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _DecorationPainter(variant: variant, color: accent),
        ),
      ),
    );
  }
}

class _DecorationPainter extends CustomPainter {
  _DecorationPainter({required this.variant, required this.color});

  final ColorVariant variant;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (variant == ColorVariant.mono) {
      _paintMoonAndHills(canvas, size);
    } else {
      _paintLeaves(canvas, size);
    }
  }

  void _paintMoonAndHills(Canvas canvas, Size size) {
    // 远山：两道低矮弧线，越远越淡。
    final hillFar = Paint()..color = color.withValues(alpha: 0.07);
    final hillNear = Paint()..color = color.withValues(alpha: 0.12);

    final far = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.42,
          size.width * 0.62, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.72, size.width,
          size.height * 0.56)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(far, hillFar);

    final near = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width,
          size.height * 0.84)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(near, hillNear);

    // 弦月：外圆减去偏移内圆。
    final c = Offset(size.width * 0.78, size.height * 0.26);
    const r = 22.0;
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()
        ..addOval(Rect.fromCircle(
            center: c.translate(r * 0.55, -r * 0.35), radius: r)),
    );
    canvas.drawPath(crescent, Paint()..color = color.withValues(alpha: 0.20));
  }

  void _paintLeaves(Canvas canvas, Size size) {
    // 三片叶子，自左下向上铺开，由深到浅。
    final specs = [
      (Offset(size.width * 0.16, size.height * 0.92), 78.0, -0.5, 0.16),
      (Offset(size.width * 0.34, size.height * 0.98), 96.0, -0.95, 0.12),
      (Offset(size.width * 0.2, size.height * 0.99), 60.0, -0.15, 0.09),
    ];
    for (final (base, len, angle, alpha) in specs) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      final w = len * 0.42;
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(w, -len * 0.35, 0, -len)
        ..quadraticBezierTo(-w, -len * 0.35, 0, 0)
        ..close();
      canvas.drawPath(leaf, Paint()..color = color.withValues(alpha: alpha));
      // 叶脉
      canvas.drawLine(
        const Offset(0, 0),
        Offset(0, -len),
        Paint()
          ..color = color.withValues(alpha: alpha * 0.6)
          ..strokeWidth = 1,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_DecorationPainter old) =>
      old.variant != variant || old.color != color;
}
