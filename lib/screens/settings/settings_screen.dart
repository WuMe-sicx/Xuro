import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/core/theme/theme_controller.dart';
import 'package:asmrapp/core/platform/wakelock_controller.dart';
import 'package:asmrapp/screens/settings/cache_manager_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.settings),
      ),
      body: ListView(
        children: [
          _sectionHeader(context, '外观'),
          Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return RadioGroup<ThemeMode>(
                groupValue: themeController.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeController.setThemeMode(value);
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text('跟随系统'),
                      subtitle: Text('自动切换深浅色模式'),
                      value: ThemeMode.system,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('浅色模式'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('深色模式'),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              );
            },
          ),
          _sectionHeader(context, '播放'),
          Builder(builder: (context) {
            final controller = GetIt.I<WakeLockController>();
            return ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return SwitchListTile(
                  title: const Text('屏幕常亮'),
                  subtitle: const Text('播放时保持屏幕开启'),
                  value: controller.enabled,
                  onChanged: (_) => controller.toggle(),
                );
              },
            );
          }),
          _sectionHeader(context, '存储'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('缓存管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CacheManagerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
