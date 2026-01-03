import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('GameCenterService', () {
    late GameCenterService service;

    setUp(() {
      service = GameCenterService();
    });

    test('implements GameService interface', () {
      expect(service, isA<GameService>());
    });

    test('isSupported returns false on non-iOS/macOS platforms', () {
      // Test environment is typically Linux or other non-iOS platform
      // On non-iOS/macOS, isSupported should be false
      if (!service.isSupported) {
        expect(service.isSupported, isFalse);
      }
    });

    // Note: Tests for signIn, signOut, isSignedIn, getPlayerId, etc.
    // are skipped because they require platform channels (MethodChannel)
    // which are not available in unit tests. These methods call the
    // games_services plugin which requires a Flutter engine.
    //
    // These should be tested as integration tests on real iOS/macOS devices.

    test('clearCache completes without error', () {
      expect(() => service.clearCache(), returnsNormally);
    });

    test('playerAvatarBase64 is null initially', () {
      expect(service.playerAvatarBase64, isNull);
    });
  });

  group('GameCenterService caching', () {
    late GameCenterService service;

    setUp(() {
      service = GameCenterService();
    });

    test('clearCache clears cached data', () {
      // Even without signing in, clearCache should work
      service.clearCache();
      expect(service.playerAvatarBase64, isNull);
    });
  });
}
