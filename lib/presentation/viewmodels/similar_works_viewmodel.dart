import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimilarWorksViewModel extends ChangeNotifier {
  static const _subtitleFilterKey = 'subtitle_filter'; // 与其他 ViewModel 使用相同的 key
  final ApiService _apiService;
  final Work work;
  List<Work> _works = [];
  bool _isLoading = false;
  String? _error;
  Pagination? _pagination;
  int _currentPage = 1;
  bool _hasSubtitle = false;
  bool _filterPanelExpanded = false;

  SimilarWorksViewModel(this.work) : _apiService = GetIt.I<ApiService>() {
    _loadFilterState();
  }

  // Getters
  List<Work> get works => _works;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasSubtitle => _hasSubtitle;
  bool get filterPanelExpanded => _filterPanelExpanded;
  int? get totalPages =>
      _pagination?.totalCount != null && _pagination?.pageSize != null
          ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
          : null;

  // 加载筛选状态
  Future<void> _loadFilterState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSubtitle = prefs.getBool(_subtitleFilterKey) ?? false;
      notifyListeners();
      // 首次加载时应用筛选状态
      loadSimilarWorks(refresh: true);
    } catch (e) {
      AppLogger.error('加载筛选状态失败', e);
    }
  }

  // 保存筛选状态
  Future<void> _saveFilterState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_subtitleFilterKey, _hasSubtitle);
    } catch (e) {
      AppLogger.error('保存筛选状态失败', e);
    }
  }

  // 切换字幕筛选
  void toggleSubtitleFilter() {
    _hasSubtitle = !_hasSubtitle;
    _saveFilterState();
    notifyListeners();
    loadSimilarWorks(refresh: true);
  }

  void toggleFilterPanel() {
    _filterPanelExpanded = !_filterPanelExpanded;
    notifyListeners();
  }

  void closeFilterPanel() {
    if (_filterPanelExpanded) {
      _filterPanelExpanded = false;
      notifyListeners();
    }
  }

  /// 加载指定页面的数据
  Future<void> loadPage(int page) async {
    if (_isLoading) return;
    if (page < 1 || (totalPages != null && page > totalPages!)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getItemNeighbors(
        itemId: work.id.toString(),
        page: page,
        hasSubtitle: _hasSubtitle, // 添加字幕筛选参数
      );
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('第$page页相关推荐加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载相关推荐失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载相关推荐(用于初始加载和刷新)
  Future<void> loadSimilarWorks({bool refresh = false}) async {
    await loadPage(1);
  }

  @override
  void dispose() {
    _saveFilterState();
    super.dispose();
  }
} 