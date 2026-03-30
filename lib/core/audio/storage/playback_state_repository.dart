import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/data/models/playback/playback_state.dart';
import 'i_playback_state_repository.dart';

class PlaybackStateRepository implements IPlaybackStateRepository {
  static const _key = 'last_playback_state';
  final SharedPreferences _prefs;

  PlaybackStateRepository(this._prefs);

  @override
  Future<void> saveState(PlaybackState state) async {
    try {
      final json = state.toJson();
      final data = jsonEncode(json);
      await _prefs.setString(_key, data);
      AppLogger.debug('播放状态已保存');
    } catch (e) {
      AppLogger.error('保存播放状态失败', e);
      rethrow;
    }
  }

  @override
  Future<PlaybackState?> loadState() async {
    try {
      final data = _prefs.getString(_key);
      if (data == null) {
        AppLogger.debug('没有找到保存的播放状态');
        return null;
      }

      final json = jsonDecode(data) as Map<String, dynamic>;
      final state = PlaybackState.fromJson(json);
      AppLogger.debug('播放状态已加载');
      return state;
    } catch (e) {
      AppLogger.error('加载播放状态失败', e);
      return null;
    }
  }
} 