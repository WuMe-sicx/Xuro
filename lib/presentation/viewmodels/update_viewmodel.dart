import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/models/update_info.dart';
import 'package:xuro/data/services/exceptions/update_exception.dart';
import 'package:xuro/data/services/update_service.dart';
import 'package:xuro/utils/logger.dart';

class UpdateViewModel extends ChangeNotifier {
  final UpdateService _service;

  bool _isChecking = false;
  bool _disposed = false;
  String? _error;
  UpdateInfo? _latest;
  bool _hasUpdate = false;
  String _currentVersion = '';

  UpdateViewModel({required UpdateService service}) : _service = service;

  @override
  void dispose() {
    // Dialog 在检查中被遮罩/返回键关掉时，ChangeNotifierProvider 会 dispose
    // 这个本地 VM；in-flight 请求回来后若再 notify 会 "used after disposed"。
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  bool get isChecking => _isChecking;
  String? get error => _error;
  UpdateInfo? get latest => _latest;
  bool get hasUpdate => _hasUpdate;
  String get currentVersion => _currentVersion;

  Future<void> check() async {
    if (_isChecking) return;

    _isChecking = true;
    _error = null;
    _safeNotify();

    try {
      final r = await _service.checkForUpdate();
      _latest = r.latest;
      _hasUpdate = r.hasUpdate;
      _currentVersion = r.currentVersion;
    } on UpdateException catch (e) {
      // 走 GitHub 专用文案；ViewModel 不依赖 NetworkException。
      AppLogger.error('UpdateViewModel: 检查更新失败', e);
      _error = e.userMessage;
    } catch (e) {
      AppLogger.error('UpdateViewModel: 检查更新未知异常', e);
      _error = Strings.updateErrorUnknown;
    } finally {
      _isChecking = false;
      _safeNotify();
    }
  }

  /// 外部打开下载地址。Android 优先打开 `.apk` 直链，缺失时回退打开
  /// Release 页；iOS / 其它平台一律打开 Release 页。返回是否成功唤起。
  Future<bool> openDownload() async {
    final info = _latest;
    if (info == null) return false;

    final preferApk = Platform.isAndroid && info.apkDownloadUrl != null;
    final target = preferApk ? info.apkDownloadUrl! : info.htmlUrl;

    try {
      return await launchUrl(
        Uri.parse(target),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      AppLogger.error('UpdateViewModel: 打开下载地址失败', e);
      return false;
    }
  }
}
