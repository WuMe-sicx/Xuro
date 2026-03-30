import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _TileType { navigation, toggle, selection }

class SettingsTile extends StatelessWidget {
  final _TileType _type;
  final String title;
  final String? subtitle;
  final IconData leading;
  final VoidCallback? onTap;
  final String? value;
  final bool? toggled;
  final ValueChanged<bool>? onChanged;
  final bool? selected;

  const SettingsTile._({
    super.key,
    required _TileType type,
    required this.title,
    this.subtitle,
    required this.leading,
    this.onTap,
    this.value,
    this.toggled,
    this.onChanged,
    this.selected,
  }) : _type = type;

  /// Navigation tile with trailing chevron
  const SettingsTile.navigation({
    Key? key,
    required String title,
    String? subtitle,
    required IconData leading,
    VoidCallback? onTap,
    String? value,
  }) : this._(
          key: key,
          type: _TileType.navigation,
          title: title,
          subtitle: subtitle,
          leading: leading,
          onTap: onTap,
          value: value,
        );

  /// Toggle tile with CupertinoSwitch
  const SettingsTile.toggle({
    Key? key,
    required String title,
    String? subtitle,
    required IconData leading,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) : this._(
          key: key,
          type: _TileType.toggle,
          title: title,
          subtitle: subtitle,
          leading: leading,
          toggled: value,
          onChanged: onChanged,
        );

  /// Selection tile with checkmark
  const SettingsTile.selection({
    Key? key,
    required String title,
    String? subtitle,
    required IconData leading,
    required bool selected,
    VoidCallback? onTap,
  }) : this._(
          key: key,
          type: _TileType.selection,
          title: title,
          subtitle: subtitle,
          leading: leading,
          selected: selected,
          onTap: onTap,
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget trailing = _buildTrailing(context, colorScheme);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: InkWell(
        onTap: _type == _TileType.toggle ? null : (onTap != null ? _handleTap : null),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _buildLeadingIcon(colorScheme),
              const SizedBox(width: 12),
              Expanded(child: _buildText(context, colorScheme)),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ColorScheme colorScheme) {
    return SizedBox(
      width: 32,
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(leading, size: 20, color: colorScheme.primary),
      ),
    );
  }

  Widget _buildText(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context, ColorScheme colorScheme) {
    switch (_type) {
      case _TileType.navigation:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  value!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        );

      case _TileType.toggle:
        return CupertinoSwitch(
          value: toggled ?? false,
          activeTrackColor: colorScheme.primary,
          onChanged: (v) {
            HapticFeedback.lightImpact();
            onChanged?.call(v);
          },
        );

      case _TileType.selection:
        return selected == true
            ? Icon(Icons.check, color: colorScheme.primary)
            : const SizedBox(width: 24);
    }
  }

  void _handleTap() {
    if (_type == _TileType.selection) {
      HapticFeedback.selectionClick();
    }
    onTap?.call();
  }
}
