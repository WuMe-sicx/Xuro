import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/widgets/auth/login_dialog.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  /// Closes the drawer, then opens [builder] via the root navigator so it
  /// inherits the global app theme rather than the local dark `Theme`
  /// override applied inside the drawer.
  void _closeDrawerThenShowDialog(
    BuildContext context,
    WidgetBuilder builder,
  ) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context); // close drawer
    showDialog(
      context: rootNavigator.context,
      useRootNavigator: true,
      builder: builder,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    _closeDrawerThenShowDialog(
      context,
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

  void _showLoginDialog(BuildContext context) {
    _closeDrawerThenShowDialog(context, (_) => const LoginDialog());
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
                  _showLogoutDialog(context, authVM);
                } else {
                  _showLoginDialog(context);
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
                      color: const Color(0xFF6750A4).withValues(alpha: 0.18),
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
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C5CFF),
            Color(0xFF3D2C8F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.45),
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
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.6,
        ),
      ),
      child: Icon(
        CupertinoIcons.arrow_right,
        size: 16,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
