import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/continent.dart';

/// Holds the count of countries per continent.
///
/// Loaded from the Countries.json file at app startup.
class CountryCounts {
  final Map<Continent, int> _counts;
  final int _total;

  const CountryCounts._(this._counts, this._total);

  /// Creates a [CountryCounts] with default test values.
  ///
  /// Used in tests where asset loading is not available.
  /// Values match the actual Countries.json data.
  static const forTest = CountryCounts._({
    Continent.af: 58,
    Continent.as: 52,
    Continent.eu: 53,
    Continent.na: 41,
    Continent.oc: 27,
    Continent.sa: 14,
  }, 245);

  /// Gets the count for a specific continent.
  int getCount(Continent continent) {
    if (continent == Continent.all) {
      return _total;
    }
    return _counts[continent] ?? 0;
  }

  /// Loads country counts from the Countries.json asset.
  static Future<CountryCounts> load() async {
    final jsonString = await rootBundle.loadString('assets/Countries.json');
    final List<dynamic> countries = json.decode(jsonString) as List<dynamic>;

    final counts = <Continent, int>{};
    var total = 0;

    for (final country in countries) {
      final continentStr = (country['continent'] as String?)?.toLowerCase();
      if (continentStr == null || continentStr == 'null') continue;

      final continent = _parseContinentFromString(continentStr);
      if (continent != null) {
        counts[continent] = (counts[continent] ?? 0) + 1;
        total++;
      }
    }

    return CountryCounts._(counts, total);
  }

  static Continent? _parseContinentFromString(String value) {
    switch (value) {
      case 'af':
        return Continent.af;
      case 'eu':
        return Continent.eu;
      case 'as':
        return Continent.as;
      case 'na':
        return Continent.na;
      case 'sa':
        return Continent.sa;
      case 'oc':
        return Continent.oc;
      default:
        return null;
    }
  }
}
