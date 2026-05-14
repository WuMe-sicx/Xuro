import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_animations.dart';

class SidebarTile extends StatefulWidget {
  const SidebarTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.onTap,
    this.showSeparator = true,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final VoidCallback onTap;
  final bool showSeparator;

  /// Custom trailing widget. Defaults to a thin chevron when null.
  final Widget? trailing;

  @override
  State<SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<SidebarTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: AppAnimations.micro,
          color: _isPressed
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      _ColoredIconBadge(
                        icon: widget.icon,
                        iconColor: widget.iconColor,
                        backgroundColor: widget.iconBackgroundColor,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      widget.trailing ??
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                    ],
                  ),
                ),
                if (widget.showSeparator)
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.only(left: 46),
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColoredIconBadge extends StatelessWidget {
  const _ColoredIconBadge({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            Color.lerp(backgroundColor, Colors.black, 0.18) ?? backgroundColor,
          ],
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}
