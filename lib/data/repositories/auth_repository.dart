import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xuro/data/models/auth/auth_resp/auth_resp.dart';
import 'package:xuro/utils/logger.dart';

/// 认证数据仓库。
///
/// - 含 bearer token 的 [AuthResp] 整体 JSON blob 存 [FlutterSecureStorage]
///   （Android EncryptedSharedPreferences / iOS Keychain），不再明文落 prefs。
/// - 内存缓存（[_cached]/[_loaded]）：[AuthInterceptor] 每个 HTTP 请求都会
///   读取，首次加载后零存储开销、零 json 解码。
/// - 旧版明文 `auth_data` 一次性迁移：迁移成功才清明文；迁移/读写失败
///   **防御式降级**回 prefs，绝不因 Keystore 故障登出用户或崩溃。
class AuthRepository {
  static const _authDataKey = 'auth_data';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  AuthResp? _cached;
  bool _loaded = false;
  Future<AuthResp?>? _loadFuture;

  // 串行化所有 secure/prefs 写操作：保证「发起顺序 == 落盘顺序」。配合
  // 加载/迁移前的 `if (_loaded) return` 守卫（无 save/clear 时迁移才入链），
  // 杜绝在途 legacy 迁移写在平台层与并发 save/clear 乱序、使旧 token 在
  // secure 复活。最后发起的写是最终落盘状态。
  Future<void> _writeLock = Future<void>.value();

  AuthRepository(this._prefs, {FlutterSecureStorage? secureStorage})
      : _secure = secureStorage ?? const FlutterSecureStorage();

  Future<R> _serialize<R>(Future<R> Function() action) {
    final run = _writeLock.then((_) => action());
    // 无论本次成败，链都继续（吞掉错误只为不卡死后续操作）。
    _writeLock = run.then<void>((_) {}, onError: (_) {});
    return run;
  }

  Future<AuthResp?> getAuthData() async {
    if (_loaded) return _cached;
    // `??=` 与赋值间无 await 挂起点：并发首访（拦截器并行请求）共享同一
    // in-flight Future，只加载/迁移一次。
    return _loadFuture ??= _loadAndMigrate();
  }

  Future<AuthResp?> _loadAndMigrate() async {
    try {
      // 1. 安全存储优先。
      String? jsonStr;
      try {
        jsonStr = await _secure.read(key: _authDataKey);
      } catch (e) {
        AppLogger.warning('安全存储读取失败，回退检查 prefs 明文: $e');
      }
      // 若在途加载期间发生了 save/clear（已置 _loaded），其内存态才是
      // 权威值——放弃本次加载结果，避免旧态覆盖新登录/登出态。
      if (_loaded) return _cached;
      if (jsonStr != null) {
        _cached = _decode(jsonStr);
        _loaded = true;
        return _cached;
      }

      // 2. 迁移旧版明文 prefs.auth_data。
      final legacy = _prefs.getString(_authDataKey);
      if (legacy != null) {
        // save/clear 已在途期间产生权威内存态 → 跳过迁移（其旧值会反而
        // 把并发写入 secure 的新 token 覆盖回旧值）。守卫在入链前，确保
        // 迁移写只会排在尚未发生的 save/clear 之前。
        if (_loaded) return _cached;
        await _serialize<void>(() async {
          try {
            await _secure.write(key: _authDataKey, value: legacy);
          } catch (e) {
            AppLogger.warning('迁移认证数据到安全存储失败，保留 prefs 明文（不登出用户）: $e');
            return;
          }
          // 迁移成功才清明文：否则「清明文 + 迁移失败」= 登出用户。
          try {
            await _prefs.remove(_authDataKey);
          } catch (_) {}
          AppLogger.info('认证数据已迁移到安全存储');
        });
        // 无论迁移是否成功，都用 legacy 内容回填内存（迁移失败=防御式
        // 降级，不登出）。
        if (_loaded) return _cached;
        _cached = _decode(legacy);
        _loaded = true;
        return _cached;
      }

      // 3. 未登录。
      if (_loaded) return _cached;
      _cached = null;
      _loaded = true;
      return null;
    } finally {
      _loadFuture = null;
    }
  }

  AuthResp? _decode(String jsonStr) {
    try {
      return AuthResp.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('解析认证数据失败', e);
      return null;
    }
  }

  Future<void> saveAuthData(AuthResp authData) async {
    final jsonStr = json.encode(authData.toJson());
    _cached = authData;
    _loaded = true;
    // 整个写入序列入串行链，保证相对 legacy 迁移/clear 的落盘顺序。
    await _serialize<void>(() async {
      try {
        await _secure.write(key: _authDataKey, value: jsonStr);
        // 写安全存储成功 → 清掉可能残留的旧明文。
        try {
          await _prefs.remove(_authDataKey);
        } catch (_) {}
        AppLogger.info('保存认证数据成功（安全存储）');
      } catch (e) {
        // 防御式降级：安全存储不可用时落 prefs，至少保住登录态。
        AppLogger.warning('安全存储写入失败，降级写入 prefs: $e');
        try {
          await _prefs.setString(_authDataKey, jsonStr);
        } catch (e2) {
          AppLogger.error('降级写入 prefs 也失败', e2);
          rethrow;
        }
      }
    });
  }

  Future<void> clearAuthData() async {
    _cached = null;
    _loaded = true;
    await _serialize<void>(() async {
      try {
        await _secure.delete(key: _authDataKey);
      } catch (e) {
        AppLogger.warning('清除安全存储认证数据失败: $e');
      }
      try {
        await _prefs.remove(_authDataKey);
      } catch (e) {
        AppLogger.warning('清除 prefs 认证数据失败: $e');
      }
      AppLogger.info('清除认证数据成功');
    });
  }
}
