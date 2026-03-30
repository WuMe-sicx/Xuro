import 'package:xuro/core/audio/models/subtitle.dart';
import 'package:xuro/core/subtitle/parsers/subtitle_parser.dart';
import 'package:xuro/utils/logger.dart';

class LrcParser extends BaseSubtitleParser {
  static final _timeTagRegex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\]');
  static final _idTagRegex = RegExp(r'^\[(ar|ti|al|by|offset):(.+)\]$');
  
  @override
  bool canParse(String content) {
    final lines = content.trim().split('\n');
    return lines.any((line) => _timeTagRegex.hasMatch(line));
  }
  
  @override
  SubtitleList doParse(String content) {
    final lines = content.split('\n');
    final subtitles = <Subtitle>[];
    final metadata = <String, String>{};
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // 检查是否是ID标签
      final idMatch = _idTagRegex.firstMatch(trimmedLine);
      if (idMatch != null) {
        metadata[idMatch.group(1)!] = idMatch.group(2)!;
        continue;
      }
      
      // 解析时间标签和歌词
      final timeMatches = _timeTagRegex.allMatches(trimmedLine);
      if (timeMatches.isEmpty) continue;
      
      // 获取歌词内容 (移除所有时间标签)
      final text = trimmedLine.replaceAll(_timeTagRegex, '').trim();
      if (text.isEmpty) continue;
      
      // 一行可能有多个时间标签
      for (final match in timeMatches) {
        try {
          final timestamp = _parseTimestamp(
            minutes: match.group(1)!,
            seconds: match.group(2)!,
            milliseconds: match.group(3)!,
          );
          
          subtitles.add(Subtitle(
            start: timestamp,
            end: timestamp + const Duration(seconds: 5), // 默认持续5秒
            text: text,
            index: subtitles.length,
          ));
        } catch (e) {
          AppLogger.debug('解析LRC时间标签失败: $e');
          continue;
        }
      }
    }
    
    // 按时间排序
    subtitles.sort((a, b) => a.start.compareTo(b.start));
    
    // 设置正确的结束时间
    for (int i = 0; i < subtitles.length - 1; i++) {
      subtitles[i] = Subtitle(
        start: subtitles[i].start,
        end: subtitles[i + 1].start,
        text: subtitles[i].text,
        index: i,
      );
    }
    
    AppLogger.debug('LRC解析完成: ${subtitles.length}条字幕, ${metadata.length}个元数据');
    return SubtitleList(subtitles);
  }
  
  Duration _parseTimestamp({
    required String minutes,
    required String seconds,
    required String milliseconds,
  }) {
    return Duration(
      minutes: int.parse(minutes),
      seconds: int.parse(seconds),
      milliseconds: int.parse(milliseconds) * 10,
    );
  }
} 