import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/core/audio/i_audio_player_service.dart';
import 'package:xuro/core/platform/sleep_timer_controller.dart';

/// 仅记录 pause() 次数；其余接口测试不触达 → noSuchMethod 抛错暴露误用。
class _FakeAudioService implements IAudioPlayerService {
  int pauseCount = 0;

  @override
  Future<void> pause() async => pauseCount++;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('未预期调用: ${invocation.memberName}');
}

void main() {
  group('SleepTimerController', () {
    test('初始状态：未设置、未激活、不暂停', () {
      final audio = _FakeAudioService();
      final c = SleepTimerController(audio);
      expect(c.minutes, isNull);
      expect(c.isActive, isFalse);
      expect(audio.pauseCount, 0);
    });

    test('setMinutes 设定时长 → minutes/isActive 反映', () {
      final c = SleepTimerController(_FakeAudioService());
      c.setMinutes(30);
      expect(c.minutes, 30);
      expect(c.isActive, isTrue);
    });

    test('setMinutes(null) / cancel() 取消并复位', () {
      final c = SleepTimerController(_FakeAudioService());
      c.setMinutes(30);
      c.setMinutes(null);
      expect(c.minutes, isNull);
      expect(c.isActive, isFalse);

      c.setMinutes(45);
      c.cancel();
      expect(c.minutes, isNull);
      expect(c.isActive, isFalse);
    });

    test('setMinutes(<=0) 视为取消', () {
      final c = SleepTimerController(_FakeAudioService());
      c.setMinutes(30);
      c.setMinutes(0);
      expect(c.minutes, isNull);
      expect(c.isActive, isFalse);
    });

    test('到点：调用一次 pause() 并自动复位', () {
      fakeAsync((async) {
        final audio = _FakeAudioService();
        final c = SleepTimerController(audio);
        c.setMinutes(1);
        async.elapse(const Duration(seconds: 59));
        expect(audio.pauseCount, 0);
        async.elapse(const Duration(seconds: 1));
        expect(audio.pauseCount, 1);
        expect(c.minutes, isNull);
        expect(c.isActive, isFalse);
      });
    });

    test('重新设定会取消旧 Timer（不重复 pause）', () {
      fakeAsync((async) {
        final audio = _FakeAudioService();
        final c = SleepTimerController(audio);
        c.setMinutes(15);
        async.elapse(const Duration(minutes: 10));
        c.setMinutes(45); // 替换：旧 15min Timer 应被取消
        async.elapse(const Duration(minutes: 10)); // 累计 20min，旧档若未取消会在此触发
        expect(audio.pauseCount, 0);
        async.elapse(const Duration(minutes: 35)); // 到 45min
        expect(audio.pauseCount, 1);
      });
    });

    test('cancel 后不再触发 pause', () {
      fakeAsync((async) {
        final audio = _FakeAudioService();
        final c = SleepTimerController(audio);
        c.setMinutes(5);
        async.elapse(const Duration(minutes: 2));
        c.cancel();
        async.elapse(const Duration(minutes: 10));
        expect(audio.pauseCount, 0);
      });
    });

    test('dispose 取消 Timer', () {
      fakeAsync((async) {
        final audio = _FakeAudioService();
        final c = SleepTimerController(audio);
        c.setMinutes(5);
        c.dispose();
        async.elapse(const Duration(minutes: 10));
        expect(audio.pauseCount, 0);
      });
    });
  });
}
