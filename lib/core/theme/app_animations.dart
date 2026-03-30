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
  /// Emphasis: elastic bounce
  static const Curve emphasis = Curves.elasticOut;
  /// Lyric scroll / long list
  static const Curve smoothScroll = Curves.easeOutQuart;

  // === Durations ===
  /// Micro: ripple, color change, opacity toggle
  static const Duration micro = Duration(milliseconds: 100);
  /// Short: tag popup, menu expand, chip toggle
  static const Duration short = Duration(milliseconds: 200);
  /// Medium: list enter, card expand, lyric sync
  static const Duration medium = Duration(milliseconds: 300);
  /// Long: player fullscreen transition, page route
  static const Duration long = Duration(milliseconds: 450);

  // Absolute max for any single animation is 500ms
}

/// Micro-interaction constants for press feedback, favorites, morphing icons, etc.
class MicroInteractions {
  MicroInteractions._();

  // Button press feedback
  static const double buttonScaleDown = 0.95;
  static const double buttonOpacityDown = 0.8;
  static const Duration buttonDuration = Duration(milliseconds: 100);

  // Card tap feedback
  static const double cardElevationIncrease = 2.0; // light mode only
  static const Duration cardDuration = Duration(milliseconds: 150);

  // Favorite/like toggle
  static const double favScaleUp = 1.3;
  static const Duration favDuration = Duration(milliseconds: 300);
  static const Curve favCurve = Curves.elasticOut;

  // Play/pause icon morph
  static const Duration morphDuration = Duration(milliseconds: 200);

  // Pull-to-refresh
  static const double refreshIndicatorSize = 40.0;
  static const double refreshTriggerDistance = 100.0;

  // Progress bar thumb
  static const double thumbExpandedRadius = 8.0;
  static const double thumbNormalRadius = 0.0;
  static const Duration thumbDuration = Duration(milliseconds: 150);
}
