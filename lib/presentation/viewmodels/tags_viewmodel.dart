import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/tags/tag_item.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/utils/logger.dart';
import 'package:get_it/get_it.dart';

class TagsViewModel extends ChangeNotifier {
  final ApiService _apiService = GetIt.I<ApiService>();

  List<TagItem> _allTags = [];
  List<TagItem> _filteredTags = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  TagsViewModel() {
    loadTags();
  }

  List<TagItem> get tags => _filteredTags;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadTags() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTags = await _apiService.getTags();
      _allTags.sort((a, b) => (b.count ?? 0).compareTo(a.count ?? 0));
      _applyFilter();
      AppLogger.info('标签列表加载成功: ${_allTags.length}个标签');
    } catch (e) {
      AppLogger.error('加载标签列表失败', e);
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
      _filteredTags = List.from(_allTags);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredTags = _allTags.where((tag) {
        final name = tag.name?.toLowerCase() ?? '';
        final zhName = tag.i18n?.zhCn?.name?.toLowerCase() ?? '';
        final enName = tag.i18n?.enUs?.name?.toLowerCase() ?? '';
        final jaName = tag.i18n?.jaJp?.name?.toLowerCase() ?? '';
        return name.contains(lowerQuery) ||
            zhName.contains(lowerQuery) ||
            enName.contains(lowerQuery) ||
            jaName.contains(lowerQuery);
      }).toList();
    }
  }

  Future<void> refresh() async {
    await loadTags();
  }
}
