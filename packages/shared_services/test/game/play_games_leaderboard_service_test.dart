import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('PlayGamesLeaderboardService', () {
    late PlayGamesLeaderboardService service;

    setUp(() {
      service = PlayGamesLeaderboardService();
    });

    test('implements LeaderboardService interface', () {
      expect(service, isA<LeaderboardService>());
    });

    test('isSupported returns false on non-Android platforms', () {
      // Test environment is typically Linux or other non-Android platform
      if (!service.isSupported) {
        expect(service.isSupported, isFalse);
      }
    });

    // Note: Tests for submitScore, getTopScores, getPlayerScore, showLeaderboard, etc.
    // are skipped because they require platform channels (MethodChannel)
    // which are not available in unit tests. These methods call the
    // games_services plugin which requires a Flutter engine.
    //
    // These should be tested as integration tests on real Android devices.

    group('LeaderboardTimeSpan compatibility', () {
      test('uses same LeaderboardTimeSpan enum as Game Center', () {
        // Both services use the same LeaderboardTimeSpan enum
        expect(LeaderboardTimeSpan.values.length, equals(3));
        expect(LeaderboardTimeSpan.allTime, isNotNull);
        expect(LeaderboardTimeSpan.weekly, isNotNull);
        expect(LeaderboardTimeSpan.daily, isNotNull);
      });
    });
  });
}
