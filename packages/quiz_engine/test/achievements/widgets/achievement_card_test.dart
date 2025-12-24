import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../../test_helpers.dart';

void main() {
  Achievement createTestAchievement({
    String id = 'test_achievement',
    String name = 'Test Achievement',
    String description = 'Test description',
    String icon = '🎯',
    AchievementTier tier = AchievementTier.common,
    int? target,
  }) {
    return Achievement(
      id: id,
      name: (_) => name,
      description: (_) => description,
      icon: icon,
      tier: tier,
      trigger: AchievementTrigger.cumulative(
        field: StatField.totalCompletedSessions,
        target: target ?? 1,
      ),
      target: target,
    );
  }

  group('AchievementCard', () {
    testWidgets('displays achievement name and description', (tester) async {
      final achievement = createTestAchievement(
        name: 'First Steps',
        description: 'Complete your first quiz',
      );
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(data: data),
        ),
      );

      expect(find.text('First Steps'), findsOneWidget);
      expect(find.text('Complete your first quiz'), findsOneWidget);
    });

    testWidgets('displays achievement icon', (tester) async {
      final achievement = createTestAchievement(icon: '⭐');
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(data: data),
        ),
      );

      expect(find.text('⭐'), findsOneWidget);
    });

    testWidgets('shows check icon for unlocked achievements', (tester) async {
      final achievement = createTestAchievement();
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(data: data),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows lock icon for locked achievements', (tester) async {
      final achievement = createTestAchievement();
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.locked(
          achievementId: achievement.id,
          targetValue: 1,
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(data: data),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows progress bar for in-progress achievements',
        (tester) async {
      final achievement = createTestAchievement(target: 10);
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.inProgress(
          achievementId: achievement.id,
          currentValue: 5,
          targetValue: 10,
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(data: data),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('5/10'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('shows tier badge when enabled', (tester) async {
      final achievement = createTestAchievement(tier: AchievementTier.rare);
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(
            data: data,
            style: const AchievementCardStyle(showTierBadge: true),
          ),
        ),
      );

      expect(find.text('Rare'), findsOneWidget);
    });

    testWidgets('shows points badge when enabled', (tester) async {
      final achievement = createTestAchievement(tier: AchievementTier.rare);
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(
            data: data,
            style: const AchievementCardStyle(showPoints: true),
          ),
        ),
      );

      // Rare tier = 50 points
      expect(find.text('50 pts'), findsOneWidget);
    });

    testWidgets('shows hidden placeholder for hidden locked achievements',
        (tester) async {
      final achievement = createTestAchievement(tier: AchievementTier.epic);
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.locked(
          achievementId: achievement.id,
          targetValue: 1,
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(data: data),
        ),
      );

      // Epic tier is hidden, so should show hidden placeholder
      expect(find.text('Hidden Achievement'), findsOneWidget);
      expect(find.text('Keep playing to discover!'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final achievement = createTestAchievement();
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCard(
            data: data,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AchievementCard));
      expect(tapped, isTrue);
    });
  });

  group('AchievementCardCompact', () {
    testWidgets('displays achievement icon', (tester) async {
      final achievement = createTestAchievement(icon: '🏆');
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCardCompact(data: data),
        ),
      );

      expect(find.text('🏆'), findsOneWidget);
    });

    testWidgets('shows check icon for unlocked achievements', (tester) async {
      final achievement = createTestAchievement();
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCardCompact(data: data),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows question mark for hidden locked achievements',
        (tester) async {
      final achievement = createTestAchievement(tier: AchievementTier.legendary);
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.locked(
          achievementId: achievement.id,
          targetValue: 1,
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCardCompact(data: data),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('shows progress bar for in-progress achievements',
        (tester) async {
      final achievement = createTestAchievement(target: 10);
      final data = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.inProgress(
          achievementId: achievement.id,
          currentValue: 3,
          targetValue: 10,
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementCardCompact(data: data),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('AchievementDisplayData', () {
    test('isUnlocked returns correct value', () {
      final achievement = createTestAchievement();

      final unlocked = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );
      expect(unlocked.isUnlocked, isTrue);

      final locked = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.locked(
          achievementId: achievement.id,
          targetValue: 1,
        ),
      );
      expect(locked.isUnlocked, isFalse);
    });

    test('isHiddenAndLocked returns correct value', () {
      final commonAchievement =
          createTestAchievement(tier: AchievementTier.common);
      final epicAchievement = createTestAchievement(tier: AchievementTier.epic);

      final commonLocked = AchievementDisplayData(
        achievement: commonAchievement,
        progress: AchievementProgress.locked(
          achievementId: commonAchievement.id,
          targetValue: 1,
        ),
      );
      expect(commonLocked.isHiddenAndLocked, isFalse);

      final epicLocked = AchievementDisplayData(
        achievement: epicAchievement,
        progress: AchievementProgress.locked(
          achievementId: epicAchievement.id,
          targetValue: 1,
        ),
      );
      expect(epicLocked.isHiddenAndLocked, isTrue);

      final epicUnlocked = AchievementDisplayData(
        achievement: epicAchievement,
        progress: AchievementProgress.unlocked(
          achievementId: epicAchievement.id,
          targetValue: 1,
          unlockedAt: DateTime.now(),
        ),
      );
      expect(epicUnlocked.isHiddenAndLocked, isFalse);
    });

    test('showProgress returns correct value', () {
      final achievement = createTestAchievement(target: 10);

      final inProgress = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.inProgress(
          achievementId: achievement.id,
          currentValue: 5,
          targetValue: 10,
        ),
      );
      expect(inProgress.showProgress, isTrue);

      final noProgress = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.locked(
          achievementId: achievement.id,
          targetValue: 10,
        ),
      );
      expect(noProgress.showProgress, isFalse);

      final unlocked = AchievementDisplayData(
        achievement: achievement,
        progress: AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: 10,
          unlockedAt: DateTime.now(),
        ),
      );
      expect(unlocked.showProgress, isFalse);
    });
  });
}
