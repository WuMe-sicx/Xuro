import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/data/services/update_service.dart';

void main() {
  group('UpdateService.compareSemver', () {
    test('完全相等返回 0', () {
      expect(UpdateService.compareSemver('1.1.11', '1.1.11'), 0);
    });

    test('主/次/修订号各位的大于小于', () {
      expect(UpdateService.compareSemver('2.0.0', '1.9.9'), greaterThan(0));
      expect(UpdateService.compareSemver('1.2.0', '1.1.9'), greaterThan(0));
      expect(UpdateService.compareSemver('1.1.12', '1.1.11'), greaterThan(0));
      expect(UpdateService.compareSemver('1.1.11', '1.1.12'), lessThan(0));
    });

    test('位数不齐按 0 补齐：1.2 == 1.2.0', () {
      expect(UpdateService.compareSemver('1.2', '1.2.0'), 0);
      expect(UpdateService.compareSemver('1.2.1', '1.2'), greaterThan(0));
    });

    test('剥离 v / V 前缀', () {
      expect(UpdateService.compareSemver('v1.1.12', '1.1.11'), greaterThan(0));
      expect(UpdateService.compareSemver('V1.1.11', 'v1.1.11'), 0);
    });

    test('非法输入按 0 处理而非崩溃', () {
      expect(UpdateService.compareSemver('abc', '0.0.0'), 0);
      expect(UpdateService.compareSemver('1.x.3', '1.0.3'), 0);
      expect(UpdateService.compareSemver('', '0.0.0'), 0);
    });
  });

  group('UpdateService.selectLatestRelease 选最大', () {
    Map<String, dynamic> release(String tag) => {
          'tag_name': tag,
          'html_url': 'https://github.com/WuMe-sicx/Xuro/releases/tag/$tag',
          'body': 'notes $tag',
          'assets': const [],
        };

    test('列表首项是旧 tag、靠后才是最大 → 选最大', () {
      final picked = UpdateService.selectLatestRelease([
        release('v1.1.9'),
        release('v1.2.0'),
        release('v1.1.11'),
      ]);
      expect(picked, isNotNull);
      expect(picked!.version, '1.2.0');
    });

    test('空列表 → null', () {
      expect(UpdateService.selectLatestRelease(const []), isNull);
    });

    test('全部 tag 非法（含带后缀的 pre-release tag）→ null', () {
      final picked = UpdateService.selectLatestRelease([
        release('nightly'),
        release('v1.2.3-rc.1'),
        release('v1.2.3foo'),
        release('1.2'),
      ]);
      expect(picked, isNull);
    });

    test('合法 tag 但缺 html_url 的条目被跳过，不拖垮整次', () {
      final picked = UpdateService.selectLatestRelease([
        {'tag_name': 'v9.9.9', 'body': 'broken, no html_url'},
        release('v1.0.0'),
      ]);
      expect(picked, isNotNull);
      expect(picked!.version, '1.0.0');
    });
  });
}
