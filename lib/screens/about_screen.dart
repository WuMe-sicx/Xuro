import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/screens/settings/widgets/settings_group.dart';
import 'package:xuro/screens/settings/widgets/settings_tile.dart';
import 'package:xuro/screens/settings/widgets/settings_theme.dart';
import 'package:xuro/presentation/widgets/update/update_dialog.dart';
import 'package:xuro/widgets/common/app_footer.dart';
import 'package:xuro/widgets/common/brand_wordmark.dart';
import 'package:xuro/widgets/common/social_icon_row.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Strings.cannotOpenLink)),
        );
      }
    }
  }

  // 居中品牌头：标志锁定 + 版本 + 简介（对齐参考图关于页结构）。
  Widget _header(BuildContext context, String version) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space24,
        AppSpacing.space24,
        AppSpacing.space24,
        AppSpacing.space24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const BrandWordmark(
            text: Strings.aboutAppName,
            fontSize: 28,
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            '${Strings.versionLabel} v$version',
            style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            Strings.aboutAppDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = SettingsTheme.pageBackground(context);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.aboutUs)),
      backgroundColor: bgColor,
      body: SettingsTheme.noSplashTheme(
        context: context,
        child: FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (context, snapshot) {
            final version = snapshot.hasData ? snapshot.data!.version : '...';
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
              children: [
                _header(context, version),
                SettingsGroup(
                  header: Strings.about,
                  children: [
                    SettingsTile.navigation(
                      title: Strings.checkForUpdates,
                      leading: Icons.system_update_outlined,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const UpdateDialog(),
                      ),
                    ),
                    SettingsTile.navigation(
                      title: Strings.openSourceLicenses,
                      leading: Icons.description_outlined,
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: Strings.appName,
                        applicationVersion: snapshot.data?.version,
                      ),
                    ),
                    SettingsTile.navigation(
                      title: Strings.feedback,
                      leading: Icons.feedback_outlined,
                      onTap: () => _openUrl(context, Strings.feedbackUrl),
                    ),
                    SettingsTile.navigation(
                      title: Strings.originalRepo,
                      leading: Icons.account_circle_outlined,
                      onTap: () => _openUrl(context, Strings.originalRepoUrl),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space24),
                SocialIconRow(
                  actions: [
                    SocialAction(
                      icon: Icons.send_outlined,
                      semanticLabel: Strings.telegramChannel,
                      onTap: () =>
                          _openUrl(context, Strings.telegramChannelUrl),
                    ),
                    SocialAction(
                      icon: Icons.code,
                      semanticLabel: Strings.sourceCode,
                      onTap: () => _openUrl(context, Strings.repoUrl),
                    ),
                  ],
                ),
                const AppFooter(text: Strings.aboutFooter),
              ],
            );
          },
        ),
      ),
    );
  }
}
