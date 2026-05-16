import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level accent color variants. Surfaces stay neutral (white/black) across
/// all variants — only the `primary` token rotates. Persisted by
/// [AppSettingsService.colorVariant].
enum ColorVariant {
  blue,
  mono,
  green,
}

class AppSettingsService extends ChangeNotifier {
  static const String _serverUrlKey = 'server_url';
  static const String _smartPathKey = 'smart_path_enabled';
  static const String _audioFormatOrderKey = 'audio_format_order';
  static const String _colorVariantKey = 'color_variant';
  static const String _lyricOverlayUnlockedKey = 'lyric_overlay_unlocked';
  static const String _backgroundPlayKey = 'background_play_enabled';
  // 跨多个列表 ViewModel 共享的「仅看带字幕作品」筛选。收敛到此单点，
  // 取代各 VM 自行 SharedPreferences.getInstance() + dispose 回写陈旧值。
  static const String _subtitleFilterKey = 'subtitle_filter';

  static const String defaultServerUrl = 'https://api.asmr.one/api';
  static const ColorVariant defaultColorVariant = ColorVariant.blue;
  static const List<String> defaultAudioFormatOrder = [
    'mp3', 'flac', 'wav', 'opus', 'm4a', 'aac'
  ];

  /// Available server options
  static const Map<String, String> serverOptions = {
    'https://api.asmr.one/api': '主站 (asmr.one)',
    'https://api.asmr-100.com/api': '节点1 (asmr-100.com)',
    'https://api.asmr-200.com/api': '节点2 (asmr-200.com)',
    'https://api.asmr-300.com/api': '节点3 (asmr-300.com)',
  };

  final SharedPreferences _prefs;

  late String _serverUrl;
  late bool _smartPathEnabled;
  late List<String> _audioFormatOrder;
  late ColorVariant _colorVariant;
  late bool _lyricOverlayUnlocked;
  late bool _backgroundPlayEnabled;
  late bool _hasSubtitleFilter;

  AppSettingsService(this._prefs) {
    _serverUrl = _prefs.getString(_serverUrlKey) ?? defaultServerUrl;
    _smartPathEnabled = _prefs.getBool(_smartPathKey) ?? true;
    final savedOrder = _prefs.getStringList(_audioFormatOrderKey);
    _audioFormatOrder = savedOrder ?? List.from(defaultAudioFormatOrder);
    final savedVariant = _prefs.getString(_colorVariantKey);
    _colorVariant = ColorVariant.values.firstWhere(
      (v) => v.name == savedVariant,
      orElse: () => defaultColorVariant,
    );
    _lyricOverlayUnlocked = _prefs.getBool(_lyricOverlayUnlockedKey) ?? false;
    _backgroundPlayEnabled = _prefs.getBool(_backgroundPlayKey) ?? true;
    _hasSubtitleFilter = _prefs.getBool(_subtitleFilterKey) ?? false;
  }

  // === Server URL ===
  String get serverUrl => _serverUrl;

  Future<void> setServerUrl(String url) async {
    if (_serverUrl == url) return;
    _serverUrl = url;
    notifyListeners();
    await _prefs.setString(_serverUrlKey, url);
  }

  // === Smart Path ===
  bool get smartPathEnabled => _smartPathEnabled;

  Future<void> setSmartPathEnabled(bool enabled) async {
    if (_smartPathEnabled == enabled) return;
    _smartPathEnabled = enabled;
    notifyListeners();
    await _prefs.setBool(_smartPathKey, enabled);
  }

  // === Subtitle Filter (shared across list ViewModels) ===
  bool get hasSubtitleFilter => _hasSubtitleFilter;

  Future<void> setHasSubtitleFilter(bool value) async {
    if (_hasSubtitleFilter == value) return;
    _hasSubtitleFilter = value;
    notifyListeners();
    await _prefs.setBool(_subtitleFilterKey, value);
  }

  // === Audio Format Order ===
  List<String> get audioFormatOrder => List.unmodifiable(_audioFormatOrder);

  /// Get supported audio file extensions with dot prefix, ordered by preference
  List<String> get audioExtensions =>
      _audioFormatOrder.map((f) => '.$f').toList();

  Future<void> setAudioFormatOrder(List<String> order) async {
    _audioFormatOrder = List.from(order);
    notifyListeners();
    await _prefs.setStringList(_audioFormatOrderKey, _audioFormatOrder);
  }

  Future<void> resetAudioFormatOrder() async {
    await setAudioFormatOrder(List.from(defaultAudioFormatOrder));
  }

  // === Lyric Overlay Lock ===
  /// `true` → 悬浮歌词可拖动调整位置；`false` → 锁定（点穿，默认）。
  bool get lyricOverlayUnlocked => _lyricOverlayUnlocked;

  Future<void> setLyricOverlayUnlocked(bool unlocked) async {
    if (_lyricOverlayUnlocked == unlocked) return;
    _lyricOverlayUnlocked = unlocked;
    notifyListeners();
    await _prefs.setBool(_lyricOverlayUnlockedKey, unlocked);
  }

  // === Background Play ===
  /// `true`（默认）→ 切后台继续播放（现有行为）；`false` → 切后台自动暂停。
  bool get backgroundPlayEnabled => _backgroundPlayEnabled;

  Future<void> setBackgroundPlayEnabled(bool enabled) async {
    if (_backgroundPlayEnabled == enabled) return;
    _backgroundPlayEnabled = enabled;
    notifyListeners();
    await _prefs.setBool(_backgroundPlayKey, enabled);
  }

  // === Color Variant ===
  ColorVariant get colorVariant => _colorVariant;

  Future<void> setColorVariant(ColorVariant variant) async {
    if (_colorVariant == variant) return;
    _colorVariant = variant;
    notifyListeners();
    await _prefs.setString(_colorVariantKey, variant.name);
  }
}
