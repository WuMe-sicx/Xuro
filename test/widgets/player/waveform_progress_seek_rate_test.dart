/// waveform_progress_seek_rate_test.dart：锁定进度条拖动期间的 seek 调用次数。
///
/// 一次连续拖动会产生几十个 pointer move，每个都触发 onHorizontalDragUpdate。
/// 若每个都直通 IAudioPlayerService.seek()，就是几十次 `await ready` +
/// just_audio 平台通道往返，表现为拖动卡顿。此测试把「一次拖动 = 少量 seek」
/// 变成可执行断言。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:xuro/core/audio/events/playback_event.dart';
import 'package:xuro/core/audio/events/playback_event_hub.dart';
import 'package:xuro/core/audio/i_audio_player_service.dart';
import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/core/subtitle/i_subtitle_service.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';
import 'package:xuro/widgets/player/waveform_progress.dart';

/// 只记录 seek，其余调用一律暴露（本测试路径不应触达）。
class _CountingAudioService implements IAudioPlayerService {
  final List<Duration> seeks = [];

  @override
  Future<void> seek(Duration position) async => seeks.add(position);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('未预期调用: ${invocation.memberName}');
}

class _FakeSubtitleService implements ISubtitleService {
  @override
  Stream<SubtitleList?> get subtitleStream => const Stream.empty();

  @override
  Stream<Subtitle?> get currentSubtitleStream => const Stream.empty();

  @override
  void updatePosition(Duration position) {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('未预期调用: ${invocation.memberName}');
}

const double _trackWidth = 300;

void main() {
  late _CountingAudioService audio;
  late PlaybackEventHub hub;
  late PlayerViewModel vm;

  setUp(() async {
    audio = _CountingAudioService();
    hub = PlaybackEventHub();
    vm = PlayerViewModel(
      audioService: audio,
      eventHub: hub,
      subtitleService: _FakeSubtitleService(),
    );
    GetIt.I.registerSingleton<PlayerViewModel>(vm);
  });

  tearDown(() async {
    await GetIt.I.reset();
    vm.dispose();
  });

  Future<void> pumpBar(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: _trackWidth, child: WaveformProgress()),
          ),
        ),
      ),
    );
    // duration 必须非空，否则 seekToDx 直接 return，拖动不产生任何 seek。
    hub.emit(PlaybackStateEvent(
      PlayerState(false, ProcessingState.ready),
      Duration.zero,
      const Duration(seconds: 100),
    ));
    await tester.pump();
    await tester.pump();
    // 前置条件：duration 没落地时 seekToDx 会静默 return，测试会「0 次 seek」
    // 假绿。这里断死，防止回路失效而无人察觉。
    expect(vm.duration, const Duration(seconds: 100),
        reason: '前置条件不成立：duration 未送达，拖动不会产生任何 seek');
  }

  /// 轨道是 LinearTrackPainter 的那个 CustomPaint——MaterialApp/Scaffold 自带
  /// 多个 CustomPaint，按类型取 first 会抓错目标，手势落到空处。
  Finder trackFinder() => find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is LinearTrackPainter);

  /// 从 10% 拖到 ~70%，60 个 pointer move，模拟真机约 1 秒的连续拖动。
  Future<void> dragAcross(WidgetTester tester) async {
    final track = trackFinder();
    expect(track, findsOneWidget);
    final topLeft = tester.getTopLeft(track);
    final size = tester.getSize(track);

    final gesture = await tester.startGesture(
      Offset(topLeft.dx + size.width * 0.1, topLeft.dy + size.height / 2),
    );
    for (var i = 0; i < 60; i++) {
      await gesture.moveBy(Offset(size.width * 0.01, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump();
  }

  testWidgets('一次连续拖动只应产生少量 seek，而不是每个 pointer move 一次', (tester) async {
    await pumpBar(tester);
    await dragAcross(tester);

    // 拖动必须真的到达手势层，否则 0 次 seek 也能满足上限断言（假绿）。
    expect(audio.seeks, isNotEmpty, reason: '手势没打到轨道上，回路本身失效');
    expect(
      audio.seeks.length,
      lessThanOrEqualTo(5),
      reason: '一次拖动打了 ${audio.seeks.length} 次 seek——每次都是 await ready + '
          '平台通道往返，这就是拖动卡顿的来源',
    );
  });

  testWidgets('拖动结束后必须 seek 到抬手处（节流不能吞掉最终位置）', (tester) async {
    await pumpBar(tester);
    await dragAcross(tester);

    expect(audio.seeks, isNotEmpty);
    // 抬手在 70% → 100s * 0.7 = 70s，容 2s 抖动。
    expect(
      audio.seeks.last.inSeconds,
      closeTo(70, 2),
      reason: '最终 seek 必须落在抬手位置，否则节流把用户的目标位置丢了',
    );
  });
}
