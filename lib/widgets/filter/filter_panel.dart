import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/common/constants/strings.dart';

class FilterPanel extends StatelessWidget {
  final bool expanded;
  final bool hasSubtitle;
  final String orderField;
  final bool isDescending;
  final ValueChanged<bool> onSubtitleChanged;
  final ValueChanged<String> onOrderFieldChanged;
  final ValueChanged<bool> onSortDirectionChanged;

  const FilterPanel({
    super.key,
    this.expanded = false,
    required this.hasSubtitle,
    required this.orderField,
    required this.isDescending,
    required this.onSubtitleChanged,
    required this.onOrderFieldChanged,
    required this.onSortDirectionChanged,
  });

  String _getOrderFieldText(String field) {
    switch (field) {
      case 'create_date':
        return Strings.filterOrderCreateDate;
      case 'release':
        return Strings.filterOrderRelease;
      case 'dl_count':
        return Strings.filterOrderSales;
      case 'price':
        return Strings.filterOrderPrice;
      case 'rate_average_2dp':
        return Strings.filterOrderRating;
      case 'review_count':
        return Strings.filterOrderReview;
      case 'id':
        return Strings.filterOrderRj;
      case 'rating':
        return Strings.filterOrderMyRating;
      case 'nsfw':
        return Strings.filterOrderAllAges;
      case 'random':
        return Strings.filterOrderRandom;
      default:
        return Strings.filterOrderDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 字幕过滤
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
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Strings.hasSubtitle,
                          style: TextStyle(
                            color: hasSubtitle
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 排序字段
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
              child: PopupMenuButton<String>(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getOrderFieldText(orderField)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  _buildOrderMenuItem(
                      Strings.filterOrderCreateDate, 'create_date'),
                  _buildOrderMenuItem(Strings.filterOrderRelease, 'release'),
                  _buildOrderMenuItem(Strings.filterOrderSales, 'dl_count'),
                  _buildOrderMenuItem(Strings.filterOrderPrice, 'price'),
                  _buildOrderMenuItem(
                      Strings.filterOrderRating, 'rate_average_2dp'),
                  _buildOrderMenuItem(
                      Strings.filterOrderReview, 'review_count'),
                  _buildOrderMenuItem(Strings.filterOrderRj, 'id'),
                  _buildOrderMenuItem(Strings.filterOrderMyRating, 'rating'),
                  _buildOrderMenuItem(Strings.filterOrderAllAges, 'nsfw'),
                  _buildOrderMenuItem(Strings.filterOrderRandom, 'random'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 排序方向
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
                  onTap: () => onSortDirectionChanged(!isDescending),
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isDescending
                            ? Strings.sortDescending
                            : Strings.sortAscending),
                        const SizedBox(width: 4),
                        Icon(
                          isDescending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
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

  PopupMenuItem<String> _buildOrderMenuItem(String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Text(text),
    );
  }
}
