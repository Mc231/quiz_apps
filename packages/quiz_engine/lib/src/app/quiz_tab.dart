import 'package:flutter/widgets.dart';

import '../l10n/quiz_localizations.dart';

/// A sealed class representing a tab in the quiz app's bottom navigation.
///
/// Each tab type has its own icon, selected icon, and label.
/// Apps can customize which tabs to show and in what order.
///
/// Factory methods provide easy creation of standard tabs:
/// ```dart
/// final tabs = [
///   QuizTab.play(),
///   QuizTab.history(),
///   QuizTab.statistics(),
///   QuizTab.settings(),
/// ];
/// ```
///
/// Custom tabs can be created using [QuizTab.custom]:
/// ```dart
/// final customTab = QuizTab.custom(
///   id: 'leaderboard',
///   icon: Icons.leaderboard_outlined,
///   selectedIcon: Icons.leaderboard,
///   labelBuilder: (context) => 'Leaderboard',
///   builder: (context) => LeaderboardScreen(),
/// );
/// ```
sealed class QuizTab {
  /// Unique identifier for this tab.
  final String id;

  /// Icon shown when the tab is not selected.
  final IconData icon;

  /// Icon shown when the tab is selected.
  /// If null, [icon] is used for both states.
  final IconData? selectedIcon;

  /// Builder function that returns the localized label for this tab.
  final String Function(BuildContext context) labelBuilder;

  const QuizTab._({
    required this.id,
    required this.icon,
    this.selectedIcon,
    required this.labelBuilder,
  });

  /// Creates a Play tab for category selection.
  ///
  /// [labelBuilder] - Optional custom label builder.
  /// Defaults to using engine localizations.
  factory QuizTab.play({
    String Function(BuildContext context)? labelBuilder,
  }) {
    return PlayTab(labelBuilder: labelBuilder);
  }

  /// Creates a History tab for viewing past quiz sessions.
  ///
  /// [labelBuilder] - Optional custom label builder.
  /// Defaults to using engine localizations.
  factory QuizTab.history({
    String Function(BuildContext context)? labelBuilder,
  }) {
    return HistoryTab(labelBuilder: labelBuilder);
  }

  /// Creates a Statistics tab for viewing performance statistics.
  ///
  /// [labelBuilder] - Optional custom label builder.
  /// Defaults to using engine localizations.
  factory QuizTab.statistics({
    String Function(BuildContext context)? labelBuilder,
  }) {
    return StatisticsTab(labelBuilder: labelBuilder);
  }

  /// Creates a Settings tab for app configuration.
  ///
  /// [labelBuilder] - Optional custom label builder.
  /// Defaults to using engine localizations.
  factory QuizTab.settings({
    String Function(BuildContext context)? labelBuilder,
  }) {
    return SettingsTab(labelBuilder: labelBuilder);
  }

  /// Creates a custom tab with app-specific content.
  ///
  /// [id] - Unique identifier for this tab.
  /// [icon] - Icon shown when not selected.
  /// [selectedIcon] - Icon shown when selected.
  /// [labelBuilder] - Function returning the localized label.
  /// [builder] - Function building the tab's content widget.
  factory QuizTab.custom({
    required String id,
    required IconData icon,
    IconData? selectedIcon,
    required String Function(BuildContext context) labelBuilder,
    required Widget Function(BuildContext context) builder,
  }) {
    return CustomTab(
      id: id,
      icon: icon,
      selectedIcon: selectedIcon,
      labelBuilder: labelBuilder,
      builder: builder,
    );
  }

  /// Returns the effective selected icon.
  IconData get effectiveSelectedIcon => selectedIcon ?? icon;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizTab && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'QuizTab($id)';
}

/// Tab for playing quizzes (category selection).
final class PlayTab extends QuizTab {
  /// Default icon for play tab.
  static const IconData defaultIcon = IconData(0xe51a, fontFamily: 'MaterialIcons'); // play_circle_outline

  /// Default selected icon for play tab.
  static const IconData defaultSelectedIcon = IconData(0xe518, fontFamily: 'MaterialIcons'); // play_circle

  /// Creates a [PlayTab].
  PlayTab({String Function(BuildContext context)? labelBuilder})
      : super._(
          id: 'play',
          icon: defaultIcon,
          selectedIcon: defaultSelectedIcon,
          labelBuilder: labelBuilder ?? _defaultLabel,
        );

  static String _defaultLabel(BuildContext context) =>
      QuizL10n.of(context).play;
}

/// Tab for viewing quiz history.
final class HistoryTab extends QuizTab {
  /// Default icon for history tab.
  static const IconData defaultIcon = IconData(0xe3ce, fontFamily: 'MaterialIcons'); // history_outlined

