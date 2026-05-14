# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Mandatory Development Workflow

**Before touching code** for any task that touches multiple files _or_ has observable runtime / build / external behavior changes (single-file typo/format/comment fixes are exempt):

1. Read [`docs/dev_workflow.md`](docs/dev_workflow.md).
2. Create the task's TODO doc under [`docs/todos/active/`](docs/todos/active/) using [`docs/todos/_template.md`](docs/todos/_template.md). Fix goal, scope, acceptance criteria, and step-by-step plan **before** any code change.
3. During development, tick steps in the TODO doc as they land and reference produced files / commit hashes.
4. **On feature completion**: append the `✅ 完成标记` block (with `/init` line + timestamp), then **actually run `/init`** to refresh this `CLAUDE.md`. Move the TODO file from `active/` to `done/`.
5. Cancelled tasks go to `docs/todos/cancelled/` with a `⛔ 取消标记` block — they do **not** run `/init`.

Companion specs: [`docs/guidelines_zh.md`](docs/guidelines_zh.md) (architecture / code style), [`docs/ui-design-spec.md`](docs/ui-design-spec.md) (visual / animation), [`docs/audio_architecture.md`](docs/audio_architecture.md) (audio subsystem). On conflict: `dev_workflow > subsystem doc > general guidelines`.

## Project Overview

Xuro is a Flutter-based ASMR.ONE client app (package name: `xuro`, app ID: `com.xuro`). It provides ASMR audio streaming with background playback, subtitle/lyric display, playlists, and caching. Licensed CC BY-NC-SA.

## Build & Development Commands

This project pins Flutter **3.27.0** via [`.fvmrc`](.fvmrc). Prefer `fvm flutter ...` to ensure the pinned SDK is used; substitute plain `flutter` only if you have it on PATH and matching the pinned version.

```bash
# Install dependencies
fvm flutter pub get

# Run code generation (freezed + json_serializable)
fvm dart run build_runner build --delete-conflicting-outputs

# Run the app (debug)
fvm flutter run

# Run all tests (currently only test/widget_test.dart)
fvm flutter test

# Run a single test file
fvm flutter test test/widget_test.dart

# Static analysis (use this before commit; warnings exist for pre-existing
# withOpacity deprecations — don't introduce new ones)
fvm flutter analyze

# Analyze a single subtree (faster feedback while iterating)
fvm flutter analyze lib/widgets/sidebar/

# Build release APK
fvm flutter build apk --release

# Build iOS (no codesign)
fvm flutter build ios --no-codesign
```

**Environment:** Dart SDK >=3.2.3 <4.0.0, Flutter 3.27.0 (FVM-pinned), Android min SDK 21 / target 33, Java 17.

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
  - `database/` - `database_service.dart` (local persistence)
  - `image/cache/` - Image cache layer used by network image widgets
  - `settings/` - `app_settings_service.dart` (user preferences persistence)

- **`lib/data/`** - Data layer
  - `models/` - Freezed immutable data classes (auto-generated `.freezed.dart` + `.g.dart` files)
  - `services/api_service.dart` - Dio HTTP client hitting `https://api.asmr.one/api`
  - `services/auth_service.dart` - Authentication
  - `services/interceptors/auth_interceptor.dart` - Dio auth interceptor
  - `repositories/` - Repository implementations (AuthRepository, audio state)

- **`lib/presentation/`** - Presentation layer
  - `viewmodels/` - ChangeNotifier ViewModels (one per screen). `PaginatedWorksViewModel` is the base class for all paginated list screens
  - `viewmodels/player_viewmodel.dart` - Central player state, depends on AudioService + SubtitleService + EventHub
  - `layouts/` - `work_layout_config.dart` / `work_layout_strategy.dart` (responsive grid sizing — see ui-design-spec §5)
  - `models/filter_state.dart` - UI-only state object for the filter panel
  - `widgets/auth/` - Auth UI widgets (e.g., `LoginDialog`)

- **`lib/screens/`** - Full-page screens. `MainScreen` is the tab-based root. `contents/` holds the tab content widgets; `browse/` holds tag/circle/voice-actor lists; `settings/` holds the settings tree

- **`lib/widgets/`** - Reusable UI components (work cards, player controls, lyrics, mini player, filters, sidebar drawer). The sidebar (`widgets/sidebar/`) is a glassmorphism-styled drawer with its own dark palette enforced via a local `Theme` override — don't expect it to follow the global ColorScheme

- **`lib/utils/`** - Cross-cutting utilities: `logger.dart`, `file_size_formatter.dart`

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
fvm dart run build_runner build --delete-conflicting-outputs
```

## Tests

Test suite is currently a single smoke test at `test/widget_test.dart`. There is no broader unit/widget test scaffolding — when adding tests for a new subsystem, set up the structure under `test/<subsystem>/` rather than expecting one to already exist.
