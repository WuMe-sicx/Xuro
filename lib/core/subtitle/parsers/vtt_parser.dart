import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'package:asmrapp/core/subtitle/parsers/subtitle_parser.dart';

class VttParser extends BaseSubtitleParser {
  static final _vttHeaderRegex = RegExp(r'^WEBVTT');
  
  @override
  bool canParse(String content) {
    return content.trim().startsWith(_vttHeaderRegex);
  }
  
  @override
  SubtitleList doParse(String content) {
    final lines = content.split('\n');
    final subtitles = <Subtitle>[];
    int index = 0;
    
    // 跳过WEBVTT头部
    while (index < lines.length && !lines[index].contains('-->')) {
      index++;
    }
    
    while (index < lines.length) {
      final timeLine = lines[index];
      if (timeLine.contains('-->')) {
        final times = timeLine.split('-->');
        if (times.length == 2) {
          final start = _parseTimeString(times[0].trim());
          final end = _parseTimeString(times[1].trim());
          
          // 收集字幕文本
          index++;
          String text = '';
          while (index < lines.length && lines[index].trim().isNotEmpty) {
            text += '${lines[index].trim()}\n';
            index++;
          }
          
          if (text.isNotEmpty) {
            subtitles.add(Subtitle(
              start: start,
              end: end,
              text: text.trim(),
              index: subtitles.length,
            ));
          }
        }
      }
      index++;
    }
    
    return SubtitleList(subtitles);
  }
  
  Duration _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 3) throw const FormatException('Invalid time format');
    
    final seconds = parts[2].split('.');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(seconds[0]),
      milliseconds: seconds.length > 1 ? int.parse(seconds[1].padRight(3, '0')) : 0,
    );
  }
} 