import 'package:flags_quiz/data/flags_categories.dart';
import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flags_quiz/models/continent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsService = SettingsService();
    await settingsService.initialize();
  });

  tearDown(() {
    settingsService.dispose();
  });

  group('FlagsCategories', () {
    test('creates categories for all continents', () {
      // Given
      final categories = createFlagsCategories();

      // Then
      expect(categories.length, Continent.values.length);
    });

    test('each category has valid id and title', () {
      // Given
      final categories = createFlagsCategories();

      // Then
      for (final category in categories) {
        expect(category.id, isNotEmpty);
        expect(category.title, isNotNull);
        expect(category.icon, isNotNull);
      }
    });

    test('category ids match continent names', () {
      // Given
      final categories = createFlagsCategories();

      // Then
      for (int i = 0; i < categories.length; i++) {
        expect(categories[i].id, Continent.values[i].name);
      }
    });
  });

  group('QuizHomeScreen integration', () {
    testWidgets('displays categories from createFlagsCategories',
        (WidgetTester tester) async {
      // Given
      final categories = createFlagsCategories();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QuizHomeScreen(
            categories: categories,
            config: QuizHomeScreenConfig(
              tabConfig: QuizTabConfig(
                tabs: [QuizTab.play(), QuizTab.history()],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Then - should have category cards
      final categoryCards = find.byType(CategoryCard);
      expect(categoryCards, findsWidgets);
    });

    testWidgets('category card shows localized continent name',
        (WidgetTester tester) async {
      // Given
      final categories = createFlagsCategories();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: QuizHomeScreen(
            categories: categories,
            config: QuizHomeScreenConfig(
              tabConfig: QuizTabConfig(
                tabs: [QuizTab.play(), QuizTab.history()],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Then - should display "All" (first continent)
      expect(find.text('All'), findsOneWidget);
    });
  });
}
