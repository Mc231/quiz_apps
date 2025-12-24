import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('ProgressDataPoint', () {
    test('creates with required parameters', () {
      final now = DateTime.now();
      final point = ProgressDataPoint(
        date: now,
        value: 75.0,
      );

      expect(point.date, now);
      expect(point.value, 75.0);
      expect(point.label, isNull);
      expect(point.sessions, 0);
      expect(point.questionsAnswered, 0);
    });

    test('creates with all parameters', () {
      final now = DateTime.now();
      final point = ProgressDataPoint(
        date: now,
        value: 85.0,
        label: 'Mon',
        sessions: 5,
        questionsAnswered: 50,
      );

      expect(point.date, now);
      expect(point.value, 85.0);
      expect(point.label, 'Mon');
      expect(point.sessions, 5);
      expect(point.questionsAnswered, 50);
    });
  });

  group('ProgressTimeRange', () {
    test('has all expected values', () {
      expect(ProgressTimeRange.values.length, 5);
      expect(ProgressTimeRange.values, contains(ProgressTimeRange.week));
      expect(ProgressTimeRange.values, contains(ProgressTimeRange.month));
      expect(ProgressTimeRange.values, contains(ProgressTimeRange.quarter));
      expect(ProgressTimeRange.values, contains(ProgressTimeRange.year));
      expect(ProgressTimeRange.values, contains(ProgressTimeRange.allTime));
    });
  });

  group('ProgressChartWidget', () {
    testWidgets('shows empty state when no data points', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const ProgressChartWidget(
            dataPoints: [],
            title: 'Progress',
          ),
        ),
      );

      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('shows chart with data points', (tester) async {
      final dataPoints = [
        ProgressDataPoint(
          date: DateTime(2024, 1, 1),
          value: 70.0,
          label: 'Jan 1',
        ),
        ProgressDataPoint(
          date: DateTime(2024, 1, 2),
          value: 75.0,
          label: 'Jan 2',
        ),
        ProgressDataPoint(
          date: DateTime(2024, 1, 3),
          value: 80.0,
          label: 'Jan 3',
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          ProgressChartWidget(
            dataPoints: dataPoints,
            title: 'Score Over Time',
          ),
        ),
      );

      expect(find.text('Score Over Time'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('shows improvement badge when improvement is provided',
        (tester) async {
      final dataPoints = [
        ProgressDataPoint(
          date: DateTime(2024, 1, 1),
          value: 70.0,
        ),
        ProgressDataPoint(
          date: DateTime(2024, 1, 2),
          value: 80.0,
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          ProgressChartWidget(
            dataPoints: dataPoints,
            title: 'Progress',
            improvement: 10.0,
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+10%'), findsOneWidget);
    });

    testWidgets('shows declining badge when improvement is negative',
        (tester) async {
      final dataPoints = [
        ProgressDataPoint(
          date: DateTime(2024, 1, 1),
          value: 80.0,
        ),
        ProgressDataPoint(
          date: DateTime(2024, 1, 2),
          value: 70.0,
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          ProgressChartWidget(
            dataPoints: dataPoints,
            title: 'Progress',
            improvement: -10.0,
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });
  });

  group('ProgressTimeRangeSelector', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ProgressTimeRangeSelector(
            selectedRange: ProgressTimeRange.week,
            onRangeChanged: (_) {},
          ),
        ),
      );

      // Widget renders successfully
      expect(find.byType(ProgressTimeRangeSelector), findsOneWidget);
    });
  });

  group('ProgressSummary', () {
    test('calculates change correctly', () {
      final summary = ProgressSummary(
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 7),
        startValue: 70.0,
        endValue: 80.0,
        averageValue: 75.0,
        highestValue: 85.0,
        lowestValue: 65.0,
        totalSessions: 10,
        totalQuestions: 100,
      );

      expect(summary.change, 10.0);
      expect(summary.isImproving, isTrue);
      expect(summary.isDeclining, isFalse);
    });

    test('identifies declining trend', () {
      final summary = ProgressSummary(
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 7),
        startValue: 80.0,
        endValue: 70.0,
        averageValue: 75.0,
        highestValue: 85.0,
        lowestValue: 65.0,
        totalSessions: 10,
        totalQuestions: 100,
      );

      expect(summary.change, -10.0);
      expect(summary.isImproving, isFalse);
      expect(summary.isDeclining, isTrue);
    });

    test('identifies stable trend', () {
      final summary = ProgressSummary(
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 7),
        startValue: 75.0,
        endValue: 76.0,
        averageValue: 75.5,
        highestValue: 80.0,
        lowestValue: 70.0,
        totalSessions: 10,
        totalQuestions: 100,
      );

      expect(summary.isStable, isTrue);
    });

    test('calculates percentage change', () {
      final summary = ProgressSummary(
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 7),
        startValue: 50.0,
        endValue: 75.0,
        averageValue: 62.5,
        highestValue: 80.0,
        lowestValue: 45.0,
        totalSessions: 10,
        totalQuestions: 100,
      );

      expect(summary.percentageChange, 50.0); // (75-50)/50 * 100 = 50%
    });
  });
}
