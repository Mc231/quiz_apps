import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  group('QuizLocalizations', () {
    testWidgets('QuizL10n.of returns localizations', (tester) async {
      late QuizEngineLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              l10n = QuizL10n.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify that we got English localizations
      expect(l10n.play, 'Play');
      expect(l10n.history, 'History');
      expect(l10n.statistics, 'Statistics');
      expect(l10n.settings, 'Settings');
    });

    testWidgets('QuizL10n.of provides all UI strings', (tester) async {
      late QuizEngineLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              l10n = QuizL10n.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify quiz UI strings
      expect(l10n.gameOverText, isNotEmpty);
      expect(l10n.exitDialogTitle, isNotEmpty);
      expect(l10n.exitDialogMessage, isNotEmpty);
      expect(l10n.exitDialogConfirm, isNotEmpty);
      expect(l10n.exitDialogCancel, isNotEmpty);
      expect(l10n.correctFeedback, isNotEmpty);
      expect(l10n.incorrectFeedback, isNotEmpty);
      expect(l10n.hint5050Label, isNotEmpty);
      expect(l10n.hintSkipLabel, isNotEmpty);
      expect(l10n.timerSecondsSuffix, isNotEmpty);
      expect(l10n.videoLoadError, isNotEmpty);
    });

    testWidgets('QuizLocalizationsDelegate supports English', (tester) async {
      const delegate = QuizLocalizationsDelegate();

      expect(delegate.isSupported(const Locale('en')), isTrue);
    });

    testWidgets('QuizL10n falls back gracefully when no delegate', (tester) async {
      late QuizEngineLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          // No localization delegates
          home: Builder(
            builder: (context) {
              // This should fallback to English without crashing
              l10n = QuizL10n.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Should fallback to English
      expect(l10n.play, 'Play');
    });
  });
}
