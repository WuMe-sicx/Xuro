import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/widgets/auth/login_dialog.dart';
import 'package:xuro/utils/logger.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Re-render the submit button as user types so the disabled state tracks
    // validity without the user having to lose focus.
    for (final c in [
      _nameController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? get _nameError {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    return name.length < 5 ? Strings.nameTooShort : null;
  }

  String? get _passwordError {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) return null;
    return pwd.length < 5 ? Strings.passwordTooShort : null;
  }

  String? get _confirmError {
    final pwd = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (confirm.isEmpty) return null;
    return pwd != confirm ? Strings.passwordMismatch : null;
  }

  bool get _isFormValid {
    final name = _nameController.text.trim();
    final pwd = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (name.length < 5) return false;
    if (pwd.length < 5) return false;
    if (pwd != confirm) return false;
    return true;
  }

  Future<void> _handleRegister() async {
    if (!_isFormValid) return;

    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    AppLogger.info('RegisterDialog: 尝试注册: name=$name');

    final authVM = context.read<AuthViewModel>();
    await authVM.register(name, password);

    if (!mounted) return;
    if (authVM.error == null) {
      AppLogger.info('RegisterDialog: 注册成功，关闭对话框');
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(Strings.registerSuccess),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      AppLogger.error('RegisterDialog: 注册失败: ${authVM.error}');
    }
  }

  void _switchToLogin() {
    final navigator = Navigator.of(context);
    context.read<AuthViewModel>().clearError();
    navigator.pop();
    showDialog(
      context: navigator.context,
      useRootNavigator: true,
      builder: (_) => const LoginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Strings.registerTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: Strings.username,
                border: const OutlineInputBorder(),
                errorText: _nameError,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: Strings.password,
                border: const OutlineInputBorder(),
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: Strings.passwordConfirm,
                border: const OutlineInputBorder(),
                errorText: _confirmError,
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleRegister(),
            ),
            const SizedBox(height: 8),
            Consumer<AuthViewModel>(
              builder: (context, authVM, _) {
                if (authVM.error != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      authVM.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _switchToLogin,
                child: const Text(Strings.haveAccountCta),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(Strings.cancel),
        ),
        Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            final canSubmit = _isFormValid && !authVM.isLoading;
            return FilledButton(
              onPressed: canSubmit ? _handleRegister : null,
              child: authVM.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(Strings.register),
            );
          },
        ),
      ],
    );
  }
}
