import 'dart:io';
import 'package:dio/dio.dart';
import 'package:xuro/data/services/interceptors/retry_interceptor.dart';
import 'package:xuro/data/services/interceptors/auth_interceptor.dart';
import 'package:xuro/core/platform/dummy_lyric_overlay_controller.dart';
import 'package:get_it/get_it.dart';
import '../audio/i_audio_player_service.dart';
import '../audio/audio_player_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/update_service.dart';
import '../../presentation/viewmodels/player_viewmodel.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import '../subtitle/i_subtitle_service.dart';
import '../subtitle/subtitle_service.dart';
import '../subtitle/subtitle_loader.dart';
import '../../core/audio/storage/i_playback_state_repository.dart';
import '../../core/audio/storage/playback_state_repository.dart';
import '../audio/events/playback_event_hub.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/platform/i_lyric_overlay_controller.dart';
import '../../core/platform/lyric_overlay_controller.dart';
import '../../core/platform/lyric_overlay_manager.dart';
import '../../core/platform/wakelock_controller.dart';
import '../../core/platform/sleep_timer_controller.dart';
import '../../core/platform/background_play_controller.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/database/database_service.dart';
import 'package:xuro/core/subtitle/storage/i_user_subtitle_repository.dart';
import 'package:xuro/core/subtitle/storage/user_subtitle_repository.dart';
import 'package:xuro/core/subtitle/import/i_file_picker_service.dart';
import 'package:xuro/core/subtitle/import/file_picker_service.dart';
import 'package:xuro/core/subtitle/subtitle_import_service.dart';
import 'package:xuro/core/download/storage/i_download_repository.dart';
import 'package:xuro/core/download/storage/download_repository.dart';
import 'package:xuro/core/download/download_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();

  // 注册 EventHub
  getIt.registerLazySingleton(() => PlaybackEventHub());

  // 注册 SharedPreferences 实例
  getIt.registerSingleton<SharedPreferences>(prefs);

  // 数据库服务
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());

  // 用户字幕存储
  getIt.registerLazySingleton<IUserSubtitleRepository>(
    () => UserSubtitleRepository(getIt<DatabaseService>()),
  );

  // 文件选择器
  getIt.registerLazySingleton<IFilePickerService>(() => FilePickerService());

  // 字幕导入服务
  getIt.registerLazySingleton<SubtitleImportService>(
    () => SubtitleImportService(
      picker: getIt<IFilePickerService>(),
      repository: getIt<IUserSubtitleRepository>(),
    ),
  );

  // 下载存储 + 服务（依赖 DatabaseService，已于上方注册）
  getIt.registerLazySingleton<IDownloadRepository>(
    () => DownloadRepository(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<DownloadService>(
    () => DownloadService(repository: getIt<IDownloadRepository>()),
  );

  // 注册 PlaybackStateRepository
  getIt.registerLazySingleton<IPlaybackStateRepository>(
    () => PlaybackStateRepository(getIt()),
  );

  // 核心服务
  getIt.registerLazySingleton<IAudioPlayerService>(
    () => AudioPlayerService(
      eventHub: getIt(),
      stateRepository: getIt(),
    ),
  );

  // 注册 PlayerViewModel
  getIt.registerLazySingleton<PlayerViewModel>(
    () => PlayerViewModel(
      audioService: getIt(),
      eventHub: getIt(),
      subtitleService: getIt(),
    ),
  );

  // 注册 AppSettingsService
  getIt.registerSingleton<AppSettingsService>(
    AppSettingsService(prefs),
  );

  // API 服务
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(settings: getIt<AppSettingsService>()),
  );

  // 检查更新服务（独立 GitHub Dio，与 asmr 节点解耦）
  getIt.registerLazySingleton<UpdateService>(
    () => UpdateService(),
  );

  // 添加 AuthService 注册
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(settings: getIt<AppSettingsService>()),
  );

  // 添加 AuthRepository 注册
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(prefs),
  );

  // 修改 AuthViewModel 注册
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(
      authService: getIt<AuthService>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // 添加字幕服务注册
  getIt.registerLazySingleton<ISubtitleService>(
    () => SubtitleService(),
  );

  setupSubtitleServices();

  // 注册主题控制器
  getIt.registerLazySingleton<ThemeController>(
    () => ThemeController(prefs),
  );

  // 注册 WakeLockController
  getIt.registerLazySingleton(() => WakeLockController(prefs));

  // 注册 SleepTimerController（会话级；到点 pause()，不持久化）
  getIt.registerLazySingleton(
    () => SleepTimerController(getIt<IAudioPlayerService>()),
  );

  // 注册 BackgroundPlayController（后台播放开关执行端，main 中 initialize）
  getIt.registerLazySingleton(
    () => BackgroundPlayController(
      settings: getIt<AppSettingsService>(),
      audioService: getIt<IAudioPlayerService>(),
    ),
  );
}

void setupSubtitleServices() {
  getIt.registerLazySingleton<SubtitleLoader>(() {
    final dio = Dio();
    dio.interceptors.add(RetryInterceptor(dio: dio));
    dio.interceptors.add(AuthInterceptor());
    return SubtitleLoader(dio: dio);
  });
  if (Platform.isAndroid) {
    getIt.registerLazySingleton<ILyricOverlayController>(
        () => LyricOverlayController());
  } else {
    getIt.registerLazySingleton<ILyricOverlayController>(
        () => DummyLyricOverlayController());
  }
  getIt.registerLazySingleton(() => LyricOverlayManager(
        controller: getIt(),
        subtitleService: getIt(),
        settings: getIt<AppSettingsService>(),
      ));
}

/// 首帧之后再执行的非关键启动初始化。
///
/// `LyricOverlayManager.initialize()` 会做平台通道往返（controller.initialize /
/// isShowing），放在冷启动关键路径（runApp 之前）上会拖慢首个可交互帧，而悬浮
/// 歌词在有曲目播放、用户开启之前并不需要——因此推迟到首帧绘制之后再做。
Future<void> initDeferredStartupServices() async {
  await getIt<LyricOverlayManager>().initialize();
}
