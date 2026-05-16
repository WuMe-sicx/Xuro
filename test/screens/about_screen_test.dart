import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/screens/about_screen.dart';
import 'package:xuro/widgets/common/app_footer.dart';
import 'package:xuro/widgets/common/brand_wordmark.dart';
import 'package:xuro/widgets/common/social_icon_row.dart';

/// D2 关于页结构回归：对齐参考图——居中品牌头(BrandWordmark+版本)、
/// 复用 SettingsGroup 真实链接、SocialIconRow、AppFooter；版本不再是列表项。
void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Xuro',
      packageName: 'com.xuro',
      version: '9.9.9',
      buildNumber: '42',
      buildSignature: '',
    );
  });

  testWidgets('品牌头 + 版本 + Social + Footer 就位，版本不再是列表项',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();

    // 居中品牌锁定（品牌名取 Strings.aboutAppName='Xuro'，非模板 'ASMR'）
    final wordmark = tester.widget<BrandWordmark>(find.byType(BrandWordmark));
    expect(wordmark.text, Strings.aboutAppName);
    expect(find.text('Xuro'), findsOneWidget);

    // 版本在头部，不在列表（旧 '版本信息' tile 已移除）
    expect(find.text('${Strings.versionLabel} v9.9.9'), findsOneWidget);
    expect(find.text(Strings.versionInfo), findsNothing);

    // Social 行有 2 个真实入口（Telegram + GitHub）
    final social = tester.widget<SocialIconRow>(find.byType(SocialIconRow));
    expect(social.actions.length, 2);

    // 真实 CC 版权脚（非模板 "© 2024 ASMR All Rights Reserved"）
    final footer = tester.widget<AppFooter>(find.byType(AppFooter));
    expect(footer.text, Strings.aboutFooter);
    expect(footer.text.contains('CC BY-NC-SA'), isTrue);
  });
}
