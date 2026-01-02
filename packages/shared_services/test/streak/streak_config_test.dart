import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StreakConfig', () {
    group('constructor', () {
      test('creates with default values', () {
        const config = StreakConfig();

        expect(config.gracePeriodHours, 0);
        expect(config.freezeTokensEnabled, false);
        expect(config.streakMilestones, StreakConfig.defaultMilestones);
      });

      test('creates with custom values', () {
        const config = StreakConfig(
          gracePeriodHours: 4,
          freezeTokensEnabled: true,
          streakMilestones: [7, 30, 100],
        );

        expect(config.gracePeriodHours, 4);
        expect(config.freezeTokensEnabled, true);
        expect(config.streakMilestones, [7, 30, 100]);
      });
    });

    group('defaults', () {
      test('provides default configuration', () {
        expect(StreakConfig.defaults.gracePeriodHours, 0);
        expect(StreakConfig.defaults.freezeTokensEnabled, false);
      });
    });

    group('defaultMilestones', () {
      test('has expected milestones', () {
        expect(StreakConfig.defaultMilestones, [7, 14, 30, 50, 100, 365]);
      });
    });

    group('getNextMilestone', () {
      test('returns first milestone when streak is 0', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getNextMilestone(0), 7);
      });

      test('returns correct milestone when streak is between milestones', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getNextMilestone(5), 7);
        expect(config.getNextMilestone(7), 30);
        expect(config.getNextMilestone(15), 30);
        expect(config.getNextMilestone(30), 100);
        expect(config.getNextMilestone(50), 100);
      });

      test('returns null when all milestones are reached', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getNextMilestone(100), null);
        expect(config.getNextMilestone(150), null);
      });

      test('handles empty milestones', () {
        const config = StreakConfig(streakMilestones: []);

        expect(config.getNextMilestone(0), null);
        expect(config.getNextMilestone(10), null);
      });
    });

    group('getLastReachedMilestone', () {
      test('returns null when no milestones reached', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getLastReachedMilestone(0), null);
        expect(config.getLastReachedMilestone(5), null);
      });

      test('returns correct milestone when streak equals milestone', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getLastReachedMilestone(7), 7);
        expect(config.getLastReachedMilestone(30), 30);
        expect(config.getLastReachedMilestone(100), 100);
      });

      test('returns correct milestone when streak is past milestone', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getLastReachedMilestone(10), 7);
        expect(config.getLastReachedMilestone(50), 30);
        expect(config.getLastReachedMilestone(150), 100);
      });

      test('handles empty milestones', () {
        const config = StreakConfig(streakMilestones: []);

        expect(config.getLastReachedMilestone(10), null);
      });
    });

    group('isMilestone', () {
      test('returns true for milestone values', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.isMilestone(7), true);
        expect(config.isMilestone(30), true);
        expect(config.isMilestone(100), true);
      });

      test('returns false for non-milestone values', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.isMilestone(0), false);
        expect(config.isMilestone(5), false);
        expect(config.isMilestone(15), false);
        expect(config.isMilestone(50), false);
      });
    });

    group('getMilestoneProgress', () {
      test('returns 0 when at start', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getMilestoneProgress(0), 0.0);
      });

      test('returns correct progress within first milestone', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        // 3 out of 7 = ~0.43
        expect(config.getMilestoneProgress(3), closeTo(3 / 7, 0.01));
        // 7 out of 7 = progress to next milestone (0 / 23)
        expect(config.getMilestoneProgress(7), closeTo(0 / 23, 0.01));
      });

      test('returns correct progress between milestones', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        // 7 days reached, 20 days = 13 into 23 range = ~0.57
        expect(config.getMilestoneProgress(20), closeTo(13 / 23, 0.01));
      });

      test('returns 1.0 when all milestones reached', () {
        const config = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config.getMilestoneProgress(100), 1.0);
        expect(config.getMilestoneProgress(150), 1.0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated gracePeriodHours', () {
        const original = StreakConfig();
        final copy = original.copyWith(gracePeriodHours: 4);

        expect(copy.gracePeriodHours, 4);
        expect(copy.freezeTokensEnabled, original.freezeTokensEnabled);
        expect(copy.streakMilestones, original.streakMilestones);
      });

      test('creates copy with updated freezeTokensEnabled', () {
        const original = StreakConfig();
        final copy = original.copyWith(freezeTokensEnabled: true);

        expect(copy.freezeTokensEnabled, true);
        expect(copy.gracePeriodHours, original.gracePeriodHours);
      });

      test('creates copy with updated streakMilestones', () {
        const original = StreakConfig();
        final copy = original.copyWith(streakMilestones: [10, 50]);

        expect(copy.streakMilestones, [10, 50]);
        expect(copy.gracePeriodHours, original.gracePeriodHours);
      });
    });

    group('equality', () {
      test('two configs with same values are equal', () {
        const config1 = StreakConfig(
          gracePeriodHours: 4,
          freezeTokensEnabled: true,
          streakMilestones: [7, 30],
        );
        const config2 = StreakConfig(
          gracePeriodHours: 4,
          freezeTokensEnabled: true,
          streakMilestones: [7, 30],
        );

        expect(config1, config2);
        expect(config1.hashCode, config2.hashCode);
      });

      test('two configs with different values are not equal', () {
        const config1 = StreakConfig(gracePeriodHours: 4);
        const config2 = StreakConfig(gracePeriodHours: 0);

        expect(config1, isNot(config2));
      });

      test('configs with different milestones are not equal', () {
        const config1 = StreakConfig(streakMilestones: [7, 30]);
        const config2 = StreakConfig(streakMilestones: [7, 30, 100]);

        expect(config1, isNot(config2));
      });
    });
  });
}
