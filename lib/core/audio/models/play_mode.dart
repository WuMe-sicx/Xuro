import 'package:just_audio/just_audio.dart';

enum PlayMode {
  single,     // 单曲循环
  loop,       // 列表循环
  sequence;   // 顺序播放

  LoopMode toLoopMode() {
    switch (this) {
      case PlayMode.single:
        return LoopMode.one;
      case PlayMode.loop:
        return LoopMode.all;
      case PlayMode.sequence:
        return LoopMode.off;
    }
  }
}
