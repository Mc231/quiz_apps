import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('CumulativeTrigger', () {
    test('creates with required fields', () {
      final trigger = AchievementTrigger.cumulative(
        field: StatField.totalCompletedSessions,
        target: 100,
      );

      expect(trigger, isA<CumulativeTrigger>());
      expect((trigger as CumulativeTrigger).field,
          StatField.totalCompletedSessions);
      expect(trigger.target, 100);
    });

    test('equality based on field and target', () {
      final trigger1 = AchievementTrigger.cumulative(
        field: StatField.totalCompletedSessions,
        target: 100,
      );
      final trigger2 = AchievementTrigger.cumulative(
        field: StatField.totalCompletedSessions,
        target: 100,
      );
      final trigger3 = AchievementTrigger.cumulative(
        field: StatField.totalCompletedSessions,
        target: 50,
      );

      expect(trigger1, equals(trigger2));
      expect(trigger1, isNot(equals(trigger3)));
    });

    test('toString contains field and target', () {
      final trigger = AchievementTrigger.cumulative(
        field: StatField.totalPerfectScores,
        target: 10,
      );

      expect(trigger.toString(), contains('totalPerfectScores'));
      expect(trigger.toString(), contains('10'));
    });
  });

  group('ThresholdTrigger', () {
    test('creates with required fields', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionScorePercentage,
        value: 90,
      );

      expect(trigger, isA<ThresholdTrigger>());
      expect((trigger as ThresholdTrigger).field,
          StatField.sessionScorePercentage);
      expect(trigger.value, 90);
      expect(trigger.operator, ThresholdOperator.greaterOrEqual);
    });

    test('creates with custom operator', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionDurationSeconds,
        value: 60,
        operator: ThresholdOperator.lessThan,
      );

      expect((trigger as ThresholdTrigger).operator, ThresholdOperator.lessThan);
    });

    test('equality includes operator', () {
      final trigger1 = AchievementTrigger.threshold(
        field: StatField.sessionScorePercentage,
        value: 90,
        operator: ThresholdOperator.greaterOrEqual,
      );
      final trigger2 = AchievementTrigger.threshold(
        field: StatField.sessionScorePercentage,
        value: 90,
        operator: ThresholdOperator.greaterOrEqual,
      );
      final trigger3 = AchievementTrigger.threshold(
        field: StatField.sessionScorePercentage,
        value: 90,
        operator: ThresholdOperator.equal,
      );

      expect(trigger1, equals(trigger2));
      expect(trigger1, isNot(equals(trigger3)));
    });
  });

  group('StreakTrigger', () {
    test('creates with required fields', () {
      final trigger = AchievementTrigger.streak(target: 10);

      expect(trigger, isA<StreakTrigger>());
      expect((trigger as StreakTrigger).target, 10);
      expect(trigger.useBestStreak, true);
    });

    test('can use current streak instead of best', () {
      final trigger = AchievementTrigger.streak(
        target: 10,
        useBestStreak: false,
      );

      expect((trigger as StreakTrigger).useBestStreak, false);
    });

    test('equality based on target and useBestStreak', () {
      final trigger1 = AchievementTrigger.streak(target: 10);
      final trigger2 = AchievementTrigger.streak(target: 10);
      final trigger3 = AchievementTrigger.streak(target: 10, useBestStreak: false);

      expect(trigger1, equals(trigger2));
      expect(trigger1, isNot(equals(trigger3)));
    });
  });

  group('CategoryTrigger', () {
    test('creates with required fields', () {
      final trigger = AchievementTrigger.category(categoryId: 'europe');

      expect(trigger, isA<CategoryTrigger>());
      expect((trigger as CategoryTrigger).categoryId, 'europe');
      expect(trigger.requirePerfect, false);
      expect(trigger.requiredCount, 1);
    });

    test('can require perfect score', () {
      final trigger = AchievementTrigger.category(
        categoryId: 'europe',
        requirePerfect: true,
        requiredCount: 5,
      );

      expect((trigger as CategoryTrigger).requirePerfect, true);
      expect(trigger.requiredCount, 5);
    });

    test('equality based on all fields', () {
      final trigger1 = AchievementTrigger.category(
        categoryId: 'europe',
        requirePerfect: true,
        requiredCount: 5,
      );
      final trigger2 = AchievementTrigger.category(
        categoryId: 'europe',
        requirePerfect: true,
        requiredCount: 5,
      );
      final trigger3 = AchievementTrigger.category(
        categoryId: 'asia',
        requirePerfect: true,
        requiredCount: 5,
      );

      expect(trigger1, equals(trigger2));
      expect(trigger1, isNot(equals(trigger3)));
    });
  });

  group('ChallengeTrigger', () {
    test('creates with required fields', () {
      final trigger = AchievementTrigger.challenge(challengeId: 'survival');

      expect(trigger, isA<ChallengeTrigger>());
      expect((trigger as ChallengeTrigger).challengeId, 'survival');
      expect(trigger.requirePerfect, false);
      expect(trigger.requireNoLivesLost, false);
    });

    test('can require perfect and no lives lost', () {
      final trigger = AchievementTrigger.challenge(
        challengeId: 'survival',
        requirePerfect: true,
        requireNoLivesLost: true,
      );

      expect((trigger as ChallengeTrigger).requirePerfect, true);
      expect(trigger.requireNoLivesLost, true);
    });

    test('equality based on all fields', () {
      final trigger1 = AchievementTrigger.challenge(
        challengeId: 'blitz',
        requirePerfect: true,
      );
      final trigger2 = AchievementTrigger.challenge(
        challengeId: 'blitz',
        requirePerfect: true,
      );
      final trigger3 = AchievementTrigger.challenge(
        challengeId: 'blitz',
        requirePerfect: false,
      );

      expect(trigger1, equals(trigger2));
      expect(trigger1, isNot(equals(trigger3)));
    });
  });

  group('CompositeTrigger', () {
    test('creates with list of triggers', () {
      final trigger = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.threshold(
            field: StatField.sessionScorePercentage,
            value: 100,
          ),
          AchievementTrigger.threshold(
            field: StatField.sessionHintsUsed,
            value: 0,
            operator: ThresholdOperator.equal,
          ),
        ],
      );

      expect(trigger, isA<CompositeTrigger>());
      expect((trigger as CompositeTrigger).triggers.length, 2);
    });

    test('equality based on triggers list', () {
      final trigger1 = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.streak(target: 10),
          AchievementTrigger.threshold(
            field: StatField.sessionScorePercentage,
            value: 90,
          ),
        ],
      );
      final trigger2 = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.streak(target: 10),
          AchievementTrigger.threshold(
            field: StatField.sessionScorePercentage,
            value: 90,
          ),
        ],
      );
      final trigger3 = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.streak(target: 20),
        ],
      );

      expect(trigger1, equals(trigger2));
      expect(trigger1, isNot(equals(trigger3)));
    });
  });

  group('CustomTrigger', () {
    test('creates with evaluate function', () {
      final trigger = AchievementTrigger.custom(
        evaluate: (stats, session) => stats.totalPerfectScores > 0,
      );

      expect(trigger, isA<CustomTrigger>());
    });

    test('can include progress function and target', () {
      final trigger = AchievementTrigger.custom(
        evaluate: (stats, session) => stats.totalPerfectScores >= 10,
        getProgress: (stats) => stats.totalPerfectScores,
        target: 10,
      );

      expect((trigger as CustomTrigger).target, 10);
      expect(trigger.getProgress, isNotNull);
    });
  });

  group('ThresholdOperator', () {
    test('has all expected operators', () {
      expect(ThresholdOperator.values.length, 5);
      expect(ThresholdOperator.values, contains(ThresholdOperator.greaterOrEqual));
      expect(ThresholdOperator.values, contains(ThresholdOperator.lessOrEqual));
      expect(ThresholdOperator.values, contains(ThresholdOperator.greaterThan));
      expect(ThresholdOperator.values, contains(ThresholdOperator.lessThan));
      expect(ThresholdOperator.values, contains(ThresholdOperator.equal));
    });
  });
}
