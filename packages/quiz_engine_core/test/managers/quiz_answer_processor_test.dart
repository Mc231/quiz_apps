import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/business_logic/managers/quiz_answer_processor.dart';
import 'package:quiz_engine_core/src/model/answer.dart';
import 'package:quiz_engine_core/src/model/question.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';
import 'package:quiz_engine_core/src/storage/quiz_storage_service.dart';

void main() {
  late QuizAnswerProcessor processor;

  // Test data
  final testEntry1 = QuestionEntry(type: TextQuestion('Answer 1'));
  final testEntry2 = QuestionEntry(type: TextQuestion('Answer 2'));
  final testEntry3 = QuestionEntry(type: TextQuestion('Answer 3'));
  final testEntry4 = QuestionEntry(type: TextQuestion('Answer 4'));

  Question createQuestion(QuestionEntry correctAnswer) {
    return Question(
      correctAnswer,
      [testEntry1, testEntry2, testEntry3, testEntry4],
    );
  }

  setUp(() {
    processor = QuizAnswerProcessor();
  });

  group('QuizAnswerProcessor createAnswer', () {
    test('should create correct answer when correct option selected', () {
      final question = createQuestion(testEntry1);

      final answer = processor.createAnswer(testEntry1, question);

      expect(answer.isCorrect, isTrue);
      expect(answer.isSkipped, isFalse);
      expect(answer.isTimeout, isFalse);
      expect(answer.selectedOption, equals(testEntry1));
      expect(answer.question, equals(question));
    });

    test('should create incorrect answer when wrong option selected', () {
      final question = createQuestion(testEntry1);

      final answer = processor.createAnswer(testEntry2, question);

      expect(answer.isCorrect, isFalse);
      expect(answer.isSkipped, isFalse);
      expect(answer.isTimeout, isFalse);
      expect(answer.selectedOption, equals(testEntry2));
    });
  });

  group('QuizAnswerProcessor createTimeoutAnswer', () {
    test('should create timeout answer', () {
      final question = createQuestion(testEntry1);

      final answer = processor.createTimeoutAnswer(question);

      expect(answer.isTimeout, isTrue);
      expect(answer.isSkipped, isFalse);
      expect(answer.question, equals(question));
      // Timeout answers use the correct answer as selected option
      expect(answer.selectedOption, equals(testEntry1));
    });
  });

  group('QuizAnswerProcessor createSkippedAnswer', () {
    test('should create skipped answer', () {
      final question = createQuestion(testEntry1);

      final answer = processor.createSkippedAnswer(question);

      expect(answer.isSkipped, isTrue);
      expect(answer.isTimeout, isFalse);
      expect(answer.question, equals(question));
      // Skipped answers use the correct answer as selected option
      expect(answer.selectedOption, equals(testEntry1));
    });
  });

  group('QuizAnswerProcessor getAnswerStatus', () {
    test('should return correct status for correct answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry1, question);

      final status = processor.getAnswerStatus(answer);

      expect(status, equals(AnswerStatus.correct));
    });

    test('should return incorrect status for wrong answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry2, question);

      final status = processor.getAnswerStatus(answer);

      expect(status, equals(AnswerStatus.incorrect));
    });

    test('should return skipped status for skipped answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry1, question, isSkipped: true);

      final status = processor.getAnswerStatus(answer);

      expect(status, equals(AnswerStatus.skipped));
    });

    test('should return timeout status for timeout answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry1, question, isTimeout: true);

      final status = processor.getAnswerStatus(answer);

      expect(status, equals(AnswerStatus.timeout));
    });

    test('should prioritize skipped over correctness', () {
      final question = createQuestion(testEntry1);
      // Skipped but would be correct
      final answer = Answer(testEntry1, question, isSkipped: true);

      final status = processor.getAnswerStatus(answer);

      expect(status, equals(AnswerStatus.skipped));
    });
  });

  group('QuizAnswerProcessor processUserAnswer', () {
    test('should process correct user answer', () {
      final question = createQuestion(testEntry1);

      final result = processor.processUserAnswer(testEntry1, question);

      expect(result.answer.isCorrect, isTrue);
      expect(result.isCorrect, isTrue);
      expect(result.status, equals(AnswerStatus.correct));
    });

    test('should process incorrect user answer', () {
      final question = createQuestion(testEntry1);

      final result = processor.processUserAnswer(testEntry2, question);

      expect(result.answer.isCorrect, isFalse);
      expect(result.isCorrect, isFalse);
      expect(result.status, equals(AnswerStatus.incorrect));
    });
  });

  group('QuizAnswerProcessor processTimeout', () {
    test('should process timeout correctly', () {
      final question = createQuestion(testEntry1);

      final result = processor.processTimeout(question);

      expect(result.answer.isTimeout, isTrue);
      expect(result.isCorrect, isFalse);
      expect(result.status, equals(AnswerStatus.timeout));
    });
  });

  group('QuizAnswerProcessor processSkip', () {
    test('should process skip correctly', () {
      final question = createQuestion(testEntry1);

      final result = processor.processSkip(question);

      expect(result.answer.isSkipped, isTrue);
      expect(result.isCorrect, isFalse);
      expect(result.status, equals(AnswerStatus.skipped));
    });
  });
}
