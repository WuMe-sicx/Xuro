import 'package:flutter/foundation.dart';
import 'package:asmrapp/data/models/circles/circle_item.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:get_it/get_it.dart';

class CirclesViewModel extends ChangeNotifier {
  final ApiService _apiService = GetIt.I<ApiService>();

  List<CircleItem> _allCircles = [];
  List<CircleItem> _filteredCircles = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  CirclesViewModel() {
    loadCircles();
  }

  List<CircleItem> get circles => _filteredCircles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadCircles() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCircles = await _apiService.getCircles();
      _allCircles.sort((a, b) => (b.count ?? 0).compareTo(a.count ?? 0));
      _applyFilter();
      AppLogger.info('社团列表加载成功: ${_allCircles.length}个社团');
    } catch (e) {
      AppLogger.error('加载社团列表失败', e);
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
      _filteredCircles = List.from(_allCircles);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredCircles = _allCircles.where((circle) {
        final name = circle.name?.toLowerCase() ?? '';
        return name.contains(lowerQuery);
      }).toList();
    }
  }

  Future<void> refresh() async {
    await loadCircles();
  }
}
