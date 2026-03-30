import 'dart:async';
import 'package:asmrapp/utils/logger.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/core/subtitle/subtitle_loader.dart';
import 'package:asmrapp/core/subtitle/managers/subtitle_state_manager.dart';


class SubtitleService implements ISubtitleService {
  final _subtitleLoader = GetIt.I<SubtitleLoader>();
  final _stateManager = SubtitleStateManager();
  
  @override
  Stream<SubtitleList?> get subtitleStream => _stateManager.subtitleStream;
  
  @override
  Stream<Subtitle?> get currentSubtitleStream => _stateManager.currentSubtitleStream;
  
  @override
  Subtitle? get currentSubtitle => _stateManager.currentSubtitle;
  
  @override
  Future<void> loadSubtitle(String url) async {
    try {
      clearSubtitle();
      final subtitleList = await _subtitleLoader.loadSubtitleContent(url);
      _stateManager.setSubtitleList(subtitleList);
    } catch (e) {
      AppLogger.debug('字幕加载失败: $e');
      clearSubtitle();
      rethrow;
    }
  }
  
  @override
  Future<void> loadSubtitleFromContent(SubtitleList subtitleList) async {
    clearSubtitle();
    _stateManager.setSubtitleList(subtitleList);
  }

  @override
  void updatePosition(Duration position) {
    _stateManager.updatePosition(position);
  }

  @override
  void dispose() {
    _stateManager.dispose();
  }

  @override
  SubtitleList? get subtitleList => _stateManager.subtitleList;

  @override
  void clearSubtitle() {
    _stateManager.clear();
  }

  @override
  Stream<SubtitleWithState?> get currentSubtitleWithStateStream => 
      _stateManager.currentSubtitleWithStateStream;
  
  @override
  SubtitleWithState? get currentSubtitleWithState => 
      _stateManager.currentSubtitleWithState;
} 