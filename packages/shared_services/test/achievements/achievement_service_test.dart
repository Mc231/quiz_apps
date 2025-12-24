import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock implementation of AchievementRepository for testing.
class MockAchievementRepository implements AchievementRepository {
  final Set<String> _unlockedIds = {};
  final List<UnlockedAchievement> _unlocked = [];
  final _unlockController = StreamController<UnlockedAchievement>.broadcast();
  int _idCounter = 0;

  @override
  Stream<UnlockedAchievement> get unlockEvents => _unlockController.stream;

  @override
  Future<Set<String>> getUnlockedAchievementIds() async => Set.from(_unlockedIds);

  @override
  Future<List<UnlockedAchievement>> getUnlockedAchievements() async =>
      List.from(_unlocked);

  @override
  Future<bool> unlock({
    required String achievementId,
    required int progress,
    required int points,
  }) async {
    if (_unlockedIds.contains(achievementId)) {
      return false;
    }
    _unlockedIds.add(achievementId);
    final unlocked = UnlockedAchievement.create(
      id: 'mock_${_idCounter++}',
      achievementId: achievementId,
      progress: progress,
    );
    _unlocked.add(unlocked);
    _unlockController.add(unlocked);
    return true;
  }

  @override
  Future<bool> isUnlocked(String achievementId) async =>
      _unlockedIds.contains(achievementId);

  @override
  Future<int> getUnlockedCount() async => _unlockedIds.length;

  @override
  Future<int> getTotalPoints(List<Achievement> achievements) async {
    var total = 0;
    for (final a in achievements) {
      if (_unlockedIds.contains(a.id)) {
        total += a.points;
      }
    }
    return total;
  }

  @override
  Future<List<UnlockedAchievement>> getPendingNotifications() async =>
      _unlocked.where((u) => !u.notified).toList();

  @override
  Future<void> markAsNotified(String achievementId) async {
    final index = _unlocked.indexWhere((u) => u.achievementId == achievementId);
    if (index != -1) {
      _unlocked[index] = _unlocked[index].markAsNotified();
    }
  }

  @override
  Future<void> resetAll() async {
    _unlockedIds.clear();
    _unlocked.clear();
  }

  @override
  Future<List<AchievementProgress>> getProgressForAll(
    List<Achievement> definitions,
  ) async {
    return definitions.map((a) {
      if (_unlockedIds.contains(a.id)) {
        final unlocked = _unlocked.firstWhere((u) => u.achievementId == a.id);
        return AchievementProgress.unlocked(
          achievementId: a.id,
          targetValue: a.progressTarget,
          unlockedAt: unlocked.unlockedAt,
        );
      }
      return AchievementProgress.locked(
        achievementId: a.id,
        targetValue: a.progressTarget,
      );
    }).toList();
  }

  void addUnlocked(String achievementId, {bool notified = false}) {
    _unlockedIds.add(achievementId);
    var unlocked = UnlockedAchievement.create(
      id: 'mock_${_idCounter++}',
      achievementId: achievementId,
      progress: 1,
    );
    if (notified) {
      unlocked = unlocked.markAsNotified();
    }
    _unlocked.add(unlocked);
  }

  void dispose() {
    _unlockController.close();
  }
}

/// Minimal mock of StatisticsDataSource for testing.
class MockStatisticsDataSource implements StatisticsDataSource {
  GlobalStatistics _stats;

  MockStatisticsDataSource(this._stats);

  @override
  Future<GlobalStatistics> getGlobalStatistics() async => _stats;

  void setStats(GlobalStatistics stats) {
    _stats = stats;
  }

  @override
  Future<void> incrementQuickAnswersCount([int count = 1]) async {}

  @override
  Future<void> updateAchievementStats({
    required int totalUnlocked,
    required int totalPoints,
  }) async {}

  @override
  Future<void> updateStatistics(GlobalStatistics stats) async {
    _stats = stats;
  }

  // Stub methods - not used in service tests
  @override
  Future<void> deleteQuizTypeStatistics(String quizType, {String? category}) async {}

