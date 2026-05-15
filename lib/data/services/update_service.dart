import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xuro/data/models/update_info.dart';
import 'package:xuro/data/services/exceptions/update_exception.dart';
import 'package:xuro/utils/logger.dart';

class UpdateCheckResult {
  final UpdateInfo latest;
  final String currentVersion;
  final bool hasUpdate;

  UpdateCheckResult({
    required this.latest,
    required this.currentVersion,
    required this.hasUpdate,
  });
}

/// 读取本仓库 GitHub Releases 并与当前版本比对。
///
/// 独立 Dio，host 固定为 api.github.com：**刻意不监听 `AppSettingsService`**，
/// 因为 asmr 节点切换与 GitHub 无关；也不挂 `AuthInterceptor`。
class UpdateService {
  static const String _owner = 'WuMe-sicx';
  static const String _repo = 'Xuro';

  /// CI 用 `softprops/action-gh-release` 且 `prerelease: true`，所以
  /// `/releases/latest`（只返回 non-prerelease）取不到——必须用列表端点。
  static const String _releasesPath = '/repos/$_owner/$_repo/releases';

  /// 只接受恰好 `vX.Y.Z` 形态的 tag（`$` 锚定：拒绝 `v1.2.3-rc.1`、
  /// `v1.2.3foo` 等带后缀 tag）。CI 的 tag 恒为精确三段式。
  static final RegExp _tagRe = RegExp(r'^v?\d+\.\d+\.\d+$');

  final Dio _dio;

  UpdateService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.github.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        ));

  Future<UpdateCheckResult> checkForUpdate() async {
    try {
      final resp = await _dio.get(
        _releasesPath,
        queryParameters: const {'per_page': 10},
      );
      final data = resp.data;
      if (data is! List) {
        throw UpdateException(
          type: UpdateErrorType.invalidPayload,
          message: 'releases 响应不是数组: ${data.runtimeType}',
        );
      }

      final latest = selectLatestRelease(data);
      if (latest == null) {
        throw UpdateException(
          type: UpdateErrorType.noRelease,
          message: '无合法发布（空列表或无 vX.Y.Z tag）',
        );
      }

      final current = (await PackageInfo.fromPlatform()).version;
      final hasUpdate = compareSemver(latest.version, current) > 0;
      AppLogger.info(
        '检查更新: 远端=${latest.version} 当前=$current 有更新=$hasUpdate',
      );
      return UpdateCheckResult(
        latest: latest,
        currentVersion: current,
        hasUpdate: hasUpdate,
      );
    } on UpdateException {
      rethrow;
    } on DioException catch (e, st) {
      AppLogger.error('检查更新网络失败', e, st);
      throw UpdateException.fromDioException(e);
    } catch (e, st) {
      AppLogger.error('检查更新解析失败', e, st);
      throw UpdateException(
        type: UpdateErrorType.invalidPayload,
        message: '解析失败: $e',
        originalError: e,
      );
    }
  }

  /// 从 releases 列表里挑出 **semver 最大** 的合法发布。
  ///
  /// 不取 `[0]`：GitHub 不承诺列表首项即最大，后补发旧/异常 tag 会误判。
  /// 单个 release 解析失败（如缺 `html_url`）会被跳过而非拖垮整次检查。
  /// 全部不合法时返回 `null`，由调用方转成 `noRelease`。
  static UpdateInfo? selectLatestRelease(List<dynamic> releases) {
    UpdateInfo? best;
    for (final r in releases) {
      if (r is! Map) continue;
      final map = Map<String, dynamic>.from(r);
      final tag = map['tag_name'];
      if (tag is! String || !_tagRe.hasMatch(tag)) continue;
      UpdateInfo info;
      try {
        info = UpdateInfo.fromReleaseJson(map);
      } on FormatException {
        continue;
      }
      if (best == null || compareSemver(info.version, best.version) > 0) {
        best = info;
      }
    }
    return best;
  }

  /// 纯函数语义化版本比较：返回 `>0` 表示 a 比 b 新，`0` 相等，`<0` 更旧。
  ///
  /// 容错：剥 `v` 前缀、位数不齐按 0 补齐（`1.2` == `1.2.0`）、非数字段按 0。
  static int compareSemver(String a, String b) {
    List<int> parts(String v) {
      var s = v.trim();
      if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
      final segs = s.split('.');
      return List<int>.generate(
        3,
        (i) => i < segs.length ? (int.tryParse(segs[i].trim()) ?? 0) : 0,
      );
    }

    final pa = parts(a);
    final pb = parts(b);
    for (var i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i] > pb[i] ? 1 : -1;
    }
    return 0;
  }
}
