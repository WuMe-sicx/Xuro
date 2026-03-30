import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xuro/data/models/works/i18n.dart';

part 'circle_item.freezed.dart';
part 'circle_item.g.dart';

@freezed
class CircleItem with _$CircleItem {
  factory CircleItem({
    int? id,
    String? name,
    int? count,
    I18n? i18n,
  }) = _CircleItem;

  factory CircleItem.fromJson(Map<String, dynamic> json) => _$CircleItemFromJson(json);
}
