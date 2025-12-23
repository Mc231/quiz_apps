import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/l10n/quiz_localizations.dart';
import 'package:quiz_engine/src/l10n/quiz_localizations_en.dart';
import 'package:quiz_engine/src/l10n/quiz_localizations_delegate.dart';

/// Custom Spanish localization for testing
class QuizLocalizationsEs extends QuizLocalizations {
  const QuizLocalizationsEs();

  @override
  String get play => 'Jugar';
  @override
  String get history => 'Historial';
  @override
  String get statistics => 'Estadísticas';
  @override
  String get settings => 'Configuración';
  @override
  String get score => 'Puntuación';
  @override
  String get correct => 'Correcto';
  @override
  String get incorrect => 'Incorrecto';
  @override
  String get duration => 'Duración';
  @override
  String get questions => 'preguntas';
  @override
  String get exitDialogTitle => '¿Salir del Quiz?';
  @override
  String get exitDialogMessage => '¿Estás seguro de que quieres salir?';
  @override
  String get exitDialogConfirm => 'Sí';
  @override
  String get exitDialogCancel => 'No';
  @override
  String get correctFeedback => '¡Correcto!';
  @override
  String get incorrectFeedback => '¡Incorrecto!';
  @override
  String get videoLoadError => 'Error al cargar video';
  @override
  String get hint5050Label => '50/50';
  @override
  String get hintSkipLabel => 'Saltar';
  @override
  String get timerSecondsSuffix => 's';
  @override
  String get hours => 'h';
  @override
  String get minutes => 'min';
  @override
  String get seconds => 'seg';
  @override
  String get sessionCompleted => 'Completado';
  @override
  String get sessionCancelled => 'Cancelado';
  @override
  String get sessionTimeout => 'Tiempo agotado';
  @override
  String get sessionFailed => 'Fallido';
  @override
  String get perfectScore => '¡Perfecto!';
  @override
  String get today => 'Hoy';
  @override
  String get yesterday => 'Ayer';
  @override
  String daysAgo(int count) => 'hace $count días';
  @override
  String get noSessionsYet => 'Aún no hay sesiones';
  @override
  String get startPlayingToSee => 'Empieza a jugar para ver tu historial';
  @override
  String get sessionDetails => 'Detalles de la sesión';
  @override
  String get reviewAnswers => 'Revisar respuestas';
  @override
  String questionNumber(int number) => 'Pregunta $number';
  @override
  String get yourAnswer => 'Tu respuesta';
  @override
  String get correctAnswer => 'Respuesta correcta';
  @override
  String get skipped => 'Omitido';
  @override
  String get practiceWrongAnswers => 'Practicar errores';
  @override
  String get totalSessions => 'Total de sesiones';
  @override
  String get totalQuestions => 'Total de preguntas';
  @override
  String get averageScore => 'Puntuación promedio';
  @override
  String get bestScore => 'Mejor puntuación';
  @override
  String get accuracy => 'Precisión';
  @override
  String get timePlayed => 'Tiempo jugado';
  @override
  String get perfectScores => 'Puntuaciones perfectas';
  @override
  String get currentStreak => 'Racha actual';
  @override
  String get bestStreak => 'Mejor racha';
  @override
  String get weeklyTrend => 'Tendencia semanal';
  @override
  String get improving => 'Mejorando';
  @override
  String get declining => 'Empeorando';
  @override
  String get stable => 'Estable';
  @override
  String get noStatisticsYet => 'Aún no hay estadísticas';
  @override
  String get playQuizzesToSee => 'Juega algunos quizzes para ver tus estadísticas';
  @override
  String get overview => 'Resumen';
  @override
  String get insights => 'Insights';
  @override
  String get days => 'días';
  @override
  String get audioAndHaptics => 'Audio y Hápticos';
  @override
  String get soundEffects => 'Efectos de sonido';
  @override
  String get soundEffectsDescription => 'Reproducir sonidos';
  @override
  String get backgroundMusic => 'Música de fondo';
  @override
  String get backgroundMusicDescription => 'Reproducir música';
  @override
  String get hapticFeedback => 'Vibración';
  @override
  String get hapticFeedbackDescription => 'Vibrar al presionar';
  @override
  String get quizBehavior => 'Comportamiento del quiz';
  @override
  String get showAnswerFeedback => 'Mostrar feedback';
  @override
  String get showAnswerFeedbackDescription => 'Mostrar animaciones';
  @override
  String get appearance => 'Apariencia';
  @override
  String get theme => 'Tema';
  @override
  String get themeLight => 'Claro';
  @override
  String get themeDark => 'Oscuro';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get selectTheme => 'Seleccionar tema';
  @override
  String get about => 'Acerca de';
  @override
  String get version => 'Versión';
  @override
  String get build => 'Build';
  @override
  String get aboutThisApp => 'Acerca de esta app';
  @override
  String get privacyPolicy => 'Política de privacidad';
  @override
  String get termsOfService => 'Términos de servicio';
  @override
  String get openSourceLicenses => 'Licencias de código abierto';
  @override
  String get advanced => 'Avanzado';
  @override
  String get resetToDefaults => 'Restablecer valores';
  @override
  String get resetToDefaultsDescription => 'Restaurar configuración';
  @override
  String get resetSettings => 'Restablecer configuración';
  @override
  String get resetSettingsMessage => '¿Estás seguro?';
  @override
  String get cancel => 'Cancelar';
  @override
  String get reset => 'Restablecer';
  @override
  String get close => 'Cerrar';
  @override
  String get share => 'Compartir';
  @override
  String get delete => 'Eliminar';
  @override
  String get viewAll => 'Ver todo';
  @override
  String get credits => 'Créditos';
  @override
  String get attributions => 'Atribuciones';
  @override
  String get exportSession => 'Exportar sesión';
  @override
  String get exportAsJson => 'Exportar como JSON';
  @override
  String get exportAsCsv => 'Exportar como CSV';
  @override
  String get exportSuccess => 'Sesión exportada';
  @override
  String get exportError => 'Error al exportar';
  @override
  String get deleteSession => 'Eliminar sesión';
  @override
  String get deleteSessionMessage => '¿Estás seguro de eliminar?';
  @override
  String get sessionDeleted => 'Sesión eliminada';
  @override
  String get recentSessions => 'Sesiones recientes';
  @override
  String get settingsResetToDefaults => 'Configuración restablecida';
  @override
  String couldNotOpenUrl(String url) => 'No se pudo abrir $url';
}

