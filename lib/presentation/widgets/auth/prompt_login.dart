/// prompt_login.dart：列表页「去登录」入口的统一实现。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/widgets/auth/login_dialog.dart';

/// 弹登录框，登录成功后调 [onLoggedIn] 重新加载。
///
/// 此前每个列表页手抄一份这十行，共三份；候选 D 要给另外八屏也接上入口，
/// 再抄就是九份。抽出来的理由不是「去重」，而是这十行里有三处**抄错了就
/// 静默出错**的细节：
///
/// - `useRootNavigator: true`：侧边栏给自己套了一层局部深色 `Theme`，走局部
///   navigator 会把那层主题漏进登录框。
/// - `await` 之后必须重查 `context.mounted`：登录框是可中途关闭的，用户可能
///   在期间退出这一页。
/// - 必须重查 `isLoggedIn` 再重载：用户可能只是关掉了登录框而没有登录，
///   此时重载只会再撞一次同样的 401。
Future<void> promptLogin(
  BuildContext context, {
  required VoidCallback onLoggedIn,
}) async {
  await showDialog(
    context: context,
    useRootNavigator: true,
    builder: (_) => const LoginDialog(),
  );
  if (!context.mounted) return;
  if (context.read<AuthViewModel>().isLoggedIn) {
    onLoggedIn();
  }
}
