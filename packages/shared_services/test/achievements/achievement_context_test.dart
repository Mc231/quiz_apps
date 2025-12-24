import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  final now = DateTime.now();

  GlobalStatistics createStats({
    int totalSessions = 10,
    int totalPerfectScores = 5,
    int bestStreak = 7,
    int currentStreak = 3,
  }) {
    return GlobalStatistics(
      totalSessions: totalSessions,
      totalCompletedSessions: totalSessions,
      totalPerfectScores: totalPerfectScores,
      bestStreak: bestStreak,
      currentStreak: currentStreak,
      createdAt: now,
      updatedAt: now,
    );
  }

  QuizSession createSession({
    double scorePercentage = 80.0,
    int totalCorrect = 8,
    int totalFailed = 2,
    int hintsUsed5050 = 0,
    int hintsUsedSkip = 0,
  }) {
    return QuizSession(
      id: 'test-session-1',
      quizName: 'Test Quiz',
      quizId: 'quiz-1',
      quizType: 'flags',
      totalQuestions: 10,
      totalAnswered: 10,
      totalCorrect: totalCorrect,
      totalFailed: totalFailed,
      totalSkipped: 0,
      scorePercentage: scorePercentage,
      hintsUsed5050: hintsUsed5050,
      hintsUsedSkip: hintsUsedSkip,
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

  group('AchievementContext', () {
    test('creates with required fields', () {
      final stats = createStats();
      final context = AchievementContext(globalStats: stats);

      expect(context.globalStats, stats);
      expect(context.session, isNull);
      expect(context.categoryData, isEmpty);
      expect(context.challengeData, isEmpty);
    });

    test('hasSession returns false when no session', () {
      final stats = createStats();
      final context = AchievementContext(globalStats: stats);

      expect(context.hasSession, isFalse);
    });

    test('hasSession returns true when session present', () {
      final stats = createStats();
      final session = createSession();
      final context = AchievementContext(
        globalStats: stats,
        session: session,
      );

      expect(context.hasSession, isTrue);
    });
  });

  group('AchievementContext.afterSession', () {
    test('creates context with session', () {
      final stats = createStats();
      final session = createSession();

      final context = AchievementContext.afterSession(
        globalStats: stats,
        session: session,
      );

      expect(context.globalStats, stats);
      expect(context.session, session);
      expect(context.hasSession, isTrue);
    });

    test('sessionCompleted returns true for completed session', () {
      final stats = createStats();
      final session = createSession();

      final context = AchievementContext.afterSession(
        globalStats: stats,
        session: session,
      );

      expect(context.sessionCompleted, isTrue);
    });

    test('sessionPerfect returns true for 100% score', () {
      final stats = createStats();
      final session = createSession(
        scorePercentage: 100.0,
        totalCorrect: 10,
        totalFailed: 0,
      );

      final context = AchievementContext.afterSession(
        globalStats: stats,
        session: session,
      );

      expect(context.sessionPerfect, isTrue);
    });

    test('sessionNoHints returns true when no hints used', () {
      final stats = createStats();
      final session = createSession(
        hintsUsed5050: 0,
        hintsUsedSkip: 0,
      );

      final context = AchievementContext.afterSession(
        globalStats: stats,
        session: session,
      );

      expect(context.sessionNoHints, isTrue);
    });

    test('sessionNoHints returns false when hints used', () {
      final stats = createStats();
      final session = createSession(
        hintsUsed5050: 2,
      );

      final context = AchievementContext.afterSession(
        globalStats: stats,
        session: session,
      );

      expect(context.sessionNoHints, isFalse);
    });
  });

  group('AchievementContext.forProgress', () {
    test('creates context without session', () {
      final stats = createStats();

      final context = AchievementContext.forProgress(globalStats: stats);

      expect(context.globalStats, stats);
      expect(context.session, isNull);
      expect(context.hasSession, isFalse);
    });
  });

  group('CategoryCompletionData', () {
    test('getCategoryData returns data for known category', () {
      final stats = createStats();
      final categoryData = {
        'europe': const CategoryCompletionData(
          categoryId: 'europe',
          totalCompletions: 5,
          perfectCompletions: 2,
        ),
      };

      final context = AchievementContext(
        globalStats: stats,
        categoryData: categoryData,
      );

      final data = context.getCategoryData('europe');
      expect(data, isNotNull);
      expect(data!.totalCompletions, 5);
      expect(data.perfectCompletions, 2);
    });

    test('getCategoryData returns null for unknown category', () {
      final stats = createStats();
      final context = AchievementContext(globalStats: stats);

      expect(context.getCategoryData('unknown'), isNull);
    });
  });

  group('ChallengeCompletionData', () {
    test('getChallengeData returns data for known challenge', () {
      final stats = createStats();
      final challengeData = {
        'survival': const ChallengeCompletionData(
          challengeId: 'survival',
          totalCompletions: 3,
          perfectCompletions: 1,
          noLivesLostCompletions: 2,
        ),
      };

      final context = AchievementContext(
        globalStats: stats,
        challengeData: challengeData,
      );

      final data = context.getChallengeData('survival');
      expect(data, isNotNull);
      expect(data!.totalCompletions, 3);
      expect(data.hasCompleted, isTrue);
      expect(data.hasCompletedPerfect, isTrue);
      expect(data.hasCompletedNoLivesLost, isTrue);
    });

    test('getChallengeData returns null for unknown challenge', () {
      final stats = createStats();
      final context = AchievementContext(globalStats: stats);

      expect(context.getChallengeData('unknown'), isNull);
    });
  });

  group('CategoryCompletionData', () {
    test('creates with defaults', () {
      const data = CategoryCompletionData(categoryId: 'test');

      expect(data.categoryId, 'test');
      expect(data.totalCompletions, 0);
      expect(data.perfectCompletions, 0);
      expect(data.isFullyCompleted, false);
    });

    test('toString contains relevant info', () {
      const data = CategoryCompletionData(
        categoryId: 'europe',
        totalCompletions: 5,
        perfectCompletions: 2,
      );

      expect(data.toString(), contains('europe'));
      expect(data.toString(), contains('5'));
    });
  });

  group('ChallengeCompletionData', () {
    test('creates with defaults', () {
      const data = ChallengeCompletionData(challengeId: 'test');

      expect(data.challengeId, 'test');
      expect(data.totalCompletions, 0);
      expect(data.perfectCompletions, 0);
      expect(data.noLivesLostCompletions, 0);
      expect(data.bestScore, 0.0);
    });

    test('hasCompleted is false when no completions', () {
      const data = ChallengeCompletionData(
        challengeId: 'test',
        totalCompletions: 0,
      );

      expect(data.hasCompleted, isFalse);
    });

    test('hasCompletedPerfect is true when perfect completions > 0', () {
      const data = ChallengeCompletionData(
        challengeId: 'test',
        totalCompletions: 3,
        perfectCompletions: 1,
      );

      expect(data.hasCompletedPerfect, isTrue);
    });

    test('toString contains relevant info', () {
      const data = ChallengeCompletionData(
        challengeId: 'survival',
        totalCompletions: 3,
      );

      expect(data.toString(), contains('survival'));
      expect(data.toString(), contains('3'));
    });
  });
}