  @override
  Future<List<QuizTypeStatistics>> getAllQuizTypeStatistics() async => [];

  @override
  Future<DailyStatistics?> getDailyStatistics(DateTime date) async => null;

  @override
  Future<List<DailyStatistics>> getDailyStatisticsRange(DateTime start, DateTime end) async => [];

  @override
  Future<QuizTypeStatistics?> getQuizTypeStatistics(String quizType, {String? category}) async => null;

  @override
  Future<List<DailyStatistics>> getRecentDailyStatistics(int days) async => [];

  @override
  Future<void> recalculateAllStatistics() async {}

  @override
  Future<void> resetGlobalStatistics() async {}

  @override
  Future<void> updateDailyStatisticsForSession(QuizSession session) async {}

  @override
  Future<void> updateGlobalStatisticsForSession(QuizSession session, {bool isNewSession = false}) async {}

  @override
  Future<void> updateQuizTypeStatisticsForSession(QuizSession session) async {}
}

void main() {
  late AchievementService service;
  late MockAchievementRepository repository;
  late MockStatisticsDataSource statsDataSource;
  late AchievementEngine engine;
  final now = DateTime.now();

  GlobalStatistics createStats({
    int totalSessions = 10,
    int totalPerfectScores = 5,
    int bestStreak = 7,
  }) {
    return GlobalStatistics(
      totalSessions: totalSessions,
      totalCompletedSessions: totalSessions,
      totalPerfectScores: totalPerfectScores,
      bestStreak: bestStreak,
      createdAt: now,
      updatedAt: now,
    );
  }

  QuizSession createSession({double scorePercentage = 80.0}) {
    return QuizSession(
      id: 'test-session-1',
      quizName: 'Test Quiz',
      quizId: 'quiz-1',
      quizType: 'flags',
      totalQuestions: 10,
      totalAnswered: 10,
      totalCorrect: (scorePercentage / 10).round(),
      totalFailed: 10 - (scorePercentage / 10).round(),
      totalSkipped: 0,
      scorePercentage: scorePercentage,
      startTime: now.subtract(const Duration(minutes: 5)),
      endTime: now,
      durationSeconds: 300,
      completionStatus: CompletionStatus.completed,
      mode: QuizMode.normal,
      appVersion: '1.0.0',
      createdAt: now,
      updatedAt: now,
    );
  }

  List<Achievement> createTestAchievements() {
    return [
      Achievement(
        id: 'sessions_10',
        name: (_) => 'Quiz Starter',
        description: (_) => 'Complete 10 quiz sessions',
        icon: '🏆',
        tier: AchievementTier.common,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalSessions,
          target: 10,
        ),
      ),
      Achievement(
        id: 'sessions_50',
        name: (_) => 'Quiz Master',
        description: (_) => 'Complete 50 quiz sessions',
        icon: '🏆',
        tier: AchievementTier.uncommon,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalSessions,
          target: 50,
        ),
      ),
      Achievement(
        id: 'streak_7',
        name: (_) => 'Week Warrior',
        description: (_) => 'Achieve a 7-day streak',
        icon: '🔥',
        tier: AchievementTier.rare,
        trigger: AchievementTrigger.streak(target: 7),
      ),
    ];
  }

  setUp(() {
    repository = MockAchievementRepository();
    statsDataSource = MockStatisticsDataSource(createStats());
    engine = AchievementEngine(repository: repository);
    service = AchievementService(
      repository: repository,
      statisticsDataSource: statsDataSource,
      engine: engine,
    );
  });

  tearDown(() {
    service.dispose();
    repository.dispose();
  });

  group('AchievementService initialization', () {
    test('initialize sets achievement definitions', () {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final byTier = service.getAchievementsByTier();
      expect(byTier[AchievementTier.common]!.length, 1);
      expect(byTier[AchievementTier.uncommon]!.length, 1);
      expect(byTier[AchievementTier.rare]!.length, 1);
    });
  });

  group('AchievementService checkAfterSession', () {
    test('returns empty list when not initialized', () async {
      final session = createSession();
      final result = await service.checkAfterSession(session);

      expect(result, isEmpty);
    });

    test('returns newly unlocked achievements', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final session = createSession();
      final result = await service.checkAfterSession(session);

      // sessions_10 and streak_7 should be unlocked
      expect(result.length, 2);
      expect(result.map((a) => a.id), containsAll(['sessions_10', 'streak_7']));
    });

    test('emits unlock events to stream', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final unlocked = <List<Achievement>>[];
      service.onAchievementsUnlocked.listen(unlocked.add);

      final session = createSession();
      await service.checkAfterSession(session);

      await Future.delayed(Duration.zero); // Allow stream to emit
      expect(unlocked.length, 1);
      expect(unlocked.first.length, 2);
    });
  });

  group('AchievementService checkAll', () {
    test('returns empty list when not initialized', () async {
      final result = await service.checkAll();
      expect(result, isEmpty);
    });

    test('checks all achievements', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final result = await service.checkAll();

      // sessions_10 and streak_7 should be unlocked
      expect(result.length, 2);
    });
  });

  group('AchievementService progress', () {
    test('getAllProgress returns empty list when not initialized', () async {
      final result = await service.getAllProgress();
      expect(result, isEmpty);
    });

    test('getAllProgress returns progress for all achievements', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final progress = await service.getAllProgress();

      expect(progress.length, 3);
    });

    test('getProgress returns progress for specific achievement', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final progress = await service.getProgress('sessions_50');

      expect(progress.achievementId, 'sessions_50');
      expect(progress.currentValue, 10);
      expect(progress.targetValue, 50);
      expect(progress.percentage, 0.2);
    });

    test('getProgress throws for unknown achievement', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      expect(
        () => service.getProgress('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('AchievementService visibility and sorting', () {
    test('getVisibleAchievements returns empty list when not initialized', () async {
      final result = await service.getVisibleAchievements();
      expect(result, isEmpty);
    });

    test('getVisibleAchievements filters hidden achievements', () async {
      // Use stats with 0 sessions so legendary has no progress
      statsDataSource.setStats(createStats(totalSessions: 0, bestStreak: 0));

      final achievements = [
        ...createTestAchievements(),
        Achievement(
          id: 'legendary_hidden',
          name: (_) => 'Legend',
          description: (_) => 'Hidden achievement',
          icon: '💎',
          tier: AchievementTier.legendary,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1000,
          ),
        ),
      ];
      service.initialize(achievements);

      final visible = await service.getVisibleAchievements();

      // Legendary with no progress should be hidden
      expect(visible.any((a) => a.id == 'legendary_hidden'), isFalse);
    });

    test('getSortedAchievements returns empty list when not initialized', () async {
      final result = await service.getSortedAchievements();
      expect(result, isEmpty);
    });

    test('getSortedAchievements returns sorted achievements', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final sorted = await service.getSortedAchievements();

      expect(sorted.length, 3);
    });
  });

  group('AchievementService summary', () {
    test('getSummary returns correct statistics', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);
      repository.addUnlocked('sessions_10');

      final summary = await service.getSummary();

      expect(summary.totalAchievements, 3);
      expect(summary.unlockedAchievements, 1);
      expect(summary.totalPoints, 10); // common tier = 10 points
      expect(summary.maxPoints, 85); // 10 + 25 + 50
      expect(summary.completionPercentage, closeTo(0.333, 0.01));
    });
  });

  group('AchievementService unlock queries', () {
    test('isUnlocked returns correct status', () async {
      repository.addUnlocked('test_achievement');

      expect(await service.isUnlocked('test_achievement'), isTrue);
      expect(await service.isUnlocked('unknown'), isFalse);
    });

    test('getUnlockedCount returns correct count', () async {
      repository.addUnlocked('a1');
      repository.addUnlocked('a2');

      expect(await service.getUnlockedCount(), 2);
    });

    test('getTotalPoints returns sum of points', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);
      repository.addUnlocked('sessions_10');
      repository.addUnlocked('streak_7');

      expect(await service.getTotalPoints(), 60); // 10 + 50
    });
  });

  group('AchievementService notifications', () {
    test('getPendingNotifications returns unnotified achievements', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);
      repository.addUnlocked('sessions_10', notified: false);
      repository.addUnlocked('streak_7', notified: true);

      final pending = await service.getPendingNotifications();

      expect(pending.length, 1);
      expect(pending.first.id, 'sessions_10');
    });

    test('markNotificationShown marks single notification', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);
      repository.addUnlocked('sessions_10', notified: false);

      await service.markNotificationShown('sessions_10');

      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });

    test('markAllNotificationsShown marks multiple notifications', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);
      repository.addUnlocked('sessions_10', notified: false);
      repository.addUnlocked('streak_7', notified: false);

      await service.markAllNotificationsShown(['sessions_10', 'streak_7']);

      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });
  });

  group('AchievementService reset', () {
    test('resetAll clears all progress', () async {
      repository.addUnlocked('test');

      await service.resetAll();

      expect(await service.getUnlockedCount(), 0);
    });
  });

  group('AchievementService data providers', () {
    test('uses categoryDataProvider when set', () async {
      final achievements = [
        Achievement(
          id: 'europe_master',
          name: (_) => 'Europe Master',
          description: (_) => 'Complete Europe category 5 times',
          icon: '🌍',
          tier: AchievementTier.rare,
          trigger: AchievementTrigger.category(
            categoryId: 'europe',
            requiredCount: 5,
          ),
        ),
      ];
      service.initialize(achievements);
      service.categoryDataProvider = () => {
        'europe': const CategoryCompletionData(
          categoryId: 'europe',
          totalCompletions: 5,
        ),
      };

      final result = await service.checkAll();

      expect(result.length, 1);
      expect(result.first.id, 'europe_master');
    });

    test('uses challengeDataProvider when set', () async {
      final achievements = [
        Achievement(
          id: 'survival_champion',
          name: (_) => 'Survival Champion',
          description: (_) => 'Complete survival challenge',
          icon: '💪',
          tier: AchievementTier.rare,
          trigger: AchievementTrigger.challenge(challengeId: 'survival'),
        ),
      ];
      service.initialize(achievements);
      service.challengeDataProvider = () => {
        'survival': const ChallengeCompletionData(
          challengeId: 'survival',
          totalCompletions: 1,
        ),
      };

      final result = await service.checkAll();

      expect(result.length, 1);
      expect(result.first.id, 'survival_champion');
    });
  });

  group('AchievementService streams', () {
    test('onUnlockEvent forwards repository unlock events', () async {
      final events = <UnlockedAchievement>[];
      service.onUnlockEvent.listen(events.add);

      await repository.unlock(
        achievementId: 'test',
        progress: 1,
        points: 10,
      );

      await Future.delayed(Duration.zero);
      expect(events.length, 1);
      expect(events.first.achievementId, 'test');
    });
  });

  group('AchievementSummary', () {
    test('completionPercentage handles zero achievements', () {
      const summary = AchievementSummary(
        totalAchievements: 0,
        unlockedAchievements: 0,
        totalPoints: 0,
        maxPoints: 0,
      );

      expect(summary.completionPercentage, 0.0);
    });

    test('pointsPercentage handles zero max points', () {
      const summary = AchievementSummary(
        totalAchievements: 0,
        unlockedAchievements: 0,
        totalPoints: 0,
        maxPoints: 0,
      );

      expect(summary.pointsPercentage, 0.0);
    });

    test('toString returns meaningful string', () {
      const summary = AchievementSummary(
        totalAchievements: 10,
        unlockedAchievements: 5,
        totalPoints: 100,
        maxPoints: 200,
      );

      expect(summary.toString(), contains('5/10'));
      expect(summary.toString(), contains('100/200'));
    });
  });
}
