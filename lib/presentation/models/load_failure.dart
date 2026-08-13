/// load_failure.dart：一次列表加载失败——文案 + 该走哪条恢复路径。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
library;

import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/data/services/exceptions/network_exception.dart';

/// 失败态的单一载体。
///
/// 此前这是 ViewModel 上并列的两个字段：`String? error` 与 `bool isLoginError`。
/// 它们必须由**同一个异常一次算出**，拆成两个就给了「只设其一」的机会——而两者
/// 的默认值（无文案 / `false`）恰好都是静默错的那一边：401 会渲染成
/// 「请先登录」配一个**「重试」**按钮，正是这套不变量存在的理由。
///
/// 合成一个值之后，「这次失败该给什么恢复动作」不再由每个屏幕各自记住，而是
/// 跟着失败本身走。
class LoadFailure {
  /// 给用户看的文案。已经过 [userMessageOf] 翻译（VPN 提示 / 请先登录 /
  /// 通用兜底），调用方不要再拼 `e.toString()`。
  final String message;

  /// 恢复动作是「去登录」而不是「重试」。
  final bool needsLogin;

  const LoadFailure(this.message, {this.needsLogin = false});

  /// 从捕获到的异常推导。文案与恢复路径在这里一次算完，不给它们分叉的机会。
  LoadFailure.from(Object e)
      : message = userMessageOf(e),
        needsLogin = isAuthErrorOf(e);

  /// 请求还没发就知道要登录（未登录的早返回路径）。
  const LoadFailure.loginRequired()
      : message = Strings.loginRequired,
        needsLogin = true;

  @override
  bool operator ==(Object other) =>
      other is LoadFailure &&
      other.message == message &&
      other.needsLogin == needsLogin;

  @override
  int get hashCode => Object.hash(message, needsLogin);

  @override
  String toString() => 'LoadFailure($message, needsLogin: $needsLogin)';
}
