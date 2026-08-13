import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/widgets/auth/login_dialog.dart';

class SidebarHeader extends StatefulWidget {
  const SidebarHeader({super.key});

  @override
  State<SidebarHeader> createState() => _SidebarHeaderState();
}

class _SidebarHeaderState extends State<SidebarHeader> {
  // Guards against fast double-taps during the drawer's pop animation. Once
  // a tap has scheduled a dialog, ignore further taps until that dialog has
  // closed; otherwise multiple post-frame callbacks could each push their
  // own dialog onto the root navigator.
  bool _dialogScheduled = false;

  void _showLogoutDialog(AuthViewModel authVM) {
    _closeDrawerThenShowDialog(
      (dialogContext) => AlertDialog(
        title: const Text(Strings.dialogHint),
        content: const Text(Strings.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await authVM.logout();
              // Use dialogContext.mounted (not NavigatorState.mounted) — we
              // need to know whether THIS dialog route is still showing, not
              // just whether the root navigator exists. If the user dismissed
              // the dialog (back button / barrier tap) during the await, this
              // check returns false and we skip the pop, avoiding accidentally
              // popping the underlying page.
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
            },
            child: Text(
              Strings.logout,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog() {
    _closeDrawerThenShowDialog((_) => const LoginDialog());
  }

  /// Closes the drawer, then opens [builder] via the root navigator so it
  /// inherits the global app theme rather than any local `Theme` override.
  ///
  /// The pop and the showDialog are intentionally split across two frames via
  /// [WidgetsBinding.instance.addPostFrameCallback]. Doing both in the same
  /// frame on the same navigator caused intermittent symptoms in the wild —
  /// the drawer would close but the dialog would never appear (so the user
  /// "couldn't log out"), and occasionally the route transition would crash.
  void _closeDrawerThenShowDialog(WidgetBuilder builder) {
    if (_dialogScheduled) return;
    _dialogScheduled = true;

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    Navigator.maybePop(context); // close drawer if it's still open

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!rootNavigator.mounted) {
        if (mounted) _dialogScheduled = false;
        return;
      }
      showDialog<void>(
        context: rootNavigator.context,
        useRootNavigator: true,
        builder: builder,
      ).whenComplete(() {
        if (mounted) _dialogScheduled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final isLoggedIn = authVM.isLoggedIn;
        final title = isLoggedIn
            ? (authVM.username ?? Strings.loggedInFallback)
            : Strings.loginCta;
        final subtitle =
            isLoggedIn ? Strings.loggedInSubtitle : Strings.loginCtaSubtitle;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space16,
            AppSpacing.space8,
            AppSpacing.space16,
            AppSpacing.space12,
          ),
          child: Semantics(
            button: true,
            label: isLoggedIn ? Strings.a11yUserAccount : Strings.loginAction,
            child: Material(
              color: cs.surfaceContainerHighest,
              borderRadius: AppRadius.lgAll,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (isLoggedIn) {
                    _showLogoutDialog(authVM);
                  } else {
                    _showLoginDialog();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        // 实心 accent 方块，呼应播放器主按钮的处理。
                        // 圆形是「最大圆角」，与零圆角这条设计语言直接冲突。
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.smAll,
                          color: cs.primary,
                        ),
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: cs.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
