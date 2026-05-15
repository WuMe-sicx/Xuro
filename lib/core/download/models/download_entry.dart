/// 一条已完成的本地下载记录。
///
/// 纯类 + toMap/fromMap，无 codegen。去重键是 [fileKey]（稳定身份摘要），
/// 与 `downloads` 表 `UNIQUE(work_id, file_key)` 一致——**不是**展示名
/// [fileName]：同一作品下不同目录/URL 的同名文件必须算不同下载。
class DownloadEntry {
  final int? id;
  final String workId;

  /// 稳定身份摘要（md5(hash|url|title)）。去重 / 查询 / 删除均用它。
  final String fileKey;

  /// 原始展示文件名（`Child.title`），仅用于 UI 展示。
  final String fileName;
  final String filePath;

  /// 'audio' | 'video'——来源 `Child.type`，决定离线播放走音频管线还是外部查看器。
  final String mediaType;
  final String sourceUrl;
  final int size;
  final int createdAt;

  const DownloadEntry({
    this.id,
    required this.workId,
    required this.fileKey,
    required this.fileName,
    required this.filePath,
    required this.mediaType,
    required this.sourceUrl,
    required this.size,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'work_id': workId,
      'file_key': fileKey,
      'file_name': fileName,
      'file_path': filePath,
      'media_type': mediaType,
      'source_url': sourceUrl,
      'size': size,
      'created_at': createdAt,
    };
  }

  factory DownloadEntry.fromMap(Map<String, dynamic> map) {
    return DownloadEntry(
      id: map['id'] as int?,
      workId: map['work_id'] as String,
      fileKey: map['file_key'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      mediaType: map['media_type'] as String,
      sourceUrl: map['source_url'] as String,
      size: map['size'] as int,
      createdAt: map['created_at'] as int,
    );
  }
}
