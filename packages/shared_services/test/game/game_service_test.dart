import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('SignInResult', () {
    test('success factory creates SignInSuccess', () {
      final result = SignInResult.success(
        playerId: 'player123',
        displayName: 'John Doe',
      );

      expect(result, isA<SignInSuccess>());
      expect((result as SignInSuccess).playerId, equals('player123'));
      expect(result.displayName, equals('John Doe'));
    });

    test('cancelled factory creates SignInCancelled', () {
      final result = SignInResult.cancelled();

      expect(result, isA<SignInCancelled>());
    });

    test('failed factory creates SignInFailed', () {
      final result = SignInResult.failed(
        error: 'Network error',
        errorCode: 'NET_001',
      );

      expect(result, isA<SignInFailed>());
      expect((result as SignInFailed).error, equals('Network error'));
      expect(result.errorCode, equals('NET_001'));
    });

    test('failed factory works without errorCode', () {
      final result = SignInResult.failed(error: 'Unknown error');

      expect(result, isA<SignInFailed>());
      expect((result as SignInFailed).errorCode, isNull);
    });

    test('notAuthenticated factory creates SignInNotAuthenticated', () {
      final result = SignInResult.notAuthenticated();

      expect(result, isA<SignInNotAuthenticated>());
    });

    test('sealed class pattern matching works', () {
      final results = [
        SignInResult.success(playerId: 'p1', displayName: 'User 1'),
        SignInResult.cancelled(),
        SignInResult.failed(error: 'error'),
        SignInResult.notAuthenticated(),
      ];

      final types = results.map((result) {
        return switch (result) {
          SignInSuccess() => 'success',
          SignInCancelled() => 'cancelled',
          SignInFailed() => 'failed',
          SignInNotAuthenticated() => 'notAuthenticated',
        };
      }).toList();

      expect(types, equals(['success', 'cancelled', 'failed', 'notAuthenticated']));
    });
  });

  group('PlayerInfo', () {
    test('creates with required fields', () {
      final player = PlayerInfo(
        playerId: 'player123',
        displayName: 'John Doe',
      );

      expect(player.playerId, equals('player123'));
      expect(player.displayName, equals('John Doe'));
      expect(player.avatarUrl, isNull);
    });

    test('creates with all fields', () {
      final player = PlayerInfo(
        playerId: 'player123',
        displayName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.png',
      );

      expect(player.playerId, equals('player123'));
      expect(player.displayName, equals('John Doe'));
      expect(player.avatarUrl, equals('https://example.com/avatar.png'));
    });

    test('toString returns readable format', () {
      final player = PlayerInfo(
        playerId: 'player123',
        displayName: 'John Doe',
      );

      expect(
        player.toString(),
        equals('PlayerInfo(playerId: player123, displayName: John Doe)'),
      );
    });
  });

  group('NoOpGameService', () {
    late NoOpGameService service;

    setUp(() {
      service = const NoOpGameService();
    });

    test('signIn returns notAuthenticated', () async {
      final result = await service.signIn();

      expect(result, isA<SignInNotAuthenticated>());
    });

    test('signOut completes without error', () async {
      await expectLater(service.signOut(), completes);
    });

    test('isSignedIn returns false', () async {
      final result = await service.isSignedIn();

      expect(result, isFalse);
    });

    test('getPlayerId returns null', () async {
      final result = await service.getPlayerId();

      expect(result, isNull);
    });

    test('getPlayerDisplayName returns null', () async {
      final result = await service.getPlayerDisplayName();

      expect(result, isNull);
    });

    test('getPlayerAvatar returns null', () async {
      final result = await service.getPlayerAvatar();

      expect(result, isNull);
    });

    test('getPlayerInfo returns null', () async {
      final result = await service.getPlayerInfo();

      expect(result, isNull);
    });
  });
}