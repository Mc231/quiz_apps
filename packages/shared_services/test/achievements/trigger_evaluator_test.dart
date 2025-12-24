import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  late TriggerEvaluator evaluator;
  final now = DateTime.now();

  setUp(() {
    evaluator = const TriggerEvaluator();
  });

  GlobalStatistics createStats({
    int totalSessions = 10,
    int totalCompletedSessions = 10,
    int totalQuestionsAnswered = 100,
    int totalCorrectAnswers = 80,
    int totalPerfectScores = 5,
    int bestStreak = 7,
    int currentStreak = 3,
    int quickAnswersCount = 20,
    int sessionsNoHints = 4,
    int highScore90Count = 6,
    int highScore95Count = 3,
  }) {
    return GlobalStatistics(
      totalSessions: totalSessions,
      totalCompletedSessions: totalCompletedSessions,
      totalQuestionsAnswered: totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers,
      totalPerfectScores: totalPerfectScores,
      bestStreak: bestStreak,
      currentStreak: currentStreak,
      quickAnswersCount: quickAnswersCount,
      sessionsNoHints: sessionsNoHints,
      highScore90Count: highScore90Count,
      highScore95Count: highScore95Count,
      createdAt: now,
      updatedAt: now,
    );
  }

  QuizSession createSession({
    double scorePercentage = 80.0,
    int totalCorrect = 8,
    int totalFailed = 2,
    int totalSkipped = 0,
    int durationSeconds = 300,
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
      totalSkipped: totalSkipped,
      scorePercentage: scorePercentage,
      durationSeconds: durationSeconds,
      hintsUsed5050: hintsUsed5050,
      hintsUsedSkip: hintsUsedSkip,
      startTime: now.subtract(Duration(seconds: durationSeconds)),
      endTime: now,
      completionStatus: CompletionStatus.completed,
      mode: QuizMode.normal,
      appVersion: '1.0.0',
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CumulativeTrigger evaluation', () {
    test('evaluates true when target is met', () {
      final trigger = AchievementTrigger.cumulative(
        field: StatField.totalSessions,
        target: 10,
      );
      final context = AchievementContext(globalStats: createStats());

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('evaluates false when target is not met', () {
      final trigger = AchievementTrigger.cumulative(
        field: StatField.totalSessions,
        target: 20,
      );
      final context = AchievementContext(globalStats: createStats());

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('getProgress returns current value', () {
      final trigger = AchievementTrigger.cumulative(
        field: StatField.totalSessions,
        target: 20,
      );
      final context = AchievementContext(globalStats: createStats());

      expect(evaluator.getProgress(trigger, context), 10);
    });

    test('getTarget returns target value', () {
      final trigger = AchievementTrigger.cumulative(
        field: StatField.totalSessions,
        target: 20,
      );

      expect(evaluator.getTarget(trigger), 20);
    });
  });

  group('ThresholdTrigger evaluation', () {
    test('evaluates true for greaterOrEqual when condition met', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionScorePercentage,
        value: 80,
        operator: ThresholdOperator.greaterOrEqual,
      );
      final session = createSession(scorePercentage: 90.0);
      final context = AchievementContext.afterSession(
        globalStats: createStats(),
        session: session,
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('evaluates false when no session present', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionScorePercentage,
        value: 80,
      );
      final context = AchievementContext(globalStats: createStats());

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('evaluates lessThan operator correctly', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionDurationSeconds,
        value: 60,
        operator: ThresholdOperator.lessThan,
      );
      final session = createSession(durationSeconds: 45);
      final context = AchievementContext.afterSession(
        globalStats: createStats(),
        session: session,
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('evaluates equal operator correctly', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionHintsUsed,
        value: 0,
        operator: ThresholdOperator.equal,
      );
      final session = createSession(hintsUsed5050: 0, hintsUsedSkip: 0);
      final context = AchievementContext.afterSession(
        globalStats: createStats(),
        session: session,
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('getProgress returns session value', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionScorePercentage,
        value: 100,
      );
      final session = createSession(scorePercentage: 85.0);
      final context = AchievementContext.afterSession(
        globalStats: createStats(),
        session: session,
      );

      expect(evaluator.getProgress(trigger, context), 85);
    });
  });

  group('StreakTrigger evaluation', () {
    test('evaluates true for best streak when target met', () {
      final trigger = AchievementTrigger.streak(target: 7);
      final context = AchievementContext(globalStats: createStats(bestStreak: 7));

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('evaluates using current streak when useBestStreak is false', () {
      final trigger = AchievementTrigger.streak(
        target: 3,
        useBestStreak: false,
      );
      final context = AchievementContext(
        globalStats: createStats(currentStreak: 3, bestStreak: 10),
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('getProgress returns best streak by default', () {
      final trigger = AchievementTrigger.streak(target: 10);
      final context = AchievementContext(
        globalStats: createStats(bestStreak: 7, currentStreak: 3),
      );

      expect(evaluator.getProgress(trigger, context), 7);
    });

    test('getProgress returns current streak when specified', () {
      final trigger = AchievementTrigger.streak(
        target: 10,
        useBestStreak: false,
      );
      final context = AchievementContext(
        globalStats: createStats(bestStreak: 7, currentStreak: 3),
      );

      expect(evaluator.getProgress(trigger, context), 3);
    });
  });

  group('CategoryTrigger evaluation', () {
    test('evaluates true when category has enough completions', () {
      final trigger = AchievementTrigger.category(
        categoryId: 'europe',
        requiredCount: 3,
      );
      final context = AchievementContext(
        globalStats: createStats(),
        categoryData: {
          'europe': const CategoryCompletionData(
            categoryId: 'europe',
            totalCompletions: 5,
          ),
        },
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('evaluates false when category not found', () {
      final trigger = AchievementTrigger.category(categoryId: 'europe');
      final context = AchievementContext(globalStats: createStats());

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('evaluates using perfect completions when required', () {
      final trigger = AchievementTrigger.category(
        categoryId: 'europe',
        requirePerfect: true,
        requiredCount: 3,
      );
      final context = AchievementContext(
        globalStats: createStats(),
        categoryData: {
          'europe': const CategoryCompletionData(
            categoryId: 'europe',
            totalCompletions: 10,
            perfectCompletions: 2,
          ),
        },
      );

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('getProgress returns total completions', () {
      final trigger = AchievementTrigger.category(
        categoryId: 'europe',
        requiredCount: 10,
      );
      final context = AchievementContext(
        globalStats: createStats(),
        categoryData: {
          'europe': const CategoryCompletionData(
            categoryId: 'europe',
            totalCompletions: 5,
          ),
        },
      );

      expect(evaluator.getProgress(trigger, context), 5);
    });
  });

  group('ChallengeTrigger evaluation', () {
    test('evaluates true when challenge is completed', () {
      final trigger = AchievementTrigger.challenge(challengeId: 'survival');
      final context = AchievementContext(
        globalStats: createStats(),
        challengeData: {
          'survival': const ChallengeCompletionData(
            challengeId: 'survival',
            totalCompletions: 1,
          ),
        },
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('evaluates false when challenge not completed', () {
      final trigger = AchievementTrigger.challenge(challengeId: 'survival');
      final context = AchievementContext(
        globalStats: createStats(),
        challengeData: {
          'survival': const ChallengeCompletionData(
            challengeId: 'survival',
            totalCompletions: 0,
          ),
        },
      );

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('evaluates perfect requirement correctly', () {
      final trigger = AchievementTrigger.challenge(
        challengeId: 'survival',
        requirePerfect: true,
      );
      final context = AchievementContext(
        globalStats: createStats(),
        challengeData: {
          'survival': const ChallengeCompletionData(
            challengeId: 'survival',
            totalCompletions: 5,
            perfectCompletions: 0,
          ),
        },
      );

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('evaluates no lives lost requirement correctly', () {
      final trigger = AchievementTrigger.challenge(
        challengeId: 'survival',
        requireNoLivesLost: true,
      );
      final context = AchievementContext(
        globalStats: createStats(),
        challengeData: {
          'survival': const ChallengeCompletionData(
            challengeId: 'survival',
            totalCompletions: 5,
            noLivesLostCompletions: 1,
          ),
        },
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('getTarget returns 1 for challenge triggers', () {
      final trigger = AchievementTrigger.challenge(challengeId: 'survival');

      expect(evaluator.getTarget(trigger), 1);
    });
  });

  group('CompositeTrigger evaluation', () {
    test('evaluates true when all sub-triggers are met', () {
      final trigger = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
          AchievementTrigger.streak(target: 5),
        ],
      );
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10, bestStreak: 7),
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('evaluates false when any sub-trigger is not met', () {
      final trigger = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
          AchievementTrigger.streak(target: 15),
        ],
      );
      final context = AchievementContext(
        globalStats: createStats(totalSessions: 10, bestStreak: 7),
      );

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('evaluates false for empty triggers list', () {
      final trigger = AchievementTrigger.composite(triggers: []);
      final context = AchievementContext(globalStats: createStats());

      expect(evaluator.evaluate(trigger, context), isFalse);
    });

    test('getProgress returns count of satisfied sub-triggers', () {
      final trigger = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
          AchievementTrigger.streak(target: 15),
          AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores,
            target: 3,
          ),
        ],
      );
      final context = AchievementContext(
        globalStats: createStats(
          totalSessions: 10,
          bestStreak: 7,
          totalPerfectScores: 5,
        ),
      );

      // First and third are satisfied
      expect(evaluator.getProgress(trigger, context), 2);
    });

    test('getTarget returns number of sub-triggers', () {
      final trigger = AchievementTrigger.composite(
        triggers: [
          AchievementTrigger.cumulative(
            field: StatField.totalSessions,
            target: 10,
          ),
          AchievementTrigger.streak(target: 5),
        ],
      );

      expect(evaluator.getTarget(trigger), 2);
    });
  });

  group('CustomTrigger evaluation', () {
    test('evaluates using custom function', () {
      final trigger = AchievementTrigger.custom(
        evaluate: (stats, session) => stats.totalPerfectScores >= 5,
      );
      final context = AchievementContext(
        globalStats: createStats(totalPerfectScores: 5),
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('getProgress uses custom getProgress function', () {
      final trigger = AchievementTrigger.custom(
        evaluate: (stats, session) => stats.totalPerfectScores >= 10,
        getProgress: (stats) => stats.totalPerfectScores,
        target: 10,
      );
      final context = AchievementContext(
        globalStats: createStats(totalPerfectScores: 7),
      );

      expect(evaluator.getProgress(trigger, context), 7);
    });

    test('getProgress returns 1 or 0 when no getProgress function', () {
      final satisfiedTrigger = AchievementTrigger.custom(
        evaluate: (stats, session) => true,
      );
      final notSatisfiedTrigger = AchievementTrigger.custom(
        evaluate: (stats, session) => false,
      );
      final context = AchievementContext(globalStats: createStats());

      expect(evaluator.getProgress(satisfiedTrigger, context), 1);
      expect(evaluator.getProgress(notSatisfiedTrigger, context), 0);
    });

    test('getTarget returns custom target or defaults to 1', () {
      final withTarget = AchievementTrigger.custom(
        evaluate: (stats, session) => true,
        target: 10,
      );
      final withoutTarget = AchievementTrigger.custom(
        evaluate: (stats, session) => true,
      );

      expect(evaluator.getTarget(withTarget), 10);
      expect(evaluator.getTarget(withoutTarget), 1);
    });
  });

  group('StatField extraction', () {
    test('extracts session-specific fields correctly', () {
      final trigger = AchievementTrigger.threshold(
        field: StatField.sessionIsPerfect,
        value: 1,
        operator: ThresholdOperator.equal,
      );
      final session = createSession(scorePercentage: 100.0);
      final context = AchievementContext.afterSession(
        globalStats: createStats(),
        session: session,
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
    });

    test('extracts V2 stat fields correctly', () {
      final trigger = AchievementTrigger.cumulative(
        field: StatField.quickAnswersCount,
        target: 15,
      );
      final context = AchievementContext(
        globalStats: createStats(quickAnswersCount: 20),
      );

      expect(evaluator.evaluate(trigger, context), isTrue);
      expect(evaluator.getProgress(trigger, context), 20);
    });
  });
}
