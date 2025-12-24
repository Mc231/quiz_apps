import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../../test_helpers.dart';

void main() {
  AchievementsScreenData createTestData({
    int unlockedCount = 5,
    int totalCount = 20,
    int totalPoints = 150,
  }) {
    final achievements = <AchievementDisplayData>[];

    // Create unlocked achievements
    for (var i = 0; i < unlockedCount; i++) {
      achievements.add(
        AchievementDisplayData(
          achievement: Achievement(
            id: 'unlocked_$i',
            name: (_) => 'Unlocked $i',
            description: (_) => 'Description $i',
            icon: '🏆',
            tier: AchievementTier.common,
            category: AchievementCategory.beginner.name,
            trigger: AchievementTrigger.cumulative(
              field: StatField.totalCompletedSessions,
              target: 1,
            ),
          ),
          progress: AchievementProgress.unlocked(
            achievementId: 'unlocked_$i',
            targetValue: 1,
            unlockedAt: DateTime.now(),
          ),
        ),
      );
    }

    // Create in-progress achievements
    final inProgressCount = (totalCount - unlockedCount) ~/ 2;
    for (var i = 0; i < inProgressCount; i++) {
      achievements.add(
        AchievementDisplayData(
          achievement: Achievement(
            id: 'in_progress_$i',
            name: (_) => 'In Progress $i',
            description: (_) => 'Description $i',
            icon: '📚',
            tier: AchievementTier.uncommon,
            category: AchievementCategory.progress.name,
            trigger: AchievementTrigger.cumulative(
              field: StatField.totalCompletedSessions,
              target: 10,
            ),
            target: 10,
          ),
          progress: AchievementProgress.inProgress(
            achievementId: 'in_progress_$i',
            currentValue: i + 1,
            targetValue: 10,
          ),
        ),
      );
    }

    // Create locked achievements
    final lockedCount = totalCount - unlockedCount - inProgressCount;
    for (var i = 0; i < lockedCount; i++) {
      achievements.add(
        AchievementDisplayData(
          achievement: Achievement(
            id: 'locked_$i',
            name: (_) => 'Locked $i',
            description: (_) => 'Description $i',
            icon: '⭐',
            tier: AchievementTier.rare,
            category: AchievementCategory.mastery.name,
            trigger: AchievementTrigger.cumulative(
              field: StatField.totalPerfectScores,
              target: 5,
            ),
            target: 5,
          ),
          progress: AchievementProgress.locked(
            achievementId: 'locked_$i',
            targetValue: 5,
          ),
        ),
      );
    }

    return AchievementsScreenData(
      achievements: achievements,
      totalPoints: totalPoints,
    );
  }

  group('AchievementsScreenData', () {
    test('unlockedCount returns correct count', () {
      final data = createTestData(unlockedCount: 5, totalCount: 20);
      expect(data.unlockedCount, equals(5));
    });

    test('totalCount returns correct count', () {
      final data = createTestData(totalCount: 20);
      expect(data.totalCount, equals(20));
    });

    test('filterCounts returns correct counts', () {
      final data = createTestData(unlockedCount: 5, totalCount: 20);
      final counts = data.filterCounts;

      expect(counts[AchievementFilter.all], equals(20));
      expect(counts[AchievementFilter.unlocked], equals(5));
      // 7 in progress (half of remaining 15, rounded down)
      expect(counts[AchievementFilter.inProgress], equals(7));
      // 8 locked (remaining after unlocked and in progress)
      expect(counts[AchievementFilter.locked], equals(8));
    });

    test('empty data has zero counts', () {
      const data = AchievementsScreenData.empty();
      expect(data.unlockedCount, equals(0));
      expect(data.totalCount, equals(0));
      expect(data.totalPoints, equals(0));
    });
  });

  group('AchievementsScreenConfig', () {
    test('default config has expected values', () {
      const config = AchievementsScreenConfig();
      expect(config.showHeader, isTrue);
      expect(config.showFilterChips, isTrue);
      expect(config.showTierFilter, isFalse);
      expect(config.showPointsInHeader, isTrue);
      expect(config.groupByCategory, isTrue);
      expect(config.enablePullToRefresh, isTrue);
      expect(config.initialFilter, equals(AchievementFilter.all));
    });
  });

  group('AchievementsScreen', () {
    testWidgets('displays app bar with title', (tester) async {
      final data = createTestData();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(data: data),
        ),
      );

      // Find Achievements text in AppBar
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Achievements'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays header with stats', (tester) async {
      final data = createTestData(
        unlockedCount: 12,
        totalCount: 67,
        totalPoints: 450,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(data: data),
        ),
      );

      // Check for unlocked count display - format is "{count} of {total} Unlocked"
      expect(find.text('12 of 67 Unlocked'), findsOneWidget);
      // Check for points display - format is "{points} pts"
      expect(find.text('450 pts'), findsOneWidget);
    });

    testWidgets('displays filter chips', (tester) async {
      final data = createTestData();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(data: data),
        ),
      );

      expect(find.text('All (20)'), findsOneWidget);
      expect(find.text('Unlocked (5)'), findsOneWidget);
    });

    testWidgets('hides header when configured', (tester) async {
      final data = createTestData(
        unlockedCount: 12,
        totalCount: 67,
        totalPoints: 450,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            config: const AchievementsScreenConfig(showHeader: false),
          ),
        ),
      );

      // Header content should not be visible - use the full format
      expect(find.text('12 of 67 Unlocked'), findsNothing);
      expect(find.text('450 pts'), findsNothing);
    });

    testWidgets('hides filter chips when configured', (tester) async {
      final data = createTestData();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            config: const AchievementsScreenConfig(showFilterChips: false),
          ),
        ),
      );

      expect(find.text('All (20)'), findsNothing);
    });

    testWidgets('shows tier filter when configured', (tester) async {
      final data = createTestData();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            config: const AchievementsScreenConfig(showTierFilter: true),
          ),
        ),
      );

      expect(find.text('All Tiers'), findsOneWidget);
      expect(find.text('Common'), findsWidgets);
    });

    testWidgets('displays achievements list', (tester) async {
      final data = createTestData(unlockedCount: 3, totalCount: 5);

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            config: const AchievementsScreenConfig(groupByCategory: false),
          ),
        ),
      );

      // Check that some achievements are visible
      expect(find.text('Unlocked 0'), findsOneWidget);
    });

    testWidgets('filter chips change displayed achievements', (tester) async {
      final data = createTestData(unlockedCount: 3, totalCount: 10);

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            config: const AchievementsScreenConfig(groupByCategory: false),
          ),
        ),
      );

      // Initially shows all
      expect(find.text('Unlocked 0'), findsOneWidget);

      // Tap on Locked filter
      await tester.tap(find.textContaining('Locked'));
      await tester.pumpAndSettle();

      // Unlocked achievements should no longer be visible
      expect(find.text('Unlocked 0'), findsNothing);
    });

    testWidgets('calls onAchievementTap when achievement is tapped',
        (tester) async {
      AchievementDisplayData? tappedAchievement;
      final data = createTestData(unlockedCount: 1, totalCount: 1);

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            config: const AchievementsScreenConfig(
              groupByCategory: false,
              showHeader: false, // Hide header to make room for list
              showFilterChips: false,
            ),
            onAchievementTap: (achievement) => tappedAchievement = achievement,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlocked 0'));
      await tester.pumpAndSettle();
      expect(tappedAchievement?.achievement.id, equals('unlocked_0'));
    });

    testWidgets('wraps content in RefreshIndicator when onRefresh provided',
        (tester) async {
      final data = createTestData();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            onRefresh: () async {},
          ),
        ),
      );

      // RefreshIndicator should be present when onRefresh is provided
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('no RefreshIndicator when pull-to-refresh disabled',
        (tester) async {
      final data = createTestData();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            config: const AchievementsScreenConfig(enablePullToRefresh: false),
            onRefresh: () async {},
          ),
        ),
      );

      // RefreshIndicator should not be present
      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('uses custom app bar when provided', (tester) async {
      final data = createTestData();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(
            data: data,
            appBar: AppBar(title: const Text('Custom Title')),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      // Default "Achievements" title should not be in the AppBar
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Achievements'),
        ),
        findsNothing,
      );
    });

    testWidgets('displays progress bar in header', (tester) async {
      final data = createTestData(unlockedCount: 10, totalCount: 20);

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(data: data),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // Percentage format is "{percent}%" so 50% becomes "50%"
      expect(find.textContaining('50'), findsWidgets);
    });

    testWidgets('shows remaining points text', (tester) async {
      final data = AchievementsScreenData(
        achievements: [
          AchievementDisplayData(
            achievement: Achievement(
              id: 'test',
              name: (_) => 'Test',
              description: (_) => 'Desc',
              icon: '🏆',
              tier: AchievementTier.common,
              trigger: AchievementTrigger.cumulative(
                field: StatField.totalCompletedSessions,
                target: 1,
              ),
            ),
            progress: AchievementProgress.locked(
              achievementId: 'test',
              targetValue: 1,
            ),
          ),
        ],
        totalPoints: 0,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(data: data),
        ),
      );

      // Common tier = 10 points remaining, format is "{points} remaining"
      expect(find.textContaining('remaining'), findsOneWidget);
    });

    testWidgets('shows all earned text when no remaining points',
        (tester) async {
      final data = AchievementsScreenData(
        achievements: [
          AchievementDisplayData(
            achievement: Achievement(
              id: 'test',
              name: (_) => 'Test',
              description: (_) => 'Desc',
              icon: '🏆',
              tier: AchievementTier.common,
              trigger: AchievementTrigger.cumulative(
                field: StatField.totalCompletedSessions,
                target: 1,
              ),
            ),
            progress: AchievementProgress.unlocked(
              achievementId: 'test',
              targetValue: 1,
              unlockedAt: DateTime.now(),
            ),
          ),
        ],
        totalPoints: 10,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreen(data: data),
        ),
      );

      // Format is "All earned!"
      expect(find.textContaining('earned'), findsOneWidget);
    });
  });

  group('AchievementsHeaderStyle', () {
    test('default style has expected values', () {
      const style = AchievementsHeaderStyle();
      expect(style.padding, equals(const EdgeInsets.all(16)));
      expect(style.progressBarHeight, equals(8.0));
      expect(style.showProgressBar, isTrue);
    });
  });

  group('AchievementsScreenBuilder', () {
    testWidgets('shows loading state while fetching data', (tester) async {
      final completer = Completer<AchievementsScreenData>();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreenBuilder(
            dataLoader: () => completer.future,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid timer pending error
      completer.complete(const AchievementsScreenData.empty());
      await tester.pumpAndSettle();
    });

    testWidgets('shows data after loading', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreenBuilder(
            dataLoader: () async => AchievementsScreenData(
              achievements: [
                AchievementDisplayData(
                  achievement: Achievement(
                    id: 'test',
                    name: (_) => 'Test Achievement',
                    description: (_) => 'Desc',
                    icon: '🏆',
                    tier: AchievementTier.common,
                    trigger: AchievementTrigger.cumulative(
                      field: StatField.totalCompletedSessions,
                      target: 1,
                    ),
                  ),
                  progress: AchievementProgress.unlocked(
                    achievementId: 'test',
                    targetValue: 1,
                    unlockedAt: DateTime.now(),
                  ),
                ),
              ],
              totalPoints: 10,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Achievement'), findsOneWidget);
    });

    testWidgets('shows error state on failure', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsScreenBuilder(
            dataLoader: () async => throw Exception('Test error'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
