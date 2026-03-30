import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xuro/data/models/works/i18n.dart';

part 'voice_actor.freezed.dart';
part 'voice_actor.g.dart';

@freezed
class VoiceActor with _$VoiceActor {
  factory VoiceActor({
    String? id,
    String? name,
    int? count,
    I18n? i18n,
  }) = _VoiceActor;

  factory VoiceActor.fromJson(Map<String, dynamic> json) => _$VoiceActorFromJson(json);
}
