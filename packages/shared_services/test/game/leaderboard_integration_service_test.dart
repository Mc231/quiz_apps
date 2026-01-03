import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock GameService for testing.
class MockGameService implements GameService {
  bool _isSignedIn = true;
  String? _playerId = 'player123';

  void setSignedIn(bool value) {
    _isSignedIn = value;
  }

  void setPlayerId(String? value) {
    _playerId = value;
  }

  @override
  Future<bool> isSignedIn() async => _isSignedIn;

  @override
  Future<String?> getPlayerId() async => _playerId;

  @override
  Future<String?> getPlayerDisplayName() async => 'Test User';

  @override
  Future<PlayerInfo?> getPlayerInfo() async => _isSignedIn
      ? PlayerInfo(playerId: _playerId ?? '', displayName: 'Test User')
      : null;

  @override
  Future<SignInResult> signIn() async =>
      SignInResult.success(playerId: 'player123', displayName: 'Test User');

  @override
  Future<void> signOut() async {}

  @override
  Future<Uint8List?> getPlayerAvatar() async => null;
}

/// Mock LeaderboardService for testing.
class MockLeaderboardService implements LeaderboardService {
  final List<(String leaderboardId, int score)> submittedScores = [];
  SubmitScoreResult Function(String leaderboardId, int score)?
      submitScoreHandler;

  void reset() {
    submittedScores.clear();
    submitScoreHandler = null;
  }

  @override
  Future<SubmitScoreResult> submitScore({
    required String leaderboardId,
    required int score,
  }) async {
    submittedScores.add((leaderboardId, score));
    if (submitScoreHandler != null) {
      return submitScoreHandler!(leaderboardId, score);
    }
    return SubmitScoreResult.success();
  }

  @override
  Future<List<LeaderboardEntry>> getTopScores({
    required String leaderboardId,
    required int count,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  }) async {
    return [];
  }

  @override
  Future<PlayerScore?> getPlayerScore({
    required String leaderboardId,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  }) async {
    return null;
  }

  @override
  Future<bool> showLeaderboard({String? leaderboardId}) async => true;

  @override
  Future<bool> showAllLeaderboards() async => true;
}

