import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/business_logic/managers/quiz_session_manager.dart';
import 'package:quiz_engine_core/src/model/config/hint_config.dart';
import 'package:quiz_engine_core/src/model/config/quiz_config.dart';
import 'package:quiz_engine_core/src/model/config/quiz_mode_config.dart';
import 'package:quiz_engine_core/src/model/config/storage_config.dart';
import 'package:quiz_engine_core/src/model/question.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';
import 'package:quiz_engine_core/src/storage/quiz_storage_service.dart';

/// A mock storage service for testing.
class MockQuizStorageService implements QuizStorageService {
  String? lastCreatedSessionId;
  int createSessionCallCount = 0;
  int saveAnswerCallCount = 0;
  int completeSessionCallCount = 0;
  int deleteSessionCallCount = 0;

  SessionCompletionStatus? lastCompletionStatus;
  bool shouldThrowOnCreate = false;
  bool shouldThrowOnSave = false;
  bool shouldThrowOnComplete = false;
  bool shouldThrowOnDelete = false;

  bool hasRecoverableSessionResult = false;
  RecoverableSession? recoverableSessionResult;

  @override
  Future<String> createSession({
    required QuizConfig config,
    required int totalQuestions,
  }) async {
    createSessionCallCount++;
    if (shouldThrowOnCreate) {
      throw Exception('Storage error');
    }
    lastCreatedSessionId = 'test-session-$createSessionCallCount';
    return lastCreatedSessionId!;
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required int questionNumber,
    required Question question,
    required QuestionEntry? selectedAnswer,
    required bool isCorrect,
    required AnswerStatus status,
    required int? timeSpentSeconds,
    required HintType? hintUsed,
    required Set<QuestionEntry> disabledOptions,
    String? layoutUsed,
  }) async {
    saveAnswerCallCount++;
    if (shouldThrowOnSave) {
      throw Exception('Storage error');
    }
  }

  @override
  Future<void> updateSessionProgress({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
  }) async {
    // Not tested directly
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required SessionCompletionStatus status,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required int durationSeconds,
    required int hintsUsed5050,
    required int hintsUsedSkip,
    int bestStreak = 0,
    int score = 0,
  }) async {
    completeSessionCallCount++;
    lastCompletionStatus = status;
    if (shouldThrowOnComplete) {
      throw Exception('Storage error');
    }
  }

  @override
  Future<bool> hasRecoverableSession(String quizId) async {
    return hasRecoverableSessionResult;
  }

  @override
  Future<RecoverableSession?> getRecoverableSession(String quizId) async {
    return recoverableSessionResult;
  }

  @override
  Future<void> clearRecoverableSession(String sessionId) async {
    // Not tested directly
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    deleteSessionCallCount++;
    if (shouldThrowOnDelete) {
      throw Exception('Storage error');
    }
  }

  @override
  void dispose() {
    // Nothing to dispose
  }
}

