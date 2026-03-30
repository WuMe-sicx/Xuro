import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_va.freezed.dart';
part 'work_va.g.dart';

@freezed
class WorkVA with _$WorkVA {
  factory WorkVA({
    String? id,
    String? name,
  }) = _WorkVA;

  factory WorkVA.fromJson(Map<String, dynamic> json) => _$WorkVAFromJson(json);
}
