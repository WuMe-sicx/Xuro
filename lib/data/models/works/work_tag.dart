import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asmrapp/data/models/works/i18n.dart';

part 'work_tag.freezed.dart';
part 'work_tag.g.dart';

@freezed
class WorkTag with _$WorkTag {
  factory WorkTag({
    int? id,
    String? name,
    I18n? i18n,
    int? upvote,
    int? downvote,
    int? voteRank,
    int? voteStatus,
  }) = _WorkTag;

  factory WorkTag.fromJson(Map<String, dynamic> json) => _$WorkTagFromJson(json);
}
