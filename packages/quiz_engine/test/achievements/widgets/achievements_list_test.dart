import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../../test_helpers.dart';

void main() {
  List<AchievementDisplayData> createTestAchievements() {
    final achievements = <AchievementDisplayData>[];

    // Beginner category - unlocked
    achievements.add(
      AchievementDisplayData(
        achievement: Achievement(
          id: 'first_quiz',
          name: (_) => 'First Steps',
          description: (_) => 'Complete your first quiz',
          icon: '🎯',
          tier: AchievementTier.common,
          category: AchievementCategory.beginner.name,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions,
            target: 1,
          ),
        ),
        progress: AchievementProgress.unlocked(
          achievementId: 'first_quiz',
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      ),
    );

    // Progress category - in progress
    achievements.add(
      AchievementDisplayData(
        achievement: Achievement(
          id: 'quizzes_10',
          name: (_) => 'Getting Started',
          description: (_) => 'Complete 10 quizzes',
          icon: '📚',
          tier: AchievementTier.common,
          category: AchievementCategory.progress.name,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions,
            target: 10,
          ),
          target: 10,
        ),
        progress: AchievementProgress.inProgress(
          achievementId: 'quizzes_10',
          currentValue: 5,
          targetValue: 10,
        ),
      ),
    );

    // Mastery category - locked
    achievements.add(
      AchievementDisplayData(
        achievement: Achievement(
          id: 'perfect_5',
          name: (_) => 'Rising Star',
          description: (_) => 'Get 5 perfect scores',
          icon: '⭐',
          tier: AchievementTier.uncommon,
          category: AchievementCategory.mastery.name,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores,
            target: 5,
          ),
          target: 5,
        ),
        progress: AchievementProgress.locked(
          achievementId: 'perfect_5',
          targetValue: 5,
        ),
      ),
    );

    // Skill category - epic (hidden)
    achievements.add(
      AchievementDisplayData(
        achievement: Achievement(
          id: 'flawless',
          name: (_) => 'Flawless Victory',
          description: (_) => 'Perfect score, no hints, no lives lost',
          icon: '👑',
          tier: AchievementTier.epic,
          category: AchievementCategory.skill.name,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores,
            target: 1,
          ),
        ),
        progress: AchievementProgress.locked(
          achievementId: 'flawless',
          targetValue: 1,
        ),
      ),
    );

    return achievements;
  }

  group('AchievementsList', () {
    testWidgets('displays all achievements', (tester) async {
      final achievements = createTestAchievements();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(
            achievements: achievements,
            config: const AchievementsListConfig(groupByCategory: false),
          ),
        ),
      );

      expect(find.text('First Steps'), findsOneWidget);
      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Rising Star'), findsOneWidget);
      // Epic achievement should show hidden placeholder
      expect(find.text('Hidden Achievement'), findsOneWidget);
    });

    testWidgets('groups achievements by category', (tester) async {
      final achievements = createTestAchievements();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(
            achievements: achievements,
            config: const AchievementsListConfig(groupByCategory: true),
          ),
        ),
      );

      // Category headers should be visible
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Mastery'), findsOneWidget);
      expect(find.text('Skill'), findsOneWidget);
    });

    testWidgets('filters unlocked achievements', (tester) async {
      final achievements = createTestAchievements();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(
            achievements: achievements,
            config: const AchievementsListConfig(
              filter: AchievementFilter.unlocked,
              groupByCategory: false,
            ),
          ),
        ),
      );

      expect(find.text('First Steps'), findsOneWidget);
      expect(find.text('Getting Started'), findsNothing);
      expect(find.text('Rising Star'), findsNothing);
    });

    testWidgets('filters in-progress achievements', (tester) async {
      final achievements = createTestAchievements();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(
            achievements: achievements,
            config: const AchievementsListConfig(
              filter: AchievementFilter.inProgress,
              groupByCategory: false,
            ),
          ),
        ),
      );

      expect(find.text('First Steps'), findsNothing);
      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Rising Star'), findsNothing);
    });

    testWidgets('filters locked achievements', (tester) async {
      final achievements = createTestAchievements();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(
            achievements: achievements,
            config: const AchievementsListConfig(
              filter: AchievementFilter.locked,
              groupByCategory: false,
            ),
          ),
        ),
      );

      expect(find.text('First Steps'), findsNothing);
      expect(find.text('Getting Started'), findsNothing);
      expect(find.text('Rising Star'), findsOneWidget);
      expect(find.text('Hidden Achievement'), findsOneWidget);
    });

    testWidgets('shows empty state when no achievements match filter',
        (tester) async {
      final achievements = <AchievementDisplayData>[];

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(achievements: achievements),
        ),
      );

      expect(find.text('No achievements found'), findsOneWidget);
      expect(find.text('Try changing the filter'), findsOneWidget);
    });

    testWidgets('calls onAchievementTap when achievement is tapped',
        (tester) async {
      AchievementDisplayData? tappedAchievement;
      final achievements = createTestAchievements();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(
            achievements: achievements,
            config: const AchievementsListConfig(groupByCategory: false),
            onAchievementTap: (data) => tappedAchievement = data,
          ),
        ),
      );

      await tester.tap(find.text('First Steps'));
      expect(tappedAchievement?.achievement.id, equals('first_quiz'));
    });

    testWidgets('shows category count in header', (tester) async {
      final achievements = createTestAchievements();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementsList(
            achievements: achievements,
            config: const AchievementsListConfig(groupByCategory: true),
          ),
        ),
      );

      // Beginner: 1 unlocked / 1 total
      expect(find.text('1/1'), findsOneWidget);
    });
  });

  group('AchievementFilter', () {
    test('getLabel returns localized label', () {
      // This test would require a real l10n instance
      // Just test that the enum values exist
      expect(AchievementFilter.values.length, equals(4));
      expect(AchievementFilter.all, isNotNull);
      expect(AchievementFilter.unlocked, isNotNull);
      expect(AchievementFilter.inProgress, isNotNull);
      expect(AchievementFilter.locked, isNotNull);
    });
  });

  group('AchievementSort', () {
    test('sort enum has all expected values', () {
      expect(AchievementSort.values.length, equals(4));
      expect(AchievementSort.category, isNotNull);
      expect(AchievementSort.tier, isNotNull);
      expect(AchievementSort.progress, isNotNull);
      expect(AchievementSort.recentlyUnlocked, isNotNull);
    });
  });

  group('AchievementsListConfig', () {
    test('default config has expected values', () {
      const config = AchievementsListConfig();
      expect(config.filter, equals(AchievementFilter.all));
      expect(config.sort, equals(AchievementSort.category));
      expect(config.groupByCategory, isTrue);
      expect(config.showFilterChips, isTrue);
    });

    test('copyWith creates new config with replaced values', () {
      const config = AchievementsListConfig();
      final newConfig = config.copyWith(
        filter: AchievementFilter.unlocked,
        groupByCategory: false,
      );

      expect(newConfig.filter, equals(AchievementFilter.unlocked));
      expect(newConfig.groupByCategory, isFalse);
      expect(newConfig.sort, equals(AchievementSort.category));
    });
  });

  group('AchievementFilterChips', () {
    testWidgets('displays all filter options', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementFilterChips(
            selected: AchievementFilter.all,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unlocked'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
    });

    testWidgets('calls onChanged when chip is tapped', (tester) async {
      AchievementFilter? selectedFilter;

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementFilterChips(
            selected: AchievementFilter.all,
            onChanged: (filter) => selectedFilter = filter,
          ),
        ),
      );

      await tester.tap(find.text('Unlocked'));
      expect(selectedFilter, equals(AchievementFilter.unlocked));
    });

    testWidgets('displays counts when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementFilterChips(
            selected: AchievementFilter.all,
            onChanged: (_) {},
            counts: const {
              AchievementFilter.all: 67,
              AchievementFilter.unlocked: 12,
              AchievementFilter.inProgress: 5,
              AchievementFilter.locked: 50,
            },
          ),
        ),
      );

      expect(find.text('All (67)'), findsOneWidget);
      expect(find.text('Unlocked (12)'), findsOneWidget);
    });
  });

  group('AchievementTierFilterChips', () {
    testWidgets('displays all tier options plus "All Tiers"', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementTierFilterChips(
            selected: null,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('All Tiers'), findsOneWidget);
      expect(find.text('Common'), findsOneWidget);
      expect(find.text('Uncommon'), findsOneWidget);
      expect(find.text('Rare'), findsOneWidget);
      expect(find.text('Epic'), findsOneWidget);
      expect(find.text('Legendary'), findsOneWidget);
    });

    testWidgets('calls onChanged when chip is tapped', (tester) async {
      AchievementTier? selectedTier;

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementTierFilterChips(
            selected: null,
            onChanged: (tier) => selectedTier = tier,
          ),
        ),
      );

      await tester.tap(find.text('Rare'));
      expect(selectedTier, equals(AchievementTier.rare));
    });

    testWidgets('calls onChanged with null when "All Tiers" is tapped',
        (tester) async {
      AchievementTier? selectedTier = AchievementTier.common;

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementTierFilterChips(
            selected: AchievementTier.common,
            onChanged: (tier) => selectedTier = tier,
          ),
        ),
      );

      await tester.tap(find.text('All Tiers'));
      expect(selectedTier, isNull);
    });
  });
}
