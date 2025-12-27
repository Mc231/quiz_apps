import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

import '../analytics/composite_analytics_service_test.dart';
import 'achievement_service_test.dart';

void main() {
  late AchievementService service;
  late MockAchievementRepository repository;
  late MockStatisticsDataSource statsDataSource;
  late AchievementEngine engine;
  late MockAnalyticsService analyticsService;
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

  QuizSession createSession({
    String id = 'test-session-1',
    double scorePercentage = 80.0,
  }) {
    return QuizSession(
      id: id,
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
        id: 'streak_7',
        name: (_) => 'Week Warrior',
        description: (_) => 'Achieve a 7-day streak',
        icon: '🔥',
        tier: AchievementTier.rare,
        trigger: AchievementTrigger.streak(target: 7),
      ),
    ];
  }

  setUp(() async {
    repository = MockAchievementRepository();
    statsDataSource = MockStatisticsDataSource(createStats());
    engine = AchievementEngine(repository: repository);
    analyticsService = MockAnalyticsService();
    await analyticsService.initialize();
    service = AchievementService(
      repository: repository,
      statisticsDataSource: statsDataSource,
      engine: engine,
      analyticsService: analyticsService,
    );
  });

  tearDown(() {
    service.dispose();
    repository.dispose();
  });

  group('AchievementService Analytics Integration', () {
    test('tracks achievement unlock event when unlocked', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      final session = createSession();
      await service.checkAfterSession(session);

      // Two achievements should be unlocked: sessions_10 and streak_7
      final events = analyticsService.loggedEvents
          .whereType<AchievementEvent>()
          .toList();
      expect(events.length, 2);

      // Verify sessions_10 event
      final sessionsEvent = events.firstWhere(
        (e) => e.parameters['achievement_id'] == 'sessions_10',
      );
      expect(sessionsEvent.eventName, 'achievement_unlocked');
      expect(sessionsEvent.parameters['achievement_name'], 'sessions_10');
      expect(sessionsEvent.parameters['achievement_category'], 'common');
      expect(sessionsEvent.parameters['points_awarded'], 10);
      expect(sessionsEvent.parameters['total_points'], 60); // 10 + 50
      expect(sessionsEvent.parameters['unlocked_count'], 2);
      expect(sessionsEvent.parameters['total_achievements'], 2);
      expect(sessionsEvent.parameters['trigger_quiz_id'], 'test-session-1');

      // Verify streak_7 event
      final streakEvent = events.firstWhere(
        (e) => e.parameters['achievement_id'] == 'streak_7',
      );
      expect(streakEvent.eventName, 'achievement_unlocked');
      expect(streakEvent.parameters['achievement_name'], 'streak_7');
      expect(streakEvent.parameters['achievement_category'], 'rare');
      expect(streakEvent.parameters['points_awarded'], 50);
    });

    test('tracks all achievements unlocked via checkAll', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      await service.checkAll();

      final events = analyticsService.loggedEvents
          .whereType<AchievementEvent>()
          .toList();
      expect(events.length, 2);

      // Verify trigger_quiz_id is null for checkAll
      for (final event in events) {
        expect(event.parameters.containsKey('trigger_quiz_id'), false);
      }
    });

    test('does not track when no achievements are unlocked', () async {
      final achievements = [
        Achievement(
          id: 'sessions_100',
          name: (_) => 'Century',
          description: (_) => 'Complete 100 sessions',
          icon: '💯',
          tier: AchievementTier.epic,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 100,
          ),
        ),
      ];
      service.initialize(achievements);

      final session = createSession();
      await service.checkAfterSession(session);

      // No achievements should be unlocked (only 10 sessions)
      expect(analyticsService.loggedEvents, isEmpty);
    });

    test('does not track when analytics service is null', () async {
      // Create service without analytics
      final serviceWithoutAnalytics = AchievementService(
        repository: repository,
        statisticsDataSource: statsDataSource,
        engine: engine,
        analyticsService: NoOpAnalyticsService(),
      );

      final achievements = createTestAchievements();
      serviceWithoutAnalytics.initialize(achievements);

      final session = createSession();
      await serviceWithoutAnalytics.checkAfterSession(session);

      // Verify no events logged (service doesn't have analytics)
      expect(analyticsService.loggedEvents, isEmpty);

      serviceWithoutAnalytics.dispose();
    });

    test('tracks correct tier names for all tiers', () async {
      final achievements = [
        Achievement(
          id: 'common',
          name: (_) => 'Common',
          description: (_) => 'Common achievement',
          icon: '🥉',
          tier: AchievementTier.common,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 1,
          ),
        ),
        Achievement(
          id: 'uncommon',
          name: (_) => 'Uncommon',
          description: (_) => 'Uncommon achievement',
          icon: '🥈',
          tier: AchievementTier.uncommon,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 2,
          ),
        ),
        Achievement(
          id: 'rare',
          name: (_) => 'Rare',
          description: (_) => 'Rare achievement',
          icon: '🥇',
          tier: AchievementTier.rare,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 3,
          ),
        ),
        Achievement(
          id: 'epic',
          name: (_) => 'Epic',
          description: (_) => 'Epic achievement',
          icon: '🏆',
          tier: AchievementTier.epic,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 4,
          ),
        ),
        Achievement(
          id: 'legendary',
          name: (_) => 'Legendary',
          description: (_) => 'Legendary achievement',
          icon: '👑',
          tier: AchievementTier.legendary,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 5,
          ),
        ),
      ];
      service.initialize(achievements);

      await service.checkAll();

      final events = analyticsService.loggedEvents
          .whereType<AchievementEvent>()
          .toList();
      expect(events.length, 5);

      expect(events[0].parameters['achievement_category'], 'common');
      expect(events[1].parameters['achievement_category'], 'uncommon');
      expect(events[2].parameters['achievement_category'], 'rare');
      expect(events[3].parameters['achievement_category'], 'epic');
      expect(events[4].parameters['achievement_category'], 'legendary');
    });

    test('tracks multiple unlock sessions correctly', () async {
      final achievements = [
        Achievement(
          id: 'sessions_10',
          name: (_) => 'First 10',
          description: (_) => 'Complete 10 sessions',
          icon: '🎯',
          tier: AchievementTier.common,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
        ),
        Achievement(
          id: 'sessions_20',
          name: (_) => 'First 20',
          description: (_) => 'Complete 20 sessions',
          icon: '🎯',
          tier: AchievementTier.uncommon,
          trigger: AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 20,
          ),
        ),
      ];
      service.initialize(achievements);

      // First session - unlocks sessions_10
      final session1 = createSession(id: 'session-1');
      await service.checkAfterSession(session1);

      expect(analyticsService.loggedEvents.length, 1);
      expect(
        analyticsService.loggedEvents[0].parameters['achievement_id'],
        'sessions_10',
      );

      analyticsService.reset();

      // Update stats to 20 sessions
      statsDataSource.setStats(createStats(totalSessions: 20, bestStreak: 0));

      // Second check - unlocks sessions_20
      final session2 = createSession(id: 'session-2');
      await service.checkAfterSession(session2);

      expect(analyticsService.loggedEvents.length, 1);
      expect(
        analyticsService.loggedEvents[0].parameters['achievement_id'],
        'sessions_20',
      );
      expect(
        analyticsService.loggedEvents[0].parameters['trigger_quiz_id'],
        'session-2',
      );
    });

    test('tracks achievement unlocks with correct point totals', () async {
      final achievements = createTestAchievements();
      service.initialize(achievements);

      // Unlock first achievement
      await service.checkAfterSession(createSession());

      final events = analyticsService.loggedEvents
          .whereType<AchievementEvent>()
          .toList();

      // Both achievements unlock (common: 10 points, rare: 50 points)
      expect(events.length, 2);

      // Total points should be cumulative
      final totalPoints = events.first.parameters['total_points'] as int;
      expect(totalPoints, 60); // 10 + 50
    });
  });
}
