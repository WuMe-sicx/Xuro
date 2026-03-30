import 'dart:async';
import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/utils/logger.dart';

class SubtitleStateManager {
  SubtitleList? _subtitleList;
  Subtitle? _currentSubtitle;
  SubtitleWithState? _currentSubtitleWithState;

  final _subtitleController = StreamController<SubtitleList?>.broadcast();
  final _currentSubtitleController = StreamController<Subtitle?>.broadcast();
  final _currentSubtitleWithStateController = StreamController<SubtitleWithState?>.broadcast();

  Stream<SubtitleList?> get subtitleStream => _subtitleController.stream;
  Stream<Subtitle?> get currentSubtitleStream => _currentSubtitleController.stream;
  Stream<SubtitleWithState?> get currentSubtitleWithStateStream => 
      _currentSubtitleWithStateController.stream;

  Subtitle? get currentSubtitle => _currentSubtitle;
  SubtitleList? get subtitleList => _subtitleList;
  SubtitleWithState? get currentSubtitleWithState => _currentSubtitleWithState;

  void setSubtitleList(SubtitleList? subtitleList) {
    _subtitleList = subtitleList;
    _subtitleController.add(_subtitleList);
  }

  void updatePosition(Duration position) {
    if (_subtitleList != null) {
      final newSubtitleWithState = _subtitleList!.getCurrentSubtitle(position);
      if (newSubtitleWithState?.subtitle != _currentSubtitleWithState?.subtitle) {
        _currentSubtitleWithState = newSubtitleWithState;
        _currentSubtitle = newSubtitleWithState?.subtitle;
        AppLogger.debug('字幕更新: ${_currentSubtitle?.text ?? '无字幕'} (${newSubtitleWithState?.state})');
        _currentSubtitleWithStateController.add(newSubtitleWithState);
        _currentSubtitleController.add(_currentSubtitle);
      }
    }
  }

  void clear() {
    _subtitleList = null;
    _currentSubtitle = null;
    _currentSubtitleWithState = null;
    _subtitleController.add(null);
    _currentSubtitleController.add(null);
    _currentSubtitleWithStateController.add(null);
    AppLogger.debug('字幕状态已清除');
  }

  void dispose() {
    _subtitleController.close();
    _currentSubtitleController.close();
    _currentSubtitleWithStateController.close();
  }
} 