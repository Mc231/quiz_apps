import 'package:flutter/material.dart';

import 'play_screen_config.dart';

/// Configuration for [TabbedPlayScreen].
class TabbedPlayScreenConfig {
  /// Creates a [TabbedPlayScreenConfig].
  const TabbedPlayScreenConfig({
    this.title,
    this.showAppBar = true,
    this.showSettingsAction = true,
    this.appBarActions,
    this.tabBarIndicatorColor,
    this.tabBarLabelColor,
    this.tabBarUnselectedLabelColor,
    this.tabBarIndicatorWeight = 2.0,
    this.tabBarIsScrollable = false,
    this.playScreenConfig = const PlayScreenConfig(showAppBar: false),
  });

  /// Title for the app bar.
  final String? title;

  /// Whether to show the app bar.
  final bool showAppBar;

  /// Whether to show settings action in app bar.
  final bool showSettingsAction;

  /// Custom app bar actions.
  final List<Widget>? appBarActions;

  /// Color for the tab indicator.
  final Color? tabBarIndicatorColor;

  /// Color for selected tab label.
  final Color? tabBarLabelColor;

  /// Color for unselected tab labels.
  final Color? tabBarUnselectedLabelColor;

  /// Weight of the tab indicator.
  final double tabBarIndicatorWeight;

  /// Whether tabs should be scrollable.
  ///
  /// Set to true when you have many tabs that don't fit on screen.
  final bool tabBarIsScrollable;

  /// Configuration for the play screen content (grid/list layout).
  final PlayScreenConfig playScreenConfig;
}
