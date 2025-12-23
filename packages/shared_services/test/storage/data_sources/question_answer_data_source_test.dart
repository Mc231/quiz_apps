import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('QuestionAnswerFilter', () {
    test('hasConditions returns false for empty filter', () {
      const filter = QuestionAnswerFilter();
      expect(filter.hasConditions, false);
    });

    test('hasConditions returns true when sessionId is set', () {
      const filter = QuestionAnswerFilter(sessionId: 'session-1');
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when questionId is set', () {
      const filter = QuestionAnswerFilter(questionId: 'q-1');
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when isCorrect is set', () {
      const filter = QuestionAnswerFilter(isCorrect: true);
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when answerStatus is set', () {
      const filter = QuestionAnswerFilter(answerStatus: AnswerStatus.correct);
      expect(filter.hasConditions, true);
    });

    test('hasConditions returns true when hintUsed is set', () {
      const filter = QuestionAnswerFilter(hintUsed: HintUsed.fiftyFifty);
      expect(filter.hasConditions, true);
    });

    test('buildWhereClause returns empty for no conditions', () {
      const filter = QuestionAnswerFilter();
      final clause = filter.buildWhereClause();

      expect(clause.where, '');
      expect(clause.args, isEmpty);
    });

    test('buildWhereClause builds correct clause for sessionId', () {
      const filter = QuestionAnswerFilter(sessionId: 'session-1');
      final clause = filter.buildWhereClause();

      expect(clause.where, 'session_id = ?');
      expect(clause.args, ['session-1']);
    });

    test('buildWhereClause builds correct clause for questionId', () {
      const filter = QuestionAnswerFilter(questionId: 'q-1');
      final clause = filter.buildWhereClause();

      expect(clause.where, 'question_id = ?');
      expect(clause.args, ['q-1']);
    });

    test('buildWhereClause builds correct clause for isCorrect true', () {
      const filter = QuestionAnswerFilter(isCorrect: true);
      final clause = filter.buildWhereClause();

      expect(clause.where, 'is_correct = ?');
      expect(clause.args, [1]);
    });

    test('buildWhereClause builds correct clause for isCorrect false', () {
      const filter = QuestionAnswerFilter(isCorrect: false);
      final clause = filter.buildWhereClause();

      expect(clause.where, 'is_correct = ?');
      expect(clause.args, [0]);
    });

    test('buildWhereClause builds correct clause for answerStatus', () {
      const filter = QuestionAnswerFilter(answerStatus: AnswerStatus.skipped);
      final clause = filter.buildWhereClause();

      expect(clause.where, 'answer_status = ?');
      expect(clause.args, ['skipped']);
    });

    test('buildWhereClause builds correct clause for hintUsed', () {
      const filter = QuestionAnswerFilter(hintUsed: HintUsed.fiftyFifty);
      final clause = filter.buildWhereClause();

      expect(clause.where, 'hint_used = ?');
      expect(clause.args, ['50_50']);
    });

    test('buildWhereClause combines multiple conditions with AND', () {
      const filter = QuestionAnswerFilter(
        sessionId: 'session-1',
        isCorrect: false,
        answerStatus: AnswerStatus.incorrect,
      );
      final clause = filter.buildWhereClause();

      expect(clause.where, contains('session_id = ?'));
      expect(clause.where, contains('is_correct = ?'));
      expect(clause.where, contains('answer_status = ?'));
      expect(clause.where, contains(' AND '));
      expect(clause.args.length, 3);
    });

    test('buildWhereClause handles all filters combined', () {
      const filter = QuestionAnswerFilter(
        sessionId: 'session-1',
        questionId: 'q-1',
        isCorrect: true,
        answerStatus: AnswerStatus.correct,
        hintUsed: HintUsed.none,
      );
      final clause = filter.buildWhereClause();

      expect(clause.args.length, 5);
      expect(clause.where.split(' AND ').length, 5);
    });
  });

  group('QuestionAnswerDataSource Interface', () {
    test('QuestionAnswerDataSourceImpl can be instantiated', () {
      expect(
        () => QuestionAnswerDataSourceImpl(),
        returnsNormally,
      );
    });
  });
}
