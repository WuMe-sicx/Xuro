import 'package:flutter/material.dart';
import 'package:asmrapp/core/theme/app_colors.dart';

class SettingsTheme {
  const SettingsTheme._();

  /// Get page background color (SurfaceL1)
  static Color pageBackground(BuildContext context) {
    return AppColors.surfaceL1(Theme.of(context).brightness);
  }

  /// Wrap child with local theme that disables ripple
  static Widget noSplashTheme({
    required BuildContext context,
    required Widget child,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: child,
    );
  }
}
