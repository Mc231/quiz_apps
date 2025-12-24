import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quiz_engine/quiz_engine.dart';

/// Test title for quiz tests.
const testQuizTitle = 'Test Quiz';

/// Wraps a widget with the necessary localization delegates for testing.
///
/// This is required because quiz widgets use QuizL10n.of(context) to get
/// localized strings.
Widget wrapWithLocalizations(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      QuizLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}
