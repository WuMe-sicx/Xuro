/// player_viewmodel_position_test.dart：锁定 PlayerViewModel 的 position 通知边界——
/// 高频位置 tick 只能走 positionListenable，绝不能触发 notifyListeners()；切轨仍要通知。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/audio/events/playback_event.dart';
import 'package:xuro/core/audio/events/playback_event_hub.dart';
import 'package:xuro/core/audio/i_audio_player_service.dart';
import 'package:xuro/core/audio/models/audio_track_info.dart';
import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/core/subtitle/i_subtitle_service.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';

/// 播放路径全程用不到，误用即暴露（noSuchMethod 抛错）。
class _FakeAudioService implements IAudioPlayerService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('未预期调用: ${invocation.memberName}');
}

/// 只实现 PlayerViewModel 构造/进度路径实际会碰到的两个流 + updatePosition，
/// 其余（导入字幕等）本轮测试不触达。
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

void main() {
  test('位置事件只驱动 positionListenable，不触发 notifyListeners；切轨仍触发', () {
    fakeAsync((async) {
      final hub = PlaybackEventHub();
      final vm = PlayerViewModel(
        audioService: _FakeAudioService(),
        eventHub: hub,
        subtitleService: _FakeSubtitleService(),
      );

      var n = 0;
      vm.addListener(() => n++);
      var m = 0;
      vm.positionListenable.addListener(() => m++);

      // 三次不同位置，间隔跨过 200ms 节流窗口，确保都能落地而非被丢弃。
      hub.emit(PlaybackProgressEvent(const Duration(milliseconds: 100), null));
      async.elapse(const Duration(milliseconds: 250));
      hub.emit(PlaybackProgressEvent(const Duration(milliseconds: 500), null));
      async.elapse(const Duration(milliseconds: 250));
      hub.emit(PlaybackProgressEvent(const Duration(milliseconds: 900), null));
      async.elapse(const Duration(milliseconds: 250));

      expect(n, 0, reason: '位置 tick 绝不能走 ChangeNotifier，否则退化回全员 5Hz 广播');
      expect(m, greaterThan(0));
      expect(vm.position, const Duration(milliseconds: 900));

      // 切轨：锁住「共享通知 seam 仍然通知」，防止将来误删外层订阅。
      hub.emit(
        TrackChangeEvent(
          AudioTrackInfo(title: 't', artist: 'a', coverUrl: '', url: ''),
          Child(),
          Work(),
        ),
      );
      async.flushMicrotasks();

      expect(n, 1);

      vm.dispose();
    });
  });
}
