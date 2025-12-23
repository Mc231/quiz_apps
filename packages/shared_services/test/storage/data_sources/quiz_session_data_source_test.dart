import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('QuizSessionFilter', () {
    test('hasConditions returns false for empty filter', () {
      const filter = QuizSessionFilter();
      expect(filter.hasConditions, false);
    });

    test('hasConditions returns true when quizType is set', () {
      const filter = QuizSessionFilter(quizType: 'flags');
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when quizCategory is set', () {
      const filter = QuizSessionFilter(quizCategory: 'europe');
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when completionStatus is set', () {
      const filter = QuizSessionFilter(
        completionStatus: CompletionStatus.completed,
      );
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when mode is set', () {
      const filter = QuizSessionFilter(mode: QuizMode.timed);
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when date range is set', () {
      final filter = QuizSessionFilter(
        startDateFrom: DateTime(2024, 1, 1),
        startDateTo: DateTime(2024, 12, 31),
      );
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when score range is set', () {
      const filter = QuizSessionFilter(minScore: 50.0, maxScore: 100.0);
      expect(filter.hasConditions, true);
    });

    test('buildWhereClause returns empty for no conditions', () {
      const filter = QuizSessionFilter();
      final clause = filter.buildWhereClause();

      expect(clause.where, '');
      expect(clause.args, isEmpty);
    });

    test('buildWhereClause builds correct clause for quizType', () {
      const filter = QuizSessionFilter(quizType: 'flags');
      final clause = filter.buildWhereClause();

      expect(clause.where, 'quiz_type = ?');
      expect(clause.args, ['flags']);
    });

    test('buildWhereClause builds correct clause for completionStatus', () {
      const filter = QuizSessionFilter(
        completionStatus: CompletionStatus.completed,
      );
      final clause = filter.buildWhereClause();

      expect(clause.where, 'completion_status = ?');
      expect(clause.args, ['completed']);
    });

    test('buildWhereClause builds correct clause for mode', () {
      const filter = QuizSessionFilter(mode: QuizMode.timed);
      final clause = filter.buildWhereClause();

      expect(clause.where, 'mode = ?');
      expect(clause.args, ['timed']);
    });

    test('buildWhereClause combines multiple conditions with AND', () {
      const filter = QuizSessionFilter(
        quizType: 'flags',
        quizCategory: 'europe',
        completionStatus: CompletionStatus.completed,
      );
      final clause = filter.buildWhereClause();

      expect(clause.where, contains('quiz_type = ?'));
      expect(clause.where, contains('quiz_category = ?'));
      expect(clause.where, contains('completion_status = ?'));
      expect(clause.where, contains(' AND '));
      expect(clause.args.length, 3);
      expect(clause.args, contains('flags'));
      expect(clause.args, contains('europe'));
      expect(clause.args, contains('completed'));
    });

    test('buildWhereClause handles date range correctly', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      final filter = QuizSessionFilter(
        startDateFrom: startDate,
        startDateTo: endDate,
      );
      final clause = filter.buildWhereClause();

      expect(clause.where, contains('start_time >= ?'));
      expect(clause.where, contains('start_time <= ?'));
      expect(clause.args.length, 2);
      expect(clause.args[0], startDate.millisecondsSinceEpoch ~/ 1000);
      expect(clause.args[1], endDate.millisecondsSinceEpoch ~/ 1000);
    });

    test('buildWhereClause handles score range correctly', () {
      const filter = QuizSessionFilter(minScore: 50.0, maxScore: 90.0);
      final clause = filter.buildWhereClause();

      expect(clause.where, contains('score_percentage >= ?'));
      expect(clause.where, contains('score_percentage <= ?'));
      expect(clause.args, contains(50.0));
      expect(clause.args, contains(90.0));
    });

    test('buildWhereClause handles all filters combined', () {
      final filter = QuizSessionFilter(
        quizType: 'flags',
        quizCategory: 'europe',
        completionStatus: CompletionStatus.completed,
        mode: QuizMode.normal,
        startDateFrom: DateTime(2024, 1, 1),
        startDateTo: DateTime(2024, 12, 31),
        minScore: 50.0,
        maxScore: 100.0,
      );
      final clause = filter.buildWhereClause();

      // Should have 8 conditions
      expect(clause.args.length, 8);
      expect(clause.where.split(' AND ').length, 8);
    });
  });

  group('QuizSessionDataSource Interface', () {
    test('QuizSessionDataSourceImpl can be instantiated', () {
      // This test verifies the implementation class exists and can be created
      // Actual database tests would require integration tests with sqflite_ffi
      expect(
        () => QuizSessionDataSourceImpl(),
        returnsNormally,
      );
    });
  });
}
