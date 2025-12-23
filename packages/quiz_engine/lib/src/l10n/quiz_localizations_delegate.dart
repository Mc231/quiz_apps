import 'package:flutter/widgets.dart';

import 'quiz_localizations.dart';

/// Delegate for loading [QuizLocalizations].
///
/// This delegate wraps the generated [QuizEngineLocalizations.delegate]
/// and is used by [MaterialApp] or [WidgetsApp] to load the appropriate
/// localization based on the device's locale.
///
/// ## Basic Usage
///
/// The simplest way is to use the generated delegates directly:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: QuizEngineLocalizations.localizationsDelegates,
///   supportedLocales: QuizEngineLocalizations.supportedLocales,
/// )
/// ```
///
/// Or use this delegate for custom configuration:
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
class QuizLocalizationsDelegate
    extends LocalizationsDelegate<QuizEngineLocalizations> {
  /// Creates a [QuizLocalizationsDelegate].
  const QuizLocalizationsDelegate();

  /// Default delegate instance.
  static const QuizLocalizationsDelegate defaultDelegate =
      QuizLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return QuizEngineLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<QuizEngineLocalizations> load(Locale locale) {
    return QuizEngineLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(QuizLocalizationsDelegate old) => false;

  @override
  String toString() => 'QuizLocalizationsDelegate()';
}

/// Extension to easily add [QuizLocalizationsDelegate] to a list of delegates.
extension QuizLocalizationsDelegateExtension
    on List<LocalizationsDelegate<dynamic>> {
  /// Adds [QuizLocalizationsDelegate] to this list.
  ///
  /// Returns a new list with the delegate added.
  List<LocalizationsDelegate<dynamic>> withQuizLocalizations() {
    return [
      const QuizLocalizationsDelegate(),
      ...this,
    ];
  }
}
