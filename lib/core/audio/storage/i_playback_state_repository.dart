import 'package:xuro/data/models/playback/playback_state.dart';

abstract class IPlaybackStateRepository {
  Future<void> saveState(PlaybackState state);
  Future<PlaybackState?> loadState();
} 