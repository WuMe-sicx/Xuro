import 'package:freezed_annotation/freezed_annotation.dart';

part 'rank_info.freezed.dart';
part 'rank_info.g.dart';

@freezed
class RankInfo with _$RankInfo {
  factory RankInfo({
    String? term,
    String? category,
    int? rank,
    @JsonKey(name: 'rank_date') String? rankDate,
  }) = _RankInfo;

  factory RankInfo.fromJson(Map<String, dynamic> json) => _$RankInfoFromJson(json);
}
