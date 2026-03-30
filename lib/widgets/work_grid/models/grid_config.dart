import 'package:xuro/core/theme/app_animations.dart';
import 'package:flutter/material.dart';

class GridConfig {
  final ScrollPhysics? physics;
  final bool enablePagination;
  final bool showLoadingOnEmpty;
  final Duration scrollDuration;
  final Curve scrollCurve;
  final EdgeInsets? padding;

  const GridConfig({
    this.physics,
    this.enablePagination = true,
    this.showLoadingOnEmpty = true,
    this.scrollDuration = AppAnimations.medium,
    this.scrollCurve = AppAnimations.enter,
    this.padding,
  });

  static const GridConfig defaultConfig = GridConfig();
} 