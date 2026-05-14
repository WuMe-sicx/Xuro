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

**Renderer (Android):** Impeller is **disabled** via `io.flutter.embedding.android.EnableImpeller=false` in `android/app/src/main/AndroidManifest.xml` — Android builds use the Skia backend. Reason: real-device `Vulkan: ErrorDeviceLost` → `SIGSEGV in libvulkan.so::CmdEndRenderPass+4` long-session crashes on Xiaomi HyperOS 3 / Android 16 + Adreno (driver-level GPU fault, zero Dart frames). Don't re-enable Impeller without first upgrading the Flutter SDK (3.29+ has many Adreno fixes) and re-running a 30+ min real-device session — see `docs/todos/active/20260515-upgrade-flutter-sdk.md`. iOS continues to use Impeller (default and stable there).

## Architecture

Clean Architecture with three layers, using **Provider (ChangeNotifier)** for state management and **GetIt** for dependency injection.

### Layer Structure

- **`lib/core/`** - Platform services and infrastructure
  - `di/service_locator.dart` - GetIt DI container setup (entry point for all service registration)
  - `audio/` - Audio playback system: `IAudioPlayerService` interface + implementation, PlaybackEventHub (event bus pattern), state persistence, notification handling
  - `subtitle/` - Subtitle/lyric system: `ISubtitleService` interface, parsers (VTT etc.), subtitle loader with caching
  - `platform/` - Platform-specific: `ILyricOverlayController` (Android floating lyric window, dummy on other platforms), WakeLockController
  - `theme/` - Theme is determined by **two axes**: `ThemeMode` (light/dark/system, owned by `ThemeController`) × `ColorVariant` (blue/mono/green, owned by `AppSettingsService`). `AppColors.lightSchemeFor(variant)` / `darkSchemeFor(variant)` produce 6 hand-rolled `ColorScheme`s; surfaces are neutral, only `primary` / `onPrimary` / `primaryContainer` rotate. Do not use `ColorScheme.fromSeed` here — it would derive secondary/tertiary in another hue and break the "two-color" simplification.
  - `cache/` - RecommendationCacheManager
  - `database/` - `database_service.dart` (local persistence)
  - `image/cache/` - Image cache layer used by network image widgets
  - `settings/` - `app_settings_service.dart` (user preferences persistence)

- **`lib/data/`** - Data layer
  - `models/` - Freezed immutable data classes (auto-generated `.freezed.dart` + `.g.dart` files)
  - `services/api_service.dart` - Dio HTTP client; baseUrl is read from `AppSettingsService.serverUrl` and updated when the user switches nodes
  - `services/auth_service.dart` - Login (`/auth/me`) and register (`/auth/reg`); also injects `AppSettingsService` so auth requests follow the user's selected node. Defines `RegisteredButNotLoggedInException` for the case where account creation succeeds but the auto-login fallback fails — callers must distinguish this from a register failure
  - `services/interceptors/auth_interceptor.dart` - Dio auth interceptor
  - `repositories/` - Repository implementations (AuthRepository, audio state)

- **`lib/presentation/`** - Presentation layer
  - `viewmodels/` - ChangeNotifier ViewModels (one per screen). `PaginatedWorksViewModel` is the base class for all paginated list screens
  - `viewmodels/player_viewmodel.dart` - Central player state, depends on AudioService + SubtitleService + EventHub
  - `layouts/` - `work_layout_config.dart` / `work_layout_strategy.dart` (responsive grid sizing — see ui-design-spec §5)
  - `models/filter_state.dart` - UI-only state object for the filter panel
  - `widgets/auth/` - Auth UI widgets: `LoginDialog` and `RegisterDialog`. They cross-link via root navigator (`useRootNavigator: true`) so the sidebar's local dark `Theme` doesn't leak into the dialog, and call `AuthViewModel.clearError()` on the way out to avoid stale error text in the freshly opened dialog

- **`lib/screens/`** - Full-page screens. `MainScreen` is the tab-based root. `contents/` holds the tab content widgets; `browse/` holds tag/circle/voice-actor lists; `settings/` holds the settings tree

- **`lib/widgets/`** - Reusable UI components (work cards, player controls, lyrics, mini player, filters, sidebar drawer). The sidebar (`widgets/sidebar/`) is a glassmorphism-styled drawer with its own dark palette enforced via a local `Theme` override — don't expect it to follow the global ColorScheme. **When forcing dark inside the drawer, do NOT just `copyWith(brightness: dark)`** — that flips the brightness flag but keeps the light variant's `primary`, which makes accents invisible (e.g. mono variant in light mode → primary stays black, glow/avatar/footer dot disappear on near-black background). Instead use `copyWith(brightness: dark, colorScheme: AppColors.darkSchemeFor(variant))` and read the variant from `context.watch<AppSettingsService>().colorVariant`. `SidebarHeader` launches dialogs via `addPostFrameCallback` (same-frame `Navigator.pop` + `showDialog` on the same navigator caused intermittent crashes / "no-show" in production) and uses a `_dialogScheduled` reentrancy flag — preserve both when adding new actions to that widget. **Don't add a fullscreen `BackdropFilter` to this drawer**: the underlying gradient is opaque so any blur is a visual no-op, but it caused a 256ms first-open jank on real Android (PerfDog evidence in `docs/todos/done/20260515-sidebar-first-open-jank.md`). All chromatic accents (avatar / arrow / footer dot / glows / card shadow) draw from `Theme.of(context).colorScheme.primary`; menu icon backgrounds are a single neutral `_kIconBgGray` so the only color in the drawer is the active variant's accent.

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

Two Dio clients, both pointed at the user-selected node:
- `ApiService` — content endpoints (`/works`, `/tracks/{id}`, `/search/{keyword}`, `/review`, `/recommender/*`, `/playlist/*`, `/tags/`, `/circles/`, `/vas/`, `/workInfo/{id}`). Auth header added by `AuthInterceptor`.
- `AuthService` — `/auth/me` (login) and `/auth/reg` (register). Owns its own Dio instance, no auth interceptor.

Both services subscribe to `AppSettingsService` and rotate `dio.options.baseUrl` when the user switches nodes. Available nodes (defined in `AppSettingsService.serverOptions`):
- `https://api.asmr.one/api` (主站, default)
- `https://api.asmr-100.com/api` / `-200` / `-300` (mirror nodes)

When adding a new HTTP-touching service, follow the `_onSettingsChanged` pattern in `ApiService`/`AuthService` — don't hardcode the host.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`) triggers on `v*` tags. Builds Android APK/AAB (signed) + iOS IPA, creates GitHub release with changelog.

## Code Generation

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis. When adding or modifying data models in `lib/data/models/`, always re-run:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

## Tests

Test suite is currently a single smoke test at `test/widget_test.dart`. There is no broader unit/widget test scaffolding — when adding tests for a new subsystem, set up the structure under `test/<subsystem>/` rather than expecting one to already exist.