void main() {
  late QuizSessionManager manager;
  late MockQuizStorageService mockStorage;

  // Test data
  final testEntry1 = QuestionEntry(type: TextQuestion('Answer 1'));
  final testEntry2 = QuestionEntry(type: TextQuestion('Answer 2'));

  QuizConfig createConfig({bool storageEnabled = true, bool saveAnswers = true}) {
    return QuizConfig(
      quizId: 'test-quiz',
      modeConfig: const StandardMode(showAnswerFeedback: true),
      storageConfig: StorageConfig(
        enabled: storageEnabled,
        saveAnswersDuringQuiz: saveAnswers,
      ),
    );
  }

  Question createQuestion() {
    return Question(testEntry1, [testEntry1, testEntry2]);
  }

  setUp(() {
    mockStorage = MockQuizStorageService();
    manager = QuizSessionManager(storageService: mockStorage);
  });

  group('QuizSessionManager initialization', () {
    test('should start with no session', () {
      expect(manager.currentSessionId, isNull);
      expect(manager.isStorageEnabled, isFalse);
    });

    test('should create session when storage is enabled', () async {
      final config = createConfig();

      final sessionId = await manager.initializeSession(
        config: config,
        totalQuestions: 10,
      );

      expect(sessionId, isNotNull);
      expect(manager.currentSessionId, equals(sessionId));
      expect(manager.isStorageEnabled, isTrue);
      expect(mockStorage.createSessionCallCount, equals(1));
    });

    test('should not create session when storage is disabled', () async {
      final config = createConfig(storageEnabled: false);

      final sessionId = await manager.initializeSession(
        config: config,
        totalQuestions: 10,
      );

      expect(sessionId, isNull);
      expect(manager.currentSessionId, isNull);
      expect(manager.isStorageEnabled, isFalse);
      expect(mockStorage.createSessionCallCount, equals(0));
    });

    test('should handle storage error gracefully', () async {
      mockStorage.shouldThrowOnCreate = true;
      final config = createConfig();

      final sessionId = await manager.initializeSession(
        config: config,
        totalQuestions: 10,
      );

      expect(sessionId, isNull);
      expect(manager.currentSessionId, isNull);
    });

    test('should work without storage service', () async {
      final managerWithoutStorage = QuizSessionManager();
      final config = createConfig();

      final sessionId = await managerWithoutStorage.initializeSession(
        config: config,
        totalQuestions: 10,
      );

      expect(sessionId, isNull);
      expect(managerWithoutStorage.isStorageEnabled, isFalse);
    });
  });

  group('QuizSessionManager answer saving', () {
    setUp(() async {
      await manager.initializeSession(
        config: createConfig(),
        totalQuestions: 10,
      );
    });

    test('should save answer when enabled', () async {
      final question = createQuestion();

      await manager.saveAnswer(
        questionNumber: 1,
        question: question,
        selectedAnswer: testEntry1,
        isCorrect: true,
        status: AnswerStatus.correct,
        timeSpentSeconds: 5,
        hintUsed: null,
        disabledOptions: {},
      );

      expect(mockStorage.saveAnswerCallCount, equals(1));
    });

    test('should not save answer when saveAnswersDuringQuiz is false', () async {
      manager = QuizSessionManager(storageService: mockStorage);
      await manager.initializeSession(
        config: createConfig(saveAnswers: false),
        totalQuestions: 10,
      );

      final question = createQuestion();

      await manager.saveAnswer(
        questionNumber: 1,
        question: question,
        selectedAnswer: testEntry1,
        isCorrect: true,
        status: AnswerStatus.correct,
        timeSpentSeconds: 5,
        hintUsed: null,
        disabledOptions: {},
      );

      expect(mockStorage.saveAnswerCallCount, equals(0));
    });

    test('should handle save error gracefully', () async {
      mockStorage.shouldThrowOnSave = true;
      final question = createQuestion();

      // Should not throw
      await manager.saveAnswer(
        questionNumber: 1,
        question: question,
        selectedAnswer: testEntry1,
        isCorrect: true,
        status: AnswerStatus.correct,
        timeSpentSeconds: 5,
        hintUsed: null,
        disabledOptions: {},
      );
    });
  });

  group('QuizSessionManager session completion', () {
    setUp(() async {
      await manager.initializeSession(
        config: createConfig(),
        totalQuestions: 10,
      );
    });

    test('should complete session', () async {
      await manager.completeSession(
        status: SessionCompletionStatus.completed,
        totalAnswered: 10,
        totalCorrect: 8,
        totalFailed: 2,
        totalSkipped: 0,
        durationSeconds: 120,
        hintsUsed5050: 1,
        hintsUsedSkip: 0,
        bestStreak: 5,
        score: 100,
      );

      expect(mockStorage.completeSessionCallCount, equals(1));
      expect(mockStorage.lastCompletionStatus, equals(SessionCompletionStatus.completed));
    });

    test('should handle complete error gracefully', () async {
      mockStorage.shouldThrowOnComplete = true;

      // Should not throw
      await manager.completeSession(
        status: SessionCompletionStatus.completed,
        totalAnswered: 10,
        totalCorrect: 8,
        totalFailed: 2,
        totalSkipped: 0,
        durationSeconds: 120,
        hintsUsed5050: 1,
        hintsUsedSkip: 0,
      );
    });

    test('should not complete when storage disabled', () async {
      manager = QuizSessionManager(storageService: mockStorage);
      await manager.initializeSession(
        config: createConfig(storageEnabled: false),
        totalQuestions: 10,
      );

      await manager.completeSession(
        status: SessionCompletionStatus.completed,
        totalAnswered: 10,
        totalCorrect: 8,
        totalFailed: 2,
        totalSkipped: 0,
        durationSeconds: 120,
        hintsUsed5050: 0,
        hintsUsedSkip: 0,
      );

      expect(mockStorage.completeSessionCallCount, equals(0));
    });
  });

  group('QuizSessionManager session cancellation', () {
    setUp(() async {
      await manager.initializeSession(
        config: createConfig(),
        totalQuestions: 10,
      );
    });

    test('should delete session when no answers given', () async {
      await manager.cancelSession(
        hasAnswers: false,
        totalCorrect: 0,
        totalFailed: 0,
        totalSkipped: 0,
        durationSeconds: 5,
        hintsUsed5050: 0,
        hintsUsedSkip: 0,
      );

      expect(mockStorage.deleteSessionCallCount, equals(1));
      expect(mockStorage.completeSessionCallCount, equals(0));
    });

    test('should complete as cancelled when answers given', () async {
      await manager.cancelSession(
        hasAnswers: true,
        totalCorrect: 3,
        totalFailed: 2,
        totalSkipped: 1,
        durationSeconds: 60,
        hintsUsed5050: 1,
        hintsUsedSkip: 0,
        bestStreak: 2,
      );

      expect(mockStorage.deleteSessionCallCount, equals(0));
      expect(mockStorage.completeSessionCallCount, equals(1));
      expect(mockStorage.lastCompletionStatus, equals(SessionCompletionStatus.cancelled));
    });

    test('should handle cancel error gracefully', () async {
      mockStorage.shouldThrowOnDelete = true;

      // Should not throw
      await manager.cancelSession(
        hasAnswers: false,
        totalCorrect: 0,
        totalFailed: 0,
        totalSkipped: 0,
        durationSeconds: 5,
        hintsUsed5050: 0,
        hintsUsedSkip: 0,
      );
    });
  });

  group('QuizSessionManager session recovery', () {
    test('should check for recoverable session', () async {
      mockStorage.hasRecoverableSessionResult = true;

      final hasSession = await manager.hasRecoverableSession('test-quiz');

      expect(hasSession, isTrue);
    });

    test('should get recoverable session', () async {
      final expectedSession = RecoverableSession(
        sessionId: 'session-1',
        quizId: 'test-quiz',
        currentQuestionNumber: 5,
        answeredQuestions: {'q1', 'q2', 'q3', 'q4'},
        correctCount: 3,
        failedCount: 1,
        skippedCount: 0,
        remainingLives: 2,
        elapsedSeconds: 120,
        startTime: DateTime.now(),
      );
      mockStorage.recoverableSessionResult = expectedSession;

      final session = await manager.getRecoverableSession('test-quiz');

      expect(session, equals(expectedSession));
    });

    test('should return false for recoverable when no storage service', () async {
      final managerWithoutStorage = QuizSessionManager();

      final hasSession = await managerWithoutStorage.hasRecoverableSession('test-quiz');

      expect(hasSession, isFalse);
    });
  });

  group('QuizSessionManager reset and dispose', () {
    test('should reset state', () async {
      await manager.initializeSession(
        config: createConfig(),
        totalQuestions: 10,
      );

      expect(manager.currentSessionId, isNotNull);

      manager.reset();

      expect(manager.currentSessionId, isNull);
      expect(manager.isStorageEnabled, isFalse);
    });

    test('should dispose storage service', () async {
      await manager.initializeSession(
        config: createConfig(),
        totalQuestions: 10,
      );

      manager.dispose();

      expect(manager.currentSessionId, isNull);
    });
  });
}