void main() {
  group('QuizLocalizationsEn', () {
    const l10n = QuizLocalizationsEn();

    test('navigation strings are correct', () {
      expect(l10n.play, 'Play');
      expect(l10n.history, 'History');
      expect(l10n.statistics, 'Statistics');
      expect(l10n.settings, 'Settings');
    });

    test('quiz UI strings are correct', () {
      expect(l10n.score, 'Score');
      expect(l10n.correct, 'Correct');
      expect(l10n.incorrect, 'Incorrect');
      expect(l10n.exitDialogTitle, 'Exit Quiz?');
      expect(l10n.correctFeedback, 'Correct!');
      expect(l10n.incorrectFeedback, 'Incorrect!');
    });

    test('hint strings are correct', () {
      expect(l10n.hint5050Label, '50/50');
      expect(l10n.hintSkipLabel, 'Skip');
    });

    test('timer strings are correct', () {
      expect(l10n.timerSecondsSuffix, 's');
      expect(l10n.hours, 'hr');
      expect(l10n.minutes, 'min');
      expect(l10n.seconds, 'sec');
    });

    test('session status strings are correct', () {
      expect(l10n.sessionCompleted, 'Completed');
      expect(l10n.sessionCancelled, 'Cancelled');
      expect(l10n.sessionTimeout, 'Timeout');
      expect(l10n.sessionFailed, 'Failed');
      expect(l10n.perfectScore, 'Perfect!');
    });

    test('parameterized strings work correctly', () {
      expect(l10n.daysAgo(3), '3 days ago');
      expect(l10n.daysAgo(1), '1 days ago');
      expect(l10n.questionNumber(5), 'Question 5');
      expect(l10n.couldNotOpenUrl('https://example.com'),
          'Could not open https://example.com');
    });

    test('statistics strings are correct', () {
      expect(l10n.totalSessions, 'Total Sessions');
      expect(l10n.averageScore, 'Average Score');
      expect(l10n.accuracy, 'Accuracy');
      expect(l10n.weeklyTrend, 'Weekly Trend');
      expect(l10n.improving, 'Improving');
      expect(l10n.declining, 'Declining');
      expect(l10n.stable, 'Stable');
    });

    test('settings strings are correct', () {
      expect(l10n.audioAndHaptics, 'Audio & Haptics');
      expect(l10n.soundEffects, 'Sound Effects');
      expect(l10n.hapticFeedback, 'Haptic Feedback');
      expect(l10n.theme, 'Theme');
      expect(l10n.themeLight, 'Light');
      expect(l10n.themeDark, 'Dark');
      expect(l10n.themeSystem, 'System default');
    });

    test('common action strings are correct', () {
      expect(l10n.cancel, 'Cancel');
      expect(l10n.reset, 'Reset');
      expect(l10n.close, 'Close');
      expect(l10n.share, 'Share');
      expect(l10n.delete, 'Delete');
    });
  });

  group('QuizLocalizations.override', () {
    test('overrides specific strings', () {
      final overridden = QuizLocalizations.override(
        base: const QuizLocalizationsEn(),
        overrides: {'play': 'Start Game', 'history': 'Past Games'},
      );

      expect(overridden.play, 'Start Game');
      expect(overridden.history, 'Past Games');
      // Non-overridden strings fall back to base
      expect(overridden.statistics, 'Statistics');
      expect(overridden.settings, 'Settings');
    });

    test('overrides plural strings', () {
      final overridden = QuizLocalizations.override(
        base: const QuizLocalizationsEn(),
        overrides: {},
        pluralOverrides: {
          'daysAgo': (count) => '$count d ago',
          'questionNumber': (n) => 'Q$n',
        },
      );

      expect(overridden.daysAgo(3), '3 d ago');
      expect(overridden.questionNumber(5), 'Q5');
    });

    test('overrides parameterized strings', () {
      final overridden = QuizLocalizations.override(
        base: const QuizLocalizationsEn(),
        overrides: {},
        parameterizedOverrides: {
          'couldNotOpenUrl': (url) => 'Failed: $url',
        },
      );

      expect(overridden.couldNotOpenUrl('test.com'), 'Failed: test.com');
    });

    test('preserves all non-overridden strings', () {
      final overridden = QuizLocalizations.override(
        base: const QuizLocalizationsEn(),
        overrides: {'play': 'Custom'},
      );

      // Check that all other strings still work
      expect(overridden.score, 'Score');
      expect(overridden.correct, 'Correct');
      expect(overridden.exitDialogTitle, 'Exit Quiz?');
      expect(overridden.hint5050Label, '50/50');
      expect(overridden.sessionCompleted, 'Completed');
      expect(overridden.totalSessions, 'Total Sessions');
      expect(overridden.soundEffects, 'Sound Effects');
      expect(overridden.cancel, 'Cancel');
      expect(overridden.exportAsJson, 'Export as JSON');
    });
  });

  group('QuizLocalizationsDelegate', () {
    test('isSupported returns true for any locale', () {
      const delegate = QuizLocalizationsDelegate();

      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('es')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isTrue);
      expect(delegate.isSupported(const Locale('zh')), isTrue);
    });

    test('load returns English for unsupported locales', () async {
      const delegate = QuizLocalizationsDelegate();

      final l10n = await delegate.load(const Locale('fr'));

      expect(l10n, isA<QuizLocalizationsEn>());
      expect(l10n.play, 'Play');
    });

    test('load uses custom factory for supported locale', () async {
      final delegate = QuizLocalizationsDelegate(
        localizationFactories: {
          'es': () => const QuizLocalizationsEs(),
        },
      );

      final l10n = await delegate.load(const Locale('es'));

      expect(l10n, isA<QuizLocalizationsEs>());
      expect(l10n.play, 'Jugar');
    });

    test('load applies overrides', () async {
      final delegate = QuizLocalizationsDelegate(
        overrides: {
          'en': {'play': 'Start'},
        },
      );

      final l10n = await delegate.load(const Locale('en'));

      expect(l10n.play, 'Start');
      expect(l10n.history, 'History'); // Non-overridden
    });

    test('shouldReload returns true when config changes', () {
      const delegate1 = QuizLocalizationsDelegate();
      final delegate2 = QuizLocalizationsDelegate(
        localizationFactories: {'es': () => const QuizLocalizationsEs()},
      );

      expect(delegate1.shouldReload(delegate1), isFalse);
      expect(delegate1.shouldReload(delegate2), isTrue);
    });
  });

  group('QuizLocalizations.of', () {
    testWidgets('returns English when no delegate provided', (tester) async {
      QuizLocalizations? l10n;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              l10n = QuizLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(l10n, isNotNull);
      expect(l10n!.play, 'Play');
    });

    testWidgets('returns localization from delegate with custom factory',
        (tester) async {
      // Test with English locale but custom factory that returns Spanish
      // This avoids needing full locale setup while testing factory functionality
      QuizLocalizations? l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            QuizLocalizationsDelegate(
              localizationFactories: {
                'en': () => const QuizLocalizationsEs(), // Use Spanish for English
              },
            ),
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              l10n = QuizLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(l10n, isNotNull);
      expect(l10n!.play, 'Jugar'); // Spanish string from factory
    });

    testWidgets('returns overridden localization', (tester) async {
      QuizLocalizations? l10n;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            QuizLocalizationsDelegate(
              overrides: {
                'en': {'play': 'Start Game'},
              },
            ),
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              l10n = QuizLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(l10n, isNotNull);
      expect(l10n!.play, 'Start Game');
      expect(l10n!.history, 'History');
    });
  });

  group('QuizLocalizationsDelegateExtension', () {
    test('withQuizLocalizations adds delegate to list', () {
      final delegates = <LocalizationsDelegate<dynamic>>[];

      final result = delegates.withQuizLocalizations();

      expect(result.length, 1);
      expect(result.first, isA<QuizLocalizationsDelegate>());
    });

    test('withQuizLocalizations preserves existing delegates', () {
      final delegates = <LocalizationsDelegate<dynamic>>[
        DefaultWidgetsLocalizations.delegate,
      ];

      final result = delegates.withQuizLocalizations();

      expect(result.length, 2);
      expect(result[0], isA<QuizLocalizationsDelegate>());
      expect(result[1], DefaultWidgetsLocalizations.delegate);
    });

    test('withQuizLocalizations supports overrides', () {
      final result = <LocalizationsDelegate<dynamic>>[].withQuizLocalizations(
        overrides: {
          'en': {'play': 'Custom Play'},
        },
      );

      expect(result.length, 1);
      expect(result.first, isA<QuizLocalizationsDelegate>());
    });
  });
}
