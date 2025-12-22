import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/model/question.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';
import 'package:quiz_engine_core/src/model/random_pick_result.dart';

void main() {
  group('Question Class Tests', () {
    test('should create a Question with given answer and options', () {
      // Given
      final answer = QuestionEntry(
        type: QuestionType.text("A"),
        otherOptions: {},
      );
      final options = [
        answer,
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];

      // When
      final question = Question(answer, options);

      // Then
      expect(question.answer, equals(answer));
      expect(question.options, equals(options));
    });

    test('should create a Question from RandomPickResult', () {
      // Given
      final answer = QuestionEntry(
        type: QuestionType.text("A"),
        otherOptions: {},
      );
      final options = [
        answer,
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      final randomResult = RandomPickResult(answer, options);

      // When
      final question = Question.fromRandomResult(randomResult);

      // Then
      expect(question.answer, equals(randomResult.answer));
      expect(question.options, equals(randomResult.options));
    });

    test('should create a Question from RandomPickResult', () {
      // Given
      final answer = QuestionEntry(
        type: QuestionType.text("A"),
        otherOptions: {},
      );
      final options = [
        answer,
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      final randomResult = RandomPickResult(answer, options);

      // When
      final question = Question.fromRandomResult(randomResult);

      // Then
      expect(question.answer, equals(randomResult.answer));
      expect(question.options, equals(randomResult.options));
    });

    test('options should contain the answer', () {
      // Given
      final answer = QuestionEntry(
        type: QuestionType.text("A"),
        otherOptions: {},
      );
      final options = [
        answer,
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];

      // When
      final question = Question(answer, options);

      // Then
      expect(question.options.contains(answer), isTrue);
    });

    test('should maintain correct options order', () {
      // Given
      final answer = QuestionEntry(
        type: QuestionType.text("A"),
        otherOptions: {},
      );
      final options = [
        answer,
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];

      // When
      final question = Question(answer, options);

      // Then
      expect(question.options, equals(options));
    });

    test('should handle case where options list has only one item', () {
      // Given
      final answer = QuestionEntry(
        type: QuestionType.text("A"),
        otherOptions: {},
      );
      final options = [answer];

      // When
      final question = Question(answer, options);

      // Then
      expect(question.answer, equals(answer));
      expect(question.options.length, equals(1));
      expect(question.options.first, equals(answer));
    });
  });
}
