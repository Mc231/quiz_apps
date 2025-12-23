import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('SessionWithAnswers', () {
    final testSession = QuizSession(
      id: 'test-session-1',
      quizName: 'Test Quiz',
      quizId: 'quiz-1',
      quizType: 'flags',
      totalQuestions: 10,
      totalAnswered: 10,
      totalCorrect: 7,
      totalFailed: 3,
      totalSkipped: 0,
      scorePercentage: 70.0,
      startTime: DateTime.now(),
      completionStatus: CompletionStatus.completed,
      mode: QuizMode.normal,
      appVersion: '1.0.0',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final correctAnswer = QuestionAnswer(
      id: 'answer-1',
      sessionId: 'test-session-1',
      questionNumber: 1,
      questionId: 'q1',
      questionType: QuestionType.image,
      option1: const AnswerOption(id: 'opt1', text: 'Option 1'),
      option2: const AnswerOption(id: 'opt2', text: 'Option 2'),
      option3: const AnswerOption(id: 'opt3', text: 'Option 3'),
      option4: const AnswerOption(id: 'opt4', text: 'Option 4'),
      optionsOrder: ['opt1', 'opt2', 'opt3', 'opt4'],
      correctAnswer: const AnswerOption(id: 'opt1', text: 'Option 1'),
      userAnswer: const AnswerOption(id: 'opt1', text: 'Option 1'),
      isCorrect: true,
      answerStatus: AnswerStatus.correct,
      createdAt: DateTime.now(),
    );

    final wrongAnswer = QuestionAnswer(
      id: 'answer-2',
      sessionId: 'test-session-1',
      questionNumber: 2,
      questionId: 'q2',
      questionType: QuestionType.image,
      option1: const AnswerOption(id: 'opt1', text: 'Option 1'),
      option2: const AnswerOption(id: 'opt2', text: 'Option 2'),
      option3: const AnswerOption(id: 'opt3', text: 'Option 3'),
      option4: const AnswerOption(id: 'opt4', text: 'Option 4'),
      optionsOrder: ['opt1', 'opt2', 'opt3', 'opt4'],
      correctAnswer: const AnswerOption(id: 'opt1', text: 'Option 1'),
      userAnswer: const AnswerOption(id: 'opt2', text: 'Option 2'),
      isCorrect: false,
      answerStatus: AnswerStatus.incorrect,
      createdAt: DateTime.now(),
    );

    test('creates SessionWithAnswers correctly', () {
      final sessionWithAnswers = SessionWithAnswers(
        session: testSession,
        answers: [correctAnswer, wrongAnswer],
      );

      expect(sessionWithAnswers.session, testSession);
      expect(sessionWithAnswers.answers.length, 2);
      expect(sessionWithAnswers.questionCount, 2);
    });

    test('wrongAnswers returns only incorrect answers', () {
      final sessionWithAnswers = SessionWithAnswers(
        session: testSession,
        answers: [correctAnswer, wrongAnswer],
      );

      expect(sessionWithAnswers.wrongAnswers.length, 1);
      expect(sessionWithAnswers.wrongAnswers.first.isCorrect, false);
    });

    test('correctAnswers returns only correct answers', () {
      final sessionWithAnswers = SessionWithAnswers(
        session: testSession,
        answers: [correctAnswer, wrongAnswer],
      );

      expect(sessionWithAnswers.correctAnswers.length, 1);
      expect(sessionWithAnswers.correctAnswers.first.isCorrect, true);
    });

    test('toString returns descriptive string', () {
      final sessionWithAnswers = SessionWithAnswers(
        session: testSession,
        answers: [correctAnswer, wrongAnswer],
      );

      expect(sessionWithAnswers.toString(), contains('test-session-1'));
      expect(sessionWithAnswers.toString(), contains('2'));
    });
  });

  group('QuizSessionRepository Interface', () {
    test('QuizSessionRepositoryImpl can be instantiated', () {
      expect(
        () => QuizSessionRepositoryImpl(
          sessionDataSource: QuizSessionDataSourceImpl(),
          answerDataSource: QuestionAnswerDataSourceImpl(),
          statsDataSource: StatisticsDataSourceImpl(),
        ),
        returnsNormally,
      );
    });

    test('QuizSessionRepositoryImpl accepts custom cache duration', () {
      expect(
        () => QuizSessionRepositoryImpl(
          sessionDataSource: QuizSessionDataSourceImpl(),
          answerDataSource: QuestionAnswerDataSourceImpl(),
          statsDataSource: StatisticsDataSourceImpl(),
          cacheDuration: const Duration(minutes: 10),
        ),
        returnsNormally,
      );
    });
  });

  group('QuizSessionRepository Stream support', () {
    // Note: Stream tests that trigger database access are skipped in unit tests.
    // Integration tests with sqflite_ffi would be needed for full coverage.

    test('repository can be instantiated for stream operations', () {
      final repository = QuizSessionRepositoryImpl(
        sessionDataSource: QuizSessionDataSourceImpl(),
        answerDataSource: QuestionAnswerDataSourceImpl(),
        statsDataSource: StatisticsDataSourceImpl(),
      );

      // Verify the repository is created successfully
      expect(repository, isNotNull);

      // Clean up without triggering database access
      repository.dispose();
    });
  });

  group('QuizSessionRepository Cache', () {
    test('clearCache executes without error', () {
      final repository = QuizSessionRepositoryImpl(
        sessionDataSource: QuizSessionDataSourceImpl(),
        answerDataSource: QuestionAnswerDataSourceImpl(),
        statsDataSource: StatisticsDataSourceImpl(),
      );

      expect(() => repository.clearCache(), returnsNormally);

      repository.dispose();
    });
  });
}
