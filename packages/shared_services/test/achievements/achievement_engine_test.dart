import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock implementation of AchievementRepository for testing.
class MockAchievementRepository implements AchievementRepository {
  final Set<String> _unlockedIds = {};
  final List<UnlockedAchievement> _unlocked = [];
  int unlockCallCount = 0;
  int _idCounter = 0;

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
    unlockCallCount++;
    if (_unlockedIds.contains(achievementId)) {
      return false;
    }
    _unlockedIds.add(achievementId);
    _unlocked.add(UnlockedAchievement.create(
      id: 'mock_${_idCounter++}',
      achievementId: achievementId,
      progress: progress,
    ));
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
    // No-op for tests
  }

  @override
  Future<void> resetAll() async {
    _unlockedIds.clear();
    _unlocked.clear();
  }

  @override
  Stream<UnlockedAchievement> get unlockEvents => const Stream.empty();

  @override
  Future<List<AchievementProgress>> getProgressForAll(
    List<Achievement> definitions,
  ) async {
    return definitions.map((a) {
      final unlocked = _unlocked.firstWhere(
        (u) => u.achievementId == a.id,
        orElse: () => UnlockedAchievement.create(
          id: 'temp',
          achievementId: 'temp',
          progress: 0,
        ),
      );
      if (_unlockedIds.contains(a.id)) {
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

  void addUnlocked(String achievementId) {
    _unlockedIds.add(achievementId);
    _unlocked.add(UnlockedAchievement.create(
      id: 'mock_${_idCounter++}',
      achievementId: achievementId,
      progress: 1,
    ));
  }
}

void main() {
  late AchievementEngine engine;
  late MockAchievementRepository repository;
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

  Achievement createAchievement({
    required String id,
    required AchievementTrigger trigger,
    AchievementTier tier = AchievementTier.common,
  }) {
    return Achievement(
      id: id,
      name: (_) => 'Test Achievement',
      description: (_) => 'Test Description',
      icon: '🏆',
      tier: tier,
      trigger: trigger,
    );
  }

  setUp(() {
    repository = MockAchievementRepository();
    engine = AchievementEngine(repository: repository);
  });

  group('AchievementEngine checkAll', () {
    test('unlocks achievements when triggers are satisfied', () async {
      final achievements = [
        createAchievement(
          id: 'sessions_10',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked.length, 1);
      expect(result.newlyUnlocked.first.id, 'sessions_10');
      expect(result.hasNewUnlocks, isTrue);
    });

    test('does not unlock when trigger is not satisfied', () async {
      final achievements = [
        createAchievement(
          id: 'sessions_100',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked, isEmpty);
      expect(result.stillLocked.length, 1);
      expect(result.hasNewUnlocks, isFalse);
    });

    test('reports already unlocked achievements', () async {
      repository.addUnlocked('already_unlocked');

      final achievements = [
        createAchievement(
          id: 'already_unlocked',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
        ),
      ];
      final context = AchievementContext(globalStats: createStats());

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked, isEmpty);
      expect(result.alreadyUnlocked.length, 1);
      expect(result.alreadyUnlocked.first.id, 'already_unlocked');
    });

    test('calculates points earned from newly unlocked', () async {
      final achievements = [
        createAchievement(
          id: 'a1',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 5,
          ),
          tier: AchievementTier.common, // 10 points
        ),
        createAchievement(
          id: 'a2',
          trigger: AchievementTrigger.streak(target: 5),
          tier: AchievementTier.rare, // 50 points
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10, bestStreak: 7),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked.length, 2);
      expect(result.pointsEarned, 60); // 10 + 50
    });
  });

  group('AchievementEngine checkAfterSession', () {
    test('returns empty result when no session in context', () async {
      final achievements = [
        createAchievement(
          id: 'test',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
        ),
      ];
      final context = AchievementContext(globalStats: createStats());

      final result = await engine.checkAfterSession(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked, isEmpty);
      expect(result.alreadyUnlocked, isEmpty);
      expect(result.stillLocked, isEmpty);
    });

    test('checks achievements when session is present', () async {
      final achievements = [
        createAchievement(
          id: 'sessions_10',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
        ),
      ];
      final session = createSession();
      final context = AchievementContext.afterSession(
        globalStats: createStats(totalSessions: 10),
        session: session,
      );

      final result = await engine.checkAfterSession(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked.length, 1);
    });
  });

  group('AchievementEngine getProgress', () {
    test('returns unlocked progress when already unlocked', () async {
      final unlockedAt = DateTime.now().subtract(const Duration(days: 1));
      final achievement = createAchievement(
        id: 'test',
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalSessions,
          target: 10,
        ),
      );
      final context = AchievementContext(globalStats: createStats());

      final progress = engine.getProgress(
        achievement: achievement,
        context: context,
        unlockedAt: unlockedAt,
      );

      expect(progress.isUnlocked, isTrue);
      expect(progress.percentage, 1.0);
      expect(progress.unlockedAt, unlockedAt);
    });

    test('returns in-progress when not unlocked', () {
      final achievement = createAchievement(
        id: 'test',
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalSessions,
          target: 20,
        ),
      );
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final progress = engine.getProgress(
        achievement: achievement,
        context: context,
      );

      expect(progress.isUnlocked, isFalse);
      expect(progress.currentValue, 10);
      expect(progress.targetValue, 20);
      expect(progress.percentage, 0.5);
    });
  });

  group('AchievementEngine getAllProgress', () {
    test('returns progress for all achievements', () async {
      repository.addUnlocked('unlocked_one');

      final achievements = [
        createAchievement(
          id: 'unlocked_one',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 5,
          ),
        ),
        createAchievement(
          id: 'in_progress',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 20,
          ),
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final progressList = await engine.getAllProgress(
        achievements: achievements,
        context: context,
      );

      expect(progressList.length, 2);

      final unlocked = progressList.firstWhere((p) => p.achievementId == 'unlocked_one');
      expect(unlocked.isUnlocked, isTrue);

      final inProgress = progressList.firstWhere((p) => p.achievementId == 'in_progress');
      expect(inProgress.isUnlocked, isFalse);
      expect(inProgress.percentage, 0.5);
    });
  });

  group('AchievementEngine filterByVisibility', () {
    test('shows non-hidden tiers regardless of progress', () {
      final achievements = [
        createAchievement(
          id: 'common',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
          tier: AchievementTier.common,
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 0),
      );

      final visible = engine.filterByVisibility(
        achievements: achievements,
        context: context,
      );

      expect(visible.length, 1);
    });

    test('hides hidden tier with no progress', () {
      final achievements = [
        createAchievement(
          id: 'legendary',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1000,
          ),
          tier: AchievementTier.legendary,
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 0),
      );

      final visible = engine.filterByVisibility(
        achievements: achievements,
        context: context,
      );

      expect(visible, isEmpty);
    });

    test('shows hidden tier when there is progress', () {
      final achievements = [
        createAchievement(
          id: 'legendary',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1000,
          ),
          tier: AchievementTier.legendary,
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 100),
      );

      final visible = engine.filterByVisibility(
        achievements: achievements,
        context: context,
      );

      expect(visible.length, 1);
    });

    test('shows hidden tier when unlocked', () {
      final achievements = [
        createAchievement(
          id: 'legendary',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
          tier: AchievementTier.legendary,
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 0),
      );

      final visible = engine.filterByVisibility(
        achievements: achievements,
        context: context,
        unlockedIds: {'legendary'},
      );

      expect(visible.length, 1);
    });
  });

  group('AchievementEngine groupByTier', () {
    test('groups achievements by tier', () {
      final achievements = [
        createAchievement(
          id: 'common1',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
          tier: AchievementTier.common,
        ),
        createAchievement(
          id: 'common2',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 20,
          ),
          tier: AchievementTier.common,
        ),
        createAchievement(
          id: 'rare1',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
          tier: AchievementTier.rare,
        ),
      ];

      final grouped = engine.groupByTier(achievements);

      expect(grouped[AchievementTier.common]!.length, 2);
      expect(grouped[AchievementTier.rare]!.length, 1);
      expect(grouped[AchievementTier.uncommon], isEmpty);
    });
  });

  group('AchievementEngine sortForDisplay', () {
    test('unlocked achievements come first', () {
      final achievements = [
        createAchievement(
          id: 'locked',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
        ),
        createAchievement(
          id: 'unlocked',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final sorted = engine.sortForDisplay(
        achievements: achievements,
        context: context,
        unlockedIds: {'unlocked'},
      );

      expect(sorted.first.id, 'unlocked');
    });

    test('higher progress comes before lower progress', () {
      final achievements = [
        createAchievement(
          id: 'low_progress',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
        ),
        createAchievement(
          id: 'high_progress',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 20,
          ),
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final sorted = engine.sortForDisplay(
        achievements: achievements,
        context: context,
      );

      // 10/20 = 50% vs 10/100 = 10%, so high_progress should come first
      expect(sorted.first.id, 'high_progress');
    });
  });

  group('AchievementEngine cache', () {
    test('clearCache resets the unlocked cache', () async {
      final achievements = [
        createAchievement(
          id: 'test',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      // First check
      await engine.checkAll(achievements: achievements, context: context);
      expect(repository.unlockCallCount, 1);

      // Clear cache and check again
      engine.clearCache();

      // Check again
      await engine.checkAll(achievements: achievements, context: context);

      // Should have refreshed cache from repository
      expect(repository.unlockCallCount, 1); // Still 1 because already unlocked
    });
  });

  group('AchievementCheckResult', () {
    test('toString returns meaningful string', () {
      const result = AchievementCheckResult(
        newlyUnlocked: [],
        alreadyUnlocked: [],
        stillLocked: [],
      );

      expect(result.toString(), contains('newlyUnlocked'));
      expect(result.toString(), contains('0'));
    });
  });
}
