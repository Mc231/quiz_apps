import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('Achievement', () {
    late Achievement testAchievement;

    setUp(() {
      testAchievement = Achievement(
        id: 'first_quiz',
        name: (context) => 'First Steps',
        description: (context) => 'Complete your first quiz',
        icon: '🎯',
        tier: AchievementTier.common,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 1,
        ),
      );
    });

    test('creates with required fields', () {
      expect(testAchievement.id, 'first_quiz');
      expect(testAchievement.icon, '🎯');
      expect(testAchievement.tier, AchievementTier.common);
      expect(testAchievement.category, isNull);
      expect(testAchievement.target, isNull);
    });

    test('creates with optional fields', () {
      final achievement = Achievement(
        id: 'quiz_master',
        name: (context) => 'Quiz Master',
        description: (context) => 'Complete 100 quizzes',
        icon: '🎓',
        tier: AchievementTier.rare,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 100,
        ),
        category: 'progress',
        target: 100,
      );

      expect(achievement.category, 'progress');
      expect(achievement.target, 100);
    });

    test('points comes from tier', () {
      expect(testAchievement.points, AchievementTier.common.points);
      expect(testAchievement.points, 10);

      final rareAchievement = testAchievement.copyWith(
        tier: AchievementTier.rare,
      );
      expect(rareAchievement.points, 50);
    });

    test('isHidden comes from tier', () {
      expect(testAchievement.isHidden, false);

      final epicAchievement = testAchievement.copyWith(
        tier: AchievementTier.epic,
      );
      expect(epicAchievement.isHidden, true);
    });

    group('progressTarget', () {
      test('returns explicit target if set', () {
        final achievement = testAchievement.copyWith(target: 50);
        expect(achievement.progressTarget, 50);
      });

      test('extracts target from CumulativeTrigger', () {
        final achievement = Achievement(
          id: 'test',
          name: (context) => 'Test',
          description: (context) => 'Test',
          icon: '🎯',
          tier: AchievementTier.common,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions,
            target: 100,
          ),
        );
        expect(achievement.progressTarget, 100);
      });

      test('extracts target from StreakTrigger', () {
        final achievement = Achievement(
          id: 'test',
          name: (context) => 'Test',
          description: (context) => 'Test',
          icon: '🎯',
          tier: AchievementTier.common,
          trigger: AchievementTrigger.streak(target: 25),
        );
        expect(achievement.progressTarget, 25);
      });

      test('extracts requiredCount from CategoryTrigger', () {
        final achievement = Achievement(
          id: 'test',
          name: (context) => 'Test',
          description: (context) => 'Test',
          icon: '🎯',
          tier: AchievementTier.common,
          trigger: AchievementTrigger.category(
            categoryId: 'europe',
            requiredCount: 5,
          ),
        );
        expect(achievement.progressTarget, 5);
      });

      test('returns 1 for ThresholdTrigger without explicit target', () {
        final achievement = Achievement(
          id: 'test',
          name: (context) => 'Test',
          description: (context) => 'Test',
          icon: '🎯',
          tier: AchievementTier.common,
          trigger: AchievementTrigger.threshold(
            field: StatField.sessionScorePercentage,
            value: 90,
          ),
        );
        expect(achievement.progressTarget, 1);
      });
    });

    test('copyWith creates modified copy', () {
      final modified = testAchievement.copyWith(
        icon: '⭐',
        tier: AchievementTier.epic,
      );

      expect(modified.id, testAchievement.id);
      expect(modified.icon, '⭐');
      expect(modified.tier, AchievementTier.epic);
    });

    test('equality based on id', () {
      final achievement1 = Achievement(
        id: 'same_id',
        name: (context) => 'Name 1',
        description: (context) => 'Desc 1',
        icon: '🎯',
        tier: AchievementTier.common,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 1,
        ),
      );
      final achievement2 = Achievement(
        id: 'same_id',
        name: (context) => 'Name 2',
        description: (context) => 'Desc 2',
        icon: '⭐',
        tier: AchievementTier.rare,
        trigger: AchievementTrigger.streak(target: 10),
      );
      final achievement3 = Achievement(
        id: 'different_id',
        name: (context) => 'Name 1',
        description: (context) => 'Desc 1',
        icon: '🎯',
        tier: AchievementTier.common,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 1,
        ),
      );

      expect(achievement1, equals(achievement2));
      expect(achievement1, isNot(equals(achievement3)));
    });

    test('hashCode based on id', () {
      final achievement1 = testAchievement;
      final achievement2 = testAchievement.copyWith(icon: '⭐');

      expect(achievement1.hashCode, equals(achievement2.hashCode));
    });

    test('toString contains id and tier', () {
      expect(testAchievement.toString(), contains('first_quiz'));
      expect(testAchievement.toString(), contains('common'));
    });
  });
}
