import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/vas/voice_actor.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/utils/logger.dart';
import 'package:get_it/get_it.dart';

class VoiceActorsViewModel extends ChangeNotifier {
  final ApiService _apiService = GetIt.I<ApiService>();

  List<VoiceActor> _allVoiceActors = [];
  List<VoiceActor> _filteredVoiceActors = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  VoiceActorsViewModel() {
    loadVoiceActors();
  }

  List<VoiceActor> get voiceActors => _filteredVoiceActors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadVoiceActors() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allVoiceActors = await _apiService.getVoiceActors();
      _allVoiceActors.sort((a, b) => (b.count ?? 0).compareTo(a.count ?? 0));
      _applyFilter();
      AppLogger.info('声优列表加载成功: ${_allVoiceActors.length}个声优');
    } catch (e) {
      AppLogger.error('加载声优列表失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredVoiceActors = List.from(_allVoiceActors);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredVoiceActors = _allVoiceActors.where((va) {
        final name = va.name?.toLowerCase() ?? '';
        return name.contains(lowerQuery);
      }).toList();
    }
  }

  Future<void> refresh() async {
    await loadVoiceActors();
  }
}
