import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xuro/core/subtitle/import/i_file_picker_service.dart';
import 'package:xuro/core/subtitle/storage/i_user_subtitle_repository.dart';
import 'package:xuro/core/subtitle/models/user_subtitle_entry.dart';
import 'package:xuro/core/subtitle/parsers/subtitle_parser_factory.dart';
import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/utils/logger.dart';

enum ImportResult {
  success,
  cancelled,
  invalidFormat,
  fileTooLarge,
  parseFailed,
  ioError,
}

class ImportResponse {
  final ImportResult result;
  final SubtitleList? subtitleList;

  const ImportResponse(this.result, [this.subtitleList]);
}

class SubtitleImportService {
  static const _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const _supportedExtensions = ['.vtt', '.lrc'];

  final IFilePickerService _picker;
  final IUserSubtitleRepository _repository;

  SubtitleImportService({
    required IFilePickerService picker,
    required IUserSubtitleRepository repository,
  })  : _picker = picker,
        _repository = repository;

  /// Full import flow: pick → validate → parse → copy → persist
  Future<ImportResponse> importSubtitle(String workId, String fileName) async {
    try {
      // 1. Pick file
      final pickedPath = await _picker.pickSubtitleFile();
      if (pickedPath == null) return const ImportResponse(ImportResult.cancelled);

      final file = File(pickedPath);
      final originalName = p.basename(pickedPath);
      final ext = p.extension(pickedPath).toLowerCase();

      // 2. Validate extension
      if (!_supportedExtensions.contains(ext)) {
        AppLogger.warning('字幕格式不支持: $ext');
        return const ImportResponse(ImportResult.invalidFormat);
      }

      // 3. File size guard
      final fileSize = await file.length();
      if (fileSize > _maxFileSizeBytes) {
        AppLogger.warning('字幕文件过大: ${fileSize ~/ 1024}KB');
        return const ImportResponse(ImportResult.fileTooLarge);
      }

      // 4. Read + parse to validate content
      final content = await file.readAsString();
      final parser = SubtitleParserFactory.getParser(content);
      if (parser == null) {
        AppLogger.warning('字幕内容解析失败: $originalName');
        return const ImportResponse(ImportResult.parseFailed);
      }

      SubtitleList subtitleList;
      try {
        subtitleList = parser.parse(content);
        if (subtitleList.subtitles.isEmpty) {
          AppLogger.warning('字幕文件无有效内容: $originalName');
          return const ImportResponse(ImportResult.parseFailed);
        }
      } catch (e) {
        AppLogger.error('字幕解析异常', e);
        return const ImportResponse(ImportResult.parseFailed);
      }

      // 5. Compute destination path and clean up old file if re-importing
      final destPath = await _getDestPath(workId, fileName, ext);
      final existingEntry = await _repository.find(workId, fileName);
      if (existingEntry != null && existingEntry.subtitlePath != destPath) {
        final oldFile = File(existingEntry.subtitlePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
          AppLogger.debug('删除旧的导入字幕文件: ${existingEntry.subtitlePath}');
        }
      }

      // 6. Copy to app-private storage
      await file.copy(destPath);

      // 7. Persist association to SQLite
      final entry = UserSubtitleEntry(
        workId: workId,
        fileName: fileName,
        subtitlePath: destPath,
        originalName: originalName,
        format: ext.replaceFirst('.', ''),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _repository.upsert(entry);

      AppLogger.debug('字幕导入成功: $originalName -> $workId/$fileName');
      return ImportResponse(ImportResult.success, subtitleList);
    } catch (e) {
      AppLogger.error('字幕导入失败', e);
      return const ImportResponse(ImportResult.ioError);
    }
  }

  /// Check if a user-imported subtitle exists for this audio.
  Future<UserSubtitleEntry?> findImported(String workId, String fileName) {
    return _repository.find(workId, fileName);
  }

  /// Load and parse a local subtitle file. Returns null on any failure.
  Future<SubtitleList?> loadLocalSubtitle(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.warning('本地字幕文件不存在: $filePath');
        return null;
      }
      final content = await file.readAsString();
      final parser = SubtitleParserFactory.getParser(content);
      if (parser == null) return null;
      final subtitleList = parser.parse(content);
      return subtitleList.subtitles.isNotEmpty ? subtitleList : null;
    } catch (e) {
      AppLogger.error('加载本地字幕失败', e);
      return null;
    }
  }

  /// Remove imported subtitle: delete local file + DB entry.
  Future<void> removeImportedSubtitle(String workId, String fileName) async {
    try {
      final entry = await _repository.find(workId, fileName);
      if (entry != null) {
        final file = File(entry.subtitlePath);
        if (await file.exists()) await file.delete();
      }
      await _repository.remove(workId, fileName);
      AppLogger.debug('已移除导入字幕: $workId/$fileName');
    } catch (e) {
      AppLogger.error('移除导入字幕失败', e);
    }
  }

  /// Compute destination path (creates directory if needed).
  Future<String> _getDestPath(String workId, String audioFileName, String ext) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(docsDir.path, 'user_subtitles', workId));
    if (!await destDir.exists()) await destDir.create(recursive: true);
    final audioBase = p.basenameWithoutExtension(audioFileName);
    return p.join(destDir.path, '$audioBase$ext');
  }
}
