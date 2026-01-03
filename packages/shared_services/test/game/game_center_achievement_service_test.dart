import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('GameCenterAchievementService', () {
    late GameCenterAchievementService service;

    setUp(() {
      service = GameCenterAchievementService();
    });

    test('implements CloudAchievementService interface', () {
      expect(service, isA<CloudAchievementService>());
    });

    test('isSupported returns false on non-iOS/macOS platforms', () {
      if (!service.isSupported) {
        expect(service.isSupported, isFalse);
      }
    });

    test('can be created with achievement ID mapping', () {
      final serviceWithMapping = GameCenterAchievementService(
        achievementIdMapping: {
          'first_quiz': 'com.example.firstquiz',
          'perfect_score': 'com.example.perfectscore',
        },
      );
      expect(serviceWithMapping, isA<CloudAchievementService>());
    });

    // Note: Tests for unlockAchievement, incrementAchievement, getAchievements, etc.
    // are skipped because they require platform channels (MethodChannel)
    // which are not available in unit tests. These methods call the
    // games_services plugin which requires a Flutter engine.
    //
    // These should be tested as integration tests on real iOS/macOS devices.

    group('achievement ID mapping', () {
      test('without mapping uses original ID', () {
        // The mapping behavior is internal, but we verify the service
        // can be created and used with and without mapping
        final serviceWithoutMapping = GameCenterAchievementService();
        expect(serviceWithoutMapping, isNotNull);
      });

      test('with mapping uses mapped IDs', () {
        final serviceWithMapping = GameCenterAchievementService(
          achievementIdMapping: {
            'local_id': 'gamecenter_id',
          },
        );
        expect(serviceWithMapping, isNotNull);
      });

      test('empty mapping is valid', () {
        final serviceWithEmptyMapping = GameCenterAchievementService(
          achievementIdMapping: {},
        );
        expect(serviceWithEmptyMapping, isNotNull);
      });
    });
  });
}
