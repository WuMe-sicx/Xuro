import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/widgets/auth/register_dialog.dart';
import 'package:xuro/utils/logger.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final name = _nameController.text.trim();
    AppLogger.info('LoginDialog: 尝试登录: name=$name');

    final authVM = context.read<AuthViewModel>();
    await authVM.login(name, _passwordController.text);

    if (mounted) {
      if (authVM.error == null) {
        AppLogger.info('LoginDialog: 登录成功，关闭对话框');
        Navigator.of(context).pop();
      } else {
        AppLogger.error('LoginDialog: 登录失败: ${authVM.error}');
      }
    }
  }

  void _switchToRegister() {
    final navigator = Navigator.of(context);
    context.read<AuthViewModel>().clearError();
    navigator.pop();
    showDialog(
      context: navigator.context,
      useRootNavigator: true,
      builder: (_) => const RegisterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Strings.loginAction),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: Strings.username,
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: Strings.password,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 8),
          Consumer<AuthViewModel>(
            builder: (context, authVM, _) {
              if (authVM.error != null) {
                return Text(
                  authVM.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _switchToRegister,
              child: const Text(Strings.registerCta),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(Strings.cancel),
        ),
        Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            return FilledButton(
              onPressed: authVM.isLoading ? null : _handleLogin,
              child: authVM.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(Strings.loginAction),
            );
          },
        ),
      ],
    );
  }
}
