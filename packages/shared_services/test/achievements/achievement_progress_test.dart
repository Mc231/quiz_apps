import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('AchievementProgress', () {
    test('creates with required fields', () {
      final progress = AchievementProgress(
        achievementId: 'test_achievement',
        currentValue: 50,
        targetValue: 100,
        isUnlocked: false,
      );

      expect(progress.achievementId, 'test_achievement');
      expect(progress.currentValue, 50);
      expect(progress.targetValue, 100);
      expect(progress.isUnlocked, false);
      expect(progress.unlockedAt, isNull);
    });

    group('factory constructors', () {
      test('unlocked creates progress at 100%', () {
        final now = DateTime.now();
        final progress = AchievementProgress.unlocked(
          achievementId: 'test',
          targetValue: 10,
          unlockedAt: now,
        );

        expect(progress.currentValue, 10);
        expect(progress.targetValue, 10);
        expect(progress.isUnlocked, true);
        expect(progress.unlockedAt, now);
        expect(progress.percentage, 1.0);
      });

      test('inProgress creates locked progress', () {
        final progress = AchievementProgress.inProgress(
          achievementId: 'test',
          currentValue: 7,
          targetValue: 10,
        );

        expect(progress.currentValue, 7);
        expect(progress.targetValue, 10);
        expect(progress.isUnlocked, false);
        expect(progress.unlockedAt, isNull);
      });

      test('locked creates progress with zero', () {
        final progress = AchievementProgress.locked(
          achievementId: 'test',
          targetValue: 100,
        );

        expect(progress.currentValue, 0);
        expect(progress.targetValue, 100);
        expect(progress.isUnlocked, false);
        expect(progress.percentage, 0.0);
      });
    });

    group('percentage', () {
      test('calculates correct percentage', () {
        final progress = AchievementProgress(
          achievementId: 'test',
          currentValue: 25,
          targetValue: 100,
          isUnlocked: false,
        );

        expect(progress.percentage, 0.25);
      });

      test('clamps to 0.0 for negative values', () {
        final progress = AchievementProgress(
          achievementId: 'test',
          currentValue: -10,
          targetValue: 100,
          isUnlocked: false,
        );

        expect(progress.percentage, 0.0);
      });

      test('clamps to 1.0 for values over target', () {
        final progress = AchievementProgress(
          achievementId: 'test',
          currentValue: 150,
          targetValue: 100,
          isUnlocked: false,
        );

        expect(progress.percentage, 1.0);
      });

      test('returns 1.0 when unlocked with zero target', () {
        final progress = AchievementProgress(
          achievementId: 'test',
          currentValue: 0,
          targetValue: 0,
          isUnlocked: true,
        );

        expect(progress.percentage, 1.0);
      });

      test('returns 0.0 when locked with zero target', () {
        final progress = AchievementProgress(
          achievementId: 'test',
          currentValue: 0,
          targetValue: 0,
          isUnlocked: false,
        );

        expect(progress.percentage, 0.0);
      });
    });

    test('percentageInt rounds correctly', () {
      final progress1 = AchievementProgress(
        achievementId: 'test',
        currentValue: 33,
        targetValue: 100,
        isUnlocked: false,
      );
      expect(progress1.percentageInt, 33);

      final progress2 = AchievementProgress(
        achievementId: 'test',
        currentValue: 67,
        targetValue: 100,
        isUnlocked: false,
      );
      expect(progress2.percentageInt, 67);
    });

    test('hasProgress returns true when currentValue > 0', () {
      final noProgress = AchievementProgress.locked(
        achievementId: 'test',
        targetValue: 10,
      );
      expect(noProgress.hasProgress, false);

      final withProgress = AchievementProgress.inProgress(
        achievementId: 'test',
        currentValue: 1,
        targetValue: 10,
      );
      expect(withProgress.hasProgress, true);
    });

    test('isCloseToUnlock returns true at 80%+', () {
      final at79 = AchievementProgress(
        achievementId: 'test',
        currentValue: 79,
        targetValue: 100,
        isUnlocked: false,
      );
      expect(at79.isCloseToUnlock, false);

      final at80 = AchievementProgress(
        achievementId: 'test',
        currentValue: 80,
        targetValue: 100,
        isUnlocked: false,
      );
      expect(at80.isCloseToUnlock, true);

      final unlocked = AchievementProgress(
        achievementId: 'test',
        currentValue: 100,
        targetValue: 100,
        isUnlocked: true,
      );
      expect(unlocked.isCloseToUnlock, false);
    });

    test('copyWith creates modified copy', () {
      final original = AchievementProgress(
        achievementId: 'test',
        currentValue: 50,
        targetValue: 100,
        isUnlocked: false,
      );

      final modified = original.copyWith(
        currentValue: 75,
        isUnlocked: true,
      );

      expect(modified.achievementId, 'test');
      expect(modified.currentValue, 75);
      expect(modified.targetValue, 100);
      expect(modified.isUnlocked, true);
    });

    test('equality based on achievementId', () {
      final progress1 = AchievementProgress(
        achievementId: 'test',
        currentValue: 50,
        targetValue: 100,
        isUnlocked: false,
      );
      final progress2 = AchievementProgress(
        achievementId: 'test',
        currentValue: 75,
        targetValue: 100,
        isUnlocked: true,
      );
      final progress3 = AchievementProgress(
        achievementId: 'other',
        currentValue: 50,
        targetValue: 100,
        isUnlocked: false,
      );

      expect(progress1, equals(progress2));
      expect(progress1, isNot(equals(progress3)));
    });

    test('toString contains relevant info', () {
      final progress = AchievementProgress(
        achievementId: 'test_id',
        currentValue: 50,
        targetValue: 100,
        isUnlocked: false,
      );

      expect(progress.toString(), contains('test_id'));
      expect(progress.toString(), contains('50/100'));
      expect(progress.toString(), contains('unlocked: false'));
    });
  });
}
