import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('DailyChallengeResult', () {
    test('create generates result with UUID', () {
      final result = DailyChallengeResult.create(
        challengeId: 'daily_2024-01-15',
        score: 850,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 120,
        streakBonus: 50,
        timeBonus: 30,
      );

      expect(result.id, isNotEmpty);
      expect(result.challengeId, equals('daily_2024-01-15'));
      expect(result.score, equals(850));
      expect(result.correctCount, equals(8));
      expect(result.totalQuestions, equals(10));
      expect(result.completionTimeSeconds, equals(120));
      expect(result.streakBonus, equals(50));
      expect(result.timeBonus, equals(30));
      expect(result.completedAt, isNotNull);
    });

    test('scorePercentage calculates correctly', () {
      final result = DailyChallengeResult.create(
        challengeId: 'test',
        score: 800,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 100,
      );

      expect(result.scorePercentage, equals(80.0));
    });

    test('scorePercentage handles zero questions', () {
      final result = DailyChallengeResult(
        id: 'test-id',
        challengeId: 'test',
        score: 0,
        correctCount: 0,
        totalQuestions: 0,
        completionTimeSeconds: 0,
        completedAt: DateTime.now(),
      );

      expect(result.scorePercentage, equals(0.0));
    });

    test('isPerfectScore returns true when all correct', () {
      final perfect = DailyChallengeResult.create(
        challengeId: 'test',
        score: 1000,
        correctCount: 10,
        totalQuestions: 10,
        completionTimeSeconds: 100,
      );

      final notPerfect = DailyChallengeResult.create(
        challengeId: 'test',
        score: 900,
        correctCount: 9,
        totalQuestions: 10,
        completionTimeSeconds: 100,
      );

      expect(perfect.isPerfectScore, isTrue);
      expect(notPerfect.isPerfectScore, isFalse);
    });

    test('baseScore calculates correctly', () {
      final result = DailyChallengeResult.create(
        challengeId: 'test',
        score: 880,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 100,
        streakBonus: 50,
        timeBonus: 30,
      );

      expect(result.baseScore, equals(800)); // 880 - 50 - 30
    });

    test('incorrectCount calculates correctly', () {
      final result = DailyChallengeResult.create(
        challengeId: 'test',
        score: 700,
        correctCount: 7,
        totalQuestions: 10,
        completionTimeSeconds: 100,
      );

      expect(result.incorrectCount, equals(3));
    });

    test('formattedTime formats correctly', () {
      final shortTime = DailyChallengeResult.create(
        challengeId: 'test',
        score: 100,
        correctCount: 1,
        totalQuestions: 10,
        completionTimeSeconds: 45,
      );

      final longTime = DailyChallengeResult.create(
        challengeId: 'test',
        score: 100,
        correctCount: 1,
        totalQuestions: 10,
        completionTimeSeconds: 185,
      );

      expect(shortTime.formattedTime, equals('00:45'));
      expect(longTime.formattedTime, equals('03:05'));
    });

    test('fromMap and toMap are inverse operations', () {
      final original = DailyChallengeResult.create(
        challengeId: 'daily_2024-03-10',
        score: 950,
        correctCount: 9,
        totalQuestions: 10,
        completionTimeSeconds: 150,
        streakBonus: 30,
        timeBonus: 20,
      );

      final map = original.toMap();
      final restored = DailyChallengeResult.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.challengeId, equals(original.challengeId));
      expect(restored.score, equals(original.score));
      expect(restored.correctCount, equals(original.correctCount));
      expect(restored.totalQuestions, equals(original.totalQuestions));
      expect(restored.completionTimeSeconds,
          equals(original.completionTimeSeconds));
      expect(restored.streakBonus, equals(original.streakBonus));
      expect(restored.timeBonus, equals(original.timeBonus));
    });

    test('copyWith creates copy with updated fields', () {
      final original = DailyChallengeResult.create(
        challengeId: 'test',
        score: 800,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 120,
      );

      final copy = original.copyWith(
        score: 900,
        streakBonus: 100,
      );

      expect(copy.id, equals(original.id));
      expect(copy.score, equals(900));
      expect(copy.streakBonus, equals(100));
      expect(copy.correctCount, equals(8));
    });

    test('equality is based on id', () {
      final result1 = DailyChallengeResult(
        id: 'same-id',
        challengeId: 'a',
        score: 100,
        correctCount: 1,
        totalQuestions: 10,
        completionTimeSeconds: 60,
        completedAt: DateTime(2024, 1, 1),
      );

      final result2 = DailyChallengeResult(
        id: 'same-id',
        challengeId: 'b',
        score: 200,
        correctCount: 2,
        totalQuestions: 10,
        completionTimeSeconds: 120,
        completedAt: DateTime(2024, 2, 1),
      );

      expect(result1, equals(result2)); // Same id
    });
  });
}
