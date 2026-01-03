import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock GameService for testing.
class MockGameService implements GameService {
  bool _isSignedIn = true;

  void setSignedIn(bool value) {
    _isSignedIn = value;
  }

  @override
  Future<bool> isSignedIn() async => _isSignedIn;

  @override
  Future<String?> getPlayerId() async => 'player123';

  @override
  Future<String?> getPlayerDisplayName() async => 'Test User';

  @override
  Future<PlayerInfo?> getPlayerInfo() async => _isSignedIn
      ? const PlayerInfo(playerId: 'player123', displayName: 'Test User')
      : null;

  @override
  Future<SignInResult> signIn() async =>
      SignInResult.success(playerId: 'player123', displayName: 'Test User');

  @override
  Future<void> signOut() async {}

  @override
  Future<Uint8List?> getPlayerAvatar() async => null;
}

/// Mock CloudAchievementService for testing.
class MockCloudAchievementService implements CloudAchievementService {
  final List<String> unlockedAchievements = [];
  final Map<String, int> achievementProgress = {};
  UnlockAchievementResult Function(String)? unlockHandler;
  IncrementAchievementResult Function(String, int)? progressHandler;

  void reset() {
    unlockedAchievements.clear();
    achievementProgress.clear();
    unlockHandler = null;
    progressHandler = null;
  }

  @override
  Future<UnlockAchievementResult> unlockAchievement(
    String achievementId,
  ) async {
    if (unlockHandler != null) {
      return unlockHandler!(achievementId);
    }
    unlockedAchievements.add(achievementId);
    return UnlockAchievementResult.success();
  }

  @override
  Future<IncrementAchievementResult> incrementAchievement(
    String achievementId, {
    int steps = 1,
  }) async {
    achievementProgress[achievementId] =
        (achievementProgress[achievementId] ?? 0) + steps;
    return IncrementAchievementResult.success(
      currentSteps: achievementProgress[achievementId]!,
      totalSteps: 100,
      isUnlocked: achievementProgress[achievementId]! >= 100,
    );
  }

  @override
  Future<IncrementAchievementResult> setAchievementProgress(
    String achievementId, {
    required int steps,
  }) async {
    if (progressHandler != null) {
      return progressHandler!(achievementId, steps);
    }
    achievementProgress[achievementId] = steps;
    return IncrementAchievementResult.success(
      currentSteps: steps,
      totalSteps: 100,
      isUnlocked: steps >= 100,
    );
  }

  @override
  Future<List<CloudAchievementInfo>> getAchievements() async => [];

  @override
  Future<CloudAchievementInfo?> getAchievement(String achievementId) async =>
      null;

  @override
  Future<bool> showAchievements() async => true;

  @override
  Future<bool> revealAchievement(String achievementId) async => true;
}

/// Mock AchievementService for testing.
class MockAchievementService {
  final _unlockController = StreamController<List<Achievement>>.broadcast();

  Stream<List<Achievement>> get onAchievementsUnlocked =>
      _unlockController.stream;

  final List<AchievementProgress> _progress = [];

  void setProgress(List<AchievementProgress> progress) {
    _progress.clear();
    _progress.addAll(progress);
  }

  Future<List<AchievementProgress>> getAllProgress() async => _progress;

  void emitUnlock(List<Achievement> achievements) {
    _unlockController.add(achievements);
  }

  void dispose() {
    _unlockController.close();
  }
}

