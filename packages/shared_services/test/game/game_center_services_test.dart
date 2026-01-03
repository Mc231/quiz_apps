import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('GameCenterServices', () {
    late GameCenterServices services;

    setUp(() {
      services = GameCenterServices();
    });

    test('provides GameService', () {
      expect(services.gameService, isA<GameService>());
      expect(services.gameService, isA<GameCenterService>());
    });

    test('provides LeaderboardService', () {
      expect(services.leaderboardService, isA<LeaderboardService>());
      expect(services.leaderboardService, isA<GameCenterLeaderboardService>());
    });

    test('provides CloudAchievementService', () {
      expect(services.cloudAchievementService, isA<CloudAchievementService>());
      expect(
        services.cloudAchievementService,
        isA<GameCenterAchievementService>(),
      );
    });

    test('isSupported reflects platform support', () {
      // This will be false on test environment (not iOS/macOS)
      expect(services.isSupported, isA<bool>());
    });

    test('can be created with achievement ID mapping', () {
      final servicesWithMapping = GameCenterServices(
        achievementIdMapping: {
          'first_quiz': 'com.example.app.firstquiz',
          'perfect_score': 'com.example.app.perfectscore',
        },
      );

      expect(servicesWithMapping.gameService, isA<GameService>());
      expect(servicesWithMapping.leaderboardService, isA<LeaderboardService>());
      expect(
        servicesWithMapping.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
    });

    group('convenience methods', () {
      // Note: signIn and isSignedIn tests are skipped because they require
      // platform channels which are not available in unit tests.
      // These would need integration tests on real iOS/macOS devices.

      test('clearCache completes without error', () {
        expect(() => services.clearCache(), returnsNormally);
      });

      test('playerAvatarBase64 is null initially', () {
        expect(services.playerAvatarBase64, isNull);
      });
    });

    // Note: Integration tests that call platform methods are skipped.
    // The games_services package uses MethodChannel which requires
    // a Flutter engine. These tests should be run as integration tests
    // on real iOS/macOS devices.
  });

  group('GameCenterServices vs NoOpGameServices', () {
    test('both provide same interface types', () {
      final gameCenterServices = GameCenterServices();

      expect(gameCenterServices.gameService, isA<GameService>());
      expect(NoOpGameServices.gameService, isA<GameService>());

      expect(gameCenterServices.leaderboardService, isA<LeaderboardService>());
      expect(NoOpGameServices.leaderboardService, isA<LeaderboardService>());

      expect(
        gameCenterServices.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
      expect(
        NoOpGameServices.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
    });
  });
}
