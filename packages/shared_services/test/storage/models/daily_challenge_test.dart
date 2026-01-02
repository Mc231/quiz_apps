import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('DailyChallenge', () {
    test('forToday creates challenge for current date', () {
      final challenge = DailyChallenge.forToday(
        categoryId: 'europe',
        questionCount: 10,
        timeLimitSeconds: 300,
      );

      expect(challenge.isToday, isTrue);
      expect(challenge.categoryId, equals('europe'));
      expect(challenge.questionCount, equals(10));
      expect(challenge.timeLimitSeconds, equals(300));
      expect(challenge.hasTimeLimit, isTrue);
      expect(challenge.id, startsWith('daily_'));
    });

    test('forDate creates challenge for specific date', () {
      final date = DateTime(2024, 1, 15);
      final challenge = DailyChallenge.forDate(
        date: date,
        categoryId: 'asia',
        questionCount: 15,
      );

      expect(challenge.id, equals('daily_2024-01-15'));
      expect(challenge.categoryId, equals('asia'));
      expect(challenge.questionCount, equals(15));
      expect(challenge.timeLimitSeconds, isNull);
      expect(challenge.hasTimeLimit, isFalse);
    });

    test('seed is consistent for same date', () {
      final date = DateTime(2024, 6, 20);
      final challenge1 = DailyChallenge.forDate(
        date: date,
        categoryId: 'test',
      );
      final challenge2 = DailyChallenge.forDate(
        date: date,
        categoryId: 'test',
      );

      expect(challenge1.seed, equals(challenge2.seed));
      expect(challenge1.seed, equals(20240620));
    });

    test('fromMap and toMap are inverse operations', () {
      final original = DailyChallenge.forDate(
        date: DateTime(2024, 3, 10),
        categoryId: 'world',
        questionCount: 20,
        timeLimitSeconds: 600,
      );

      final map = original.toMap();
      final restored = DailyChallenge.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.categoryId, equals(original.categoryId));
      expect(restored.questionCount, equals(original.questionCount));
      expect(restored.timeLimitSeconds, equals(original.timeLimitSeconds));
      expect(restored.seed, equals(original.seed));
    });

    test('isPast returns true for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final challenge = DailyChallenge.forDate(
        date: pastDate,
        categoryId: 'test',
      );

      expect(challenge.isPast, isTrue);
      expect(challenge.isToday, isFalse);
      expect(challenge.isFuture, isFalse);
    });

    test('isFuture returns true for future dates', () {
      final futureDate = DateTime.now().add(const Duration(days: 2));
      final challenge = DailyChallenge.forDate(
        date: futureDate,
        categoryId: 'test',
      );

      expect(challenge.isFuture, isTrue);
      expect(challenge.isToday, isFalse);
      expect(challenge.isPast, isFalse);
    });

    test('copyWith creates copy with updated fields', () {
      final original = DailyChallenge.forToday(
        categoryId: 'europe',
        questionCount: 10,
        timeLimitSeconds: 300,
      );

      final copy = original.copyWith(
        categoryId: 'asia',
        questionCount: 15,
      );

      expect(copy.id, equals(original.id));
      expect(copy.categoryId, equals('asia'));
      expect(copy.questionCount, equals(15));
      expect(copy.timeLimitSeconds, equals(300));
    });

    test('copyWith can clear time limit', () {
      final original = DailyChallenge.forToday(
        categoryId: 'europe',
        timeLimitSeconds: 300,
      );

      final copy = original.copyWith(clearTimeLimit: true);

      expect(copy.timeLimitSeconds, isNull);
      expect(copy.hasTimeLimit, isFalse);
    });

    test('equality is based on id', () {
      final challenge1 = DailyChallenge.forDate(
        date: DateTime(2024, 1, 1),
        categoryId: 'a',
      );
      final challenge2 = DailyChallenge.forDate(
        date: DateTime(2024, 1, 1),
        categoryId: 'b',
      );

      expect(challenge1, equals(challenge2)); // Same id
    });
  });
}
