import 'package:flags_quiz/data/country_counts.dart';
import 'package:flags_quiz/data/flags_categories.dart';
import 'package:flags_quiz/data/flags_data_provider.dart';
import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flags_quiz/models/continent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsService = SettingsService();
    await settingsService.initialize();
    await SharedServicesInitializer.initialize();
  });

  tearDown(() {
    settingsService.dispose();
  });

  /// Creates the FlagsQuiz app widget for testing.
  Widget createTestApp(SettingsService settingsService) {
    final storageService = sl.get<StorageService>();
    final achievementService = sl.get<AchievementService>();
    final resourceManager = ResourceManager(
      config: ResourceConfig.standard(),
      repository: InMemoryResourceRepository(),
    );

    return QuizApp(
      services: QuizServices(
        settingsService: settingsService,
        storageService: storageService,
        achievementService: achievementService,
        screenAnalyticsService: NoOpAnalyticsService(),
        quizAnalyticsService: QuizAnalyticsAdapter(NoOpAnalyticsService()),
        resourceManager: resourceManager,
      ),
      categories: createFlagsCategories(CountryCounts.forTest),
      dataProvider: const FlagsDataProvider(),
      config: QuizAppConfig(
        title: 'Flags Quiz',
        appLocalizationDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        useMaterial3: false,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      homeConfig: QuizHomeScreenConfig(
        tabConfig: QuizTabConfig.defaultConfig(),
        showSettingsInAppBar: true,
      ),
    );
  }

  group('FlagsQuiz Integration Test', () {
    testWidgets('App launches and displays categories',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestApp(settingsService));
      await tester.pumpAndSettle();

      // Then - should display the Play tab with categories
      final categoryCards = find.byType(CategoryCard);
      expect(categoryCards, findsWidgets);
    });

    testWidgets('Displays all continent categories',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestApp(settingsService));
      await tester.pumpAndSettle();

      // Then - should have category cards for all continents
      final categoryCards = find.byType(CategoryCard);
      expect(categoryCards, findsNWidgets(Continent.values.length));
    });

    testWidgets('Can navigate to quiz when category is selected',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestApp(settingsService));
      await tester.pumpAndSettle();

      // When - tap first category
      final firstCard = find.byType(CategoryCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Then - should navigate to quiz screen
      // Look for quiz elements (progress indicator, etc.)
      final scoreFinder = find.byWidgetPredicate((widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.contains(RegExp(r'^\d+ / \d+$')));

      expect(scoreFinder, findsOneWidget);
    });

    testWidgets('Quiz flow completes successfully',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestApp(settingsService));
      await tester.pumpAndSettle();

      // When - tap first category (All)
      final firstCard = find.byType(CategoryCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Get the total number of questions
      final scoreFinder = find.byWidgetPredicate((widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.contains(RegExp(r'^\d+ / \d+$')));

      expect(scoreFinder, findsOneWidget);

      final scoreText = (scoreFinder.evaluate().first.widget as Text).data!;
      final totalQuestions = int.parse(scoreText.split(' / ')[1]);

      // Answer all questions
      for (int i = 0; i < totalQuestions; i++) {
        // Find the image widget to get the country code
        final imageFinder = find.byWidgetPredicate((widget) =>
            widget is Image &&
            widget.key != null &&
            widget.key.toString().startsWith('[<\'image_'));

        if (imageFinder.evaluate().isEmpty) {
          fail('No image found at question $i');
        }

        // Extract the country code from the image key
        final imageKey = imageFinder.evaluate().first.widget.key as Key;
        final keyString = imageKey.toString();
        final regex = RegExp(r'image_(.+?)]');
        final match = regex.firstMatch(keyString);

        if (match == null) {
          fail('Failed to extract country code from key: $keyString');
        }

        final countryCode = match.group(1)!;

        // Find and tap the corresponding button
        final buttonFinder = find.byWidgetPredicate((widget) =>
            widget.key != null &&
            widget.key.toString().startsWith('[<\'button_$countryCode'));

        if (buttonFinder.evaluate().isEmpty) {
          fail('Button for $countryCode not found');
        }

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
      }

      // Then - should show game over dialog
      final dialog = find.byType(Dialog);
      expect(dialog, findsOneWidget);

      // Should show perfect score
      expect(find.text('$totalQuestions / $totalQuestions'), findsAny);

      // Tap OK to return to home
      final okFinder = find.byKey(const Key('ok_button'));
      expect(okFinder, findsOneWidget);
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Should be back at home screen with categories
      final categoryCardsAfter = find.byType(CategoryCard);
      expect(categoryCardsAfter, findsWidgets);
    });
  });
}
