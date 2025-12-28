import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('StatisticsDashboardTab', () {
    test('has all expected values', () {
      expect(StatisticsDashboardTab.values.length, 4);
      expect(
          StatisticsDashboardTab.values, contains(StatisticsDashboardTab.overview));
      expect(
          StatisticsDashboardTab.values, contains(StatisticsDashboardTab.progress));
      expect(StatisticsDashboardTab.values,
          contains(StatisticsDashboardTab.categories));
      expect(StatisticsDashboardTab.values,
          contains(StatisticsDashboardTab.leaderboard));
    });
  });

  group('StatisticsDashboardData', () {
    test('hasData returns false when no sessions', () {
      const data = StatisticsDashboardData(
        globalStatistics: GlobalStatisticsData(
          totalSessions: 0,
          totalQuestions: 0,
          totalCorrect: 0,
          totalIncorrect: 0,
          averageScore: 0,
          bestScore: 0,
          totalTimePlayed: 0,
          perfectScores: 0,
          currentStreak: 0,
          bestStreak: 0,
        ),
      );

      expect(data.hasData, isFalse);
    });

    test('hasData returns true when sessions exist', () {
      const data = StatisticsDashboardData(
        globalStatistics: GlobalStatisticsData(
          totalSessions: 5,
          totalQuestions: 50,
          totalCorrect: 40,
          totalIncorrect: 10,
          averageScore: 80,
          bestScore: 100,
          totalTimePlayed: 3600,
          perfectScores: 2,
          currentStreak: 3,
          bestStreak: 5,
        ),
      );

      expect(data.hasData, isTrue);
    });

    test('empty constructor creates empty data', () {
      const data = StatisticsDashboardData.empty;

      expect(data.hasData, isFalse);
      expect(data.globalStatistics.totalSessions, 0);
      expect(data.categoryStatistics, isEmpty);
      expect(data.progressDataPoints, isEmpty);
      expect(data.leaderboardEntries, isEmpty);
      expect(data.recentSessions, isEmpty);
    });
  });

  group('StatisticsDashboardScreen', () {
    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: StatisticsDashboardData.empty,
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no data', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: StatisticsDashboardData.empty,
          ),
        ),
      );

      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    testWidgets('shows tabs when data exists', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Check all tabs are present
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(4));
    });

    testWidgets('hides tabs when showTabs is false', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          SingleChildScrollView(
            child: StatisticsDashboardScreen(
              data: _createTestData(),
              showTabs: false,
            ),
          ),
        ),
      );

      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('displays overview tab by default', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Overview stats should be visible
      expect(find.text('5'), findsOneWidget); // totalSessions
    });

    testWidgets('can navigate to progress tab', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Find and tap the Progress tab
      final progressTab = find.text('Progress');
      expect(progressTab, findsOneWidget);

      await tester.tap(progressTab);
      await tester.pumpAndSettle();

      // Progress tab should now be visible
      expect(find.byType(ProgressChartWidget), findsOneWidget);
    });

    testWidgets('can navigate to categories tab', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Find and tap the Categories tab
      final categoriesTab = find.text('Categories');
      expect(categoriesTab, findsOneWidget);

      await tester.tap(categoriesTab);
      await tester.pumpAndSettle();

      // Categories tab should now be visible
      expect(find.byType(CategoryStatisticsWidget), findsOneWidget);
    });

    testWidgets('can navigate to leaderboard tab', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Find and tap the Leaderboard tab
      final leaderboardTab = find.text('Leaderboard');
      expect(leaderboardTab, findsOneWidget);

      await tester.tap(leaderboardTab);
      await tester.pumpAndSettle();

      // Leaderboard tab should now be visible
      expect(find.byType(LeaderboardWidget), findsOneWidget);
    });

    testWidgets('shows global leaderboard coming soon banner', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Navigate to leaderboard tab
      await tester.tap(find.text('Leaderboard'));
      await tester.pumpAndSettle();

      // Should show coming soon banner
      expect(find.text('Global Leaderboard'), findsOneWidget);
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('starts on specified initial tab', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
            initialTab: StatisticsDashboardTab.leaderboard,
          ),
        ),
      );

      // Leaderboard tab should be visible initially
      expect(find.byType(LeaderboardWidget), findsOneWidget);
    });

    testWidgets('calls onSessionTap when session is tapped', (tester) async {
      SessionCardData? tappedSession;

      final data = _createTestData();

      await tester.pumpWidget(
        wrapWithServices(
          SizedBox(
            height: 1200,
            child: StatisticsDashboardScreen(
              data: data,
              onSessionTap: (session) {
                tappedSession = session;
              },
            ),
          ),
        ),
      );

      // Scroll to make session visible
      final sessionFinder = find.text('Europe Quiz');
      await tester.ensureVisible(sessionFinder);
      await tester.pumpAndSettle();

      // Tap on the session card - find the SessionCard widget instead
      final sessionCard = find.byType(SessionCard);
      expect(sessionCard, findsWidgets);
      await tester.tap(sessionCard.first, warnIfMissed: false);
      await tester.pump();

      expect(tappedSession, isNotNull);
      expect(tappedSession!.quizName, 'Europe Quiz');
    });

    testWidgets('calls onCategoryTap when category is tapped', (tester) async {
      CategoryStatisticsData? tappedCategory;

      await tester.pumpWidget(
        wrapWithServices(
          SizedBox(
            height: 800,
            child: StatisticsDashboardScreen(
              data: _createTestData(),
              onCategoryTap: (category) {
                tappedCategory = category;
              },
            ),
          ),
        ),
      );

      // Navigate to categories tab
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();

      // Tap on a category - use first widget that's tappable
      final categoryFinder = find.text('Europe').first;
      await tester.ensureVisible(categoryFinder);
      await tester.tap(categoryFinder, warnIfMissed: false);
      await tester.pump();

      expect(tappedCategory, isNotNull);
    });

    testWidgets('shows category empty state when no category data',
        (tester) async {
      final data = StatisticsDashboardData(
        globalStatistics: _createGlobalStats(),
        categoryStatistics: const [],
      );

      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: data,
          ),
        ),
      );

      // Navigate to categories tab
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();

      // Should show category empty state
      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    });

    testWidgets('progress time range selector changes range', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Navigate to progress tab
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Should find time range selector
      expect(find.byType(ProgressTimeRangeSelector), findsOneWidget);

      // Tap on Month to change range
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      // Widget should update without errors
      expect(find.byType(ProgressChartWidget), findsOneWidget);
    });

    testWidgets('leaderboard type selector changes type', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Navigate to leaderboard tab
      await tester.tap(find.text('Leaderboard'));
      await tester.pumpAndSettle();

      // Should find type selector
      expect(find.byType(LeaderboardTypeSelector), findsOneWidget);

      // Tap on Fastest Perfect to change type
      await tester.tap(find.text('Fastest Perfect'));
      await tester.pumpAndSettle();

      // Widget should update without errors
      expect(find.byType(LeaderboardWidget), findsOneWidget);
    });

    testWidgets('displays weekly trend when available', (tester) async {
      final data = StatisticsDashboardData(
        globalStatistics: _createGlobalStats(),
        weeklyTrend: [
          TrendDataPoint(label: 'Mon', value: 70),
          TrendDataPoint(label: 'Tue', value: 75),
          TrendDataPoint(label: 'Wed', value: 80),
        ],
        trendDirection: TrendType.improving,
      );

      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: data,
          ),
        ),
      );

      // Should display trends widget
      expect(find.byType(TrendsWidget), findsOneWidget);
    });

    testWidgets('hides weekly trend when not available', (tester) async {
      final data = StatisticsDashboardData(
        globalStatistics: _createGlobalStats(),
        weeklyTrend: null,
      );

      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: data,
          ),
        ),
      );

      // Should not display trends widget
      expect(find.byType(TrendsWidget), findsNothing);
    });

    testWidgets('displays recent sessions in overview', (tester) async {
      await tester.pumpWidget(
        wrapWithServices(
          StatisticsDashboardScreen(
            data: _createTestData(),
          ),
        ),
      );

      // Should display recent sessions
      expect(find.text('Europe Quiz'), findsOneWidget);
    });

    testWidgets('calls onViewAllSessions when view all is tapped',
        (tester) async {
      var viewAllCalled = false;

      await tester.pumpWidget(
        wrapWithServices(
          SizedBox(
            height: 1200,
            child: StatisticsDashboardScreen(
              data: _createTestData(),
              onViewAllSessions: () {
                viewAllCalled = true;
              },
            ),
          ),
        ),
      );

      // Scroll to make View All visible
      final viewAllFinder = find.text('View All');
      await tester.ensureVisible(viewAllFinder);
      await tester.pumpAndSettle();

      // Find and tap View All
      await tester.tap(viewAllFinder, warnIfMissed: false);
      await tester.pump();

      expect(viewAllCalled, isTrue);
    });
  });
}

