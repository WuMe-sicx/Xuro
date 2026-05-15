import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/presentation/viewmodels/detail_viewmodel.dart';

void main() {
  Child audio(String title) => Child(type: 'audio', title: title);
  Child sub(String title) => Child(type: 'text', title: title);
  Child folder(String title, List<Child> children) =>
      Child(type: 'folder', title: title, children: children);

  group('DetailViewModel.collectAudioWithSubtitles (pure)', () {
    test('flattens nested folders and pairs sibling subtitle', () {
      final tree = [
        folder('第1章', [audio('01.mp3'), sub('01.vtt'), audio('02.mp3')]),
        folder('第2章', [
          folder('深层', [audio('03.mp3'), sub('03.lrc')]),
        ]),
      ];

      final pairs = DetailViewModel.collectAudioWithSubtitles(tree);

      expect(pairs.map((p) => p.audio.title),
          ['01.mp3', '02.mp3', '03.mp3']);
      expect(pairs[0].subtitle?.title, '01.vtt'); // exact sibling match
      expect(pairs[1].subtitle, isNull); // no subtitle for 02
      expect(pairs[2].subtitle?.title, '03.lrc'); // deep folder sibling
    });

    test('subtitle in a different folder is NOT paired (siblings only)', () {
      final tree = [
        folder('audio', [audio('track.mp3')]),
        folder('subs', [sub('track.vtt')]),
      ];

      final pairs = DetailViewModel.collectAudioWithSubtitles(tree);

      expect(pairs.length, 1);
      expect(pairs.single.audio.title, 'track.mp3');
      expect(pairs.single.subtitle, isNull);
    });

    test('ignores non-audio leaves; null children → empty', () {
      expect(DetailViewModel.collectAudioWithSubtitles(null), isEmpty);
      final tree = [
        Child(type: 'image', title: 'cover.jpg'),
        sub('orphan.vtt'),
        audio('only.mp3'),
      ];
      final pairs = DetailViewModel.collectAudioWithSubtitles(tree);
      expect(pairs.length, 1);
      expect(pairs.single.audio.title, 'only.mp3');
      expect(pairs.single.subtitle, isNull);
    });
  });
}
