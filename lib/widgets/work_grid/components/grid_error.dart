import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/app_spacing.dart';

class GridError extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  /// When true and [onLogin] is provided, the action button becomes a
  /// "go to login" button instead of "retry" — retrying a not-logged-in
  /// request is pointless, the user needs to authenticate first.
  final bool isLoginError;
  final VoidCallback? onLogin;

  const GridError({
    super.key,
    required this.error,
    this.onRetry,
    this.isLoginError = false,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final showLogin = isLoginError && onLogin != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLoginError ? Icons.lock_outline : Icons.error_outline,
            size: AppSpacing.space48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            error,
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