GlobalStatisticsData _createGlobalStats() {
  return const GlobalStatisticsData(
    totalSessions: 5,
    totalQuestions: 50,
    totalCorrect: 40,
    totalIncorrect: 10,
    averageScore: 80,
    bestScore: 100,
    totalTimePlayed: 3600,
    perfectScores: 2,
    currentStreak: 3,
    bestStreak: 5,
  );
}

StatisticsDashboardData _createTestData() {
  return StatisticsDashboardData(
    globalStatistics: _createGlobalStats(),
    categoryStatistics: [
      const CategoryStatisticsData(
        categoryId: 'europe',
        categoryName: 'Europe',
        totalSessions: 3,
        totalQuestions: 30,
        averageScore: 83.3,
        bestScore: 100,
        accuracy: 83.3,
      ),
      const CategoryStatisticsData(
        categoryId: 'asia',
        categoryName: 'Asia',
        totalSessions: 2,
        totalQuestions: 20,
        averageScore: 75.0,
        bestScore: 90,
        accuracy: 75.0,
      ),
    ],
    progressDataPoints: [
      ProgressDataPoint(
        date: DateTime.now().subtract(const Duration(days: 6)),
        value: 70,
        sessions: 1,
      ),
      ProgressDataPoint(
        date: DateTime.now().subtract(const Duration(days: 3)),
        value: 80,
        sessions: 2,
      ),
      ProgressDataPoint(
        date: DateTime.now(),
        value: 85,
        sessions: 2,
      ),
    ],
    leaderboardEntries: [
      LeaderboardEntry(
        rank: 1,
        sessionId: 'session-1',
        quizName: 'Europe Quiz',
        score: 100.0,
        date: DateTime.now(),
        isPerfect: true,
      ),
      LeaderboardEntry(
        rank: 2,
        sessionId: 'session-2',
        quizName: 'Asia Quiz',
        score: 90.0,
        date: DateTime.now(),
      ),
    ],
    recentSessions: [
      SessionCardData(
        id: 'session-1',
        quizName: 'Europe Quiz',
        totalQuestions: 10,
        totalCorrect: 10,
        scorePercentage: 100,
        startTime: DateTime.now(),
        completionStatus: 'completed',
      ),
    ],
    progressImprovement: 15.0,
  );
}
