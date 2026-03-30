import 'package:xuro/data/models/my_lists/my_playlists/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/data/models/works/pagination.dart';
import 'package:xuro/data/services/api_service.dart';
import 'package:xuro/utils/logger.dart';
import 'package:get_it/get_it.dart';

class PlaylistWorksViewModel extends ChangeNotifier {
  final ApiService _apiService = GetIt.I<ApiService>();
  final Playlist playlist;
  
  List<Work> _works = [];
  bool _isLoading = false;
  String? _error;
  Pagination? _pagination;
  int _currentPage = 1;

  PlaylistWorksViewModel(this.playlist);

  List<Work> get works => _works;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int? get totalPages => _pagination?.totalCount != null && _pagination?.pageSize != null
      ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
      : null;

  Future<void> loadWorks({int page = 1}) async {
    if (_isLoading) return;
    if (page < 1 || (totalPages != null && page > totalPages!)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPlaylistWorks(
        playlistId: playlist.id!,
        page: page,
      );
      
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('第$page页播放列表作品加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载播放列表作品失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadWorks(page: 1);
}
