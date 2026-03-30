import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xuro/data/models/auth/auth_resp/auth_resp.dart';
import 'package:xuro/utils/logger.dart';

class AuthRepository {
  static const _authDataKey = 'auth_data';
  final SharedPreferences _prefs;

  AuthRepository(this._prefs);

  Future<void> saveAuthData(AuthResp authData) async {
    try {
      final jsonStr = json.encode(authData.toJson());
      await _prefs.setString(_authDataKey, jsonStr);
      AppLogger.info('保存认证数据成功');
    } catch (e) {
      AppLogger.error('保存认证数据失败', e);
      rethrow;
    }
  }

  Future<AuthResp?> getAuthData() async {
    try {
      final jsonStr = _prefs.getString(_authDataKey);
      if (jsonStr == null) return null;

      final authData = AuthResp.fromJson(json.decode(jsonStr));
      AppLogger.info('读取认证数据成功: ${authData.user?.name}');
      return authData;
    } catch (e) {
      AppLogger.error('读取认证数据失败', e);
      return null;
    }
  }

  Future<void> clearAuthData() async {
    try {
      await _prefs.remove(_authDataKey);
      AppLogger.info('清除认证数据成功');
    } catch (e) {
      AppLogger.error('清除认证数据失败', e);
      rethrow;
    }
  }
} 