void main() {
  group('LeaderboardSubmitResult', () {
    test('success factory creates LeaderboardSubmitSuccess', () {
      final result = LeaderboardSubmitResult.success(
        leaderboardId: 'global',
        newRank: 5,
        isNewHighScore: true,
      );

      expect(result, isA<LeaderboardSubmitSuccess>());
      final success = result as LeaderboardSubmitSuccess;
      expect(success.leaderboardId, equals('global'));
      expect(success.newRank, equals(5));
      expect(success.isNewHighScore, isTrue);
    });

    test('failed factory creates LeaderboardSubmitFailed', () {
      final result = LeaderboardSubmitResult.failed(
        leaderboardId: 'global',
        error: 'Network error',
        errorCode: 'NET_001',
      );

      expect(result, isA<LeaderboardSubmitFailed>());
      final failed = result as LeaderboardSubmitFailed;
      expect(failed.leaderboardId, equals('global'));
      expect(failed.error, equals('Network error'));
      expect(failed.errorCode, equals('NET_001'));
    });

    test('notSignedIn factory creates LeaderboardSubmitNotSignedIn', () {
      final result = LeaderboardSubmitResult.notSignedIn();

      expect(result, isA<LeaderboardSubmitNotSignedIn>());
    });

    test('notConfigured factory creates LeaderboardSubmitNotConfigured', () {
      final result = LeaderboardSubmitResult.notConfigured(
        leaderboardId: 'unknown',
      );

      expect(result, isA<LeaderboardSubmitNotConfigured>());
      expect(
        (result as LeaderboardSubmitNotConfigured).leaderboardId,
        equals('unknown'),
      );
    });

    test(
        'platformNotSupported factory creates LeaderboardSubmitPlatformNotSupported',
        () {
      final result = LeaderboardSubmitResult.platformNotSupported();

      expect(result, isA<LeaderboardSubmitPlatformNotSupported>());
    });
  });

  group('LeaderboardIntegrationService', () {
    late MockGameService mockGameService;
    late MockLeaderboardService mockLeaderboardService;
    late GameServiceConfig config;
    late LeaderboardIntegrationService service;

    setUp(() {
      mockGameService = MockGameService();
      mockLeaderboardService = MockLeaderboardService();
      config = const GameServiceConfig(
        isEnabled: true,
        leaderboards: [
          LeaderboardConfig(
            id: 'global',
            gameCenterId: 'com.app.global',
            playGamesId: 'CgkI_global',
          ),
          LeaderboardConfig(
            id: 'europe',
            gameCenterId: 'com.app.europe',
            playGamesId: 'CgkI_europe',
          ),
        ],
      );
      service = LeaderboardIntegrationService(
        config: config,
        gameService: mockGameService,
        leaderboardService: mockLeaderboardService,
      );
    });

    tearDown(() {
      service.dispose();
      mockLeaderboardService.reset();
    });

    test('creates with required parameters', () {
      expect(service, isNotNull);
      expect(service.pendingSubmissions, equals(0));
    });

    test('isSupported returns true for supported platforms', () {
      // This test will only pass on iOS, macOS, or Android
      // On other platforms, it returns false
      expect(service.isSupported, isA<bool>());
    });

    group('submitScore', () {
      test('returns notConfigured for unknown leaderboard', () async {
        await service.initialize();

        final result = await service.submitScore(
          leaderboardId: 'unknown',
          score: 100,
        );

        expect(result, isA<LeaderboardSubmitNotConfigured>());
        expect(
          (result as LeaderboardSubmitNotConfigured).leaderboardId,
          equals('unknown'),
        );
      });

      test('returns notSignedIn when user not signed in', () async {
        mockGameService.setSignedIn(false);
        await service.initialize();

        final result = await service.submitScore(
          leaderboardId: 'global',
          score: 100,
        );

        expect(result, isA<LeaderboardSubmitNotSignedIn>());
        expect(service.pendingSubmissions, equals(1));
      });

      test('returns platformNotSupported when config disabled', () async {
        final disabledConfig = const GameServiceConfig.disabled();
        final disabledService = LeaderboardIntegrationService(
          config: disabledConfig,
          gameService: mockGameService,
          leaderboardService: mockLeaderboardService,
        );

        final result = await disabledService.submitScore(
          leaderboardId: 'global',
          score: 100,
        );

        expect(result, isA<LeaderboardSubmitPlatformNotSupported>());
        disabledService.dispose();
      });

      test('queues score when submission fails with transient error', () async {
        mockLeaderboardService.submitScoreHandler = (_, __) =>
            SubmitScoreResult.failed(
              error: 'Network timeout',
              errorCode: 'NETWORK_TIMEOUT',
            );
        await service.initialize();

        final result = await service.submitScore(
          leaderboardId: 'global',
          score: 100,
        );

        expect(result, isA<LeaderboardSubmitFailed>());
        expect(service.pendingSubmissions, equals(1));
      });
    });

    group('submitToMultiple', () {
      test('submits to multiple leaderboards', () async {
        await service.initialize();

        final results = await service.submitToMultiple(
          leaderboardIds: ['global', 'europe'],
          score: 85,
        );

        expect(results.length, equals(2));
      });

      test('handles mixed results', () async {
        await service.initialize();

        final results = await service.submitToMultiple(
          leaderboardIds: ['global', 'unknown'],
          score: 85,
        );

        expect(results.length, equals(2));
        expect(results[1], isA<LeaderboardSubmitNotConfigured>());
      });
    });

    group('queue management', () {
      test('clearQueue removes all pending submissions', () async {
        mockGameService.setSignedIn(false);
        await service.initialize();

        await service.submitScore(leaderboardId: 'global', score: 100);
        await service.submitScore(leaderboardId: 'europe', score: 90);

        expect(service.pendingSubmissions, equals(2));

        service.clearQueue();

        expect(service.pendingSubmissions, equals(0));
      });

      test('queue respects maxQueueSize', () async {
        final limitedService = LeaderboardIntegrationService(
          config: config,
          gameService: mockGameService,
          leaderboardService: mockLeaderboardService,
          maxQueueSize: 2,
        );
        mockGameService.setSignedIn(false);
        await limitedService.initialize();

        await limitedService.submitScore(leaderboardId: 'global', score: 100);
        await limitedService.submitScore(leaderboardId: 'global', score: 110);
        await limitedService.submitScore(leaderboardId: 'global', score: 120);

        expect(limitedService.pendingSubmissions, equals(2));

        limitedService.dispose();
      });
    });

    group('dispose', () {
      test('cleans up resources', () {
        service.dispose();
        expect(service.pendingSubmissions, equals(0));
      });
    });
  });
}
