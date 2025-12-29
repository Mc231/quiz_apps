import 'package:flutter/material.dart';

import '../widgets/achievements_list.dart';

/// Configuration for [AchievementsScreen].
class AchievementsScreenConfig {
  /// Creates an [AchievementsScreenConfig].
  const AchievementsScreenConfig({
    this.showHeader = true,
    this.showFilterChips = true,
    this.showTierFilter = false,
    this.showPointsInHeader = true,
    this.groupByCategory = true,
    this.enablePullToRefresh = true,
    this.initialFilter = AchievementFilter.all,
    this.headerStyle = const AchievementsHeaderStyle(),
    this.listConfig = const AchievementsListConfig(),
  });

  /// Default configuration.
  static const defaultConfig = AchievementsScreenConfig();

  /// Whether to show the stats header.
  final bool showHeader;

  /// Whether to show filter chips.
  final bool showFilterChips;

  /// Whether to show tier filter chips.
  final bool showTierFilter;

  /// Whether to show points in the header.
  final bool showPointsInHeader;

  /// Whether to group achievements by category.
  final bool groupByCategory;

  /// Whether to enable pull-to-refresh.
  final bool enablePullToRefresh;

  /// Initial filter selection.
  final AchievementFilter initialFilter;

  /// Style for the header.
  final AchievementsHeaderStyle headerStyle;

  /// Configuration for the achievements list.
  final AchievementsListConfig listConfig;
}

/// Style configuration for the achievements header.
class AchievementsHeaderStyle {
  /// Creates an [AchievementsHeaderStyle].
  const AchievementsHeaderStyle({
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.counterStyle,
    this.pointsStyle,
    this.progressBarHeight = 8.0,
    this.showProgressBar = true,
  });

  /// Background color for the header.
  final Color? backgroundColor;

  /// Padding around the header content.
  final EdgeInsets padding;

  /// Text style for the counter.
  final TextStyle? counterStyle;

  /// Text style for the points.
  final TextStyle? pointsStyle;

  /// Height of the progress bar.
  final double progressBarHeight;

  /// Whether to show the overall progress bar.
  final bool showProgressBar;
}
