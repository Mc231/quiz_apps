import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('NoOpQuizStorageService', () {
    late NoOpQuizStorageService service;

    setUp(() {
      service = NoOpQuizStorageService();
    });

    test('createSession returns a valid UUID', () async {
      final config = QuizConfig(quizId: 'test_quiz');
      final sessionId = await service.createSession(
        config: config,
        totalQuestions: 10,
      );

      expect(sessionId, isNotEmpty);
      expect(sessionId.length, equals(36)); // UUID format
    });

    test('saveAnswer completes without error', () async {
      final question = Question(
        QuestionEntry(type: QuestionType.text('Question 1'), otherOptions: {'id': '1'}),
        [
          QuestionEntry(type: QuestionType.text('Option 1'), otherOptions: {'id': '1'}),
          QuestionEntry(type: QuestionType.text('Option 2'), otherOptions: {'id': '2'}),
          QuestionEntry(type: QuestionType.text('Option 3'), otherOptions: {'id': '3'}),
          QuestionEntry(type: QuestionType.text('Option 4'), otherOptions: {'id': '4'}),
        ],
      );

      await expectLater(
        service.saveAnswer(
          sessionId: 'test-session',
          questionNumber: 1,
          question: question,
          selectedAnswer: question.options[0],
          isCorrect: true,
          status: AnswerStatus.correct,
          timeSpentSeconds: 5,
          hintUsed: null,
          disabledOptions: {},
        ),
        completes,
      );
    });

    test('updateSessionProgress completes without error', () async {
      await expectLater(
        service.updateSessionProgress(
          sessionId: 'test-session',
          totalAnswered: 5,
          totalCorrect: 4,
          totalFailed: 1,
          totalSkipped: 0,
        ),
        completes,
      );
    });

    test('completeSession completes without error', () async {
      await expectLater(
        service.completeSession(
          sessionId: 'test-session',
          status: SessionCompletionStatus.completed,
          totalAnswered: 10,
          totalCorrect: 8,
          totalFailed: 2,
          totalSkipped: 0,
          durationSeconds: 120,
          hintsUsed5050: 1,
          hintsUsedSkip: 0,
        ),
        completes,
      );
    });

    test('hasRecoverableSession always returns false', () async {
      final result = await service.hasRecoverableSession('test_quiz');
      expect(result, isFalse);
    });

    test('getRecoverableSession always returns null', () async {
      final result = await service.getRecoverableSession('test_quiz');
      expect(result, isNull);
    });

    test('clearRecoverableSession completes without error', () async {
      await expectLater(
        service.clearRecoverableSession('test-session'),
        completes,
      );
    });

    test('dispose completes without error', () {
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('CallbackQuizStorageService', () {
    test('delegates to callbacks', () async {
      var createSessionCalled = false;
      var saveAnswerCalled = false;
      var updateProgressCalled = false;
      var completeSessionCalled = false;

      final service = CallbackQuizStorageService(
        onCreateSession: ({required config, required totalQuestions}) async {
          createSessionCalled = true;
          return 'test-session-id';
        },
        onSaveAnswer: ({
          required sessionId,
          required questionNumber,
          required question,
          required selectedAnswer,
          required isCorrect,
          required status,
          required timeSpentSeconds,
          required hintUsed,
          required disabledOptions,
          layoutUsed,
        }) async {
          saveAnswerCalled = true;
        },
        onUpdateProgress: ({
          required sessionId,
          required totalAnswered,
          required totalCorrect,
          required totalFailed,
          required totalSkipped,
        }) async {
          updateProgressCalled = true;
        },
        onCompleteSession: ({
          required sessionId,
          required status,
          required totalAnswered,
          required totalCorrect,
          required totalFailed,
          required totalSkipped,
          required durationSeconds,
          required hintsUsed5050,
          required hintsUsedSkip,
          bestStreak = 0,
          score = 0,
        }) async {
          completeSessionCalled = true;
        },
        onHasRecoverableSession: (quizId) async => false,
        onGetRecoverableSession: (quizId) async => null,
        onClearRecoverableSession: (sessionId) async {},
        onDeleteSession: (sessionId) async {},
      );

      // Create session
      final config = QuizConfig(quizId: 'test');
      final sessionId = await service.createSession(
        config: config,
        totalQuestions: 10,
      );
      expect(createSessionCalled, isTrue);
      expect(sessionId, equals('test-session-id'));

      // Save answer
      final question = Question(
        QuestionEntry(type: QuestionType.text('Q1'), otherOptions: {'id': '1'}),
        [
          QuestionEntry(type: QuestionType.text('O1'), otherOptions: {'id': '1'}),
          QuestionEntry(type: QuestionType.text('O2'), otherOptions: {'id': '2'}),
        ],
      );
      await service.saveAnswer(
        sessionId: 'test',
        questionNumber: 1,
        question: question,
        selectedAnswer: question.options[0],
        isCorrect: true,
        status: AnswerStatus.correct,
        timeSpentSeconds: 5,
        hintUsed: null,
        disabledOptions: {},
      );
      expect(saveAnswerCalled, isTrue);

      // Update progress
      await service.updateSessionProgress(
        sessionId: 'test',
        totalAnswered: 1,
        totalCorrect: 1,
        totalFailed: 0,
        totalSkipped: 0,
      );
      expect(updateProgressCalled, isTrue);

      // Complete session
      await service.completeSession(
        sessionId: 'test',
        status: SessionCompletionStatus.completed,
        totalAnswered: 1,
        totalCorrect: 1,
        totalFailed: 0,
        totalSkipped: 0,
        durationSeconds: 10,
        hintsUsed5050: 0,
        hintsUsedSkip: 0,
      );
      expect(completeSessionCalled, isTrue);
    });
  });

  group('AnswerStatus', () {
    test('has correct values', () {
      expect(AnswerStatus.correct, isNotNull);
      expect(AnswerStatus.incorrect, isNotNull);
      expect(AnswerStatus.skipped, isNotNull);
      expect(AnswerStatus.timeout, isNotNull);
    });
  });

  group('SessionCompletionStatus', () {
    test('has correct values', () {
      expect(SessionCompletionStatus.completed, isNotNull);
      expect(SessionCompletionStatus.cancelled, isNotNull);
      expect(SessionCompletionStatus.timeout, isNotNull);
      expect(SessionCompletionStatus.failed, isNotNull);
    });
  });

  group('RecoverableSession', () {
    test('can be created with valid data', () {
      final session = RecoverableSession(
        sessionId: 'test-session',
        quizId: 'test-quiz',
        currentQuestionNumber: 5,
        answeredQuestions: {'q1', 'q2', 'q3', 'q4'},
        correctCount: 3,
        failedCount: 1,
        skippedCount: 0,
        remainingLives: 2,
        elapsedSeconds: 60,
        startTime: DateTime.now(),
      );

      expect(session.sessionId, equals('test-session'));
      expect(session.quizId, equals('test-quiz'));
      expect(session.currentQuestionNumber, equals(5));
      expect(session.answeredQuestions.length, equals(4));
      expect(session.correctCount, equals(3));
      expect(session.failedCount, equals(1));
      expect(session.skippedCount, equals(0));
      expect(session.remainingLives, equals(2));
      expect(session.elapsedSeconds, equals(60));
      expect(session.totalAnswered, equals(4));
    });

    test('totalAnswered calculates correctly', () {
      final session = RecoverableSession(
        sessionId: 'test',
        quizId: 'test',
        currentQuestionNumber: 10,
        answeredQuestions: {},
        correctCount: 5,
        failedCount: 2,
        skippedCount: 2,
        remainingLives: null,
        elapsedSeconds: 0,
        startTime: DateTime.now(),
      );

      expect(session.totalAnswered, equals(9)); // 5 + 2 + 2
    });
  });

  group('QuizModeToString extension', () {
    test('modeString returns correct values', () {
      expect(const StandardMode(showAnswerFeedback: true).modeString, equals('normal'));
      expect(const TimedMode(showAnswerFeedback: true).modeString, equals('timed'));
      expect(const LivesMode(showAnswerFeedback: true).modeString, equals('survival'));
      expect(const EndlessMode(showAnswerFeedback: true).modeString, equals('endless'));
      expect(const SurvivalMode(showAnswerFeedback: true).modeString, equals('survival'));
    });

    test('questionTimeLimit returns correct values', () {
      expect(const StandardMode(showAnswerFeedback: true).questionTimeLimit, isNull);
      expect(const TimedMode(showAnswerFeedback: true, timePerQuestion: 30).questionTimeLimit, equals(30));
      expect(const LivesMode(showAnswerFeedback: true).questionTimeLimit, isNull);
      expect(const EndlessMode(showAnswerFeedback: true).questionTimeLimit, isNull);
      expect(const SurvivalMode(showAnswerFeedback: true, timePerQuestion: 20).questionTimeLimit, equals(20));
    });

    test('totalTimeLimit returns correct values', () {
      expect(const StandardMode(showAnswerFeedback: true).totalTimeLimit, isNull);
      expect(const TimedMode(showAnswerFeedback: true, totalTimeLimit: 300).totalTimeLimit, equals(300));
      expect(const TimedMode(showAnswerFeedback: true).totalTimeLimit, isNull);
      expect(const LivesMode(showAnswerFeedback: true).totalTimeLimit, isNull);
      expect(const EndlessMode(showAnswerFeedback: true).totalTimeLimit, isNull);
      expect(const SurvivalMode(showAnswerFeedback: true, totalTimeLimit: 600).totalTimeLimit, equals(600));
    });
  });
}
