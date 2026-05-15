abstract class ILyricOverlayController {
  /// 初始化悬浮窗
  Future<void> initialize();
  
  /// 显示悬浮窗
  Future<void> show();
  
  /// 隐藏悬浮窗
  Future<void> hide();
  
  /// 更新歌词内容
  Future<void> updateLyric(String? text);
  
  /// 检查悬浮窗权限
  Future<bool> checkPermission();
  
  /// 请求悬浮窗权限
  Future<bool> requestPermission();
  
  /// 释放资源
  Future<void> dispose();
  
  /// 获取悬浮窗当前显示状态
  Future<bool> isShowing();

  /// 切换可拖动状态：true 时悬浮窗接收触摸（用于上下拖动调整位置），
  /// false 时窗口对所有触摸事件透明（默认态，下层 app 可正常操作）。
  Future<void> setEditable(bool editable);
}