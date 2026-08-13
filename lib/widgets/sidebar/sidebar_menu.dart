import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';
import 'package:xuro/core/theme/theme_controller.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/widgets/auth/login_dialog.dart';
import 'package:xuro/screens/browse/circles_screen.dart';
import 'package:xuro/screens/browse/tags_screen.dart';
import 'package:xuro/screens/browse/voice_actors_screen.dart';
import 'package:xuro/screens/about_screen.dart';
import 'package:xuro/screens/favorites_screen.dart';
import 'package:xuro/screens/settings/settings_screen.dart';
import 'package:xuro/widgets/common/brand_wordmark.dart';
import 'package:xuro/widgets/sidebar/sidebar_group.dart';
import 'package:xuro/widgets/sidebar/sidebar_header.dart';
import 'package:xuro/widgets/sidebar/sidebar_tile.dart';

/// 侧边抽屉：跟随应用主题的清爽列表，层级由 2px（组）/ 1px（行）分隔线表达。
///
/// 两条不可回退的约束：玻璃拟态已被用户以产品负责人身份推翻，不得重新引入；
/// **不引入任何全屏 BackdropFilter**（旧版真机 256ms 首开 jank，见
/// docs/todos/done/20260515-sidebar-first-open-jank.md）。
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  static const _drawerWidthFraction = 0.72;
  static const _drawerMobileMaxWidth = 360.0;
  static const _drawerTabletWidth = 304.0;
  static const _tabletBreakpoint = 800.0;

  void _navigate(BuildContext context, Widget screen) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);
    rootNavigator.push(CupertinoPageRoute(builder: (_) => screen));
  }

  void _navigateToFavorites(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);
    if (!authVM.isLoggedIn) {
      showDialog(
        context: rootNavigator.context,
        useRootNavigator: true,
        builder: (_) => const LoginDialog(),
      );
      return;
    }
    rootNavigator.push(
      CupertinoPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('$feature ${Strings.comingSoon}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Strings.themeModeLight;
      case ThemeMode.dark:
        return Strings.themeModeDark;
      case ThemeMode.system:
        return Strings.themeModeSystem;
    }
  }

  /// 组间分隔线：2px，粗于 [SidebarGroup] 内部的 1px 行分隔线——
  /// Modernist 用这一粗细差别表达「组」比「行」高一级的层级。
  Widget _groupDivider(ColorScheme cs) => Divider(
        height: AppSpacing.space16,
        thickness: AppColors.dividerThickness,
        color: cs.outlineVariant,
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width >= _tabletBreakpoint
        ? _drawerTabletWidth
        : (size.width * _drawerWidthFraction).clamp(
            0.0,
            _drawerMobileMaxWidth,
          );

    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.surface,
      elevation: 0,
      width: width,
      // Modernist 零圆角：不留 Material3 Drawer 默认的圆角边，抽屉与其余屏
      // 保持同一套「层级由分隔线表达」的语言。
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.space24,
                        AppSpacing.space20,
                        AppSpacing.space16,
                        AppSpacing.space8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BrandWordmark(
                          text: Strings.aboutAppName,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    // 品牌区底部 2px 分隔线（对应设计系统 `.nav`
                    // `border-bottom`），与下方 SidebarGroup 组间分隔线
                    // 同厚度但独立于列表滚动区之外，标记「品牌/导航」边界。
                    Divider(
                      height: AppSpacing.space16,
                      thickness: AppColors.dividerThickness,
                      color: cs.outlineVariant,
                    ),
                    const SidebarHeader(),
                    const SizedBox(height: AppSpacing.space8),
                    SidebarGroup(
                      header: Strings.drawerSectionContent,
                      children: [
                        SidebarTile(
                          icon: CupertinoIcons.heart,
                          title: Strings.favorites,
                          onTap: () => _navigateToFavorites(context),
                        ),
                        SidebarTile(
                          icon: CupertinoIcons.clock,
                          title: Strings.recentPlay,
                          onTap: () => _showComingSoon(
                            context,
                            Strings.recentPlay,
                          ),
                        ),
                      ],
                    ),
                    _groupDivider(cs),
                    SidebarGroup(
                      header: Strings.drawerSectionDiscover,
                      children: [
                        SidebarTile(
                          icon: CupertinoIcons.tag,
                          title: Strings.tags,
                          onTap: () => _navigate(context, const TagsScreen()),
                        ),
                        SidebarTile(
                          icon: Icons.group_outlined,
                          title: Strings.circles,
                          onTap: () =>
                              _navigate(context, const CirclesScreen()),
                        ),
                        SidebarTile(
                          icon: CupertinoIcons.mic,
                          title: Strings.voiceActors,
                          onTap: () => _navigate(
                            context,
                            const VoiceActorsScreen(),
                          ),
                        ),
                        SidebarTile(
                          icon: Icons.bar_chart_rounded,
                          title: Strings.ranking,
                          onTap: () =>
                              _showComingSoon(context, Strings.ranking),
                        ),
                      ],
                    ),
                    _groupDivider(cs),
                    Consumer<ThemeController>(
                      builder: (context, themeController, _) {
                        return SidebarGroup(
                          header: Strings.drawerSectionSystem,
                          children: [
                            SidebarTile(
                              icon: CupertinoIcons.settings,
                              title: Strings.settings,
                              onTap: () => _navigate(
                                context,
                                const SettingsScreen(),
                              ),
                            ),
                            SidebarTile(
                              icon: CupertinoIcons.moon_stars,
                              title: Strings.darkModeMenu,
                              onTap: themeController.toggleThemeMode,
                              trailing: _ThemeModeBadge(
                                label: _themeModeLabel(
                                  themeController.themeMode,
                                ),
                              ),
                            ),
                            SidebarTile(
                              icon: CupertinoIcons.info,
                              title: Strings.aboutUs,
                              onTap: () => _navigate(
                                context,
                                const AboutScreen(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    const _SidebarFooter(),
                    const SizedBox(height: AppSpacing.space16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题模式小药丸（中性 chip，非玻璃）。
class _ThemeModeBadge extends StatelessWidget {
  const _ThemeModeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.fullAll,
        color: cs.surfaceContainerHighest,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatefulWidget {
  const _SidebarFooter();

  @override
  State<_SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends State<_SidebarFooter> {
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          final label =
              snapshot.hasData ? 'Xuro v${snapshot.data!.version}' : 'Xuro';
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.smAll,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
