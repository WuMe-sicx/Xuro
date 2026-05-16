import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/audio/cache/audio_cache_manager.dart';
import 'package:xuro/core/cache/cache_lifecycle_manager.dart';
import 'package:xuro/core/platform/background_play_controller.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'package:xuro/core/theme/app_theme.dart';
import 'package:xuro/core/theme/theme_controller.dart';
import 'screens/search_screen.dart';

void main() async {
  final startupStopwatch = kDebugMode ? (Stopwatch()..start()) : null;
  WidgetsFlutterBinding.ensureInitialized();

  // 内存图片缓存预算上限（配合各封面组件的 memCacheWidth 降采样解码，
  // 避免高分辨率封面把缓存撑爆）。
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MiB

  // 初始化服务定位器。仅保留首帧必需：prefs + 已保存鉴权态——
  // MainScreen 的各 ViewModel 在构造时即发起带 token 的请求，
  // 推迟鉴权会导致首批请求未带 token、误报登录态异常。
  await setupServiceLocator();

  runApp(const MyApp());

  // 缓存生命周期 / 旧缓存迁移：本就在 runApp 之后执行，且 CacheLifecycleManager
  // 内部已用 addPostFrameCallback 延迟首扫并自带 6h 节流，cleanLegacyCache 为
  // fire-and-forget 异步。直接调用即可——不再外套一层 post-frame，否则会把启动
  // 清理推到更靠后的帧（addPostFrameCallback 本身不主动请求下一帧）。
  CacheLifecycleManager().initialize();
  AudioCacheManager.cleanLegacyCache();

  // 后台播放开关执行端：注册生命周期观察者（默认开启＝行为不变）。
  getIt<BackgroundPlayController>().initialize();

  // 悬浮歌词管理器初始化会做平台通道往返，推迟到首帧绘制之后，避免拖慢首个可交互帧。
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (kDebugMode) {
      startupStopwatch!.stop();
      debugPrint(
        '[startup] main() → first frame: '
        '${startupStopwatch.elapsedMilliseconds} ms',
      );
    }
    initDeferredStartupServices();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<AuthViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<ThemeController>(),
        ),
        ChangeNotifierProvider.value(
          value: getIt<AppSettingsService>(),
        ),
      ],
      child: Consumer2<ThemeController, AppSettingsService>(
        builder: (context, themeController, settings, child) {
          final variant = settings.colorVariant;
          return MaterialApp(
            title: Strings.appName,
            theme: AppTheme.light(variant),
            darkTheme: AppTheme.dark(variant),
            themeMode: themeController.themeMode,
            home: const MainScreen(),
            routes: {
              // '/player': (context) => const PlayerScreen(),
              '/search': (context) {
                final keyword =
                    ModalRoute.of(context)?.settings.arguments as String?;
                return SearchScreen(initialKeyword: keyword);
              },
            },
          );
        },
      ),
    );
  }
}
