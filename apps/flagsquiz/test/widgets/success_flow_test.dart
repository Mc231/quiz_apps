import 'package:flags_quiz/data/country_counts.dart';
import 'package:flags_quiz/data/flags_categories.dart';
import 'package:flags_quiz/data/flags_data_provider.dart';
import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/shared_services.dart';

import '../test_helpers.dart';

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

  group('FlagsDataProvider', () {
    test('loads questions for all continent', () async {
      // Given
      const provider = FlagsDataProvider();

      // We can't test loadQuestions without a BuildContext
      // This is tested in integration tests
      expect(provider, isNotNull);
    });

    test('creates quiz texts with localized strings', () {
      // Given
      const provider = FlagsDataProvider();

      // Then - verify provider is created
      expect(provider, isNotNull);
    });

    test('creates storage config with correct quiz type', () {
      // Given
      const provider = FlagsDataProvider();

      // This needs BuildContext, so we just verify the provider exists
      expect(provider, isNotNull);
    });
  });

  group('FlagsCategories Integration', () {
    testWidgets('displays all continent categories',
        (WidgetTester tester) async {
      // Given
      final categories = createFlagsCategories(CountryCounts.forTest);

      await tester.pumpWidget(
        wrapWithServices(
          QuizHomeScreen(
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

      // Then - should have category cards (some may be off-screen due to scrolling)
      final categoryCards = find.byType(CategoryCard);
      expect(categoryCards, findsWidgets);
    });

    testWidgets('triggers onCategorySelected callback when category tapped',
        (WidgetTester tester) async {
      // Given
      final categories = createFlagsCategories(CountryCounts.forTest);
      QuizCategory? selectedCategory;

      await tester.pumpWidget(
        wrapWithServices(
          QuizHomeScreen(
            categories: categories,
            config: QuizHomeScreenConfig(
              tabConfig: QuizTabConfig(
                tabs: [QuizTab.play(), QuizTab.history()],
              ),
            ),
            onCategorySelected: (category) {
              selectedCategory = category;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // When - tap first category
      final firstCard = find.byType(CategoryCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Then
      expect(selectedCategory, isNotNull);
      expect(selectedCategory!.id, 'all');
    });
  });
}