void main() {
  group('AchievementSyncResult', () {
    test('success factory creates AchievementSyncSuccess', () {
      final result = AchievementSyncResult.success(
        achievementId: 'first_quiz',
        wasAlreadyUnlocked: false,
      );

      expect(result, isA<AchievementSyncSuccess>());
      final success = result as AchievementSyncSuccess;
      expect(success.achievementId, equals('first_quiz'));
      expect(success.wasAlreadyUnlocked, isFalse);
    });

    test('failed factory creates AchievementSyncFailed', () {
      final result = AchievementSyncResult.failed(
        achievementId: 'first_quiz',
        error: 'Network error',
        errorCode: 'NET_001',
      );

      expect(result, isA<AchievementSyncFailed>());
      final failed = result as AchievementSyncFailed;
      expect(failed.achievementId, equals('first_quiz'));
      expect(failed.error, equals('Network error'));
      expect(failed.errorCode, equals('NET_001'));
    });

    test('notMapped factory creates AchievementSyncNotMapped', () {
      final result = AchievementSyncResult.notMapped(
        achievementId: 'unknown',
      );

      expect(result, isA<AchievementSyncNotMapped>());
      expect(
        (result as AchievementSyncNotMapped).achievementId,
        equals('unknown'),
      );
    });

    test('notSignedIn factory creates AchievementSyncNotSignedIn', () {
      final result = AchievementSyncResult.notSignedIn();

      expect(result, isA<AchievementSyncNotSignedIn>());
    });

    test(
        'platformNotSupported factory creates AchievementSyncPlatformNotSupported',
        () {
      final result = AchievementSyncResult.platformNotSupported();

      expect(result, isA<AchievementSyncPlatformNotSupported>());
    });
  });

  group('AchievementSyncService - syncAchievement', () {
    late MockGameService mockGameService;
    late MockCloudAchievementService mockCloudService;
    late MockAchievementService mockAchievementService;
    late GameServiceConfig config;

    setUp(() {
      mockGameService = MockGameService();
      mockCloudService = MockCloudAchievementService();
      mockAchievementService = MockAchievementService();
      config = const GameServiceConfig(
        isEnabled: true,
        achievementIdMap: {
          'first_quiz': 'com.app.first_quiz',
          'perfect_10': 'com.app.perfect_10',
        },
      );
    });

    tearDown(() {
      mockCloudService.reset();
      mockAchievementService.dispose();
    });

    test('returns notMapped for unmapped achievement', () async {
      // Create a minimal mock that satisfies the service
      // Since AchievementService is complex, we test the config lookup directly
      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      final result = await syncService.syncAchievement('unknown_achievement');

      expect(result, isA<AchievementSyncNotMapped>());
      syncService.dispose();
    });

    test('returns notSignedIn when user not signed in', () async {
      mockGameService.setSignedIn(false);
      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      final result = await syncService.syncAchievement('first_quiz');

      expect(result, isA<AchievementSyncNotSignedIn>());
      expect(syncService.pendingSyncs, equals(1));
      syncService.dispose();
    });

    test('returns platformNotSupported when config disabled', () async {
      final disabledConfig = const GameServiceConfig.disabled();
      final syncService = _createSyncService(
        config: disabledConfig,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      final result = await syncService.syncAchievement('first_quiz');

      expect(result, isA<AchievementSyncPlatformNotSupported>());
      syncService.dispose();
    });

    test('queues achievement when sync fails with transient error', () async {
      mockCloudService.unlockHandler = (_) => UnlockAchievementResult.failed(
            error: 'Network timeout',
            errorCode: 'NETWORK_TIMEOUT',
          );

      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      final result = await syncService.syncAchievement('first_quiz');

      expect(result, isA<AchievementSyncFailed>());
      expect(syncService.pendingSyncs, equals(1));
      syncService.dispose();
    });

    test('does not queue for non-transient errors', () async {
      mockCloudService.unlockHandler =
          (_) => UnlockAchievementResult.notFound();

      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      final result = await syncService.syncAchievement('first_quiz');

      expect(result, isA<AchievementSyncFailed>());
      expect(syncService.pendingSyncs, equals(0));
      syncService.dispose();
    });
  });

  group('AchievementSyncService - reportProgress', () {
    late MockGameService mockGameService;
    late MockCloudAchievementService mockCloudService;
    late GameServiceConfig config;

    setUp(() {
      mockGameService = MockGameService();
      mockCloudService = MockCloudAchievementService();
      config = const GameServiceConfig(
        isEnabled: true,
        achievementIdMap: {
          'quizzes_10': 'com.app.quizzes_10',
        },
      );
    });

    tearDown(() {
      mockCloudService.reset();
    });

    test('reports progress successfully', () async {
      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      final result = await syncService.reportProgress(
        achievementId: 'quizzes_10',
        currentProgress: 5,
        totalRequired: 10,
      );

      expect(result, isA<AchievementSyncSuccess>());
      expect(mockCloudService.achievementProgress['com.app.quizzes_10'],
          equals(5));
      syncService.dispose();
    });

    test('returns notMapped for unmapped achievement', () async {
      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      final result = await syncService.reportProgress(
        achievementId: 'unknown',
        currentProgress: 5,
        totalRequired: 10,
      );

      expect(result, isA<AchievementSyncNotMapped>());
      syncService.dispose();
    });
  });

  group('AchievementSyncService - queue management', () {
    late MockGameService mockGameService;
    late MockCloudAchievementService mockCloudService;
    late GameServiceConfig config;

    setUp(() {
      mockGameService = MockGameService();
      mockCloudService = MockCloudAchievementService();
      config = const GameServiceConfig(
        isEnabled: true,
        achievementIdMap: {
          'first_quiz': 'com.app.first_quiz',
          'perfect_10': 'com.app.perfect_10',
        },
      );
    });

    tearDown(() {
      mockCloudService.reset();
    });

    test('clearQueue removes all pending syncs', () async {
      mockGameService.setSignedIn(false);

      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      await syncService.syncAchievement('first_quiz');
      await syncService.syncAchievement('perfect_10');

      expect(syncService.pendingSyncs, equals(2));

      syncService.clearQueue();

      expect(syncService.pendingSyncs, equals(0));
      syncService.dispose();
    });

    test('queue respects maxQueueSize', () async {
      mockGameService.setSignedIn(false);

      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
        maxQueueSize: 1,
      );

      await syncService.syncAchievement('first_quiz');
      await syncService.syncAchievement('perfect_10');

      // Queue should only have 1 item (most recent)
      expect(syncService.pendingSyncs, equals(1));
      syncService.dispose();
    });

    test('queue deduplicates same achievement', () async {
      mockGameService.setSignedIn(false);

      final syncService = _createSyncService(
        config: config,
        gameService: mockGameService,
        cloudService: mockCloudService,
      );

      await syncService.syncAchievement('first_quiz');
      await syncService.syncAchievement('first_quiz');
      await syncService.syncAchievement('first_quiz');

      // Should only queue once per achievement
      expect(syncService.pendingSyncs, equals(1));
      syncService.dispose();
    });
  });

  group('AchievementSyncService - dispose', () {
    test('cleans up resources', () {
      final syncService = _createSyncService(
        config: const GameServiceConfig(isEnabled: true),
        gameService: MockGameService(),
        cloudService: MockCloudAchievementService(),
      );

      syncService.dispose();
      expect(syncService.pendingSyncs, equals(0));
    });
  });
}

