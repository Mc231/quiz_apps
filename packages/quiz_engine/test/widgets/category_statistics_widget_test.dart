import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('CategoryStatisticsData', () {
    test('creates with required parameters', () {
      const data = CategoryStatisticsData(
        categoryId: 'europe',
        categoryName: 'Europe',
        totalSessions: 10,
        averageScore: 75.0,
        bestScore: 90.0,
        accuracy: 80.0,
        totalQuestions: 100,
      );

      expect(data.categoryId, 'europe');
      expect(data.categoryName, 'Europe');
      expect(data.totalSessions, 10);
      expect(data.averageScore, 75.0);
      expect(data.bestScore, 90.0);
      expect(data.accuracy, 80.0);
      expect(data.totalQuestions, 100);
    });

    test('hasData returns true when sessions > 0', () {
      const data = CategoryStatisticsData(
        categoryId: 'europe',
        categoryName: 'Europe',
        totalSessions: 1,
        averageScore: 75.0,
        bestScore: 90.0,
        accuracy: 80.0,
        totalQuestions: 100,
      );

      expect(data.hasData, isTrue);
    });

    test('hasData returns false when sessions = 0', () {
      const data = CategoryStatisticsData(
        categoryId: 'europe',
        categoryName: 'Europe',
        totalSessions: 0,
        averageScore: 0.0,
        bestScore: 0.0,
        accuracy: 0.0,
        totalQuestions: 0,
      );

      expect(data.hasData, isFalse);
    });
  });

  group('CategoryStatisticsWidget', () {
    testWidgets('shows empty state when no categories with data',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const CategoryStatisticsWidget(
            categories: [],
          ),
        ),
      );

      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    });

    testWidgets('shows category items when data is available', (tester) async {
      const categories = [
        CategoryStatisticsData(
          categoryId: 'europe',
          categoryName: 'Europe',
          totalSessions: 10,
          averageScore: 75.0,
          bestScore: 90.0,
          accuracy: 80.0,
          totalQuestions: 100,
        ),
        CategoryStatisticsData(
          categoryId: 'asia',
          categoryName: 'Asia',
          totalSessions: 5,
          averageScore: 60.0,
          bestScore: 80.0,
          accuracy: 65.0,
          totalQuestions: 50,
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          const CategoryStatisticsWidget(
            categories: categories,
          ),
        ),
      );

      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('Asia'), findsOneWidget);
    });

    testWidgets('calls onCategoryTap when category is tapped', (tester) async {
      CategoryStatisticsData? tappedCategory;

      const categories = [
        CategoryStatisticsData(
          categoryId: 'europe',
          categoryName: 'Europe',
          totalSessions: 10,
          averageScore: 75.0,
          bestScore: 90.0,
          accuracy: 80.0,
          totalQuestions: 100,
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          CategoryStatisticsWidget(
            categories: categories,
            onCategoryTap: (category) {
              tappedCategory = category;
            },
          ),
        ),
      );

      await tester.tap(find.text('Europe'));
      await tester.pump();

      expect(tappedCategory, isNotNull);
      expect(tappedCategory!.categoryId, 'europe');
    });

    testWidgets('sorts categories by sessions by default', (tester) async {
      const categories = [
        CategoryStatisticsData(
          categoryId: 'asia',
          categoryName: 'Asia',
          totalSessions: 5,
          averageScore: 60.0,
          bestScore: 80.0,
          accuracy: 65.0,
          totalQuestions: 50,
        ),
        CategoryStatisticsData(
          categoryId: 'europe',
          categoryName: 'Europe',
          totalSessions: 10,
          averageScore: 75.0,
          bestScore: 90.0,
          accuracy: 80.0,
          totalQuestions: 100,
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          const CategoryStatisticsWidget(
            categories: categories,
            sortBy: CategorySortBy.sessions,
          ),
        ),
      );

      // Europe should appear first (more sessions)
      // Get positions - Europe should be above Asia (smaller y value)
      final europeOffset = tester.getCenter(find.text('Europe'));
      final asiaOffset = tester.getCenter(find.text('Asia'));

      expect(europeOffset.dy, lessThan(asiaOffset.dy));
    });
  });

  group('CategoryStatisticsCard', () {
    testWidgets('displays category information', (tester) async {
      const category = CategoryStatisticsData(
        categoryId: 'europe',
        categoryName: 'Europe',
        totalSessions: 10,
        averageScore: 75.0,
        bestScore: 90.0,
        accuracy: 80.0,
        totalQuestions: 100,
        icon: Icons.public,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          const CategoryStatisticsCard(
            category: category,
          ),
        ),
      );

      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('10 sessions'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      const category = CategoryStatisticsData(
        categoryId: 'europe',
        categoryName: 'Europe',
        totalSessions: 10,
        averageScore: 75.0,
        bestScore: 90.0,
        accuracy: 80.0,
        totalQuestions: 100,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          CategoryStatisticsCard(
            category: category,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(CategoryStatisticsCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('CategorySortBy', () {
    test('has all expected values', () {
      expect(CategorySortBy.values.length, 6);
      expect(CategorySortBy.values, contains(CategorySortBy.sessions));
      expect(CategorySortBy.values, contains(CategorySortBy.averageScore));
      expect(CategorySortBy.values, contains(CategorySortBy.bestScore));
      expect(CategorySortBy.values, contains(CategorySortBy.accuracy));
      expect(CategorySortBy.values, contains(CategorySortBy.alphabetical));
      expect(CategorySortBy.values, contains(CategorySortBy.lastPlayed));
    });
  });
}
