import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StreakReward', () {
    group('constructor', () {
      test('creates reward with required fields', () {
        const reward = StreakReward(
          type: StreakRewardType.bonusHints,
          amount: 3,
          milestoneDay: 7,
          title: 'Bonus Hints',
          description: 'You earned 3 bonus hints!',
        );

        expect(reward.type, StreakRewardType.bonusHints);
        expect(reward.amount, 3);
        expect(reward.milestoneDay, 7);
        expect(reward.title, 'Bonus Hints');
        expect(reward.description, 'You earned 3 bonus hints!');
        expect(reward.iconName, isNull);
        expect(reward.metadata, isNull);
      });

      test('creates reward with optional fields', () {
        const reward = StreakReward(
          type: StreakRewardType.experiencePoints,
          amount: 100,
          milestoneDay: 30,
          title: 'XP Bonus',
          description: 'You earned 100 XP!',
          iconName: 'star',
          metadata: {'source': 'streak'},
        );

        expect(reward.iconName, 'star');
        expect(reward.metadata, {'source': 'streak'});
      });
    });

    group('factory constructors', () {
      test('bonusHints creates correct reward', () {
        final reward = StreakReward.bonusHints(
          amount: 5,
          milestoneDay: 14,
        );

        expect(reward.type, StreakRewardType.bonusHints);
        expect(reward.amount, 5);
        expect(reward.milestoneDay, 14);
        expect(reward.title, 'Bonus Hints');
        expect(reward.description, 'You earned 5 bonus hints!');
        expect(reward.iconName, 'lightbulb');
      });

      test('experiencePoints creates correct reward', () {
        final reward = StreakReward.experiencePoints(
          amount: 250,
          milestoneDay: 30,
        );

        expect(reward.type, StreakRewardType.experiencePoints);
        expect(reward.amount, 250);
        expect(reward.milestoneDay, 30);
        expect(reward.title, 'Experience Points');
        expect(reward.description, 'You earned 250 XP!');
        expect(reward.iconName, 'star');
      });

      test('virtualCurrency creates correct reward with custom currency', () {
        final reward = StreakReward.virtualCurrency(
          amount: 100,
          milestoneDay: 7,
          currencyName: 'gems',
        );

        expect(reward.type, StreakRewardType.virtualCurrency);
        expect(reward.amount, 100);
        expect(reward.milestoneDay, 7);
        expect(reward.title, 'Bonus gems');
        expect(reward.description, 'You earned 100 gems!');
        expect(reward.iconName, 'monetization_on');
        expect(reward.metadata, {'currency_name': 'gems'});
      });

      test('achievement creates correct reward', () {
        final reward = StreakReward.achievement(
          achievementId: 'week_warrior',
          milestoneDay: 7,
          achievementName: 'Week Warrior',
        );

        expect(reward.type, StreakRewardType.achievement);
        expect(reward.amount, 1);
        expect(reward.milestoneDay, 7);
        expect(reward.title, 'Week Warrior');
        expect(reward.description, 'Achievement unlocked!');
        expect(reward.iconName, 'emoji_events');
        expect(reward.metadata, {'achievement_id': 'week_warrior'});
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const original = StreakReward(
          type: StreakRewardType.bonusHints,
          amount: 3,
          milestoneDay: 7,
          title: 'Original',
          description: 'Original description',
        );

        final copy = original.copyWith(
          amount: 5,
          title: 'Updated',
        );

        expect(copy.type, StreakRewardType.bonusHints);
        expect(copy.amount, 5);
        expect(copy.milestoneDay, 7);
        expect(copy.title, 'Updated');
        expect(copy.description, 'Original description');
      });
    });

    group('equality', () {
      test('equal rewards are equal', () {
        const reward1 = StreakReward(
          type: StreakRewardType.bonusHints,
          amount: 3,
          milestoneDay: 7,
          title: 'Bonus',
          description: 'Description',
        );
        const reward2 = StreakReward(
          type: StreakRewardType.bonusHints,
          amount: 3,
          milestoneDay: 7,
          title: 'Bonus',
          description: 'Description',
        );

        expect(reward1, equals(reward2));
        expect(reward1.hashCode, equals(reward2.hashCode));
      });

      test('different rewards are not equal', () {
        const reward1 = StreakReward(
          type: StreakRewardType.bonusHints,
          amount: 3,
          milestoneDay: 7,
          title: 'Bonus',
          description: 'Description',
        );
        const reward2 = StreakReward(
          type: StreakRewardType.experiencePoints,
          amount: 3,
          milestoneDay: 7,
          title: 'Bonus',
          description: 'Description',
        );

        expect(reward1, isNot(equals(reward2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const reward = StreakReward(
          type: StreakRewardType.bonusHints,
          amount: 3,
          milestoneDay: 7,
          title: 'Bonus Hints',
          description: 'Description',
        );

        expect(
          reward.toString(),
          'StreakReward(type: StreakRewardType.bonusHints, amount: 3, milestoneDay: 7, title: Bonus Hints)',
        );
      });
    });
  });

  group('StreakRewardConfig', () {
    test('empty config has no rewards', () {
      const config = StreakRewardConfig.empty;

      expect(config.rewards, isEmpty);
      expect(config.rewardMilestones, isEmpty);
    });

    test('getRewardsForMilestone returns rewards for existing milestone', () {
      final config = StreakRewardConfig(
        rewards: {
          7: [
            StreakReward.bonusHints(amount: 2, milestoneDay: 7),
          ],
          30: [
            StreakReward.bonusHints(amount: 5, milestoneDay: 30),
            StreakReward.experiencePoints(amount: 100, milestoneDay: 30),
          ],
        },
      );

      final rewards7 = config.getRewardsForMilestone(7);
      final rewards30 = config.getRewardsForMilestone(30);

      expect(rewards7.length, 1);
      expect(rewards7.first.amount, 2);
      expect(rewards30.length, 2);
    });

    test('getRewardsForMilestone returns empty list for non-existent milestone', () {
      final config = StreakRewardConfig(
        rewards: {
          7: [StreakReward.bonusHints(amount: 2, milestoneDay: 7)],
        },
      );

      final rewards = config.getRewardsForMilestone(14);

      expect(rewards, isEmpty);
    });

    test('hasRewardsForMilestone returns correct value', () {
      final config = StreakRewardConfig(
        rewards: {
          7: [StreakReward.bonusHints(amount: 2, milestoneDay: 7)],
          30: [],
        },
      );

      expect(config.hasRewardsForMilestone(7), isTrue);
      expect(config.hasRewardsForMilestone(30), isFalse);
      expect(config.hasRewardsForMilestone(100), isFalse);
    });

    test('rewardMilestones returns sorted list', () {
      final config = StreakRewardConfig(
        rewards: {
          30: [StreakReward.bonusHints(amount: 5, milestoneDay: 30)],
          7: [StreakReward.bonusHints(amount: 2, milestoneDay: 7)],
          100: [StreakReward.bonusHints(amount: 10, milestoneDay: 100)],
        },
      );

      expect(config.rewardMilestones, [7, 30, 100]);
    });

    test('copyWith creates copy with updated rewards', () {
      final original = StreakRewardConfig(
        rewards: {
          7: [StreakReward.bonusHints(amount: 2, milestoneDay: 7)],
        },
      );

      final copy = original.copyWith(
        rewards: {
          14: [StreakReward.bonusHints(amount: 3, milestoneDay: 14)],
        },
      );

      expect(copy.hasRewardsForMilestone(14), isTrue);
      expect(copy.hasRewardsForMilestone(7), isFalse);
    });
  });
}
