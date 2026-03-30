import 'package:asmrapp/core/subtitle/models/user_subtitle_entry.dart';

abstract class IUserSubtitleRepository {
  Future<UserSubtitleEntry?> find(String workId, String fileName);
  Future<void> upsert(UserSubtitleEntry entry);
  Future<void> remove(String workId, String fileName);
  Future<List<UserSubtitleEntry>> listByWork(String workId);
}
