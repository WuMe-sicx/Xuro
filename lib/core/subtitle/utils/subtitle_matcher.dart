import 'dart:math';
import 'package:xuro/data/models/files/child.dart';
import 'package:xuro/utils/logger.dart';

class SubtitleMatcher {
  static const supportedFormats = ['.vtt', '.lrc'];
  static const double _similarityThreshold = 0.6;

  static bool isSubtitleFile(String? fileName) {
    if (fileName == null) return false;
    return supportedFormats.any((format) =>
        fileName.toLowerCase().endsWith(format));
  }

  /// Find matching subtitle for an audio file using 3-tier strategy:
  /// 1. Exact match (basename or basename+ext)
  /// 2. Prefix match
  /// 3. Similarity match (Levenshtein-based, threshold >= 0.6)
  static Child? findMatchingSubtitle(String audioFileName, List<Child> siblings) {
    final subtitleFiles = siblings.where((f) => isSubtitleFile(f.title)).toList();
    if (subtitleFiles.isEmpty) return null;

    final audioBase = _getBaseName(audioFileName).toLowerCase();

    // Guard: skip fuzzy matching for empty or very short basenames
    if (audioBase.trim().isEmpty) return null;

    // --- Tier 1: Exact match ---
    final exactMatch = _findExactMatch(audioFileName, subtitleFiles);
    if (exactMatch != null) {
      AppLogger.debug('字幕匹配[精确]: ${exactMatch.title}');
      return exactMatch;
    }

    // --- Tier 2: Prefix match ---
    final prefixMatch = _findPrefixMatch(audioBase, subtitleFiles);
    if (prefixMatch != null) {
      AppLogger.debug('字幕匹配[前缀]: ${prefixMatch.title}');
      return prefixMatch;
    }

    // --- Tier 3: Similarity match ---
    final similarMatch = _findSimilarMatch(audioBase, subtitleFiles);
    if (similarMatch != null) {
      AppLogger.debug('字幕匹配[相似度]: ${similarMatch.title}');
      return similarMatch;
    }

    return null;
  }

  /// Tier 1: Exact basename match (existing logic preserved)
  static Child? _findExactMatch(String audioFileName, List<Child> subtitleFiles) {
    final possibleNames = _getPossibleSubtitleNames(audioFileName);
    for (final name in possibleNames) {
      for (final file in subtitleFiles) {
        if (file.title?.toLowerCase() == name.toLowerCase()) {
          return file;
        }
      }
    }
    return null;
  }

  /// Tier 2: Prefix match - audio base is prefix of subtitle base, or vice versa.
  /// Among all prefix matches, pick the subtitle with basename length closest to audio basename.
  static Child? _findPrefixMatch(String audioBase, List<Child> subtitleFiles) {
    // Require at least 3 characters for prefix matching to avoid false positives
    if (audioBase.length < 3) return null;

    Child? bestMatch;
    int bestLengthDiff = 999999;

    for (final file in subtitleFiles) {
      final subtitleBase = _getBaseName(file.title!).toLowerCase();
      if (subtitleBase.startsWith(audioBase) || audioBase.startsWith(subtitleBase)) {
        final lengthDiff = (subtitleBase.length - audioBase.length).abs();
        if (lengthDiff < bestLengthDiff) {
          bestLengthDiff = lengthDiff;
          bestMatch = file;
        }
      }
    }
    return bestMatch;
  }

  /// Tier 3: Similarity match using Levenshtein distance.
  /// Returns the best match above the similarity threshold.
  static Child? _findSimilarMatch(String audioBase, List<Child> subtitleFiles) {
    // Require at least 3 characters for similarity matching
    if (audioBase.length < 3) return null;

    Child? bestMatch;
    double bestScore = 0.0;

    for (final file in subtitleFiles) {
      final subtitleBase = _getBaseName(file.title!).toLowerCase();
      final score = _similarity(audioBase, subtitleBase);
      if (score > bestScore && score >= _similarityThreshold) {
        bestScore = score;
        bestMatch = file;
      }
    }

    if (bestMatch != null) {
      AppLogger.debug('字幕相似度最高: ${bestMatch.title} (score: ${bestScore.toStringAsFixed(2)})');
    }
    return bestMatch;
  }

  /// Normalized similarity: 1.0 = identical, 0.0 = completely different.
  static double _similarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final maxLen = max(a.length, b.length);
    return 1.0 - (_levenshteinDistance(a, b) / maxLen);
  }

  /// Standard Levenshtein distance using O(n) two-row space optimization.
  static int _levenshteinDistance(String s, String t) {
    final m = s.length;
    final n = t.length;

    var prev = List<int>.generate(n + 1, (i) => i);
    var curr = List<int>.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        curr[j] = min(min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      final temp = prev;
      prev = curr;
      curr = temp;
    }
    return prev[n];
  }

  static List<String> _getPossibleSubtitleNames(String audioFileName) {
    final baseName = _getBaseName(audioFileName);
    return [
      for (final format in supportedFormats) ...[
        '$baseName$format',
        '$audioFileName$format',
      ]
    ];
  }

  static String _getBaseName(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }
}
