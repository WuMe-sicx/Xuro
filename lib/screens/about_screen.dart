import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/screens/settings/widgets/settings_group.dart';
import 'package:xuro/screens/settings/widgets/settings_tile.dart';
import 'package:xuro/screens/settings/widgets/settings_theme.dart';
import 'package:xuro/presentation/widgets/update/update_dialog.dart';

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

  Widget _intro(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.aboutAppName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            Strings.aboutAppDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
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
            final version = snapshot.hasData
                ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                : '...';
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _intro(context),
                SettingsGroup(
                  header: Strings.about,
                  children: [
                    SettingsTile.navigation(
                      title: Strings.versionInfo,
                      leading: Icons.info_outline,
                      value: version,
                    ),
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
                      title: Strings.sourceCode,
                      leading: Icons.code_outlined,
                      onTap: () => _openUrl(context, Strings.repoUrl),
                    ),
                    SettingsTile.navigation(
                      title: Strings.originalRepo,
                      leading: Icons.account_circle_outlined,
                      onTap: () => _openUrl(context, Strings.originalRepoUrl),
                    ),
                    SettingsTile.navigation(
                      title: Strings.telegramChannel,
                      leading: Icons.send_outlined,
                      onTap: () =>
                          _openUrl(context, Strings.telegramChannelUrl),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
