import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ShareResult', () {
    group('constructor', () {
      test('creates result with required fields', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        final result = ShareResult(
          score: 85.0,
          categoryName: 'European Flags',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: timestamp,
        );

        expect(result.score, 85.0);
        expect(result.categoryName, 'European Flags');
        expect(result.correctCount, 17);
        expect(result.totalCount, 20);
        expect(result.mode, 'standard');
        expect(result.timestamp, timestamp);
        expect(result.categoryId, isNull);
        expect(result.achievementUnlocked, isNull);
        expect(result.streakCount, isNull);
        expect(result.bestScore, isNull);
        expect(result.timeTaken, isNull);
      });

      test('creates result with optional fields', () {
        final result = ShareResult(
          score: 100.0,
          categoryName: 'World Capitals',
          correctCount: 25,
          totalCount: 25,
          mode: 'timed',
          timestamp: DateTime.now(),
          categoryId: 'world_capitals',
          achievementUnlocked: 'Perfectionist',
          streakCount: 25,
          bestScore: 92.0,
          timeTaken: const Duration(minutes: 5, seconds: 30),
        );

        expect(result.categoryId, 'world_capitals');
        expect(result.achievementUnlocked, 'Perfectionist');
        expect(result.streakCount, 25);
        expect(result.bestScore, 92.0);
        expect(result.timeTaken, const Duration(minutes: 5, seconds: 30));
      });
    });

    group('factory ShareResult.perfect', () {
      test('creates 100% score result', () {
        final result = ShareResult.perfect(
          categoryName: 'Asian Countries',
          totalCount: 30,
          mode: 'standard',
        );

        expect(result.score, 100.0);
        expect(result.correctCount, 30);
        expect(result.totalCount, 30);
        expect(result.categoryName, 'Asian Countries');
        expect(result.mode, 'standard');
        expect(result.isPerfect, isTrue);
      });

      test('includes optional fields', () {
        final result = ShareResult.perfect(
          categoryName: 'Test',
          totalCount: 10,
          mode: 'timed',
          categoryId: 'test_id',
          achievementUnlocked: 'Perfect Score',
          timeTaken: const Duration(minutes: 2),
        );

        expect(result.categoryId, 'test_id');
        expect(result.achievementUnlocked, 'Perfect Score');
        expect(result.timeTaken, const Duration(minutes: 2));
      });
    });

    group('factory ShareResult.fromQuizCompletion', () {
      test('calculates score percentage correctly', () {
        final result = ShareResult.fromQuizCompletion(
          correctCount: 15,
          totalCount: 20,
          categoryName: 'Test',
          mode: 'standard',
        );

        expect(result.score, 75.0);
        expect(result.scorePercent, 75);
      });

      test('handles zero total count', () {
        final result = ShareResult.fromQuizCompletion(
          correctCount: 0,
          totalCount: 0,
          categoryName: 'Test',
          mode: 'standard',
        );

        expect(result.score, 0.0);
      });

      test('includes optional fields', () {
        final result = ShareResult.fromQuizCompletion(
          correctCount: 8,
          totalCount: 10,
          categoryName: 'Test',
          mode: 'survival',
          categoryId: 'cat_id',
          achievementUnlocked: 'First Blood',
          streakCount: 5,
          bestScore: 70.0,
          timeTaken: const Duration(seconds: 90),
        );

        expect(result.score, 80.0);
        expect(result.categoryId, 'cat_id');
        expect(result.achievementUnlocked, 'First Blood');
        expect(result.streakCount, 5);
        expect(result.bestScore, 70.0);
        expect(result.timeTaken, const Duration(seconds: 90));
      });
    });

    group('computed properties', () {
      test('isPerfect returns true for 100% score', () {
        final result = ShareResult(
          score: 100.0,
          categoryName: 'Test',
          correctCount: 10,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        expect(result.isPerfect, isTrue);
      });

      test('isPerfect returns false for less than 100%', () {
        final result = ShareResult(
          score: 99.9,
          categoryName: 'Test',
          correctCount: 9,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        expect(result.isPerfect, isFalse);
      });

      test('isNewBest returns true when score exceeds bestScore', () {
        final result = ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
          bestScore: 80.0,
        );

        expect(result.isNewBest, isTrue);
      });

      test('isNewBest returns false when score equals bestScore', () {
        final result = ShareResult(
          score: 80.0,
          categoryName: 'Test',
          correctCount: 16,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
          bestScore: 80.0,
        );

        expect(result.isNewBest, isFalse);
      });

      test('isNewBest returns false when bestScore is null', () {
        final result = ShareResult(
          score: 90.0,
          categoryName: 'Test',
          correctCount: 18,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        expect(result.isNewBest, isFalse);
      });

      test('hasAchievement returns correct value', () {
        final withAchievement = ShareResult(
          score: 100.0,
          categoryName: 'Test',
          correctCount: 10,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
          achievementUnlocked: 'Perfect',
        );

        final withoutAchievement = ShareResult(
          score: 90.0,
          categoryName: 'Test',
          correctCount: 9,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        expect(withAchievement.hasAchievement, isTrue);
        expect(withoutAchievement.hasAchievement, isFalse);
      });

      test('scorePercent rounds correctly', () {
        expect(
          ShareResult(
            score: 85.4,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ).scorePercent,
          85,
        );

        expect(
          ShareResult(
            score: 85.5,
            categoryName: 'Test',
            correctCount: 17,
            totalCount: 20,
            mode: 'standard',
            timestamp: DateTime.now(),
          ).scorePercent,
          86,
        );
      });

      test('formattedTime returns correct format', () {
        final result = ShareResult(
          score: 80.0,
          categoryName: 'Test',
          correctCount: 8,
          totalCount: 10,
          mode: 'timed',
          timestamp: DateTime.now(),
          timeTaken: const Duration(minutes: 2, seconds: 5),
        );

        expect(result.formattedTime, '2:05');
      });

      test('formattedTime returns null when timeTaken is null', () {
        final result = ShareResult(
          score: 80.0,
          categoryName: 'Test',
          correctCount: 8,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        expect(result.formattedTime, isNull);
      });

      test('formattedTime handles edge cases', () {
        // Zero time
        expect(
          ShareResult(
            score: 80.0,
            categoryName: 'Test',
            correctCount: 8,
            totalCount: 10,
            mode: 'timed',
            timestamp: DateTime.now(),
            timeTaken: Duration.zero,
          ).formattedTime,
          '0:00',
        );

        // Just seconds
        expect(
          ShareResult(
            score: 80.0,
            categoryName: 'Test',
            correctCount: 8,
            totalCount: 10,
            mode: 'timed',
            timestamp: DateTime.now(),
            timeTaken: const Duration(seconds: 45),
          ).formattedTime,
          '0:45',
        );

        // Over an hour
        expect(
          ShareResult(
            score: 80.0,
            categoryName: 'Test',
            correctCount: 8,
            totalCount: 10,
            mode: 'timed',
            timestamp: DateTime.now(),
            timeTaken: const Duration(hours: 1, minutes: 5, seconds: 30),
          ).formattedTime,
          '65:30',
        );
      });
    });

    group('copyWith', () {
      test('copies with single field change', () {
        final original = ShareResult(
          score: 80.0,
          categoryName: 'Original',
          correctCount: 8,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(categoryName: 'Updated');

        expect(copy.categoryName, 'Updated');
        expect(copy.score, original.score);
        expect(copy.correctCount, original.correctCount);
        expect(copy.totalCount, original.totalCount);
        expect(copy.mode, original.mode);
        expect(copy.timestamp, original.timestamp);
      });

      test('copies with multiple field changes', () {
        final original = ShareResult(
          score: 80.0,
          categoryName: 'Original',
          correctCount: 8,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(
          score: 90.0,
          correctCount: 9,
          achievementUnlocked: 'New Achievement',
        );

        expect(copy.score, 90.0);
        expect(copy.correctCount, 9);
        expect(copy.achievementUnlocked, 'New Achievement');
        expect(copy.categoryName, original.categoryName);
      });
    });

    group('equality', () {
      test('equal results are equal', () {
        final timestamp = DateTime(2024, 1, 15);
        final result1 = ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: timestamp,
        );
        final result2 = ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: timestamp,
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('different results are not equal', () {
        final timestamp = DateTime(2024, 1, 15);
        final result1 = ShareResult(
          score: 85.0,
          categoryName: 'Test',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: timestamp,
        );
        final result2 = ShareResult(
          score: 90.0,
          categoryName: 'Test',
          correctCount: 18,
          totalCount: 20,
          mode: 'standard',
          timestamp: timestamp,
        );

        expect(result1, isNot(equals(result2)));
      });
    });

    group('toString', () {
      test('includes key information', () {
        final result = ShareResult(
          score: 85.0,
          categoryName: 'European Flags',
          correctCount: 17,
          totalCount: 20,
          mode: 'standard',
          timestamp: DateTime.now(),
        );

        final str = result.toString();

        expect(str, contains('85%'));
        expect(str, contains('European Flags'));
        expect(str, contains('17/20'));
        expect(str, contains('standard'));
      });

      test('includes achievement when present', () {
        final result = ShareResult(
          score: 100.0,
          categoryName: 'Test',
          correctCount: 10,
          totalCount: 10,
          mode: 'standard',
          timestamp: DateTime.now(),
          achievementUnlocked: 'Perfectionist',
        );

        expect(result.toString(), contains('achievement: Perfectionist'));
      });
    });
  });
}