/// Helper to create a sync service with a minimal mock AchievementService.
AchievementSyncService _createSyncService({
  required GameServiceConfig config,
  required GameService gameService,
  required CloudAchievementService cloudService,
  int maxQueueSize = 100,
}) {
  // Create a minimal mock AchievementService
  final mockAchievementService = _MinimalMockAchievementService();

  return AchievementSyncService(
    config: config,
    gameService: gameService,
    cloudAchievementService: cloudService,
    achievementService: mockAchievementService,
    maxQueueSize: maxQueueSize,
  );
}

/// Minimal mock that satisfies AchievementService interface.
class _MinimalMockAchievementService implements AchievementService {
  final _unlockController = StreamController<List<Achievement>>.broadcast();

  @override
  Stream<List<Achievement>> get onAchievementsUnlocked =>
      _unlockController.stream;

  @override
  Stream<UnlockedAchievement> get onUnlockEvent =>
      const Stream<UnlockedAchievement>.empty();

  @override
  void initialize(List<Achievement> achievements) {}

  @override
  Future<List<Achievement>> checkAfterSession(QuizSession session) async => [];

  @override
  Future<List<Achievement>> checkAll() async => [];

  @override
  Future<List<AchievementProgress>> getAllProgress() async => [];

  @override
  Future<AchievementProgress> getProgress(String achievementId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Achievement>> getVisibleAchievements() async => [];

  @override
  Future<List<Achievement>> getSortedAchievements() async => [];

  @override
  Map<AchievementTier, List<Achievement>> getAchievementsByTier() => {};

  @override
  Future<List<Achievement>> getPendingNotifications() async => [];

  @override
  Future<void> markNotificationShown(String achievementId) async {}

  @override
  Future<void> markAllNotificationsShown(List<String> achievementIds) async {}

  @override
  Future<AchievementSummary> getSummary() async {
    return const AchievementSummary(
      totalAchievements: 0,
      unlockedAchievements: 0,
      totalPoints: 0,
      maxPoints: 0,
    );
  }

  @override
  Future<bool> isUnlocked(String achievementId) async => false;

  @override
  Future<int> getUnlockedCount() async => 0;

  @override
  Future<int> getTotalPoints() async => 0;

  @override
  Future<void> resetAll() async {}

  @override
  void dispose() {
    _unlockController.close();
  }

  @override
  CategoryDataProvider? categoryDataProvider;

  @override
  ChallengeDataProvider? challengeDataProvider;

  @override
  AnalyticsService get analyticsService => NoOpAnalyticsService();
}
