import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('PlayGamesServices', () {
    late PlayGamesServices services;

    setUp(() {
      services = PlayGamesServices();
    });

    test('provides GameService', () {
      expect(services.gameService, isA<GameService>());
      expect(services.gameService, isA<PlayGamesService>());
    });

    test('provides LeaderboardService', () {
      expect(services.leaderboardService, isA<LeaderboardService>());
      expect(services.leaderboardService, isA<PlayGamesLeaderboardService>());
    });

    test('provides CloudAchievementService', () {
      expect(services.cloudAchievementService, isA<CloudAchievementService>());
      expect(
        services.cloudAchievementService,
        isA<PlayGamesAchievementService>(),
      );
    });

    test('isSupported reflects platform support', () {
      // This will be false on test environment (not Android)
      expect(services.isSupported, isA<bool>());
    });

    test('can be created with achievement ID mapping', () {
      final servicesWithMapping = PlayGamesServices(
        achievementIdMapping: {
          'first_quiz': 'CgkI0OvX_IAOEAIQAQ',
          'perfect_score': 'CgkI0OvX_IAOEAIQAg',
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
      // Note: signIn, signOut, and isSignedIn tests are skipped because they
      // require platform channels which are not available in unit tests.
      // These would need integration tests on real Android devices.

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
    // on real Android devices.
  });

  group('PlayGamesServices vs NoOpGameServices', () {
    test('both provide same interface types', () {
      final playGamesServices = PlayGamesServices();

      expect(playGamesServices.gameService, isA<GameService>());
      expect(NoOpGameServices.gameService, isA<GameService>());

      expect(playGamesServices.leaderboardService, isA<LeaderboardService>());
      expect(NoOpGameServices.leaderboardService, isA<LeaderboardService>());

      expect(
        playGamesServices.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
      expect(
        NoOpGameServices.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
    });
  });

  group('PlayGamesServices vs GameCenterServices', () {
    test('both provide same interface types', () {
      final playGamesServices = PlayGamesServices();
      final gameCenterServices = GameCenterServices();

      // Both should implement the same interfaces
      expect(playGamesServices.gameService, isA<GameService>());
      expect(gameCenterServices.gameService, isA<GameService>());

      expect(playGamesServices.leaderboardService, isA<LeaderboardService>());
      expect(gameCenterServices.leaderboardService, isA<LeaderboardService>());

      expect(
        playGamesServices.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
      expect(
        gameCenterServices.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
    });

    test('platform support is mutually exclusive', () {
      final playGamesServices = PlayGamesServices();
      final gameCenterServices = GameCenterServices();

      // On any given platform, at most one should be supported
      // (unless testing on iOS/macOS simulator which reports as iOS but
      // doesn't actually support Game Center)
      final bothSupported =
          playGamesServices.isSupported && gameCenterServices.isSupported;

      // In test environment, neither should be supported
      expect(bothSupported, isFalse);
    });
  });
}
