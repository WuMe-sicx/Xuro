import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
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
        title: const Text('提示'),
        content: const Text('确认退出登录？'),
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
              '退出登录',
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
  /// inherits the global app theme rather than the local dark `Theme`
  /// override applied inside the drawer.
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
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final isLoggedIn = authVM.isLoggedIn;
        final title = isLoggedIn
            ? (authVM.username ?? Strings.loggedInFallback)
            : Strings.loginCta;
        final subtitle =
            isLoggedIn ? Strings.loggedInSubtitle : Strings.loginCtaSubtitle;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Semantics(
            button: true,
            label: isLoggedIn ? '用户账户' : '登录',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (isLoggedIn) {
                  _showLogoutDialog(authVM);
                } else {
                  _showLoginDialog();
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 0.7,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const _ProfileAvatar(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.55),
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const _ArrowButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    // Hand-roll a gradient from the accent to a darker variant of itself,
    // so all 3 color variants (blue / mono / green) get a coherent depth
    // effect instead of a fixed purple gradient.
    final accentDark = Color.lerp(accent, Colors.black, 0.45)!;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accentDark],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft inner highlight to give a 3D feel.
          Positioned(
            top: 6,
            left: 10,
            child: Container(
              width: 18,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.55),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.person_fill,
            color: Colors.white,
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
        border: Border.all(
          color: accent.withValues(alpha: 0.30),
          width: 0.6,
        ),
      ),
      child: Icon(
        CupertinoIcons.arrow_right,
        size: 16,
        color: accent,
      ),
    );
  }
}
