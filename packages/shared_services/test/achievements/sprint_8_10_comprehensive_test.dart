import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Comprehensive tests for Sprint 8.10 polish and edge cases.
///
/// Tests cover:
/// - Hidden achievement reveal logic
/// - Points calculation accuracy
/// - Edge cases (empty data, overflow, boundary conditions)

/// Mock repository for testing.
class MockAchievementRepository implements AchievementRepository {
  final Set<String> _unlockedIds = {};
  final List<UnlockedAchievement> _unlocked = [];
  int _idCounter = 0;

  @override
  Future<Set<String>> getUnlockedAchievementIds() async =>
      Set.from(_unlockedIds);

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
  Future<void> markAsNotified(String achievementId) async {}

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
      if (_unlockedIds.contains(a.id)) {
        return AchievementProgress.unlocked(
          achievementId: a.id,
          targetValue: a.progressTarget,
          unlockedAt: DateTime.now(),
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

GlobalStatistics createStats({
  int totalSessions = 0,
  int totalCompletedSessions = 0,
  int totalPerfectScores = 0,
  int bestStreak = 0,
  int currentStreak = 0,
  int totalQuestionsAnswered = 0,
  int totalCorrectAnswers = 0,
  int totalTimePlayedSeconds = 0,
}) {
  final now = DateTime.now();
  return GlobalStatistics(
    totalSessions: totalSessions,
    totalCompletedSessions: totalCompletedSessions,
    totalPerfectScores: totalPerfectScores,
    bestStreak: bestStreak,
    currentStreak: currentStreak,
    totalQuestionsAnswered: totalQuestionsAnswered,
    totalCorrectAnswers: totalCorrectAnswers,
    totalTimePlayedSeconds: totalTimePlayedSeconds,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AchievementEngine engine;
  late MockAchievementRepository repository;

  setUp(() {
    repository = MockAchievementRepository();
    engine = AchievementEngine(repository: repository);
  });

  group('Hidden Achievement Reveal Logic', () {
    test('legendary tier achievements are hidden when no progress', () {
      final achievements = [
        createAchievement(
          id: 'legendary_hidden',
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

    test('legendary tier achievements show when progress > 0', () {
      final achievements = [
        createAchievement(
          id: 'legendary_progress',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1000,
          ),
          tier: AchievementTier.legendary,
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 50),
      );

      final visible = engine.filterByVisibility(
        achievements: achievements,
        context: context,
      );

      expect(visible.length, 1);
    });

    test('legendary tier achievements show when unlocked', () {
      final achievements = [
        createAchievement(
          id: 'legendary_unlocked',
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
        unlockedIds: {'legendary_unlocked'},
      );

      expect(visible.length, 1);
    });

    test('epic tier achievements are hidden when no progress', () {
      final achievements = [
        createAchievement(
          id: 'epic_hidden',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 500,
          ),
          tier: AchievementTier.epic,
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

    test('non-hidden tiers are always visible', () {
      final achievements = [
        createAchievement(
          id: 'common_visible',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
          tier: AchievementTier.common,
        ),
        createAchievement(
          id: 'uncommon_visible',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
          tier: AchievementTier.uncommon,
        ),
        createAchievement(
          id: 'rare_visible',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
          tier: AchievementTier.rare,
        ),
      ];
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 0),
      );

      final visible = engine.filterByVisibility(
        achievements: achievements,
        context: context,
      );

      expect(visible.length, 3);
    });
  });

  group('Points Calculation Accuracy', () {
    test('tier points are correct for each tier', () {
      expect(AchievementTier.common.points, 10);
      expect(AchievementTier.uncommon.points, 25);
      expect(AchievementTier.rare.points, 50);
      expect(AchievementTier.epic.points, 100);
      expect(AchievementTier.legendary.points, 250);
    });

    test('total points calculates correctly for multiple unlocked', () async {
      final achievements = [
        createAchievement(
          id: 'a1',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
          tier: AchievementTier.common, // 10 pts
        ),
        createAchievement(
          id: 'a2',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
          tier: AchievementTier.rare, // 50 pts
        ),
        createAchievement(
          id: 'a3',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
          tier: AchievementTier.legendary, // 250 pts
        ),
      ];

      repository.addUnlocked('a1');
      repository.addUnlocked('a2');
      // a3 is not unlocked

      final total = await repository.getTotalPoints(achievements);
      expect(total, 60); // 10 + 50
    });

    test('check result calculates points earned correctly', () async {
      final achievements = [
        createAchievement(
          id: 'common',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 5,
          ),
          tier: AchievementTier.common, // 10 pts
        ),
        createAchievement(
          id: 'uncommon',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores,
            target: 3,
          ),
          tier: AchievementTier.uncommon, // 25 pts
        ),
        createAchievement(
          id: 'rare',
          trigger: AchievementTrigger.streak(target: 5),
          tier: AchievementTier.rare, // 50 pts
        ),
      ];

      final context = AchievementContext(
        globalStats: createStats(
          totalSessions: 10,
          totalPerfectScores: 5,
          bestStreak: 7,
        ),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      // All three should be unlocked
      expect(result.newlyUnlocked.length, 3);
      expect(result.pointsEarned, 85); // 10 + 25 + 50
    });

    test('zero points when no achievements unlocked', () async {
      final achievements = [
        createAchievement(
          id: 'hard',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1000,
          ),
          tier: AchievementTier.legendary,
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
      expect(result.pointsEarned, 0);
    });

    test('points not double-counted for already unlocked', () async {
      repository.addUnlocked('already_unlocked');

      final achievements = [
        createAchievement(
          id: 'already_unlocked',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
          tier: AchievementTier.legendary, // 250 pts
        ),
        createAchievement(
          id: 'new_unlock',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 5,
          ),
          tier: AchievementTier.common, // 10 pts
        ),
      ];

      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      // Only new_unlock should be in newly unlocked
      expect(result.newlyUnlocked.length, 1);
      expect(result.newlyUnlocked.first.id, 'new_unlock');
      expect(result.pointsEarned, 10); // Only points for new unlock
    });
  });

  group('Edge Cases - Empty Data', () {
    test('handles empty achievement list', () async {
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10),
      );

      final result = await engine.checkAll(
        achievements: [],
        context: context,
      );

      expect(result.newlyUnlocked, isEmpty);
      expect(result.alreadyUnlocked, isEmpty);
      expect(result.stillLocked, isEmpty);
      expect(result.pointsEarned, 0);
      expect(result.hasNewUnlocks, isFalse);
    });

    test('handles zero values in statistics', () async {
      final achievements = [
        createAchievement(
          id: 'first_quiz',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
        ),
      ];

      final context = AchievementContext(
        globalStats: createStats(
          totalSessions: 0,
          totalCompletedSessions: 0,
          totalPerfectScores: 0,
          bestStreak: 0,
        ),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      expect(result.stillLocked.length, 1);
      expect(result.newlyUnlocked, isEmpty);
    });

    test('handles null session in context', () async {
      final achievements = [
        createAchievement(
          id: 'test',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
        ),
      ];

      final context = AchievementContext(
        globalStats: createStats(totalSessions: 1),
      );

      // No session means afterSession should return empty
      final result = await engine.checkAfterSession(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked, isEmpty);
      expect(result.stillLocked, isEmpty);
    });
  });

  group('Edge Cases - Boundary Conditions', () {
    test('unlocks exactly at target value', () async {
      final achievements = [
        createAchievement(
          id: 'exact_target',
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
    });

    test('does not unlock at target minus one', () async {
      final achievements = [
        createAchievement(
          id: 'below_target',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
        ),
      ];

      final context = AchievementContext(
        globalStats: createStats(totalSessions: 9),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      expect(result.stillLocked.length, 1);
      expect(result.newlyUnlocked, isEmpty);
    });

    test('handles large values without overflow', () async {
      final achievements = [
        createAchievement(
          id: 'large_target',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1000000,
          ),
        ),
      ];

      final context = AchievementContext(
        globalStats: createStats(totalSessions: 1000001),
      );

      final result = await engine.checkAll(
        achievements: achievements,
        context: context,
      );

      expect(result.newlyUnlocked.length, 1);
    });

    test('progress percentage handles edge cases', () {
      // Zero target
      final zeroTarget = AchievementProgress.locked(
        achievementId: 'test',
        targetValue: 0,
      );
      expect(zeroTarget.percentage, 0.0);

      // Current exceeds target
      final overTarget = AchievementProgress(
        achievementId: 'test',
        currentValue: 150,
        targetValue: 100,
        isUnlocked: false,
      );
      expect(overTarget.percentage, 1.0);

      // Negative current (should clamp to 0)
      final negative = AchievementProgress(
        achievementId: 'test',
        currentValue: -10,
        targetValue: 100,
        isUnlocked: false,
      );
      expect(negative.percentage, 0.0);
    });

    test('percentageInt rounds correctly at boundaries', () {
      // 49.5% should round to 50%
      final round = AchievementProgress(
        achievementId: 'test',
        currentValue: 495,
        targetValue: 1000,
        isUnlocked: false,
      );
      expect(round.percentageInt, 50);

      // 99.4% should round to 99%
      final high = AchievementProgress(
        achievementId: 'test',
        currentValue: 994,
        targetValue: 1000,
        isUnlocked: false,
      );
      expect(high.percentageInt, 99);

      // 99.5% should round to 100%
      final ceiling = AchievementProgress(
        achievementId: 'test',
        currentValue: 995,
        targetValue: 1000,
        isUnlocked: false,
      );
      expect(ceiling.percentageInt, 100);
    });
  });

  group('Edge Cases - Streak Triggers', () {
    test('streak trigger uses best streak by default', () {
      final trigger = AchievementTrigger.streak(target: 10);
      final streakTrigger = trigger as StreakTrigger;

      expect(streakTrigger.useBestStreak, isTrue);
    });

    test('streak trigger can use current streak', () {
      final trigger = AchievementTrigger.streak(
        target: 10,
        useBestStreak: false,
      );
      final streakTrigger = trigger as StreakTrigger;

      expect(streakTrigger.useBestStreak, isFalse);
    });
  });

  group('Edge Cases - Composite Triggers', () {
    test('composite trigger requires all conditions met', () async {
      final achievements = [
        createAchievement(
          id: 'composite_all',
          trigger: AchievementTrigger.composite(
            triggers: [
              AchievementTrigger.cumulative(
                field: StatField.totalSessions,
                target: 10,
              ),
              AchievementTrigger.cumulative(
                field: StatField.totalPerfectScores,
                target: 5,
              ),
            ],
          ),
        ),
      ];

      // Only sessions met
      final partialContext = AchievementContext(
        globalStats: createStats(totalSessions: 10, totalPerfectScores: 2),
      );

      var result = await engine.checkAll(
        achievements: achievements,
        context: partialContext,
      );

      expect(result.stillLocked.length, 1);

      // Both conditions met
      final fullContext = AchievementContext(
        globalStats: createStats(totalSessions: 10, totalPerfectScores: 5),
      );

      result = await engine.checkAll(
        achievements: achievements,
        context: fullContext,
      );

      expect(result.newlyUnlocked.length, 1);
    });

    test('handles empty composite trigger', () {
      final trigger = AchievementTrigger.composite(triggers: []);
      final compositeTrigger = trigger as CompositeTrigger;

      expect(compositeTrigger.triggers, isEmpty);
    });
  });

  group('Edge Cases - Threshold Triggers', () {
    test('ThresholdTrigger has correct operator enum values', () {
      expect(ThresholdOperator.greaterOrEqual, isNotNull);
      expect(ThresholdOperator.lessOrEqual, isNotNull);
      expect(ThresholdOperator.greaterThan, isNotNull);
      expect(ThresholdOperator.lessThan, isNotNull);
      expect(ThresholdOperator.equal, isNotNull);
    });

    test('ThresholdTrigger creates correctly', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.totalSessions,
        value: 10,
        operator: ThresholdOperator.greaterOrEqual,
      );
      final thresholdTrigger = trigger as ThresholdTrigger;

      expect(thresholdTrigger.field, StatField.totalSessions);
      expect(thresholdTrigger.value, 10);
      expect(thresholdTrigger.operator, ThresholdOperator.greaterOrEqual);
    });

    test('ThresholdTrigger default operator is greaterOrEqual', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.totalSessions,
        value: 10,
      );
      final thresholdTrigger = trigger as ThresholdTrigger;

      expect(thresholdTrigger.operator, ThresholdOperator.greaterOrEqual);
    });
  });

  group('Sorting and Display', () {
    test('unlocked achievements sort before locked', () {
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
            target: 1,
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
      expect(sorted.last.id, 'locked');
    });

    test('higher progress sorts before lower progress', () {
      final achievements = [
        createAchievement(
          id: 'low_progress',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1000,
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

      // 10/20 = 50% vs 10/1000 = 1%, so high_progress should come first
      expect(sorted.first.id, 'high_progress');
    });

    test('groupByTier creates groups for all tiers', () {
      final achievements = [
        createAchievement(
          id: 'common1',
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
          tier: AchievementTier.common,
        ),
      ];

      final grouped = engine.groupByTier(achievements);

      expect(grouped.containsKey(AchievementTier.common), isTrue);
      expect(grouped.containsKey(AchievementTier.uncommon), isTrue);
      expect(grouped.containsKey(AchievementTier.rare), isTrue);
      expect(grouped.containsKey(AchievementTier.epic), isTrue);
      expect(grouped.containsKey(AchievementTier.legendary), isTrue);

      expect(grouped[AchievementTier.common]!.length, 1);
      expect(grouped[AchievementTier.uncommon], isEmpty);
    });
  });
}
