import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/common/constants/strings.dart';

class FilterWithKeyword extends StatelessWidget {
  final bool hasSubtitle;
  final Function(bool) onSubtitleChanged;
  final bool showSearchField;
  final String? keyword;
  final Function(String)? onSearch;
  final VoidCallback? onClear;

  const FilterWithKeyword({
    super.key,
    required this.hasSubtitle,
    required this.onSubtitleChanged,
    this.showSearchField = false,
    this.keyword,
    this.onSearch,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.5),
                ),
                borderRadius: AppRadius.smAll,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => onSubtitleChanged(!hasSubtitle),
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasSubtitle
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                          color: hasSubtitle
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Strings.hasSubtitle,
                          style: TextStyle(
                            color: hasSubtitle
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
