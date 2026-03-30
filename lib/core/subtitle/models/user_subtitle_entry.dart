class UserSubtitleEntry {
  final int? id;
  final String workId;
  final String fileName;
  final String subtitlePath;
  final String? originalName;
  final String format;
  final int createdAt;

  const UserSubtitleEntry({
    this.id,
    required this.workId,
    required this.fileName,
    required this.subtitlePath,
    this.originalName,
    required this.format,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'work_id': workId,
      'file_name': fileName,
      'subtitle_path': subtitlePath,
      'original_name': originalName,
      'format': format,
      'created_at': createdAt,
    };
  }

  factory UserSubtitleEntry.fromMap(Map<String, dynamic> map) {
    return UserSubtitleEntry(
      id: map['id'] as int?,
      workId: map['work_id'] as String,
      fileName: map['file_name'] as String,
      subtitlePath: map['subtitle_path'] as String,
      originalName: map['original_name'] as String?,
      format: map['format'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}
