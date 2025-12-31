import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../extensions/continent_additions.dart';
import '../l10n/app_localizations.dart';
import '../models/continent.dart';
import 'country_counts.dart';

/// Creates quiz categories from the Continent enum.
///
/// [counts] provides the actual country counts loaded from JSON data.
/// Each continent becomes a category that can be displayed
/// in the QuizHomeScreen's play tab.
///
/// By default, creates categories with the standard layout (image question,
/// text answers). Use [createFlagsCategoriesWithLayout] to create categories
/// with specific layout configurations.
List<QuizCategory> createFlagsCategories(CountryCounts counts) {
  return Continent.values.map((continent) {
    return QuizCategory(
      id: continent.name,
      title: (context) => continent.localizedName(context) ?? continent.name,
      subtitle: (context) => _getContinentSubtitle(context, continent, counts),
      icon: _getContinentIcon(continent),
      showAnswerFeedback: true,
      layoutConfig: QuizLayoutConfig.imageQuestionTextAnswers(),
    );
  }).toList();
}

/// Layout mode for quiz categories.
enum FlagsLayoutMode {
  /// Standard layout: show flag image, select country name.
  standard,

  /// Reverse layout: show country name, select flag image.
  reverse,

  /// Mixed layout: alternates between standard and reverse.
  mixed,
}

/// Creates quiz categories with a specific layout mode.
///
/// [counts] provides the actual country counts loaded from JSON data.
/// [mode] specifies the layout mode for all categories.
///
/// Example:
/// ```dart
/// // Create reverse layout categories (text question, image answers)
/// final reverseCategories = createFlagsCategoriesWithLayout(
///   counts,
///   mode: FlagsLayoutMode.reverse,
/// );
/// ```
List<QuizCategory> createFlagsCategoriesWithLayout(
  CountryCounts counts, {
  required FlagsLayoutMode mode,
}) {
  return Continent.values.map((continent) {
    return QuizCategory(
      id: _getCategoryId(continent, mode),
      title: (context) => _getCategoryTitle(context, continent, mode),
      subtitle: (context) => _getCategorySubtitle(context, continent, counts, mode),
      icon: _getContinentIcon(continent),
      showAnswerFeedback: true,
      layoutConfig: _getLayoutConfig(mode),
    );
  }).toList();
}

/// Creates a single category for a continent with a specific layout mode.
///
/// Useful when you want to create individual categories rather than all at once.
QuizCategory createFlagCategory(
  Continent continent,
  CountryCounts counts, {
  FlagsLayoutMode mode = FlagsLayoutMode.standard,
}) {
  return QuizCategory(
    id: _getCategoryId(continent, mode),
    title: (context) => _getCategoryTitle(context, continent, mode),
    subtitle: (context) => _getCategorySubtitle(context, continent, counts, mode),
    icon: _getContinentIcon(continent),
    showAnswerFeedback: true,
    layoutConfig: _getLayoutConfig(mode),
  );
}

/// Gets the category ID based on continent and layout mode.
String _getCategoryId(Continent continent, FlagsLayoutMode mode) {
  return switch (mode) {
    FlagsLayoutMode.standard => continent.name,
    FlagsLayoutMode.reverse => '${continent.name}_reverse',
    FlagsLayoutMode.mixed => '${continent.name}_mixed',
  };
}

/// Gets the category title based on continent and layout mode.
String _getCategoryTitle(
  BuildContext context,
  Continent continent,
  FlagsLayoutMode mode,
) {
  final baseName = continent.localizedName(context) ?? continent.name;
  final l10n = AppLocalizations.of(context)!;

  return switch (mode) {
    FlagsLayoutMode.standard => baseName,
    FlagsLayoutMode.reverse => '$baseName - ${l10n.findTheFlag}',
    FlagsLayoutMode.mixed => '$baseName - Mixed',
  };
}

/// Gets the category subtitle based on continent, counts, and layout mode.
String _getCategorySubtitle(
  BuildContext context,
  Continent continent,
  CountryCounts counts,
  FlagsLayoutMode mode,
) {
  final l10n = AppLocalizations.of(context)!;
  final count = counts.getCount(continent);

  return switch (mode) {
    FlagsLayoutMode.standard => '$count ${l10n.questions}',
    FlagsLayoutMode.reverse => '${l10n.identifyFlags} - $count ${l10n.questions}',
    FlagsLayoutMode.mixed => '$count ${l10n.questions}',
  };
}

/// Gets the layout configuration for the specified mode.
QuizLayoutConfig _getLayoutConfig(FlagsLayoutMode mode) {
  return switch (mode) {
    FlagsLayoutMode.standard => QuizLayoutConfig.imageQuestionTextAnswers(),
    FlagsLayoutMode.reverse => QuizLayoutConfig.textQuestionImageAnswers(
        // Template will be localized by FlagsDataProvider.createLayoutConfig
        questionTemplate: '{name}',
      ),
    FlagsLayoutMode.mixed => QuizLayoutConfig.mixed(
        layouts: [
          QuizLayoutConfig.imageQuestionTextAnswers(),
          QuizLayoutConfig.textQuestionImageAnswers(
            questionTemplate: '{name}',
          ),
        ],
      ),
  };
}

/// Gets the subtitle for a continent showing the country count.
String _getContinentSubtitle(
  BuildContext context,
  Continent continent,
  CountryCounts counts,
) {
  final l10n = AppLocalizations.of(context)!;
  final count = counts.getCount(continent);
  return '$count ${l10n.questions}';
}

/// Gets an appropriate icon for each continent.
IconData _getContinentIcon(Continent continent) {
  switch (continent) {
    case Continent.all:
      return Icons.public;
    case Continent.af:
      return Icons.flag;
    case Continent.eu:
      return Icons.flag;
    case Continent.as:
      return Icons.flag;
    case Continent.na:
      return Icons.flag;
    case Continent.sa:
      return Icons.flag;
    case Continent.oc:
      return Icons.flag;
  }
}
