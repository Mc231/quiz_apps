import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('QuizResults', () {
    late QuizResults results;
    late List<Answer> answers;

    setUp(() {
      // Create test question entries
      final entry1 = QuestionEntry(
        type: TextQuestion('Question 1'),
        otherOptions: {'id': '1'},
      );
      final entry2 = QuestionEntry(
        type: TextQuestion('Question 2'),
        otherOptions: {'id': '2'},
      );
      final entry3 = QuestionEntry(
        type: TextQuestion('Question 3'),
        otherOptions: {'id': '3'},
      );

      // Create test questions
      final question1 = Question(entry1, [entry1, entry2, entry3]);
      final question2 = Question(entry2, [entry1, entry2, entry3]);
      final question3 = Question(entry3, [entry1, entry2, entry3]);

      // Create test answers (2 correct, 1 incorrect)
      answers = [
        Answer(entry1, question1), // Correct
        Answer(entry2, question2), // Correct
        Answer(entry1, question3), // Incorrect (wrong answer)
      ];

      results = QuizResults(
        sessionId: 'test-session-123',
        quizId: 'test-quiz',
        quizName: 'Test Quiz',
        completedAt: DateTime(2024, 1, 15, 10, 30),
        totalQuestions: 3,
        correctAnswers: 2,
        incorrectAnswers: 1,
        skippedAnswers: 0,
        timedOutAnswers: 0,
        durationSeconds: 120,
        modeConfig: const StandardMode(),
        answers: answers,
        hintsUsed5050: 1,
        hintsUsedSkip: 0,
      );
    });

    test('scorePercentage calculates correctly', () {
      expect(results.scorePercentage, closeTo(66.67, 0.01));
    });

    test('scorePercentage returns 0 when totalQuestions is 0', () {
      final emptyResults = QuizResults(
        sessionId: null,
        quizId: 'test',
        quizName: 'Test',
        completedAt: DateTime.now(),
        totalQuestions: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        skippedAnswers: 0,
        timedOutAnswers: 0,
        durationSeconds: 0,
        modeConfig: const StandardMode(),
        answers: [],
      );
      expect(emptyResults.scorePercentage, 0);
    });

    test('isPerfectScore returns true when all answers are correct', () {
      final perfectResults = results.copyWith(
        correctAnswers: 3,
        incorrectAnswers: 0,
      );
      expect(perfectResults.isPerfectScore, true);
    });

    test('isPerfectScore returns false when some answers are incorrect', () {
      expect(results.isPerfectScore, false);
    });

    group('starRating', () {
      test('returns 5 stars for 100%', () {
        final perfect = results.copyWith(
          correctAnswers: 3,
          incorrectAnswers: 0,
        );
        expect(perfect.starRating, 5);
      });

      test('returns 4 stars for 80-99%', () {
        final results80 = QuizResults(
          sessionId: null,
          quizId: 'test',
          quizName: 'Test',
          completedAt: DateTime.now(),
          totalQuestions: 10,
          correctAnswers: 8,
          incorrectAnswers: 2,
          skippedAnswers: 0,
          timedOutAnswers: 0,
          durationSeconds: 60,
          modeConfig: const StandardMode(),
          answers: [],
        );
        expect(results80.starRating, 4);
      });

      test('returns 3 stars for 60-79%', () {
        expect(results.starRating, 3); // 66.67%
      });

      test('returns 2 stars for 40-59%', () {
        final results40 = QuizResults(
          sessionId: null,
          quizId: 'test',
          quizName: 'Test',
          completedAt: DateTime.now(),
          totalQuestions: 10,
          correctAnswers: 4,
          incorrectAnswers: 6,
          skippedAnswers: 0,
          timedOutAnswers: 0,
          durationSeconds: 60,
          modeConfig: const StandardMode(),
          answers: [],
        );
        expect(results40.starRating, 2);
      });

      test('returns 1 star for 20-39%', () {
        final results20 = QuizResults(
          sessionId: null,
          quizId: 'test',
          quizName: 'Test',
          completedAt: DateTime.now(),
          totalQuestions: 10,
          correctAnswers: 2,
          incorrectAnswers: 8,
          skippedAnswers: 0,
          timedOutAnswers: 0,
          durationSeconds: 60,
          modeConfig: const StandardMode(),
          answers: [],
        );
        expect(results20.starRating, 1);
      });

      test('returns 0 stars for less than 20%', () {
        final results10 = QuizResults(
          sessionId: null,
          quizId: 'test',
          quizName: 'Test',
          completedAt: DateTime.now(),
          totalQuestions: 10,
          correctAnswers: 1,
          incorrectAnswers: 9,
          skippedAnswers: 0,
          timedOutAnswers: 0,
          durationSeconds: 60,
          modeConfig: const StandardMode(),
          answers: [],
        );
        expect(results10.starRating, 0);
      });
    });

    group('formattedDuration', () {
      test('formats seconds only when less than 60 seconds', () {
        final shortResults = results.copyWith(durationSeconds: 45);
        expect(shortResults.formattedDuration, '45s');
      });

      test('formats minutes and seconds', () {
        expect(results.formattedDuration, '2m 0s'); // 120 seconds
      });

      test('formats minutes and seconds correctly', () {
        final longResults = results.copyWith(durationSeconds: 125);
        expect(longResults.formattedDuration, '2m 5s');
      });
    });

    test('totalHintsUsed sums 5050 and skip hints', () {
      expect(results.totalHintsUsed, 1);

      final resultsWithMoreHints = results.copyWith(
        hintsUsed5050: 2,
        hintsUsedSkip: 3,
      );
      expect(resultsWithMoreHints.totalHintsUsed, 5);
    });

    test('wrongAnswers returns incorrect and timed out answers', () {
      expect(results.wrongAnswers.length, 1);
    });

    test('copyWith creates a new instance with updated values', () {
      final updated = results.copyWith(
        quizName: 'Updated Quiz',
        correctAnswers: 3,
      );

      expect(updated.quizName, 'Updated Quiz');
      expect(updated.correctAnswers, 3);
      expect(updated.quizId, results.quizId); // Unchanged
      expect(updated.sessionId, results.sessionId); // Unchanged
    });

    test('toString returns readable string', () {
      final str = results.toString();
      expect(str, contains('QuizResults'));
      expect(str, contains('test-session-123'));
      expect(str, contains('test-quiz'));
      expect(str, contains('Test Quiz'));
    });

    test('equality works correctly', () {
      final sameResults = QuizResults(
        sessionId: 'test-session-123',
        quizId: 'test-quiz',
        quizName: 'Test Quiz',
        completedAt: DateTime(2024, 1, 15, 10, 30),
        totalQuestions: 3,
        correctAnswers: 2,
        incorrectAnswers: 1,
        skippedAnswers: 0,
        timedOutAnswers: 0,
        durationSeconds: 120,
        modeConfig: const StandardMode(),
        answers: answers,
        hintsUsed5050: 1,
        hintsUsedSkip: 0,
      );

      expect(results, equals(sameResults));
    });

    test('hashCode is consistent', () {
      final hash1 = results.hashCode;
      final hash2 = results.hashCode;
      expect(hash1, equals(hash2));
    });

    group('QuizModeConfig variants', () {
      test('works with TimedMode', () {
        final timedResults = results.copyWith(
          modeConfig: const TimedMode(timePerQuestion: 30),
        );
        expect(timedResults.modeConfig, isA<TimedMode>());
      });

      test('works with LivesMode', () {
        final livesResults = results.copyWith(
          modeConfig: const LivesMode(lives: 3),
        );
        expect(livesResults.modeConfig, isA<LivesMode>());
      });

      test('works with EndlessMode', () {
        final endlessResults = results.copyWith(
          modeConfig: const EndlessMode(),
        );
        expect(endlessResults.modeConfig, isA<EndlessMode>());
      });

      test('works with SurvivalMode', () {
        final survivalResults = results.copyWith(
          modeConfig: const SurvivalMode(lives: 3, timePerQuestion: 30),
        );
        expect(survivalResults.modeConfig, isA<SurvivalMode>());
      });
    });
  });

  group('QuizCompletedState', () {
    test('creates state with results', () {
      final results = QuizResults(
        sessionId: 'test',
        quizId: 'quiz',
        quizName: 'Quiz',
        completedAt: DateTime.now(),
        totalQuestions: 5,
        correctAnswers: 3,
        incorrectAnswers: 2,
        skippedAnswers: 0,
        timedOutAnswers: 0,
        durationSeconds: 60,
        modeConfig: const StandardMode(),
        answers: [],
      );

      final state = QuizState.completed(results);
      expect(state, isA<QuizCompletedState>());
      expect((state as QuizCompletedState).results, equals(results));
    });
  });
}
