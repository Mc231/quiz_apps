import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../extensions/continent_additions.dart';
import '../l10n/app_localizations.dart';
import '../models/continent.dart';

/// Creates quiz categories from the Continent enum.
///
/// Each continent becomes a category that can be displayed
/// in the QuizHomeScreen's play tab.
List<QuizCategory> createFlagsCategories() {
  return Continent.values.map((continent) {
    return QuizCategory(
      id: continent.name,
      title: (context) => continent.localizedName(context) ?? continent.name,
      subtitle: (context) => _getContinentSubtitle(context, continent),
      icon: _getContinentIcon(continent),
    );
  }).toList();
}

/// Gets the subtitle for a continent showing the country count.
String _getContinentSubtitle(BuildContext context, Continent continent) {
  final l10n = AppLocalizations.of(context)!;
  final count = _getCountryCount(continent);
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

/// Gets the approximate country count for each continent.
///
/// These counts should match the actual countries in the JSON data.
int _getCountryCount(Continent continent) {
  switch (continent) {
    case Continent.all:
      return 250; // Approximate total
    case Continent.af:
      return 54;
    case Continent.eu:
      return 44;
    case Continent.as:
      return 48;
    case Continent.na:
      return 23;
    case Continent.sa:
      return 12;
    case Continent.oc:
      return 14;
  }
}
