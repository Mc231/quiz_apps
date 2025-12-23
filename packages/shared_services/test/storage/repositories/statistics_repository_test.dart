import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StatisticsTrend', () {
    test('creates StatisticsTrend correctly', () {
      const trend = StatisticsTrend(
        period: 'Last 7 days',
        dailyStats: [],
        averageScore: 75.0,
        totalSessions: 10,
        totalQuestions: 100,
        accuracyRate: 80.0,
        trend: 5.0,
      );

      expect(trend.period, 'Last 7 days');
      expect(trend.averageScore, 75.0);
      expect(trend.totalSessions, 10);
      expect(trend.totalQuestions, 100);
      expect(trend.accuracyRate, 80.0);
      expect(trend.trend, 5.0);
    });

    test('isImproving returns true for positive trend', () {
      const trend = StatisticsTrend(
        period: 'Test',
        dailyStats: [],
        averageScore: 75.0,
        totalSessions: 10,
        totalQuestions: 100,
        accuracyRate: 80.0,
        trend: 5.0,
      );

      expect(trend.isImproving, true);
      expect(trend.isDeclining, false);
      expect(trend.isStable, false);
    });

    test('isDeclining returns true for negative trend', () {
      const trend = StatisticsTrend(
        period: 'Test',
        dailyStats: [],
        averageScore: 75.0,
        totalSessions: 10,
        totalQuestions: 100,
        accuracyRate: 80.0,
        trend: -5.0,
      );

      expect(trend.isImproving, false);
      expect(trend.isDeclining, true);
      expect(trend.isStable, false);
    });

    test('isStable returns true for zero trend', () {
      const trend = StatisticsTrend(
        period: 'Test',
        dailyStats: [],
        averageScore: 75.0,
        totalSessions: 10,
        totalQuestions: 100,
        accuracyRate: 80.0,
        trend: 0,
      );

      expect(trend.isImproving, false);
      expect(trend.isDeclining, false);
      expect(trend.isStable, true);
    });

    test('toString returns descriptive string', () {
      const trend = StatisticsTrend(
        period: 'Last 7 days',
        dailyStats: [],
        averageScore: 75.0,
        totalSessions: 10,
        totalQuestions: 100,
        accuracyRate: 80.0,
        trend: 5.0,
      );

      expect(trend.toString(), contains('Last 7 days'));
      expect(trend.toString(), contains('75.0'));
      expect(trend.toString(), contains('5.0'));
    });
  });

  group('ImprovementInsight', () {
    test('creates ImprovementInsight correctly', () {
      const insight = ImprovementInsight(
        type: InsightType.achievement,
        title: 'Test Achievement',
        description: 'You achieved something great!',
        metric: 100.0,
        suggestion: 'Keep going!',
      );

      expect(insight.type, InsightType.achievement);
      expect(insight.title, 'Test Achievement');
      expect(insight.description, 'You achieved something great!');
      expect(insight.metric, 100.0);
      expect(insight.suggestion, 'Keep going!');
    });

    test('creates ImprovementInsight without optional fields', () {
      const insight = ImprovementInsight(
        type: InsightType.needsWork,
        title: 'Needs Work',
        description: 'This area needs improvement.',
      );

      expect(insight.type, InsightType.needsWork);
      expect(insight.title, 'Needs Work');
      expect(insight.metric, isNull);
      expect(insight.suggestion, isNull);
    });

    test('toString returns descriptive string', () {
      const insight = ImprovementInsight(
        type: InsightType.achievement,
        title: 'Test Achievement',
        description: 'You achieved something great!',
      );

      expect(insight.toString(), contains('achievement'));
      expect(insight.toString(), contains('Test Achievement'));
    });
  });

  group('InsightType', () {
    test('has all expected values', () {
      expect(InsightType.values.length, 6);
      expect(InsightType.values, contains(InsightType.achievement));
      expect(InsightType.values, contains(InsightType.improvement));
      expect(InsightType.values, contains(InsightType.needsWork));
      expect(InsightType.values, contains(InsightType.streak));
      expect(InsightType.values, contains(InsightType.consistency));
      expect(InsightType.values, contains(InsightType.timeManagement));
    });
  });

  group('StatisticsRepository Interface', () {
    test('StatisticsRepositoryImpl can be instantiated', () {
      expect(
        () => StatisticsRepositoryImpl(
          dataSource: StatisticsDataSourceImpl(),
        ),
        returnsNormally,
      );
    });

    test('StatisticsRepositoryImpl accepts custom cache duration', () {
      expect(
        () => StatisticsRepositoryImpl(
          dataSource: StatisticsDataSourceImpl(),
          cacheDuration: const Duration(minutes: 5),
        ),
        returnsNormally,
      );
    });
  });

  group('StatisticsRepository Stream support', () {
    // Note: Stream tests that trigger database access are skipped in unit tests.
    // Integration tests with sqflite_ffi would be needed for full coverage.

    test('repository can be instantiated for stream operations', () {
      final repository = StatisticsRepositoryImpl(
        dataSource: StatisticsDataSourceImpl(),
      );

      // Verify the repository is created successfully
      expect(repository, isNotNull);

      // Clean up without triggering database access
      repository.dispose();
    });
  });

  group('StatisticsRepository Cache', () {
    test('clearCache executes without error', () {
      final repository = StatisticsRepositoryImpl(
        dataSource: StatisticsDataSourceImpl(),
      );

      expect(() => repository.clearCache(), returnsNormally);

      repository.dispose();
    });
  });
}
