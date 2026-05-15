import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_info.freezed.dart';

/// 一个 GitHub Release 的精简视图。
///
/// 字段是从 GitHub Release JSON **派生**的（`version` 剥掉 `v` 前缀、
/// `apkDownloadUrl` 从 assets 里挑首个 `.apk`），1:1 的 generated `fromJson`
/// 并不适用，故仅用 Freezed + 自定义 [UpdateInfo.fromReleaseJson]，不接
/// json_serializable（无 `.g.dart`）。
@freezed
class UpdateInfo with _$UpdateInfo {
  const factory UpdateInfo({
    required String tagName,
    required String version,
    required String releaseNotes,
    required String htmlUrl,
    String? apkDownloadUrl,
    required String publishedAt,
  }) = _UpdateInfo;

  /// 从单个 GitHub Release JSON 构造。
  ///
  /// 缺少 `tag_name` 或 `html_url`（无法定位与跳转）时抛 [FormatException]，
  /// 由 `UpdateService` 统一转成 `UpdateException(invalidPayload)`——模型层
  /// 不依赖 service 层异常，保持层次干净且便于单测。
  factory UpdateInfo.fromReleaseJson(Map<String, dynamic> json) {
    final tag = json['tag_name'];
    final html = json['html_url'];
    if (tag is! String || tag.isEmpty || html is! String || html.isEmpty) {
      throw const FormatException('GitHub release 缺少 tag_name 或 html_url');
    }

    String? apkUrl;
    final assets = json['assets'];
    if (assets is List) {
      for (final a in assets) {
        if (a is Map &&
            a['name'] is String &&
            (a['name'] as String).toLowerCase().endsWith('.apk') &&
            a['browser_download_url'] is String) {
          apkUrl = a['browser_download_url'] as String;
          break;
        }
      }
    }

    final version =
        (tag.startsWith('v') || tag.startsWith('V')) ? tag.substring(1) : tag;
    final body = (json['body'] as String?)?.trim() ?? '';

    return UpdateInfo(
      tagName: tag,
      version: version,
      releaseNotes: body,
      htmlUrl: html,
      apkDownloadUrl: apkUrl,
      publishedAt: json['published_at'] as String? ?? '',
    );
  }
}
