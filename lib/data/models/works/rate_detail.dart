import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_detail.freezed.dart';
part 'rate_detail.g.dart';

@freezed
class RateDetail with _$RateDetail {
  factory RateDetail({
    @JsonKey(name: 'review_point') int? reviewPoint,
    int? count,
    double? ratio,
  }) = _RateDetail;

  factory RateDetail.fromJson(Map<String, dynamic> json) => _$RateDetailFromJson(json);
}
