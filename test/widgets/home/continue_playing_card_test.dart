/// continue_playing_card_test.dart：继续播放卡片——无播放态时整块不渲染；
/// 有播放态时渲染标题/进度，且进度条已播段随三配色（blue/still）取
/// `colorScheme.primary`。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/audio/events/playback_event.dart';
import 'package:xuro/core/audio/events/playback_event_hub.dart';
import 'package:xuro/core/audio/i_audio_player_service.dart';
import 'package:xuro/core/audio/models/audio_track_info.dart';
import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/subtitle/i_subtitle_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/presentation/viewmodels/player_viewmodel.dart';
import 'package:xuro/widgets/home/continue_playing_card.dart';

/// 只暴露 PlayerViewModel 构造/本卡片实际会读到的 `currentTrack`，
/// 其余方法调用即报错（同 player_viewmodel_position_test.dart 的先例）。
class _FakeAudioService implements IAudioPlayerService {
  @override
  AudioTrackInfo? currentTrack;

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

Widget _host(ColorScheme scheme, PlayerViewModel vm) => MaterialApp(
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: Scaffold(body: ContinuePlayingCard(viewModel: vm)),
    );

void main() {
  testWidgets('没有上次播放态（currentTrack 为 null）→ 整块不渲染', (tester) async {
    final vm = PlayerViewModel(
      audioService: _FakeAudioService(),
      eventHub: PlaybackEventHub(),
      subtitleService: _FakeSubtitleService(),
    );

    await tester.pumpWidget(
      _host(AppColors.lightSchemeFor(ColorVariant.blue), vm),
    );

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.text(Strings.continuePlaying), findsNothing);

    vm.dispose();
  });

  group('有播放态 → 渲染标题/进度，进度条取 colorScheme.primary（blue / still）', () {
    for (final v in [ColorVariant.blue, ColorVariant.still]) {
      testWidgets(v.name, (tester) async {
        final audio = _FakeAudioService()
          ..currentTrack = AudioTrackInfo(
            title: '测试曲目',
            artist: '测试社团',
            coverUrl: '',
            url: 'https://example.com/a.mp3',
          );
        final hub = PlaybackEventHub();
        final vm = PlayerViewModel(
          audioService: audio,
          eventHub: hub,
          subtitleService: _FakeSubtitleService(),
        );

        final scheme = AppColors.lightSchemeFor(v);
        await tester.pumpWidget(_host(scheme, vm));

        // 触发一次播放状态事件，带上 position/duration（PlayerViewModel 的
        // position/duration 均来自这条流，不是构造时就有）。
        hub.emit(PlaybackStateEvent(
          PlayerState(false, ProcessingState.ready),
          const Duration(milliseconds: 500),
          const Duration(seconds: 2),
        ));
        await tester.pump();

        expect(find.text(Strings.continuePlaying), findsOneWidget);
        expect(find.text('测试曲目'), findsOneWidget);
        expect(find.text('测试社团'), findsOneWidget);

        final progress = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progress.value, closeTo(0.25, 0.001));
        final valueColor = progress.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, scheme.primary);

        vm.dispose();
      });
    }
  });
}
