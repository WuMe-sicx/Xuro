# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Xuro is a Flutter-based ASMR.ONE client app (package name: `xuro`, app ID: `com.xuro`). It provides ASMR audio streaming with background playback, subtitle/lyric display, playlists, and caching. Licensed CC BY-NC-SA.

## Build & Development Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed + json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run the app (debug)
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Static analysis
flutter analyze

# Build release APK
flutter build apk --release

# Build iOS (no codesign)
flutter build ios --no-codesign
```

**Environment:** Dart SDK >=3.2.3 <4.0.0, Flutter 3.27.0, Android min SDK 21 / target 33, Java 17.

## Architecture

Clean Architecture with three layers, using **Provider (ChangeNotifier)** for state management and **GetIt** for dependency injection.

### Layer Structure

- **`lib/core/`** - Platform services and infrastructure
  - `di/service_locator.dart` - GetIt DI container setup (entry point for all service registration)
  - `audio/` - Audio playback system: `IAudioPlayerService` interface + implementation, PlaybackEventHub (event bus pattern), state persistence, notification handling
  - `subtitle/` - Subtitle/lyric system: `ISubtitleService` interface, parsers (VTT etc.), subtitle loader with caching
  - `platform/` - Platform-specific: `ILyricOverlayController` (Android floating lyric window, dummy on other platforms), WakeLockController
  - `theme/` - ThemeController with light/dark mode, AppTheme definitions
  - `cache/` - RecommendationCacheManager

- **`lib/data/`** - Data layer
  - `models/` - Freezed immutable data classes (auto-generated `.freezed.dart` + `.g.dart` files)
  - `services/api_service.dart` - Dio HTTP client hitting `https://api.asmr.one/api`
  - `services/auth_service.dart` - Authentication
  - `services/interceptors/auth_interceptor.dart` - Dio auth interceptor
  - `repositories/` - Repository implementations (AuthRepository, audio state)

- **`lib/presentation/`** - Presentation layer
  - `viewmodels/` - ChangeNotifier ViewModels (one per screen). `PaginatedWorksViewModel` is the base class for all paginated list screens
  - `viewmodels/player_viewmodel.dart` - Central player state, depends on AudioService + SubtitleService + EventHub

- **`lib/screens/`** - Full-page screens. `MainScreen` is the tab-based root. `contents/` holds the tab content widgets

- **`lib/widgets/`** - Reusable UI components (work cards, player controls, lyrics, mini player, filters)

- **`lib/common/constants/strings.dart`** - All UI strings centralized here (no hardcoded strings)

### Key Patterns

- **Service Locator**: All services registered in `service_locator.dart`. Access via `getIt<T>()`
- **Interface/Implementation**: Core services use interfaces (`IAudioPlayerService`, `ISubtitleService`, `ILyricOverlayController`) for testability and platform abstraction
- **EventHub**: `PlaybackEventHub` broadcasts audio state changes via RxDart streams
- **Freezed models**: Data classes use `@freezed` annotation. After modifying model files, run `build_runner`
- **Platform branching**: Android gets real `LyricOverlayController`; other platforms get `DummyLyricOverlayController`

### App Initialization Flow

`main()` -> `setupServiceLocator()` (async DI init, loads saved auth) -> `runApp(MyApp())` -> `MultiProvider` wraps `MaterialApp` with `AuthViewModel` + `ThemeController`

### API

All API calls go through `ApiService` using Dio, base URL `https://api.asmr.one/api`. Auth handled by `AuthInterceptor`. Key endpoints: `/works`, `/tracks/{id}`, `/search/{keyword}`, `/review`, `/recommender/*`, `/playlist/*`.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`) triggers on `v*` tags. Builds Android APK/AAB (signed) + iOS IPA, creates GitHub release with changelog.

## Code Generation

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis. When adding or modifying data models in `lib/data/models/`, always re-run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
