import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/presentation/viewmodels/auth_viewmodel.dart';
import 'package:asmrapp/presentation/widgets/auth/login_dialog.dart';
import 'package:asmrapp/screens/favorites_screen.dart';
import 'package:asmrapp/screens/settings/settings_screen.dart';
import 'package:asmrapp/screens/browse/tags_screen.dart';
import 'package:asmrapp/screens/browse/circles_screen.dart';
import 'package:asmrapp/screens/browse/voice_actors_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LoginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListTileTheme(
        style: ListTileStyle.drawer,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerTheme: const DividerThemeData(color: Colors.transparent),
              ),
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text(
                  Strings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Consumer<AuthViewModel>(
              builder: (context, authVM, _) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    authVM.isLoggedIn ? authVM.username ?? '' : '登录',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (authVM.isLoggedIn) {
                      authVM.logout();
                    } else {
                      _showLoginDialog(context);
                    }
                  },
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text(Strings.favorites),
              onTap: () {
                Navigator.pop(context);
                // 检查用户是否已登录
                final authVM = context.read<AuthViewModel>();
                if (!authVM.isLoggedIn) {
                  // 如果未登录，显示登录对话框
                  _showLoginDialog(context);
                  return;
                }
                // 导航到收藏页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('标签'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TagsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('社团'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CirclesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic_outlined),
              title: const Text('声优'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceActorsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(Strings.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
