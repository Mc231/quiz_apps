import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('AchievementRepository Interface', () {
    test('AchievementRepositoryImpl can be instantiated', () {
      expect(
        () => AchievementRepositoryImpl(
          dataSource: AchievementDataSourceImpl(),
          statisticsDataSource: StatisticsDataSourceImpl(),
        ),
        returnsNormally,
      );
    });

    test('AchievementRepository has required methods', () {
      final repo = AchievementRepositoryImpl(
        dataSource: AchievementDataSourceImpl(),
        statisticsDataSource: StatisticsDataSourceImpl(),
      );

      // Verify all methods exist (will throw if they don't)
      expect(repo.getUnlockedAchievements, isA<Function>());
      expect(repo.getUnlockedAchievementIds, isA<Function>());
      expect(repo.isUnlocked, isA<Function>());
      expect(repo.unlock, isA<Function>());
      expect(repo.markAsNotified, isA<Function>());
      expect(repo.getPendingNotifications, isA<Function>());
      expect(repo.getUnlockedCount, isA<Function>());
      expect(repo.getTotalPoints, isA<Function>());
      expect(repo.getProgressForAll, isA<Function>());
      expect(repo.unlockEvents, isA<Stream<UnlockedAchievement>>());
      expect(repo.resetAll, isA<Function>());
    });
  });

  group('AchievementProgress integration', () {
    test('AchievementProgress.unlocked creates correct state', () {
      final now = DateTime.now();
      final progress = AchievementProgress.unlocked(
        achievementId: 'first_quiz',
        targetValue: 1,
        unlockedAt: now,
      );

      expect(progress.achievementId, 'first_quiz');
      expect(progress.targetValue, 1);
      expect(progress.currentValue, 1);
      expect(progress.isUnlocked, true);
      expect(progress.unlockedAt, now);
      expect(progress.percentage, 1.0);
      expect(progress.percentageInt, 100);
    });

    test('AchievementProgress.inProgress creates correct state', () {
      final progress = AchievementProgress.inProgress(
        achievementId: 'quizzes_10',
        currentValue: 7,
        targetValue: 10,
      );

      expect(progress.achievementId, 'quizzes_10');
      expect(progress.currentValue, 7);
      expect(progress.targetValue, 10);
      expect(progress.isUnlocked, false);
      expect(progress.unlockedAt, isNull);
      expect(progress.percentage, 0.7);
      expect(progress.percentageInt, 70);
      expect(progress.hasProgress, true);
      expect(progress.isCloseToUnlock, false);
    });

    test('AchievementProgress.locked creates correct state', () {
      final progress = AchievementProgress.locked(
        achievementId: 'perfect_50',
        targetValue: 50,
      );

      expect(progress.achievementId, 'perfect_50');
      expect(progress.currentValue, 0);
      expect(progress.targetValue, 50);
      expect(progress.isUnlocked, false);
      expect(progress.percentage, 0.0);
      expect(progress.hasProgress, false);
    });

    test('AchievementProgress isCloseToUnlock is true at 80%+', () {
      final at79 = AchievementProgress.inProgress(
        achievementId: 'test',
        currentValue: 79,
        targetValue: 100,
      );

      final at80 = AchievementProgress.inProgress(
        achievementId: 'test',
        currentValue: 80,
        targetValue: 100,
      );

      final at99 = AchievementProgress.inProgress(
        achievementId: 'test',
        currentValue: 99,
        targetValue: 100,
      );

      expect(at79.isCloseToUnlock, false);
      expect(at80.isCloseToUnlock, true);
      expect(at99.isCloseToUnlock, true);
    });

    test('AchievementProgress isCloseToUnlock is false when unlocked', () {
      final progress = AchievementProgress.unlocked(
        achievementId: 'test',
        targetValue: 100,
        unlockedAt: DateTime.now(),
      );

      expect(progress.isCloseToUnlock, false);
    });

    test('AchievementProgress percentage clamps to 0-1 range', () {
      final over100 = AchievementProgress(
        achievementId: 'test',
        currentValue: 150,
        targetValue: 100,
        isUnlocked: true,
      );

      final negative = AchievementProgress(
        achievementId: 'test',
        currentValue: -10,
        targetValue: 100,
        isUnlocked: false,
      );

      expect(over100.percentage, 1.0);
      expect(negative.percentage, 0.0);
    });

    test('AchievementProgress handles zero targetValue', () {
      final unlockedZero = AchievementProgress(
        achievementId: 'test',
        currentValue: 0,
        targetValue: 0,
        isUnlocked: true,
      );

      final lockedZero = AchievementProgress(
        achievementId: 'test',
        currentValue: 0,
        targetValue: 0,
        isUnlocked: false,
      );

      expect(unlockedZero.percentage, 1.0);
      expect(lockedZero.percentage, 0.0);
    });

    test('AchievementProgress copyWith updates specified fields', () {
      final progress = AchievementProgress.inProgress(
        achievementId: 'test',
        currentValue: 5,
        targetValue: 10,
      );

      final updated = progress.copyWith(currentValue: 8);

      expect(updated.currentValue, 8);
      expect(updated.achievementId, 'test');
      expect(updated.targetValue, 10);
    });

    test('AchievementProgress equality is based on achievementId', () {
      final progress1 = AchievementProgress.inProgress(
        achievementId: 'same_id',
        currentValue: 5,
        targetValue: 10,
      );

      final progress2 = AchievementProgress.inProgress(
        achievementId: 'same_id',
        currentValue: 8,
        targetValue: 10,
      );

      expect(progress1, equals(progress2));
    });

    test('AchievementProgress toString returns meaningful string', () {
      final progress = AchievementProgress.inProgress(
        achievementId: 'quizzes_10',
        currentValue: 7,
        targetValue: 10,
      );

      final str = progress.toString();

      expect(str, contains('AchievementProgress'));
      expect(str, contains('quizzes_10'));
      expect(str, contains('7/10'));
    });
  });

  group('Achievement model integration', () {
    test('Achievement can be created with all trigger types', () {
      final cumulative = Achievement(
        id: 'quizzes_10',
        name: (_) => 'Quiz Enthusiast',
        description: (_) => 'Complete 10 quizzes',
        icon: '📚',
        tier: AchievementTier.common,
        target: 10,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalSessions,
          target: 10,
        ),
      );

      final threshold = Achievement(
        id: 'speed_demon',
        name: (_) => 'Speed Demon',
        description: (_) => 'Complete quiz in under 60s',
        icon: '⚡',
        tier: AchievementTier.uncommon,
        target: 1,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionDurationSeconds,
          value: 60,
        ),
      );

      final streak = Achievement(
        id: 'streak_10',
        name: (_) => 'On Fire',
        description: (_) => 'Get 10 correct in a row',
        icon: '🔥',
        tier: AchievementTier.uncommon,
        target: 10,
        trigger: AchievementTrigger.streak(target: 10),
      );

      expect(cumulative.points, 10); // common tier
      expect(threshold.points, 25); // uncommon tier
      expect(streak.points, 25); // uncommon tier
    });

    test('Achievement points match tier values', () {
      for (final tier in AchievementTier.values) {
        final achievement = Achievement(
          id: 'test_${tier.name}',
          name: (_) => 'Test',
          description: (_) => 'Test',
          icon: '🏆',
          tier: tier,
          target: 1,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
        );

        expect(achievement.points, tier.points);
      }
    });
  });
}