  /// Default selected icon for history tab.
  static const IconData defaultSelectedIcon = IconData(0xe3cd, fontFamily: 'MaterialIcons'); // history

  /// Creates a [HistoryTab].
  HistoryTab({String Function(BuildContext context)? labelBuilder})
      : super._(
          id: 'history',
          icon: defaultIcon,
          selectedIcon: defaultSelectedIcon,
          labelBuilder: labelBuilder ?? _defaultLabel,
        );

  static String _defaultLabel(BuildContext context) =>
      QuizL10n.of(context).history;
}

/// Tab for viewing statistics.
final class StatisticsTab extends QuizTab {
  /// Default icon for statistics tab.
  static const IconData defaultIcon = IconData(0xe025, fontFamily: 'MaterialIcons'); // analytics_outlined

  /// Default selected icon for statistics tab.
  static const IconData defaultSelectedIcon = IconData(0xe024, fontFamily: 'MaterialIcons'); // analytics

  /// Creates a [StatisticsTab].
  StatisticsTab({String Function(BuildContext context)? labelBuilder})
      : super._(
          id: 'statistics',
          icon: defaultIcon,
          selectedIcon: defaultSelectedIcon,
          labelBuilder: labelBuilder ?? _defaultLabel,
        );

  static String _defaultLabel(BuildContext context) =>
      QuizL10n.of(context).statistics;
}

/// Tab for app settings.
final class SettingsTab extends QuizTab {
  /// Default icon for settings tab.
  static const IconData defaultIcon = IconData(0xe8b8, fontFamily: 'MaterialIcons'); // settings_outlined

  /// Default selected icon for settings tab.
  static const IconData defaultSelectedIcon = IconData(0xe8b8, fontFamily: 'MaterialIcons'); // settings

  /// Creates a [SettingsTab].
  SettingsTab({String Function(BuildContext context)? labelBuilder})
      : super._(
          id: 'settings',
          icon: defaultIcon,
          selectedIcon: defaultSelectedIcon,
          labelBuilder: labelBuilder ?? _defaultLabel,
        );

  static String _defaultLabel(BuildContext context) =>
      QuizL10n.of(context).settings;
}

/// Custom tab with app-specific content.
final class CustomTab extends QuizTab {
  /// Builder function that creates the tab's content widget.
  final Widget Function(BuildContext context) builder;

  /// Creates a [CustomTab].
  CustomTab({
    required super.id,
    required super.icon,
    super.selectedIcon,
    required super.labelBuilder,
    required this.builder,
  }) : super._();
}

/// Configuration for quiz tabs.
///
/// Defines which tabs are shown in the bottom navigation and
/// provides callbacks for tab-specific behavior.
class QuizTabConfig {
  /// List of tabs to display in bottom navigation.
  ///
  /// Order determines display order.
  final List<QuizTab> tabs;

  /// Index of the initially selected tab.
  ///
  /// Defaults to 0 (first tab).
  final int initialIndex;

  /// Callback invoked when a tab is selected.
  ///
  /// Useful for analytics or custom logic on tab changes.
  final void Function(QuizTab tab, int index)? onTabSelected;

  /// Whether to preserve tab state when switching.
  ///
  /// If true, uses IndexedStack to keep all tabs alive.
  /// If false, rebuilds tabs when selected.
  final bool preserveState;

  /// Creates a [QuizTabConfig].
  ///
  /// Note: If [tabs] is empty, QuizHomeScreen will use default tabs.
  const QuizTabConfig({
    required this.tabs,
    this.initialIndex = 0,
    this.onTabSelected,
    this.preserveState = true,
  });

  /// Default configuration with Play, History, and Statistics tabs.
  factory QuizTabConfig.defaultConfig() {
    return QuizTabConfig(
      tabs: [
        QuizTab.play(),
        QuizTab.history(),
        QuizTab.statistics(),
      ],
    );
  }

  /// Configuration with all standard tabs.
  factory QuizTabConfig.allTabs() {
    return QuizTabConfig(
      tabs: [
        QuizTab.play(),
        QuizTab.history(),
        QuizTab.statistics(),
        QuizTab.settings(),
      ],
    );
  }

  /// Creates a copy of this config with the given fields replaced.
  QuizTabConfig copyWith({
    List<QuizTab>? tabs,
    int? initialIndex,
    void Function(QuizTab tab, int index)? onTabSelected,
    bool? preserveState,
  }) {
    return QuizTabConfig(
      tabs: tabs ?? this.tabs,
      initialIndex: initialIndex ?? this.initialIndex,
      onTabSelected: onTabSelected ?? this.onTabSelected,
      preserveState: preserveState ?? this.preserveState,
    );
  }
}
