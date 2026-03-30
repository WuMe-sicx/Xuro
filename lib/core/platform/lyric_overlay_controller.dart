import 'package:flutter/services.dart';
import 'package:xuro/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'i_lyric_overlay_controller.dart';

class LyricOverlayController implements ILyricOverlayController {
  static const _tag = 'LyricOverlay';
  static const _channel = MethodChannel('com.xuro/lyric_overlay');
  
  @override
  Future<void> initialize() async {
    try {
      AppLogger.debug('[$_tag] 初始化');
      await _channel.invokeMethod('initialize');
    } catch (e) {
      AppLogger.error('[$_tag] 初始化失败', e);
      // 这里我们不抛出异常,而是静默失败
      // 因为这个错误不应该影响应用的主要功能
    }
  }
  
  @override
  Future<void> show() async {
    AppLogger.debug('[$_tag] 显示悬浮窗');
    await _channel.invokeMethod('show');
  }
  
  @override
  Future<void> hide() async {
    AppLogger.debug('[$_tag] 隐藏悬浮窗');
    await _channel.invokeMethod('hide');
  }
  
  @override
  Future<void> updateLyric(String? text) async {
    AppLogger.debug('[$_tag] 更新歌词: ${text ?? '<空>'}');
    await _channel.invokeMethod('updateLyric', {'text': text});
  }
  
  @override
  Future<bool> checkPermission() async {
    AppLogger.debug('[$_tag] 检查权限');
    return await Permission.systemAlertWindow.isGranted;
  }
  
  @override
  Future<bool> requestPermission() async {
    AppLogger.debug('[$_tag] 请求权限');
    final status = await Permission.systemAlertWindow.request();
    return status.isGranted;
  }
  
  @override
  Future<void> dispose() async {
    AppLogger.debug('[$_tag] 释放资源');
    await _channel.invokeMethod('dispose');
  }
  
  @override
  Future<bool> isShowing() async {
    final result = await _channel.invokeMethod<bool>('isShowing') ?? false;
    return result;
  }
} 