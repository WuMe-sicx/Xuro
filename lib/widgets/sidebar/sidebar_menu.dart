import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/settings/app_settings_service.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/theme_controller.dart';
import 'package:xuro/presentation/viewmodels/auth_viewmodel.dart';
import 'package:xuro/presentation/widgets/auth/login_dialog.dart';
import 'package:xuro/screens/browse/circles_screen.dart';
import 'package:xuro/screens/browse/tags_screen.dart';
import 'package:xuro/screens/browse/voice_actors_screen.dart';
import 'package:xuro/screens/favorites_screen.dart';
import 'package:xuro/screens/settings/settings_screen.dart';
import 'package:xuro/widgets/sidebar/sidebar_group.dart';
import 'package:xuro/widgets/sidebar/sidebar_header.dart';
import 'package:xuro/widgets/sidebar/sidebar_tile.dart';

/// Single neutral gray used for ALL sidebar menu icon backgrounds. The
/// previous design had 8 different brand-style colors per icon; the
/// "two color" simplification collapses them to one neutral so the only
/// chromatic accents in the drawer are the avatar / arrow / footer dot,
/// which all draw from `Theme.of(context).colorScheme.primary`.
const Color _kIconBgGray = Color(0xFF8E8E93);

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  static const _drawerWidthFraction = 0.72;
  static const _drawerMobileMaxWidth = 360.0;
  static const _drawerTabletWidth = 304.0;
  // Matches the mobile/tablet breakpoint defined in ui-design-spec §5.
  static const _tabletBreakpoint = 800.0;
  static const _cornerRadius = 28.0;

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
    // Capture the messenger before popping the drawer so the SnackBar is
    // attached to the stable root Scaffold rather than relying on the
    // about-to-deactivate drawer subtree.
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width >= _tabletBreakpoint
        ? _drawerTabletWidth
        : (size.width * _drawerWidthFraction).clamp(
            0.0,
            _drawerMobileMaxWidth,
          );

    // Force dark, glassy palette inside the drawer regardless of app theme.
    //
    // IMPORTANT: do NOT just `copyWith(brightness: Brightness.dark)` — that
    // only flips the brightness flag and keeps the LIGHT variant's primary,
    // which on a near-black drawer background turns the avatar / glow / footer
    // dot invisible (e.g. mono variant in light mode → primary stays black).
    // Build the local Theme from the explicit dark ColorScheme of the active
    // ColorVariant so the accent rotates correctly across blue/mono/green.
    final variant = context.watch<AppSettingsService>().colorVariant;
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        colorScheme: AppColors.darkSchemeFor(variant),
      ),
      child: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        width: width,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(_cornerRadius),
            bottomRight: Radius.circular(_cornerRadius),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(_cornerRadius),
            bottomRight: Radius.circular(_cornerRadius),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Note: an earlier version stacked a fullscreen
              // BackdropFilter(blur 18) + 18% black overlay on top of
              // _DrawerBackground. PerfDog showed that the very first
              // open of the drawer cost ~256ms on real Android (Impeller
              // offscreen layer + shader). The blur was visually a no-op
              // because _DrawerBackground is opaque, and the 18% darken
              // has been folded into the gradient stops below — so the
              // BackdropFilter has been removed outright.
              const _DrawerBackground(),
              const _RightEdgeHighlight(),
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SidebarHeader(),
                          SidebarGroup(
                            header: Strings.drawerSectionContent,
                            children: [
                              SidebarTile(
                                icon: CupertinoIcons.heart_fill,
                                iconColor: Colors.white,
                                iconBackgroundColor: _kIconBgGray,
                                title: Strings.favorites,
                                onTap: () => _navigateToFavorites(context),
                              ),
                              SidebarTile(
                                icon: CupertinoIcons.clock_fill,
                                iconColor: Colors.white,
                                iconBackgroundColor: _kIconBgGray,
                                title: Strings.recentPlay,
                                onTap: () => _showComingSoon(
                                  context,
                                  Strings.recentPlay,
                                ),
                                showSeparator: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SidebarGroup(
                            header: Strings.drawerSectionDiscover,
                            children: [
                              SidebarTile(
                                icon: CupertinoIcons.tag_fill,
                                iconColor: Colors.white,
                                iconBackgroundColor: _kIconBgGray,
                                title: Strings.tags,
                                onTap: () =>
                                    _navigate(context, const TagsScreen()),
                              ),
                              SidebarTile(
                                icon: Icons.group,
                                iconColor: Colors.white,
                                iconBackgroundColor: _kIconBgGray,
                                title: Strings.circles,
                                onTap: () =>
                                    _navigate(context, const CirclesScreen()),
                              ),
                              SidebarTile(
                                icon: CupertinoIcons.mic_fill,
                                iconColor: Colors.white,
                                iconBackgroundColor: _kIconBgGray,
                                title: Strings.voiceActors,
                                onTap: () => _navigate(
                                  context,
                                  const VoiceActorsScreen(),
                                ),
                              ),
                              SidebarTile(
                                icon: Icons.bar_chart_rounded,
                                iconColor: Colors.white,
                                iconBackgroundColor: _kIconBgGray,
                                title: Strings.ranking,
                                onTap: () =>
                                    _showComingSoon(context, Strings.ranking),
                                showSeparator: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Consumer<ThemeController>(
                            builder: (context, themeController, _) {
                              return SidebarGroup(
                                header: Strings.drawerSectionSystem,
                                children: [
                                  SidebarTile(
                                    icon: CupertinoIcons.settings,
                                    iconColor: Colors.white,
                                    iconBackgroundColor: _kIconBgGray,
                                    title: Strings.settings,
                                    onTap: () => _navigate(
                                      context,
                                      const SettingsScreen(),
                                    ),
                                  ),
                                  SidebarTile(
                                    icon: CupertinoIcons.moon_stars_fill,
                                    iconColor: Colors.white,
                                    iconBackgroundColor: _kIconBgGray,
                                    title: Strings.darkModeMenu,
                                    onTap: themeController.toggleThemeMode,
                                    trailing: _ThemeModeBadge(
                                      label: _themeModeLabel(
                                        themeController.themeMode,
                                      ),
                                    ),
                                  ),
                                  SidebarTile(
                                    icon: CupertinoIcons.info_circle_fill,
                                    iconColor: Colors.white,
                                    iconBackgroundColor: _kIconBgGray,
                                    title: Strings.aboutUs,
                                    onTap: () => _navigate(
                                      context,
                                      const SettingsScreen(),
                                    ),
                                    showSeparator: false,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          const _SidebarFooter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
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

class _DrawerBackground extends StatelessWidget {
  const _DrawerBackground();

  @override
  Widget build(BuildContext context) {
    // Neutral dark gradient — no hue. Works equally for blue / mono / green
    // accent variants. The two soft glows below are tinted with the active
    // theme's primary so the drawer picks up the user's chosen accent.
    final accent = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A), // near-black
            Color(0xFF111111),
            Color(0xFF161616),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Faint accent aurora glow at the top.
          Positioned(
            top: -120,
            left: -80,
            child: _SoftGlow(
              size: 320,
              color: accent.withValues(alpha: 0.22),
            ),
          ),
          // Fainter accent glow near bottom (lower alpha for asymmetry).
          Positioned(
            bottom: -140,
            right: -60,
            child: _SoftGlow(
              size: 280,
              color: accent.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

class _RightEdgeHighlight extends StatelessWidget {
  const _RightEdgeHighlight();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 1,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeModeBadge extends StatelessWidget {
  const _ThemeModeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.85),
          letterSpacing: 0.3,
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
  // Cached so rebuilds (e.g., theme toggle) don't re-issue the platform call
  // and don't briefly flash a stale placeholder version.
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          final label = snapshot.hasData
              ? 'Xuro v${snapshot.data!.version}'
              : 'Xuro';
          final accent = Theme.of(context).colorScheme.primary;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.40),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
