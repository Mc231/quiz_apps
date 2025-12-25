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
List<QuizCategory> createFlagsCategories(CountryCounts counts) {
  return Continent.values.map((continent) {
    return QuizCategory(
      id: continent.name,
      title: (context) => continent.localizedName(context) ?? continent.name,
      subtitle: (context) => _getContinentSubtitle(context, continent, counts),
      icon: _getContinentIcon(continent),
      showAnswerFeedback: true,
    );
  }).toList();
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
