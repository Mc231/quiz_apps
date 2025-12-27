import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/app/quiz_tab.dart';
import 'package:quiz_engine/src/home/quiz_home_screen.dart';
import 'package:quiz_engine/src/l10n/quiz_localizations_delegate.dart';
import 'package:quiz_engine/src/models/quiz_category.dart';
import 'package:quiz_engine/src/screens/statistics_screen.dart';
import 'package:quiz_engine/src/widgets/session_card.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  final testCategories = [
    QuizCategory(
      id: 'europe',
      title: (context) => 'Europe',
      subtitle: (context) => '50 countries',
      icon: Icons.flag,
      showAnswerFeedback: true,
    ),
    QuizCategory(
      id: 'asia',
      title: (context) => 'Asia',
      subtitle: (context) => '48 countries',
      icon: Icons.public,
      showAnswerFeedback: true,
    ),
  ];

  Widget buildTestWidget({
    required Widget child,
    Size size = const Size(400, 800),
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        QuizLocalizationsDelegate(),
      ],
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    );
  }

  group('QuizHomeScreen', () {
    testWidgets('displays bottom navigation with default tabs', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      // Play appears in AppBar and bottom nav (TabBar hidden with single tab)
      expect(find.text('Play'), findsNWidgets(2));
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('displays app bar with tab title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      // Default first tab is Play (AppBar title + bottom nav, TabBar hidden with single tab)
      expect(find.text('Play'), findsNWidgets(2));
    });

    testWidgets('displays categories in Play tab', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('Asia'), findsOneWidget);
    });

    testWidgets('switches tabs when navigation item tapped', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on History tab
      await tester.tap(find.text('History').last);
      await tester.pumpAndSettle();

      // Should show History empty state
      expect(find.text('No quiz sessions yet'), findsOneWidget);
    });

    testWidgets('calls onCategorySelected when category tapped', (tester) async {
      QuizCategory? selectedCategory;

      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
            onCategorySelected: (category) => selectedCategory = category,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Europe'));
      await tester.pumpAndSettle();

      expect(selectedCategory, isNotNull);
      expect(selectedCategory!.id, 'europe');
    });

    testWidgets('shows settings button when configured', (tester) async {
      bool settingsPressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: const QuizHomeScreenConfig(
              showSettingsInAppBar: true,
            ),
            onSettingsPressed: () => settingsPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(settingsPressed, isTrue);
    });

    testWidgets('shows loading state for Play tab', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
            isPlayLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('QuizHomeScreen with custom tabs', () {
    testWidgets('displays custom tabs', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig(
              tabConfig: QuizTabConfig.allTabs(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Play appears in AppBar and bottom nav (TabBar hidden with single tab)
      expect(find.text('Play'), findsNWidgets(2));
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows settings placeholder for Settings tab', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig(
              tabConfig: QuizTabConfig.allTabs(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Default placeholder should show settings icon (at least 1)
      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('uses custom settings builder', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig(
              tabConfig: QuizTabConfig.allTabs(),
            ),
            settingsBuilder: (context) => const Text('Custom Settings'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Settings'), findsOneWidget);
    });
  });

  group('QuizHomeScreenConfig', () {
    test('default config creates valid config', () {
      final config = QuizHomeScreenConfig.defaultConfig();

      expect(config.tabConfig.tabs.length, 3);
      expect(config.showSettingsInAppBar, isFalse);
    });

    test('const config with empty tabs works', () {
      const config = QuizHomeScreenConfig();

      expect(config.tabConfig.tabs, isEmpty);
      expect(config.showSettingsInAppBar, isFalse);
    });
  });

  group('HistoryTabData', () {
    test('default constructor creates empty data', () {
      const data = HistoryTabData();

      expect(data.sessions, isEmpty);
      expect(data.isLoading, isFalse);
    });

    test('constructor with sessions works', () {
      final sessions = [
        SessionCardData(
          id: '1',
          quizName: 'Test Quiz',
          totalQuestions: 10,
          totalCorrect: 8,
          scorePercentage: 80.0,
          completionStatus: 'completed',
          startTime: DateTime.now(),
        ),
      ];

      final data = HistoryTabData(sessions: sessions);

      expect(data.sessions.length, 1);
      expect(data.sessions.first.quizName, 'Test Quiz');
    });
  });

  group('StatisticsTabData', () {
    test('empty factory creates zero statistics', () {
      final data = StatisticsTabData.empty();

      expect(data.statistics.totalSessions, 0);
      expect(data.statistics.averageScore, 0);
      expect(data.isLoading, isFalse);
    });

    test('constructor with statistics works', () {
      const data = StatisticsTabData(
        statistics: GlobalStatisticsData(
          totalSessions: 10,
          totalQuestions: 100,
          totalCorrect: 80,
          totalIncorrect: 20,
          averageScore: 80.0,
          bestScore: 100.0,
          totalTimePlayed: 3600,
          perfectScores: 2,
          currentStreak: 5,
          bestStreak: 10,
        ),
      );

      expect(data.statistics.totalSessions, 10);
      expect(data.statistics.averageScore, 80.0);
    });
  });

  group('Tab switching behavior', () {
    testWidgets('calls onTabSelected callback', (tester) async {
      QuizTab? selectedTab;
      int? selectedIndex;

      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig(
              tabConfig: QuizTabConfig(
                tabs: [
                  QuizTab.play(),
                  QuizTab.history(),
                  QuizTab.statistics(),
                ],
                onTabSelected: (tab, index) {
                  selectedTab = tab;
                  selectedIndex = index;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on History tab
      await tester.tap(find.text('History').last);
      await tester.pumpAndSettle();

      expect(selectedTab, isA<HistoryTab>());
      expect(selectedIndex, 1);
    });

    testWidgets('preserves state with IndexedStack by default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // IndexedStack should be used
      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });

  group('History tab data loading', () {
    testWidgets('displays sessions after loading', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: QuizHomeScreen(
            categories: testCategories,
            analyticsService: NoOpAnalyticsService(),
            config: QuizHomeScreenConfig.defaultConfig(),
            historyDataProvider: () async {
              return HistoryTabData(
                sessions: [
                  SessionCardData(
                    id: '1',
                    quizName: 'Europe Quiz',
                    totalQuestions: 10,
                    totalCorrect: 8,
                    scorePercentage: 80.0,
                    completionStatus: 'completed',
                    startTime: DateTime.now(),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to History tab
      await tester.tap(find.text('History').last);
      await tester.pumpAndSettle();

      expect(find.text('Europe Quiz'), findsOneWidget);
    });
  });
}
