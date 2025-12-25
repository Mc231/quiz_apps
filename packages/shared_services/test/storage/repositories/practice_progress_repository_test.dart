import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_services/src/storage/database/migrations/migration_v4.dart';

void main() {
  group('PracticeProgressRepository Interface', () {
    test('abstract interface exists', () {
      // Verify the abstract interface is available for dependency injection
      expect(PracticeProgressRepository, isNotNull);
    });

    test('PracticeStatistics can be created with empty values', () {
      const stats = PracticeStatistics(
        totalQuestionsToPractice: 0,
        totalWrongCount: 0,
        questionsPracticedCorrectly: 0,
      );

      expect(stats.totalQuestionsToPractice, equals(0));
      expect(stats.totalWrongCount, equals(0));
      expect(stats.questionsPracticedCorrectly, equals(0));
    });

    test('PracticeStatistics.empty returns zero values', () {
      final stats = PracticeStatistics.empty();

      expect(stats.totalQuestionsToPractice, equals(0));
      expect(stats.totalWrongCount, equals(0));
      expect(stats.questionsPracticedCorrectly, equals(0));
    });

    test('PracticeStatistics toString includes values', () {
      const stats = PracticeStatistics(
        totalQuestionsToPractice: 5,
        totalWrongCount: 10,
        questionsPracticedCorrectly: 3,
      );

      final str = stats.toString();
      expect(str, contains('5'));
      expect(str, contains('10'));
      expect(str, contains('3'));
    });
  });

  group('PracticeQuestion Model', () {
    test('needsPractice is true when never practiced', () {
      final question = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 1,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 1),
        lastPracticedCorrectlyAt: null,
      );

      expect(question.needsPractice, isTrue);
    });

    test('needsPractice is false when practiced after last wrong', () {
      final question = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 1,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 1),
        lastPracticedCorrectlyAt: DateTime(2024, 1, 2),
      );

      expect(question.needsPractice, isFalse);
    });

    test('needsPractice is true when wrong after practice', () {
      final question = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 2,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 3),
        lastPracticedCorrectlyAt: DateTime(2024, 1, 2),
      );

      expect(question.needsPractice, isTrue);
    });

    test('toMap and fromMap are inverses', () {
      final original = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 3,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 15),
        lastPracticedCorrectlyAt: DateTime(2024, 1, 10),
      );

      final map = original.toMap();
      final restored = PracticeQuestion.fromMap(map);

      expect(restored.questionId, equals(original.questionId));
      expect(restored.wrongCount, equals(original.wrongCount));
      // Note: DateTime precision may differ due to seconds conversion
      expect(
        restored.firstWrongAt.difference(original.firstWrongAt).inSeconds.abs(),
        lessThan(1),
      );
      expect(
        restored.lastWrongAt.difference(original.lastWrongAt).inSeconds.abs(),
        lessThan(1),
      );
      expect(restored.needsPractice, equals(original.needsPractice));
    });

    test('copyWith creates modified copy', () {
      final original = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 1,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 1),
        lastPracticedCorrectlyAt: null,
      );

      final modified = original.copyWith(wrongCount: 5);

      expect(modified.questionId, equals('ua'));
      expect(modified.wrongCount, equals(5));
      expect(original.wrongCount, equals(1));
    });

    test('equality is based on questionId', () {
      final q1 = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 1,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 1),
        lastPracticedCorrectlyAt: null,
      );

      final q2 = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 5, // Different wrong count
        firstWrongAt: DateTime(2024, 2, 1),
        lastWrongAt: DateTime(2024, 2, 1),
        lastPracticedCorrectlyAt: DateTime(2024, 2, 1),
      );

      final q3 = PracticeQuestion(
        questionId: 'de',
        wrongCount: 1,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 1),
        lastPracticedCorrectlyAt: null,
      );

      expect(q1, equals(q2)); // Same questionId
      expect(q1, isNot(equals(q3))); // Different questionId
    });

    test('toString includes key information', () {
      final question = PracticeQuestion(
        questionId: 'ua',
        wrongCount: 3,
        firstWrongAt: DateTime(2024, 1, 1),
        lastWrongAt: DateTime(2024, 1, 15),
        lastPracticedCorrectlyAt: null,
      );

      final str = question.toString();
      expect(str, contains('ua'));
      expect(str, contains('3'));
      expect(str, contains('needsPractice'));
    });
  });

  group('PracticeProgressTable', () {
    test('table name constant is defined', () {
      expect(practiceProgressTable, equals('practice_progress'));
    });

    test('create table SQL is defined', () {
      expect(createPracticeProgressTable, isNotEmpty);
      expect(createPracticeProgressTable, contains('practice_progress'));
      expect(createPracticeProgressTable, contains('question_id'));
      expect(createPracticeProgressTable, contains('wrong_count'));
    });

    test('column names constants are defined', () {
      expect(PracticeProgressColumns.questionId, equals('question_id'));
      expect(PracticeProgressColumns.wrongCount, equals('wrong_count'));
      expect(PracticeProgressColumns.firstWrongAt, equals('first_wrong_at'));
      expect(PracticeProgressColumns.lastWrongAt, equals('last_wrong_at'));
      expect(
        PracticeProgressColumns.lastPracticedCorrectlyAt,
        equals('last_practiced_correctly_at'),
      );
    });
  });

  group('MigrationV4', () {
    test('migration version is 4', () {
      const migration = MigrationV4();
      expect(migration.version, equals(4));
    });

    test('migration has description', () {
      const migration = MigrationV4();
      expect(migration.description, contains('practice'));
    });
  });
}
