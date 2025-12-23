import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'quiz_localizations.dart';
import 'quiz_localizations_en.dart';

/// Delegate for loading [QuizLocalizations].
///
/// This delegate is used by [MaterialApp] or [WidgetsApp] to load
/// the appropriate localization based on the device's locale.
///
/// ## Basic Usage
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     QuizLocalizationsDelegate(),
///     GlobalMaterialLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///   ],
///   supportedLocales: [Locale('en')],
/// )
/// ```
///
/// ## Custom Localizations
///
/// To provide custom localizations for different languages:
///
/// ```dart
/// QuizLocalizationsDelegate(
///   localizationFactories: {
///     'es': () => QuizLocalizationsEs(),
///     'fr': () => QuizLocalizationsFr(),
///   },
/// )
/// ```
///
/// ## App Overrides
///
/// To override specific strings:
///
/// ```dart
/// QuizLocalizationsDelegate(
///   overrides: {
///     'en': {'play': 'Start Game', 'history': 'Past Games'},
///   },
/// )
/// ```
class QuizLocalizationsDelegate
    extends LocalizationsDelegate<QuizLocalizations> {
  /// Factory functions for creating localizations by language code.
  ///
  /// If a language is not in this map, the default English is used.
  final Map<String, QuizLocalizations Function()> localizationFactories;

  /// String overrides by language code.
  ///
  /// These overrides are applied on top of the base localization.
  final Map<String, Map<String, String>>? overrides;

  /// Plural/parameterized overrides by language code.
  final Map<String, Map<String, String Function(int)>>? pluralOverrides;

  /// Creates a [QuizLocalizationsDelegate].
  ///
  /// [localizationFactories] - Custom localization factories by language code.
  /// [overrides] - String overrides by language code.
  /// [pluralOverrides] - Plural string overrides by language code.
  const QuizLocalizationsDelegate({
    this.localizationFactories = const {},
    this.overrides,
    this.pluralOverrides,
  });

  /// Default delegate with only English support.
  static const QuizLocalizationsDelegate defaultDelegate =
      QuizLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Always return true since we fall back to English
    return true;
  }

  @override
  Future<QuizLocalizations> load(Locale locale) {
    return SynchronousFuture<QuizLocalizations>(_loadSync(locale));
  }

  QuizLocalizations _loadSync(Locale locale) {
    final languageCode = locale.languageCode;

    // Get base localization
    QuizLocalizations base;
    if (localizationFactories.containsKey(languageCode)) {
      base = localizationFactories[languageCode]!();
    } else {
      // Fall back to English
      base = const QuizLocalizationsEn();
    }

    // Apply overrides if any
    final languageOverrides = overrides?[languageCode];
    final languagePluralOverrides = pluralOverrides?[languageCode];

    if (languageOverrides != null || languagePluralOverrides != null) {
      return QuizLocalizations.override(
        base: base,
        overrides: languageOverrides ?? {},
        pluralOverrides: languagePluralOverrides,
      );
    }

    return base;
  }

  @override
  bool shouldReload(QuizLocalizationsDelegate old) {
    return localizationFactories != old.localizationFactories ||
        overrides != old.overrides ||
        pluralOverrides != old.pluralOverrides;
  }

  @override
  String toString() =>
      'QuizLocalizationsDelegate(factories: ${localizationFactories.keys})';
}

/// Extension to easily add [QuizLocalizationsDelegate] to a list of delegates.
extension QuizLocalizationsDelegateExtension
    on List<LocalizationsDelegate<dynamic>> {
  /// Adds [QuizLocalizationsDelegate] to this list.
  ///
  /// Returns a new list with the delegate added.
  List<LocalizationsDelegate<dynamic>> withQuizLocalizations({
    Map<String, QuizLocalizations Function()> factories = const {},
    Map<String, Map<String, String>>? overrides,
  }) {
    return [
      QuizLocalizationsDelegate(
        localizationFactories: factories,
        overrides: overrides,
      ),
      ...this,
    ];
  }
}
