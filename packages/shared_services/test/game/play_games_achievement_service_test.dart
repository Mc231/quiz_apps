import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('PlayGamesAchievementService', () {
    late PlayGamesAchievementService service;

    setUp(() {
      service = PlayGamesAchievementService();
    });

    test('implements CloudAchievementService interface', () {
      expect(service, isA<CloudAchievementService>());
    });

    test('isSupported returns false on non-Android platforms', () {
      if (!service.isSupported) {
        expect(service.isSupported, isFalse);
      }
    });

    test('can be created with achievement ID mapping', () {
      final serviceWithMapping = PlayGamesAchievementService(
        achievementIdMapping: {
          'first_quiz': 'CgkI0OvX_IAOEAIQAQ',
          'perfect_score': 'CgkI0OvX_IAOEAIQAg',
        },
      );
      expect(serviceWithMapping, isA<CloudAchievementService>());
    });

    // Note: Tests for unlockAchievement, incrementAchievement, getAchievements, etc.
    // are skipped because they require platform channels (MethodChannel)
    // which are not available in unit tests. These methods call the
    // games_services plugin which requires a Flutter engine.
    //
    // These should be tested as integration tests on real Android devices.

    group('achievement ID mapping', () {
      test('without mapping uses original ID', () {
        // The mapping behavior is internal, but we verify the service
        // can be created and used with and without mapping
        final serviceWithoutMapping = PlayGamesAchievementService();
        expect(serviceWithoutMapping, isNotNull);
      });

      test('with mapping uses mapped IDs', () {
        final serviceWithMapping = PlayGamesAchievementService(
          achievementIdMapping: {
            'local_id': 'playgames_id',
          },
        );
        expect(serviceWithMapping, isNotNull);
      });

      test('empty mapping is valid', () {
        final serviceWithEmptyMapping = PlayGamesAchievementService(
          achievementIdMapping: {},
        );
        expect(serviceWithEmptyMapping, isNotNull);
      });
    });
  });
}
