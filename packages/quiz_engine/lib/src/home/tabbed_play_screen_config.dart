import 'package:flutter/material.dart';

import '../widgets/layout_mode_selector.dart';
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
    this.layoutModeOptions,
    this.layoutModeSelectorTitle,
    this.selectedLayoutModeId,
    this.onLayoutModeChanged,
    this.headerWidgetBuilder,
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

  /// Available layout mode options for the Play screen.
  ///
  /// When provided, a layout mode selector is shown above the category list.
  /// Users can choose between different question/answer layouts (e.g., Standard,
  /// Reverse, Mixed).
  final List<LayoutModeOption>? layoutModeOptions;

  /// Title for the layout mode selector section.
  final String? layoutModeSelectorTitle;

  /// Currently selected layout mode ID.
  ///
  /// This should be synced with settings for persistence.
  final String? selectedLayoutModeId;

  /// Callback when layout mode is changed.
  ///
  /// Use this to persist the selection to settings.
  final void Function(LayoutModeOption option)? onLayoutModeChanged;

  /// Builder for a header widget shown above the category list.
  ///
  /// When provided, this widget is rendered at the top of the Play tab content,
  /// above the layout mode selector (if present) and the category grid/list.
  ///
  /// Common use cases:
  /// - Daily challenge card
  /// - Featured quizzes banner
  /// - Promotional content
  ///
  /// Example:
  /// ```dart
  /// headerWidgetBuilder: (context) => DailyChallengeCard(
  ///   service: dailyChallengeService,
  ///   onTap: (challenge) => navigateToDailyChallenge(challenge),
  /// ),
  /// ```
  final Widget Function(BuildContext context)? headerWidgetBuilder;
}
