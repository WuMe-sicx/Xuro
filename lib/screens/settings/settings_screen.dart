import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/theme_controller.dart';
import 'package:xuro/core/platform/wakelock_controller.dart';
import 'package:xuro/core/platform/sleep_timer_controller.dart';
import 'package:xuro/core/platform/lyric_overlay_manager.dart';
import 'package:xuro/screens/settings/sleep_timer_dialog.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/screens/settings/cache_manager_screen.dart';
import 'package:xuro/screens/settings/audio_format_order_dialog.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/screens/settings/widgets/settings_group.dart';
import 'package:xuro/screens/settings/widgets/settings_tile.dart';
import 'package:xuro/screens/settings/widgets/settings_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final bgColor = SettingsTheme.pageBackground(context);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.settings)),
      backgroundColor: bgColor,
      body: SettingsTheme.noSplashTheme(
        context: context,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
          children: [
            _appearanceSection(),
            const SizedBox(height: AppSpacing.space24),
            _colorVariantSection(),
            const SizedBox(height: AppSpacing.space24),
            _networkSection(),
            const SizedBox(height: AppSpacing.space24),
            _contentSection(context),
            const SizedBox(height: AppSpacing.space24),
            _playbackSection(),
            const SizedBox(height: AppSpacing.space24),
            _lyricOverlaySection(),
            const SizedBox(height: AppSpacing.space24),
            _storageSection(context),
          ],
        ),
      ),
    );
  }

  Widget _appearanceSection() {
    return Consumer<ThemeController>(
      builder: (context, tc, _) => SettingsGroup(
        header: Strings.appearance,
        footer: Strings.themeAutoDesc,
        children: [
          SettingsTile.selection(
            title: Strings.followSystem,
            leading: Icons.brightness_auto_outlined,
            selected: tc.themeMode == ThemeMode.system,
            onTap: () => tc.setThemeMode(ThemeMode.system),
          ),
          SettingsTile.selection(
            title: Strings.lightMode,
            leading: Icons.light_mode_outlined,
            selected: tc.themeMode == ThemeMode.light,
            onTap: () => tc.setThemeMode(ThemeMode.light),
          ),
          SettingsTile.selection(
            title: Strings.darkMode,
            leading: Icons.dark_mode_outlined,
            selected: tc.themeMode == ThemeMode.dark,
            onTap: () => tc.setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }

  // 配色行的 leading 是「色彩选择器内容」——显示该配色在当前亮暗下的
  // 真实 primary（语义必需例外，非组件 chrome；其余 leading 仍中性）。
  Color _variantSwatch(BuildContext context, ColorVariant v) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? AppColors.darkSchemeFor(v).primary
        : AppColors.lightSchemeFor(v).primary;
  }

  Widget _colorVariantSection() {
    return Builder(builder: (context) {
      final settings = GetIt.I<AppSettingsService>();
      return ListenableBuilder(
        listenable: settings,
        builder: (context, _) => SettingsGroup(
          header: Strings.colorVariantTitle,
          footer: Strings.colorVariantDesc,
          children: [
            SettingsTile.selection(
              title: Strings.colorVariantBlue,
              leading: Icons.circle,
              leadingColor: _variantSwatch(context, ColorVariant.blue),
              selected: settings.colorVariant == ColorVariant.blue,
              onTap: () => settings.setColorVariant(ColorVariant.blue),
            ),
            SettingsTile.selection(
              title: Strings.colorVariantMono,
              leading: Icons.circle,
              leadingColor: _variantSwatch(context, ColorVariant.mono),
              selected: settings.colorVariant == ColorVariant.mono,
              onTap: () => settings.setColorVariant(ColorVariant.mono),
            ),
            SettingsTile.selection(
              title: Strings.colorVariantGreen,
              leading: Icons.circle,
              leadingColor: _variantSwatch(context, ColorVariant.green),
              selected: settings.colorVariant == ColorVariant.green,
              onTap: () => settings.setColorVariant(ColorVariant.green),
            ),
          ],
        ),
      );
    });
  }

  Widget _networkSection() {
    return Builder(builder: (context) {
      final settings = GetIt.I<AppSettingsService>();
      return ListenableBuilder(
        listenable: settings,
        builder: (context, _) => SettingsGroup(
          header: Strings.network,
          children: AppSettingsService.serverOptions.entries.map((entry) {
            return SettingsTile.selection(
              title: entry.value,
              subtitle: entry.key,
              leading: Icons.lan_outlined,
              selected: settings.serverUrl == entry.key,
              onTap: () => settings.setServerUrl(entry.key),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _contentSection(BuildContext context) {
    return Builder(builder: (context) {
      final settings = GetIt.I<AppSettingsService>();
      return ListenableBuilder(
        listenable: settings,
        builder: (context, _) => SettingsGroup(
          header: Strings.content,
          children: [
            SettingsTile.toggle(
              title: Strings.smartPath,
              subtitle: Strings.smartPathDesc,
              leading: Icons.folder_open_outlined,
              value: settings.smartPathEnabled,
              onChanged: (v) => settings.setSmartPathEnabled(v),
            ),
            SettingsTile.navigation(
              title: Strings.audioFormatPreference,
              leading: Icons.audio_file_outlined,
              value: settings.audioFormatOrder.join(' > '),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AudioFormatOrderDialog(settings: settings),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _playbackSection() {
    return Builder(builder: (context) {
      final wakeLock = GetIt.I<WakeLockController>();
      final sleepTimer = GetIt.I<SleepTimerController>();
      final settings = GetIt.I<AppSettingsService>();
      return ListenableBuilder(
        listenable: Listenable.merge([wakeLock, sleepTimer, settings]),
        builder: (context, _) => SettingsGroup(
          header: Strings.playback,
          children: [
            SettingsTile.navigation(
              title: Strings.sleepTimer,
              leading: Icons.bedtime_outlined,
              value: sleepTimer.minutes == null
                  ? Strings.sleepTimerOff
                  : Strings.sleepTimerMinutes(sleepTimer.minutes!),
              onTap: () => showDialog(
                context: context,
                builder: (_) => SleepTimerDialog(controller: sleepTimer),
              ),
            ),
            SettingsTile.toggle(
              title: Strings.backgroundPlay,
              subtitle: Strings.backgroundPlayDesc,
              leading: Icons.play_circle_outline,
              value: settings.backgroundPlayEnabled,
              onChanged: (v) => settings.setBackgroundPlayEnabled(v),
            ),
            SettingsTile.toggle(
              title: Strings.screenKeepAwake,
              subtitle: Strings.screenKeepAwakeDesc,
              leading: Icons.wb_sunny_outlined,
              value: wakeLock.enabled,
              onChanged: (_) => wakeLock.toggle(),
            ),
          ],
        ),
      );
    });
  }

  Widget _lyricOverlaySection() {
    return Builder(builder: (context) {
      final settings = GetIt.I<AppSettingsService>();
      final manager = GetIt.I<LyricOverlayManager>();
      return ListenableBuilder(
        listenable: settings,
        builder: (context, _) => SettingsGroup(
          header: Strings.lyricOverlaySection,
          footer: Strings.lyricOverlayUnlockDesc,
          children: [
            SettingsTile.toggle(
              title: Strings.lyricOverlayUnlockTitle,
              leading: Icons.lyrics_outlined,
              value: settings.lyricOverlayUnlocked,
              onChanged: (v) => manager.setUnlockedPreference(v),
            ),
          ],
        ),
      );
    });
  }

  Widget _storageSection(BuildContext context) {
    return SettingsGroup(
      header: Strings.storage,
      children: [
        SettingsTile.navigation(
          title: Strings.cacheManager,
          leading: Icons.storage_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CacheManagerScreen()),
          ),
        ),
      ],
    );
  }
}
