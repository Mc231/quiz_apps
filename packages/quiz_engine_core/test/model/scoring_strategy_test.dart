import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('SimpleScoring', () {
    test('calculates correct base points', () {
      const scoring = SimpleScoring();
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 60,
      );

      expect(result.basePoints, 5);
      expect(result.bonusPoints, 0);
      expect(result.totalScore, 5);
    });

    test('calculates correct points with custom pointsPerCorrect', () {
      const scoring = SimpleScoring(pointsPerCorrect: 10);
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 60,
      );

      expect(result.basePoints, 50);
      expect(result.bonusPoints, 0);
      expect(result.totalScore, 50);
    });

    test('handles zero correct answers', () {
      const scoring = SimpleScoring();
      final result = scoring.calculateScore(
        correctAnswers: 0,
        totalQuestions: 10,
        durationSeconds: 60,
      );

      expect(result.basePoints, 0);
      expect(result.totalScore, 0);
    });

    test('serializes and deserializes correctly', () {
      const original = SimpleScoring(pointsPerCorrect: 5);
      final map = original.toMap();
      final restored = SimpleScoring.fromMap(map);

      expect(restored.pointsPerCorrect, 5);
    });
  });

  group('TimedScoring', () {
    test('calculates correct base points without time bonus', () {
      const scoring = TimedScoring();
      // 30 seconds per question = no bonus
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 300, // 30s per question average
      );

      expect(result.basePoints, 500); // 5 * 100
      expect(result.bonusPoints, 0); // No bonus - at threshold
      expect(result.totalScore, 500);
    });

    test('calculates time bonus correctly', () {
      const scoring = TimedScoring(
        basePointsPerQuestion: 100,
        bonusPerSecondSaved: 5,
        timeThresholdSeconds: 30,
      );
      // 10 seconds per question = 20 seconds saved per question
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 100, // 10s per question average
      );

      expect(result.basePoints, 500); // 5 * 100
      // Time bonus: (30 - 10) * 5 * 5 = 500
      expect(result.bonusPoints, 500);
      expect(result.totalScore, 1000);
      expect(result.bonusDescription, 'Time bonus');
    });

    test('no bonus when average time exceeds threshold', () {
      const scoring = TimedScoring();
      // 40 seconds per question = over threshold
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 400,
      );

      expect(result.basePoints, 500);
      expect(result.bonusPoints, 0);
      expect(result.bonusDescription, null);
    });

    test('handles zero correct answers', () {
      const scoring = TimedScoring();
      final result = scoring.calculateScore(
        correctAnswers: 0,
        totalQuestions: 10,
        durationSeconds: 100,
      );

      expect(result.basePoints, 0);
      expect(result.bonusPoints, 0);
      expect(result.totalScore, 0);
    });

    test('handles zero total questions', () {
      const scoring = TimedScoring();
      final result = scoring.calculateScore(
        correctAnswers: 0,
        totalQuestions: 0,
        durationSeconds: 0,
      );

      expect(result.basePoints, 0);
      expect(result.bonusPoints, 0);
      expect(result.totalScore, 0);
    });

    test('serializes and deserializes correctly', () {
      const original = TimedScoring(
        basePointsPerQuestion: 50,
        bonusPerSecondSaved: 10,
        timeThresholdSeconds: 20,
      );
      final map = original.toMap();
      final restored = TimedScoring.fromMap(map);

      expect(restored.basePointsPerQuestion, 50);
      expect(restored.bonusPerSecondSaved, 10);
      expect(restored.timeThresholdSeconds, 20);
    });

    test('copyWith creates correct copy', () {
      const original = TimedScoring();
      final copy = original.copyWith(basePointsPerQuestion: 200);

      expect(copy.basePointsPerQuestion, 200);
      expect(copy.bonusPerSecondSaved, original.bonusPerSecondSaved);
      expect(copy.timeThresholdSeconds, original.timeThresholdSeconds);
    });
  });

  group('StreakScoring', () {
    test('calculates correct base points without streaks', () {
      const scoring = StreakScoring();
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 60,
      );

      expect(result.basePoints, 500); // 5 * 100
      expect(result.bonusPoints, 0);
      expect(result.totalScore, 500);
    });

    test('calculates streak bonus correctly', () {
      const scoring = StreakScoring(
        basePointsPerQuestion: 100,
        streakMultiplier: 1.5, // 0.5 bonus per streak level
      );
      // A streak of 3 means:
      // 1st correct: base (100)
      // 2nd correct: base + 0.5*base = 150 bonus of 50
      // 3rd correct: base + 1.0*base = 200 bonus of 100
      // Total base: 3 * 100 = 300
      // Total bonus: 50 + 100 = 150
      final result = scoring.calculateScore(
        correctAnswers: 3,
        totalQuestions: 5,
        durationSeconds: 60,
        streaks: [3],
      );

      expect(result.basePoints, 300);
      expect(result.bonusPoints, 150);
      expect(result.totalScore, 450);
      expect(result.bonusDescription, 'Streak bonus');
    });

    test('handles multiple streaks', () {
      const scoring = StreakScoring(
        basePointsPerQuestion: 100,
        streakMultiplier: 1.5,
      );
      // Two streaks of 2: each gives 50 bonus
      final result = scoring.calculateScore(
        correctAnswers: 4,
        totalQuestions: 6,
        durationSeconds: 60,
        streaks: [2, 2],
      );

      expect(result.basePoints, 400);
      expect(result.bonusPoints, 100); // 50 + 50
      expect(result.totalScore, 500);
    });

    test('handles null streaks', () {
      const scoring = StreakScoring();
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 60,
        streaks: null,
      );

      expect(result.basePoints, 500);
      expect(result.bonusPoints, 0);
      expect(result.totalScore, 500);
    });

    test('handles empty streaks list', () {
      const scoring = StreakScoring();
      final result = scoring.calculateScore(
        correctAnswers: 5,
        totalQuestions: 10,
        durationSeconds: 60,
        streaks: [],
      );

      expect(result.basePoints, 500);
      expect(result.bonusPoints, 0);
      expect(result.totalScore, 500);
    });

    test('serializes and deserializes correctly', () {
      const original = StreakScoring(
        basePointsPerQuestion: 50,
        streakMultiplier: 2.0,
      );
      final map = original.toMap();
      final restored = StreakScoring.fromMap(map);

      expect(restored.basePointsPerQuestion, 50);
      expect(restored.streakMultiplier, 2.0);
    });

    test('copyWith creates correct copy', () {
      const original = StreakScoring();
      final copy = original.copyWith(streakMultiplier: 2.0);

      expect(copy.streakMultiplier, 2.0);
      expect(copy.basePointsPerQuestion, original.basePointsPerQuestion);
    });
  });

  group('ScoreBreakdownData', () {
    test('toString returns correct format', () {
      const breakdown = ScoreBreakdownData(
        basePoints: 100,
        bonusPoints: 50,
        totalScore: 150,
      );

      expect(breakdown.toString(), 'ScoreBreakdownData(base: 100, bonus: 50, total: 150)');
    });

    test('stores optional bonus description', () {
      const breakdown = ScoreBreakdownData(
        basePoints: 100,
        bonusPoints: 50,
        totalScore: 150,
        bonusDescription: 'Time bonus',
      );

      expect(breakdown.bonusDescription, 'Time bonus');
    });
  });

  group('ScoringStrategy.fromMap', () {
    test('creates SimpleScoring from map', () {
      final map = {'type': 'simple', 'version': 1};
      final scoring = ScoringStrategy.fromMap(map);

      expect(scoring, isA<SimpleScoring>());
    });

    test('creates TimedScoring from map', () {
      final map = {
        'type': 'timed',
        'version': 1,
        'basePointsPerQuestion': 100,
        'bonusPerSecondSaved': 5,
        'timeThresholdSeconds': 30,
      };
      final scoring = ScoringStrategy.fromMap(map);

      expect(scoring, isA<TimedScoring>());
    });

    test('creates StreakScoring from map', () {
      final map = {
        'type': 'streak',
        'version': 1,
        'basePointsPerQuestion': 100,
        'streakMultiplier': 1.5,
      };
      final scoring = ScoringStrategy.fromMap(map);

      expect(scoring, isA<StreakScoring>());
    });

    test('defaults to SimpleScoring for unknown type', () {
      final map = {'type': 'unknown', 'version': 1};
      final scoring = ScoringStrategy.fromMap(map);

      // Unknown types default to SimpleScoring
      expect(scoring, isA<SimpleScoring>());
    });
  });
}
