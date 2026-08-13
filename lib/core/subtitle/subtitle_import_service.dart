import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xuro/core/subtitle/models/user_subtitle_entry.dart';
import 'package:xuro/core/subtitle/parsers/subtitle_parser_factory.dart';
import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/utils/logger.dart';
import 'package:xuro/core/subtitle/import/file_picker_service.dart';
import 'package:xuro/core/subtitle/storage/user_subtitle_repository.dart';

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

  final FilePickerService _picker;
  final UserSubtitleRepository _repository;

  SubtitleImportService({
    required FilePickerService picker,
    required UserSubtitleRepository repository,
  })  : _picker = picker,
        _repository = repository;

  /// Full import flow: pick → validate → parse → copy → persist
  Future<ImportResponse> importSubtitle(String workId, String fileName) async {
    try {
      // 1. Pick file
      final pickedPath = await _picker.pickSubtitleFile();
      if (pickedPath == null) {
        return const ImportResponse(ImportResult.cancelled);
      }

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

      // 5. Atomic write. rename(2) on the same filesystem is atomic, so
      //    destPath is never half-written. To keep the invariant "any
      //    failure ⇒ the user's existing subtitle is unchanged" even for a
      //    same-path re-import (where rename would overwrite the old file),
      //    the old destPath file is moved aside to a backup first and
      //    restored if copy/rename/upsert fails.
      final destPath = await _getDestPath(workId, fileName, ext);
      final existingEntry = await _repository.find(workId, fileName);
      final tmpPath = '$destPath.import_tmp';
      final bakPath = '$destPath.import_bak';
      final tmpFile = File(tmpPath);
      final bakFile = File(bakPath);
      var backedUp = false;
      try {
        // Stage new content first; if this fails nothing has been disturbed.
        await file.copy(tmpPath);

        // Move any existing destPath file aside so it can be restored.
        if (await File(destPath).exists()) {
          await File(destPath).rename(bakPath);
          backedUp = true;
        }

        await tmpFile.rename(destPath);

        // 6. Persist association to SQLite (destPath now holds full content)
        final entry = UserSubtitleEntry(
          workId: workId,
          fileName: fileName,
          subtitlePath: destPath,
          originalName: originalName,
          format: ext.replaceFirst('.', ''),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _repository.upsert(entry);

        // Success → drop the backup of the just-replaced same-path file.
        if (backedUp) {
          try {
            if (await bakFile.exists()) await bakFile.delete();
          } catch (_) {}
        }
      } catch (e) {
        // Clean up the temp file and restore the user's previous subtitle
        // so a failure never destroys existing data.
        try {
          if (await tmpFile.exists()) await tmpFile.delete();
        } catch (_) {}
        if (backedUp) {
          try {
            await bakFile.rename(destPath);
          } catch (_) {}
        }
        rethrow;
      }

      // 7. Only after full success: drop the old file if it lived at a
      //    different path (ext change). Best-effort — an orphan here is
      //    harmless since the DB already points to the new file.
      if (existingEntry != null && existingEntry.subtitlePath != destPath) {
        try {
          final oldFile = File(existingEntry.subtitlePath);
          if (await oldFile.exists()) {
            await oldFile.delete();
            AppLogger.debug('删除旧的导入字幕文件: ${existingEntry.subtitlePath}');
          }
        } catch (e) {
          AppLogger.warning('旧字幕文件清理失败（已成功导入新字幕，孤儿无害）: $e');
        }
      }

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

  /// Remove imported subtitle. DB row is removed FIRST (consistency-critical:
  /// a stale row pointing at a missing file makes the app think a subtitle
  /// still exists), then the local file is best-effort deleted (an orphan
  /// file is harmless disk waste and never blocks/rolls back the DB removal).
  Future<void> removeImportedSubtitle(String workId, String fileName) async {
    String? filePath;
    try {
      final entry = await _repository.find(workId, fileName);
      filePath = entry?.subtitlePath;
    } catch (e) {
      AppLogger.error('查询待移除字幕关联失败', e);
    }

    var dbRemoved = false;
    try {
      await _repository.remove(workId, fileName);
      dbRemoved = true;
    } catch (e) {
      AppLogger.error('移除字幕 DB 关联失败（一致性关键），保留本地文件以免产生指向缺失文件的失效行', e);
    }

    // 仅在 DB 行确实删除后才删本地文件：否则会留下"文件已删、DB 行还在"
    // 的失效行（app 会误判字幕仍存在）；DB 删失败时保留文件，关联仍可用。
    if (dbRemoved && filePath != null) {
      try {
        final file = File(filePath);
        if (await file.exists()) await file.delete();
      } catch (e) {
        AppLogger.warning('移除字幕本地文件失败（DB 关联已删，孤儿无害）: $e');
      }
    }
    if (dbRemoved) {
      AppLogger.debug('已移除导入字幕: $workId/$fileName');
    }
  }

  /// Compute destination path (creates directory if needed).
  Future<String> _getDestPath(
      String workId, String audioFileName, String ext) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(docsDir.path, 'user_subtitles', workId));
    if (!await destDir.exists()) await destDir.create(recursive: true);
    final audioBase = p.basenameWithoutExtension(audioFileName);
    return p.join(destDir.path, '$audioBase$ext');
  }
}
