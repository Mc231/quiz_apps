import 'package:flags_quiz/data/country_counts.dart';
import 'package:flags_quiz/data/flags_categories.dart';
import 'package:flags_quiz/models/continent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  group('createFlagsCategories', () {
    late CountryCounts counts;

    setUp(() {
      counts = CountryCounts.forTest;
    });

    test('creates categories for all continents', () {
      final categories = createFlagsCategories(counts);

      expect(categories.length, equals(Continent.values.length));
    });

    test('all categories have standard layout config by default', () {
      final categories = createFlagsCategories(counts);

      for (final category in categories) {
        expect(
          category.layoutConfig,
          isA<ImageQuestionTextAnswersLayout>(),
          reason: 'Category ${category.id} should have ImageQuestionTextAnswersLayout',
        );
      }
    });

    test('categories have correct IDs matching continent names', () {
      final categories = createFlagsCategories(counts);

      for (final continent in Continent.values) {
        final category = categories.firstWhere((c) => c.id == continent.name);
        expect(category, isNotNull);
      }
    });

    test('all categories have showAnswerFeedback enabled', () {
      final categories = createFlagsCategories(counts);

      for (final category in categories) {
        expect(category.showAnswerFeedback, isTrue);
      }
    });
  });

  group('createFlagsCategoriesWithLayout', () {
    late CountryCounts counts;

    setUp(() {
      counts = CountryCounts.forTest;
    });

    test('creates standard layout categories', () {
      final categories = createFlagsCategoriesWithLayout(
        counts,
        mode: FlagsLayoutMode.standard,
      );

      for (final category in categories) {
        expect(category.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
        expect(category.id, isNot(contains('_reverse')));
        expect(category.id, isNot(contains('_mixed')));
      }
    });

    test('creates reverse layout categories', () {
      final categories = createFlagsCategoriesWithLayout(
        counts,
        mode: FlagsLayoutMode.reverse,
      );

      for (final category in categories) {
        expect(category.layoutConfig, isA<TextQuestionImageAnswersLayout>());
        expect(category.id, endsWith('_reverse'));
      }
    });

    test('creates mixed layout categories', () {
      final categories = createFlagsCategoriesWithLayout(
        counts,
        mode: FlagsLayoutMode.mixed,
      );

      for (final category in categories) {
        expect(category.layoutConfig, isA<MixedLayout>());
        expect(category.id, endsWith('_mixed'));

        final mixedLayout = category.layoutConfig! as MixedLayout;
        expect(mixedLayout.layouts.length, equals(2));
        expect(mixedLayout.layouts[0], isA<ImageQuestionTextAnswersLayout>());
        expect(mixedLayout.layouts[1], isA<TextQuestionImageAnswersLayout>());
      }
    });

    test('reverse layout categories have question template placeholder', () {
      final categories = createFlagsCategoriesWithLayout(
        counts,
        mode: FlagsLayoutMode.reverse,
      );

      for (final category in categories) {
        final layout = category.layoutConfig! as TextQuestionImageAnswersLayout;
        expect(layout.questionTemplate, equals('{name}'));
      }
    });
  });

  group('createFlagCategory', () {
    late CountryCounts counts;

    setUp(() {
      counts = CountryCounts.forTest;
    });

    test('creates single standard category', () {
      final category = createFlagCategory(
        Continent.eu,
        counts,
        mode: FlagsLayoutMode.standard,
      );

      expect(category.id, equals('eu'));
      expect(category.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
    });

    test('creates single reverse category', () {
      final category = createFlagCategory(
        Continent.eu,
        counts,
        mode: FlagsLayoutMode.reverse,
      );

      expect(category.id, equals('eu_reverse'));
      expect(category.layoutConfig, isA<TextQuestionImageAnswersLayout>());
    });

    test('creates single mixed category', () {
      final category = createFlagCategory(
        Continent.eu,
        counts,
        mode: FlagsLayoutMode.mixed,
      );

      expect(category.id, equals('eu_mixed'));
      expect(category.layoutConfig, isA<MixedLayout>());
    });

    test('default mode is standard', () {
      final category = createFlagCategory(Continent.af, counts);

      expect(category.id, equals('af'));
      expect(category.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
    });
  });

  group('FlagsLayoutMode', () {
    test('all modes are defined', () {
      expect(FlagsLayoutMode.values, containsAll([
        FlagsLayoutMode.standard,
        FlagsLayoutMode.reverse,
        FlagsLayoutMode.mixed,
      ]));
    });

    test('enum has exactly 3 values', () {
      expect(FlagsLayoutMode.values.length, equals(3));
    });
  });

  group('Category ID generation', () {
    test('standard mode IDs are just continent names', () {
      expect('eu', equals('eu'));
    });

    test('reverse mode IDs have _reverse suffix', () {
      expect('eu_reverse', endsWith('_reverse'));
    });

    test('mixed mode IDs have _mixed suffix', () {
      expect('eu_mixed', endsWith('_mixed'));
    });
  });
}
