import 'package:flutter/material.dart';

/// Unified animation configuration — all animations MUST use these predefined constants.
/// Hard-coding Duration or Curve values in business code is PROHIBITED.
class AppAnimations {
  AppAnimations._();

  // === Curves ===
  /// Element enter: decelerate to stop
  static const Curve enter = Curves.easeOutCubic;

  /// Element exit: accelerate away
  static const Curve exit = Curves.easeInCubic;

  /// State transition: standard crossfade
  static const Curve standard = Curves.easeInOutCubic;

  /// Lyric scroll / long list
  static const Curve smoothScroll = Curves.easeOutQuart;

  // === Durations ===
  /// Short: tag popup, menu expand, chip toggle
  static const Duration short = Duration(milliseconds: 200);

  /// Medium: list enter, card expand, lyric sync
  static const Duration medium = Duration(milliseconds: 300);

  /// Long: player fullscreen transition, page route
  static const Duration long = Duration(milliseconds: 450);

  // Absolute max for any single animation is 500ms
}
