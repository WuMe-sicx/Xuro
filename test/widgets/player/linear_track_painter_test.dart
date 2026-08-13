import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/widgets/player/waveform_progress.dart';

/// Phase 3：波形条改 2px 直条 + 方块滑块。`WaveformProgress` 内部经
/// `GetIt.I<PlayerViewModel>()` 取数据，走不了项目现有的无 DI harness 测试
/// 路线（同 CLAUDE.md 里对 PlayerProgress/WaveformProgress 的说明）；这里
/// 转而直接单测 `LinearTrackPainter` 拆出的纯几何函数——滑块位置随
/// position（fraction）变化，且 `shouldRepaint` 在 fraction/颜色变化时正确
/// 触发重绘。已播段颜色由调用方（`WaveformProgress.build`）传入
/// `colorScheme.primary`，这层绑定见 waveform_progress.dart:71。
void main() {
  const size = Size(200, 40);

  test('滑块位置随 fraction 线性变化', () {
    expect(LinearTrackPainter.thumbRect(size, 0.0).center.dx, 0);
    expect(LinearTrackPainter.thumbRect(size, 1.0).center.dx, 200);
    expect(LinearTrackPainter.thumbRect(size, 0.5).center.dx, 100);
  });

  test('滑块是 12x12 零圆角方块', () {
    final rect = LinearTrackPainter.thumbRect(size, 0.3);
    expect(rect.width, 12);
    expect(rect.height, 12);
  });

  test('已播段宽度随 fraction 变化，底色直条占满宽度', () {
    expect(LinearTrackPainter.trackRect(size).width, size.width);
    expect(LinearTrackPainter.playedRect(size, 0.25).width, 50);
    expect(LinearTrackPainter.playedRect(size, 1.0).width, size.width);
  });

  test('shouldRepaint：fraction 或颜色变化才重绘', () {
    final base = LinearTrackPainter(
      fraction: 0.4,
      playedColor: Colors.red,
      trackColor: Colors.grey,
    );
    final sameValues = LinearTrackPainter(
      fraction: 0.4,
      playedColor: Colors.red,
      trackColor: Colors.grey,
    );
    final movedFraction = LinearTrackPainter(
      fraction: 0.5,
      playedColor: Colors.red,
      trackColor: Colors.grey,
    );

    expect(base.shouldRepaint(sameValues), isFalse);
    expect(base.shouldRepaint(movedFraction), isTrue);
  });

  test('paint 在边界 fraction（0/1）下不抛异常', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (final f in [0.0, 0.5, 1.0]) {
      LinearTrackPainter(
        fraction: f,
        playedColor: Colors.red,
        trackColor: Colors.grey,
      ).paint(canvas, size);
    }
    recorder.endRecording();
  });
}
