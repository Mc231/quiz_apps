import 'package:flutter/material.dart';

import '../app/quiz_tab.dart';
import 'play_screen_config.dart';
import 'play_screen_tab.dart';
import 'tabbed_play_screen_config.dart';

/// Default empty tab config for const initialization.
const _emptyTabConfig = QuizTabConfig(tabs: []);

/// Configuration for the QuizHomeScreen.
class QuizHomeScreenConfig {
  /// Tab configuration.
  final QuizTabConfig tabConfig;

  /// Configuration for the PlayScreen.
  final PlayScreenConfig playScreenConfig;

  /// Optional tabs for TabbedPlayScreen.
  ///
  /// When provided, uses [TabbedPlayScreen] instead of [PlayScreen].
  /// Each tab can be a [CategoriesTab], [PracticeTab], or [CustomContentTab].
  final List<PlayScreenTab>? playScreenTabs;

  /// Initial tab ID for TabbedPlayScreen.
  ///
  /// Only used when [playScreenTabs] is provided.
  final String? initialPlayTabId;

  /// Configuration for TabbedPlayScreen.
  ///
  /// Only used when [playScreenTabs] is provided.
  final TabbedPlayScreenConfig? tabbedPlayScreenConfig;

  /// Whether to show settings button in app bar.
  final bool showSettingsInAppBar;

  /// Custom app bar actions.
  final List<Widget>? appBarActions;

  /// Creates a [QuizHomeScreenConfig].
  const QuizHomeScreenConfig({
    this.tabConfig = _emptyTabConfig,
    this.playScreenConfig = const PlayScreenConfig(),
    this.playScreenTabs,
    this.initialPlayTabId,
    this.tabbedPlayScreenConfig,
    this.showSettingsInAppBar = false,
    this.appBarActions,
  });

  /// Default configuration with Play, History, and Statistics tabs.
  factory QuizHomeScreenConfig.defaultConfig() {
    return QuizHomeScreenConfig(
      tabConfig: QuizTabConfig.defaultConfig(),
    );
  }
}
