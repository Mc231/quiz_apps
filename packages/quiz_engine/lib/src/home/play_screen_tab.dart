import 'package:flutter/material.dart';

import '../models/quiz_category.dart';

/// Sealed class representing different tab content types for [TabbedPlayScreen].
///
/// Use factory constructors to create specific tab types:
/// - [PlayScreenTab.categories] for quiz category grids/lists
/// - [PlayScreenTab.practice] for practicing wrong answers
/// - [PlayScreenTab.custom] for fully custom content
///
/// Example:
/// ```dart
/// final tabs = [
///   PlayScreenTab.categories(
///     id: 'europe',
///     label: 'Europe',
///     categories: europeCategories,
///   ),
///   PlayScreenTab.practice(
///     id: 'practice',
///     label: 'Practice',
///     onLoadWrongAnswers: () => loadWrongAnswers(),
///   ),
/// ];
/// ```
sealed class PlayScreenTab {
  /// Creates a [PlayScreenTab].
  const PlayScreenTab({
    required this.id,
    required this.label,
    this.icon,
  });

  /// Unique identifier for this tab.
  ///
  /// Used for initial tab selection and tab identification.
  final String id;

  /// Display label shown in the tab bar.
  final String label;

  /// Optional icon shown alongside the label in the tab bar.
  final IconData? icon;

  /// Creates a tab displaying a list of quiz categories.
  ///
  /// The categories are displayed using the layout configuration
  /// from [PlayScreenConfig] (grid or list).
  factory PlayScreenTab.categories({
    required String id,
    required String label,
    IconData? icon,
    required List<QuizCategory> categories,
  }) = CategoriesTab;

  /// Creates a tab for practicing wrong answers from quiz history.
  ///
  /// The [onLoadWrongAnswers] callback is called to load categories
  /// containing questions the user got wrong. The tab shows a loading
  /// state while fetching and displays the categories once loaded.
  factory PlayScreenTab.practice({
    required String id,
    required String label,
    IconData? icon,
    required Future<List<QuizCategory>> Function() onLoadWrongAnswers,
    Widget? emptyStateWidget,
  }) = PracticeTab;

  /// Creates a tab with fully custom content.
  ///
  /// Use this for content that doesn't fit the categories pattern,
  /// such as challenges, achievements, or any custom widget.
  factory PlayScreenTab.custom({
    required String id,
    required String label,
    IconData? icon,
    required Widget Function(BuildContext context) builder,
  }) = CustomContentTab;
}

/// A tab that displays a list of quiz categories.
///
/// Categories are displayed in a grid or list layout based on
/// the [PlayScreenConfig] settings.
class CategoriesTab extends PlayScreenTab {
  /// Creates a [CategoriesTab].
  const CategoriesTab({
    required super.id,
    required super.label,
    super.icon = Icons.category,
    required this.categories,
  });

  /// List of categories to display in this tab.
  final List<QuizCategory> categories;
}

/// A tab for practicing wrong answers from quiz history.
///
/// Loads categories asynchronously and displays them once loaded.
/// Shows loading indicator while fetching and empty state when
/// no wrong answers are available.
class PracticeTab extends PlayScreenTab {
  /// Creates a [PracticeTab].
  const PracticeTab({
    required super.id,
    required super.label,
    super.icon = Icons.replay,
    required this.onLoadWrongAnswers,
    this.emptyStateWidget,
  });

  /// Callback to load categories containing wrong answers.
  ///
  /// Called when the tab becomes visible for the first time.
  final Future<List<QuizCategory>> Function() onLoadWrongAnswers;

  /// Widget to show when no wrong answers are available.
  ///
  /// If null, a default empty state is displayed.
  final Widget? emptyStateWidget;
}

/// A tab with fully custom content.
///
/// Use this for any content that doesn't fit the standard
/// category display pattern.
class CustomContentTab extends PlayScreenTab {
  /// Creates a [CustomContentTab].
  const CustomContentTab({
    required super.id,
    required super.label,
    super.icon,
    required this.builder,
  });

  /// Builder function that creates the tab content.
  ///
  /// Called each time the tab needs to be built.
  final Widget Function(BuildContext context) builder;
}
