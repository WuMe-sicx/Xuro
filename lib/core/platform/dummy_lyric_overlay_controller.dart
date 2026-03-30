import 'package:xuro/utils/logger.dart';
import 'i_lyric_overlay_controller.dart';

class DummyLyricOverlayController implements ILyricOverlayController {
  static const _tag = 'LyricOverlay';

  @override
  Future<void> initialize() async {
  }

  @override
  Future<void> show() async {

  }

  @override
  Future<void> hide() async {

  }

  @override
  Future<void> updateLyric(String? text) async {

  }

  @override
  Future<bool> checkPermission() async {
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    AppLogger.debug('[$_tag] 请求权限');
    return true;
  }

  @override
  Future<void> dispose() async {

  }

  @override
  Future<bool> isShowing() async {
    return false;
  }
}