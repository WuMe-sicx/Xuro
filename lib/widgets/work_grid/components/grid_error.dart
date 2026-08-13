import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/presentation/models/load_failure.dart';

class GridError extends StatelessWidget {
  final LoadFailure failure;
  final VoidCallback? onRetry;
  final VoidCallback? onLogin;

  const GridError({
    super.key,
    required this.failure,
    this.onRetry,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    // 登录态没传 onLogin 时按钮会回退成「重试」，图标必须跟按钮走同一个
    // 判断，否则出现过锁图标配重试按钮的错配（图标承诺登录、按钮却重试）。
    final showLogin = failure.needsLogin && onLogin != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showLogin ? Icons.lock_outline : Icons.error_outline,
            size: AppSpacing.space48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            failure.message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (showLogin) ...[
            const SizedBox(height: AppSpacing.space16),
            FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login),
              label: const Text(Strings.goLogin),
            ),
          ] else if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.space16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(Strings.retry),
            ),
          ],
        ],
      ),
    );
  }
}
