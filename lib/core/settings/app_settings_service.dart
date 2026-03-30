import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends ChangeNotifier {
  static const String _serverUrlKey = 'server_url';
  static const String _smartPathKey = 'smart_path_enabled';
  static const String _audioFormatOrderKey = 'audio_format_order';

  static const String defaultServerUrl = 'https://api.asmr.one/api';
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

  AppSettingsService(this._prefs) {
    _serverUrl = _prefs.getString(_serverUrlKey) ?? defaultServerUrl;
    _smartPathEnabled = _prefs.getBool(_smartPathKey) ?? true;
    final savedOrder = _prefs.getStringList(_audioFormatOrderKey);
    _audioFormatOrder = savedOrder ?? List.from(defaultAudioFormatOrder);
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
}
