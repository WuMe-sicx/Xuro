# Xuro

[中文说明](README.md)

A beautiful and modern [ASMR.ONE](https://asmr.one) client application built with Flutter.

## Project Overview

Xuro is designed to provide a smooth and enjoyable ASMR listening experience with beautiful animations and a modern user interface.

## Features

- Stable background playback
- Beautiful animations and clean UI design
- Subtitle/lyric display with VTT/LRC import support
- Playlist management
- Multi-dimensional browsing: tags, circles, voice actors
- Favorites collection
- Android 13+ notification permission support
- Floating lyric overlay (Android)
- Comprehensive settings system
- Smart caching (images, subtitles, audio files)
- Unified cache management

## Requirements

- Flutter 3.27.0+
- Dart SDK >=3.2.3 <4.0.0
- Android: minSdk 21 / targetSdk 33
- Java 17

## Getting Started

```bash
git clone https://github.com/WuMe-sicx/Xuro.git
cd Xuro
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Project Structure

```
lib/
├── core/                 # Core functionality (audio, subtitle, theme, cache, platform)
├── data/                 # Data layer (API, models, repositories)
├── presentation/         # Presentation layer (ViewModels)
├── screens/              # Full-page screens
├── widgets/              # Reusable UI components
└── common/               # Common utilities and constants
```

## Development Guidelines

- [Development Guidelines](docs/guidelines_en.md)

## Contributing

Please read our [Development Guidelines](docs/guidelines_en.md) before making a contribution.

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License (CC BY-NC-SA) - see the [LICENSE](LICENSE) file for details.

Original author: [WuMe-sicx](https://github.com/WuMe-sicx)

This license allows others to remix, tweak, and build upon your work non-commercially, as long as they credit you and license their new creations under the identical terms.
