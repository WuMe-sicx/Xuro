import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asmrapp/data/models/works/i18n.dart';

part 'tag_item.freezed.dart';
part 'tag_item.g.dart';

@freezed
class TagItem with _$TagItem {
  factory TagItem({
    int? id,
    String? name,
    int? count,
    I18n? i18n,
  }) = _TagItem;

  factory TagItem.fromJson(Map<String, dynamic> json) => _$TagItemFromJson(json);
}
