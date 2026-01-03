import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('LeaderboardScoreType', () {
    test('has correct values', () {
      expect(LeaderboardScoreType.values.length, equals(3));
      expect(LeaderboardScoreType.highScore, isNotNull);
      expect(LeaderboardScoreType.lowestTime, isNotNull);
      expect(LeaderboardScoreType.cumulative, isNotNull);
    });
  });

  group('LeaderboardConfig', () {
    test('creates with required fields', () {
      const config = LeaderboardConfig(id: 'test');

      expect(config.id, equals('test'));
      expect(config.gameCenterId, isNull);
      expect(config.playGamesId, isNull);
      expect(config.scoreType, equals(LeaderboardScoreType.highScore));
    });

    test('creates with all fields', () {
      const config = LeaderboardConfig(
        id: 'global',
        gameCenterId: 'com.app.global',
        playGamesId: 'CgkI_global',
        scoreType: LeaderboardScoreType.cumulative,
      );

      expect(config.id, equals('global'));
      expect(config.gameCenterId, equals('com.app.global'));
      expect(config.playGamesId, equals('CgkI_global'));
      expect(config.scoreType, equals(LeaderboardScoreType.cumulative));
    });

    test('platform ID getters work correctly', () {
      const config = LeaderboardConfig(
        id: 'test',
        gameCenterId: 'ios_id',
        playGamesId: 'android_id',
      );

      expect(config.iosId, equals('ios_id'));
      expect(config.androidId, equals('android_id'));
    });

    test('hasIosSupport returns correct value', () {
      const withIos = LeaderboardConfig(
        id: 'test',
        gameCenterId: 'ios_id',
      );
      const withoutIos = LeaderboardConfig(id: 'test');
      const withEmptyIos = LeaderboardConfig(
        id: 'test',
        gameCenterId: '',
      );

      expect(withIos.hasIosSupport, isTrue);
      expect(withoutIos.hasIosSupport, isFalse);
      expect(withEmptyIos.hasIosSupport, isFalse);
    });

    test('hasAndroidSupport returns correct value', () {
      const withAndroid = LeaderboardConfig(
        id: 'test',
        playGamesId: 'android_id',
      );
      const withoutAndroid = LeaderboardConfig(id: 'test');
      const withEmptyAndroid = LeaderboardConfig(
        id: 'test',
        playGamesId: '',
      );

      expect(withAndroid.hasAndroidSupport, isTrue);
      expect(withoutAndroid.hasAndroidSupport, isFalse);
      expect(withEmptyAndroid.hasAndroidSupport, isFalse);
    });

    test('copyWith creates new instance with replaced fields', () {
      const original = LeaderboardConfig(
        id: 'original',
        gameCenterId: 'ios_original',
        scoreType: LeaderboardScoreType.highScore,
      );

      final copied = original.copyWith(
        id: 'copied',
        scoreType: LeaderboardScoreType.lowestTime,
      );

      expect(copied.id, equals('copied'));
      expect(copied.gameCenterId, equals('ios_original'));
      expect(copied.scoreType, equals(LeaderboardScoreType.lowestTime));
    });

    test('equality works correctly', () {
      const config1 = LeaderboardConfig(
        id: 'test',
        gameCenterId: 'ios_id',
      );
      const config2 = LeaderboardConfig(
        id: 'test',
        gameCenterId: 'ios_id',
      );
      const config3 = LeaderboardConfig(
        id: 'different',
        gameCenterId: 'ios_id',
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('hashCode is consistent with equality', () {
      const config1 = LeaderboardConfig(
        id: 'test',
        gameCenterId: 'ios_id',
      );
      const config2 = LeaderboardConfig(
        id: 'test',
        gameCenterId: 'ios_id',
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });
  });

  group('GameServiceConfig', () {
    test('creates with defaults', () {
      const config = GameServiceConfig();

      expect(config.isEnabled, isTrue);
      expect(config.cloudSyncEnabled, isTrue);
      expect(config.syncOnLaunch, isTrue);
      expect(config.syncAfterQuizCompletion, isTrue);
      expect(config.showAccountInSettings, isTrue);
      expect(config.leaderboards, isEmpty);
      expect(config.achievementIdMap, isEmpty);
    });

    test('disabled factory creates disabled config', () {
      const config = GameServiceConfig.disabled();

      expect(config.isEnabled, isFalse);
      expect(config.cloudSyncEnabled, isFalse);
      expect(config.syncOnLaunch, isFalse);
      expect(config.syncAfterQuizCompletion, isFalse);
      expect(config.showAccountInSettings, isFalse);
    });

    test('test factory creates enabled config', () {
      const config = GameServiceConfig.test();

      expect(config.isEnabled, isTrue);
      expect(config.cloudSyncEnabled, isTrue);
      expect(config.syncOnLaunch, isTrue);
      expect(config.syncAfterQuizCompletion, isTrue);
      expect(config.showAccountInSettings, isTrue);
    });

    test('creates with leaderboards', () {
      const config = GameServiceConfig(
        leaderboards: [
          LeaderboardConfig(id: 'global'),
          LeaderboardConfig(id: 'europe'),
        ],
      );

      expect(config.leaderboards.length, equals(2));
      expect(config.hasLeaderboards, isTrue);
      expect(config.leaderboardCount, equals(2));
    });

    test('creates with achievement mappings', () {
      const config = GameServiceConfig(
        achievementIdMap: {
          'first_quiz': 'com.app.first_quiz',
          'perfect_score': 'com.app.perfect_score',
        },
      );

      expect(config.achievementIdMap.length, equals(2));
      expect(config.hasAchievements, isTrue);
      expect(config.achievementCount, equals(2));
    });

    test('getLeaderboard finds leaderboard by id', () {
      const config = GameServiceConfig(
        leaderboards: [
          LeaderboardConfig(id: 'global'),
          LeaderboardConfig(id: 'europe'),
        ],
      );

      expect(config.getLeaderboard('global')?.id, equals('global'));
      expect(config.getLeaderboard('europe')?.id, equals('europe'));
      expect(config.getLeaderboard('nonexistent'), isNull);
    });

    test('getPlatformAchievementId returns correct mapping', () {
      const config = GameServiceConfig(
        achievementIdMap: {
          'first_quiz': 'com.app.first_quiz',
        },
      );

      expect(config.getPlatformAchievementId('first_quiz'),
          equals('com.app.first_quiz'));
      expect(config.getPlatformAchievementId('nonexistent'), isNull);
    });

    test('copyWith creates new instance with replaced fields', () {
      const original = GameServiceConfig(
        isEnabled: true,
        cloudSyncEnabled: true,
      );

      final copied = original.copyWith(
        isEnabled: false,
      );

      expect(copied.isEnabled, isFalse);
      expect(copied.cloudSyncEnabled, isTrue);
    });

    test('equality works correctly', () {
      const config1 = GameServiceConfig(
        isEnabled: true,
        cloudSyncEnabled: true,
      );
      const config2 = GameServiceConfig(
        isEnabled: true,
        cloudSyncEnabled: true,
      );
      const config3 = GameServiceConfig(
        isEnabled: false,
        cloudSyncEnabled: true,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });
}
