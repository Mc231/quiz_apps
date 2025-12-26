import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/business_logic/managers/quiz_progress_tracker.dart';
import 'package:quiz_engine_core/src/model/answer.dart';
import 'package:quiz_engine_core/src/model/question.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';

void main() {
  late QuizProgressTracker tracker;

  // Test data
  final testEntry1 = QuestionEntry(type: TextQuestion('What is 2+2?'));
  final testEntry2 = QuestionEntry(type: TextQuestion('What is 3+3?'));
  final testEntry3 = QuestionEntry(type: TextQuestion('What is 4+4?'));

  Question createQuestion(QuestionEntry correctAnswer) {
    return Question(correctAnswer, [testEntry1, testEntry2, testEntry3, correctAnswer]);
  }

  setUp(() {
    tracker = QuizProgressTracker();
  });

  group('QuizProgressTracker initialization', () {
    test('should start uninitialized', () {
      expect(tracker.isInitialized, isFalse);
      expect(tracker.totalCount, equals(0));
      expect(tracker.remainingLives, isNull);
    });

    test('should initialize with total count', () {
      tracker.initialize(totalCount: 10);

      expect(tracker.isInitialized, isTrue);
      expect(tracker.totalCount, equals(10));
      expect(tracker.remainingLives, isNull);
    });

    test('should initialize with lives', () {
      tracker.initialize(totalCount: 10, initialLives: 3);

      expect(tracker.isInitialized, isTrue);
      expect(tracker.totalCount, equals(10));
      expect(tracker.remainingLives, equals(3));
    });
  });

  group('QuizProgressTracker answer recording', () {
    setUp(() {
      tracker.initialize(totalCount: 10);
    });

    test('should record correct answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry1, question);

      tracker.recordAnswer(answer);

      expect(tracker.answers.length, equals(1));
      expect(tracker.currentProgress, equals(1));
      expect(tracker.correctAnswers, equals(1));
      expect(tracker.incorrectAnswers, equals(0));
    });

    test('should record incorrect answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry2, question); // Wrong answer

      tracker.recordAnswer(answer);

      expect(tracker.answers.length, equals(1));
      expect(tracker.currentProgress, equals(1));
      expect(tracker.correctAnswers, equals(0));
      expect(tracker.incorrectAnswers, equals(1));
    });

    test('should record skipped answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry1, question, isSkipped: true);

      tracker.recordAnswer(answer);

      expect(tracker.skippedAnswers, equals(1));
      expect(tracker.incorrectAnswers, equals(0)); // Skipped != incorrect
    });

    test('should record timed out answer', () {
      final question = createQuestion(testEntry1);
      final answer = Answer(testEntry1, question, isTimeout: true);

      tracker.recordAnswer(answer);

      expect(tracker.timedOutAnswers, equals(1));
      expect(tracker.incorrectAnswers, equals(0)); // Timeout != incorrect
      expect(tracker.totalFailedAnswers, equals(1));
    });

    test('should calculate progress percentage', () {
      tracker.initialize(totalCount: 4);
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry1, question));
      expect(tracker.progressPercentage, equals(0.25));

      tracker.recordAnswer(Answer(testEntry1, question));
      expect(tracker.progressPercentage, equals(0.5));
    });
  });

  group('QuizProgressTracker streak tracking', () {
    setUp(() {
      tracker.initialize(totalCount: 10);
    });

    test('should track consecutive correct answers', () {
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry1, question)); // Correct
      expect(tracker.currentStreak, equals(1));
      expect(tracker.bestStreak, equals(1));

      tracker.recordAnswer(Answer(testEntry1, question)); // Correct
      expect(tracker.currentStreak, equals(2));
      expect(tracker.bestStreak, equals(2));

      tracker.recordAnswer(Answer(testEntry1, question)); // Correct
      expect(tracker.currentStreak, equals(3));
      expect(tracker.bestStreak, equals(3));
    });

    test('should reset streak on wrong answer', () {
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry1, question)); // Correct
      tracker.recordAnswer(Answer(testEntry1, question)); // Correct
      expect(tracker.currentStreak, equals(2));

      tracker.recordAnswer(Answer(testEntry2, question)); // Wrong
      expect(tracker.currentStreak, equals(0));
      expect(tracker.bestStreak, equals(2)); // Best streak preserved
    });

    test('should preserve best streak across multiple streaks', () {
      final question = createQuestion(testEntry1);

      // First streak of 3
      tracker.recordAnswer(Answer(testEntry1, question));
      tracker.recordAnswer(Answer(testEntry1, question));
      tracker.recordAnswer(Answer(testEntry1, question));
      expect(tracker.bestStreak, equals(3));

      // Break streak
      tracker.recordAnswer(Answer(testEntry2, question));
      expect(tracker.currentStreak, equals(0));

      // New streak of 2
      tracker.recordAnswer(Answer(testEntry1, question));
      tracker.recordAnswer(Answer(testEntry1, question));
      expect(tracker.currentStreak, equals(2));
      expect(tracker.bestStreak, equals(3)); // Still 3
    });
  });

  group('QuizProgressTracker lives management', () {
    test('should deduct life on wrong answer', () {
      tracker.initialize(totalCount: 10, initialLives: 3);
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry2, question)); // Wrong
      expect(tracker.remainingLives, equals(2));

      tracker.recordAnswer(Answer(testEntry2, question)); // Wrong
      expect(tracker.remainingLives, equals(1));
    });

    test('should not deduct life on correct answer', () {
      tracker.initialize(totalCount: 10, initialLives: 3);
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry1, question)); // Correct
      expect(tracker.remainingLives, equals(3));
    });

    test('should not deduct life on skipped answer', () {
      tracker.initialize(totalCount: 10, initialLives: 3);
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry1, question, isSkipped: true));
      expect(tracker.remainingLives, equals(3));
    });

    test('should detect when out of lives', () {
      tracker.initialize(totalCount: 10, initialLives: 2);
      final question = createQuestion(testEntry1);

      expect(tracker.isOutOfLives, isFalse);

      tracker.recordAnswer(Answer(testEntry2, question)); // Wrong
      expect(tracker.isOutOfLives, isFalse);

      tracker.recordAnswer(Answer(testEntry2, question)); // Wrong
      expect(tracker.isOutOfLives, isTrue);
    });

    test('should manually deduct life', () {
      tracker.initialize(totalCount: 10, initialLives: 3);

      tracker.deductLife();
      expect(tracker.remainingLives, equals(2));

      tracker.deductLife();
      expect(tracker.remainingLives, equals(1));
    });

    test('should not deduct life below zero', () {
      tracker.initialize(totalCount: 10, initialLives: 1);

      tracker.deductLife();
      expect(tracker.remainingLives, equals(0));

      tracker.deductLife(); // Should not go negative
      expect(tracker.remainingLives, equals(0));
    });

    test('should not deduct life when lives mode is inactive', () {
      tracker.initialize(totalCount: 10); // No lives

      tracker.deductLife(); // Should do nothing
      expect(tracker.remainingLives, isNull);
    });
  });

  group('QuizProgressTracker reset', () {
    test('should reset progress but preserve configuration', () {
      tracker.initialize(totalCount: 10, initialLives: 3);
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry1, question));
      tracker.recordAnswer(Answer(testEntry1, question));

      tracker.reset();

      expect(tracker.answers, isEmpty);
      expect(tracker.currentProgress, equals(0));
      expect(tracker.currentStreak, equals(0));
      expect(tracker.bestStreak, equals(0));
      expect(tracker.totalCount, equals(10)); // Preserved
    });

    test('should completely reset with resetAll', () {
      tracker.initialize(totalCount: 10, initialLives: 3);
      final question = createQuestion(testEntry1);

      tracker.recordAnswer(Answer(testEntry1, question));

      tracker.resetAll();

      expect(tracker.isInitialized, isFalse);
      expect(tracker.totalCount, equals(0));
      expect(tracker.remainingLives, isNull);
      expect(tracker.answers, isEmpty);
    });
  });

  group('QuizProgressTracker statistics', () {
    test('should calculate all statistics correctly', () {
      tracker.initialize(totalCount: 10, initialLives: 5);
      final question = createQuestion(testEntry1);

      // 3 correct
      tracker.recordAnswer(Answer(testEntry1, question));
      tracker.recordAnswer(Answer(testEntry1, question));
      tracker.recordAnswer(Answer(testEntry1, question));

      // 2 incorrect
      tracker.recordAnswer(Answer(testEntry2, question));
      tracker.recordAnswer(Answer(testEntry2, question));

      // 1 skipped
      tracker.recordAnswer(Answer(testEntry1, question, isSkipped: true));

      // 1 timeout
      tracker.recordAnswer(Answer(testEntry1, question, isTimeout: true));

      expect(tracker.correctAnswers, equals(3));
      expect(tracker.incorrectAnswers, equals(2));
      expect(tracker.skippedAnswers, equals(1));
      expect(tracker.timedOutAnswers, equals(1));
      expect(tracker.totalFailedAnswers, equals(3)); // 2 incorrect + 1 timeout
      expect(tracker.currentProgress, equals(7));
      expect(tracker.remainingLives, equals(3)); // 5 - 2 wrong answers
    });
  });
}
