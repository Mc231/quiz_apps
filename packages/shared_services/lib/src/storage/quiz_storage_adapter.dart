/// Adapter for connecting quiz_engine_core storage interface with shared_services storage.
///
/// This adapter implements the [QuizStorageService] interface from quiz_engine_core
/// and uses the shared_services [StorageService] as the backend.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:uuid/uuid.dart';

import 'models/question_answer.dart' as storage;
import 'models/quiz_session.dart' as storage;
import 'storage_service.dart';

/// Adapter that bridges quiz_engine_core QuizStorageService with shared_services StorageService.
///
/// Example usage:
/// ```dart
/// final storageService = sl.get<StorageService>();
/// final adapter = QuizStorageAdapter(storageService);
///
/// final bloc = QuizBloc(
///   dataProvider,
///   randomItemPicker,
///   configManager: configManager,
///   storageService: adapter,
/// );
/// ```
class QuizStorageAdapter implements QuizStorageService {
  /// Creates a [QuizStorageAdapter].
  QuizStorageAdapter(this._storageService);

  final StorageService _storageService;
  static const _uuid = Uuid();

  @override
  Future<String> createSession({
    required QuizConfig config,
    required int totalQuestions,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now();

    final session = storage.QuizSession(
      id: sessionId,
      quizName: config.storageConfig.quizName ?? config.quizId,
      quizId: config.quizId,
      quizType: config.storageConfig.quizType ?? 'general',
      quizCategory: config.storageConfig.quizCategory,
      totalQuestions: totalQuestions,
      totalAnswered: 0,
      totalCorrect: 0,
      totalFailed: 0,
      totalSkipped: 0,
      scorePercentage: 0.0,
      livesUsed: 0,
      startTime: now,
      endTime: null,
      durationSeconds: null,
      completionStatus: storage.CompletionStatus.cancelled, // Will be updated on completion
      mode: _mapQuizMode(config.modeConfig),
      timeLimitSeconds: config.modeConfig.totalTimeLimit,
      hintsUsed5050: 0,
      hintsUsedSkip: 0,
      appVersion: config.storageConfig.appVersion,
      createdAt: now,
      updatedAt: now,
      layoutMode: _mapLayoutMode(config.layoutConfig),
    );

    final result = await _storageService.saveQuizSession(session);
    if (result.isSuccess) {
      return sessionId;
    }
    throw Exception('Failed to create session: ${result.error?.message}');
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
    final answerId = _uuid.v4();
    final now = DateTime.now();

    // Extract question data
    final questionId = _extractQuestionId(question.answer);
    final questionType = _mapQuestionType(question.answer.type);
    final options = question.options;

    // Build answer model
    final answer = storage.QuestionAnswer(
      id: answerId,
      sessionId: sessionId,
      questionNumber: questionNumber,
      questionId: questionId,
      questionType: questionType,
      questionContent: _extractQuestionContent(question.answer),
      questionResourceUrl: _extractResourceUrl(question.answer),
      option1: _createAnswerOption(options.isNotEmpty ? options[0] : null, 0),
      option2: _createAnswerOption(options.length > 1 ? options[1] : null, 1),
      option3: _createAnswerOption(options.length > 2 ? options[2] : null, 2),
      option4: _createAnswerOption(options.length > 3 ? options[3] : null, 3),
      optionsOrder: options.map((o) => _extractQuestionId(o)).toList(),
      correctAnswer: _createAnswerOption(question.answer, 0),
      userAnswer: selectedAnswer != null
          ? _createAnswerOption(selectedAnswer, 0)
          : null,
      isCorrect: isCorrect,
      answerStatus: _mapAnswerStatus(status),
      timeSpentSeconds: timeSpentSeconds,
      answeredAt: now,
      hintUsed: _mapHintUsed(hintUsed),
      disabledOptions: disabledOptions.map((o) => _extractQuestionId(o)).toList(),
      explanation: null,
      createdAt: now,
      layoutUsed: layoutUsed,
    );

    final result = await _storageService.saveQuestionAnswer(answer);
    if (result.isFailure) {
      throw Exception('Failed to save answer: ${result.error?.message}');
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
    final scorePercentage = totalAnswered > 0
        ? (totalCorrect / totalAnswered) * 100
        : 0.0;

    final result = await _storageService.updateSessionScore(
      sessionId: sessionId,
      totalAnswered: totalAnswered,
      totalCorrect: totalCorrect,
      totalFailed: totalFailed,
      totalSkipped: totalSkipped,
      scorePercentage: scorePercentage,
    );

    if (result.isFailure) {
      throw Exception('Failed to update progress: ${result.error?.message}');
    }
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
    // First update the score
    final scorePercentage = totalAnswered > 0
        ? (totalCorrect / totalAnswered) * 100
        : 0.0;

    await _storageService.updateSessionScore(
      sessionId: sessionId,
      totalAnswered: totalAnswered,
      totalCorrect: totalCorrect,
      totalFailed: totalFailed,
      totalSkipped: totalSkipped,
      scorePercentage: scorePercentage,
      bestStreak: bestStreak,
      score: score,
    );

    // Then complete the session
    final result = await _storageService.completeSession(
      sessionId,
      _mapCompletionStatus(status),
    );

    if (result.isFailure) {
      throw Exception('Failed to complete session: ${result.error?.message}');
    }
  }

  @override
  Future<bool> hasRecoverableSession(String quizId) async {
    return _storageService.hasRecoverableSession(quizId);
  }

  @override
  Future<RecoverableSession?> getRecoverableSession(String quizId) async {
    final result = await _storageService.getRecoverableSession(quizId);

    if (result.isFailure || result.valueOrNull == null) {
      return null;
    }

    final sessionWithAnswers = result.value!;
    final session = sessionWithAnswers.session;
    final answers = sessionWithAnswers.answers;

    return RecoverableSession(
      sessionId: session.id,
      quizId: session.quizId,
      currentQuestionNumber: answers.length + 1,
      answeredQuestions: answers.map((a) => a.questionId).toSet(),
      correctCount: session.totalCorrect,
      failedCount: session.totalFailed,
      skippedCount: session.totalSkipped,
      remainingLives: null, // Would need to calculate from mode config
      elapsedSeconds: session.durationSeconds ?? 0,
      startTime: session.startTime,
    );
  }

  @override
  Future<void> clearRecoverableSession(String sessionId) async {
    // Mark the session as cancelled so it's no longer recoverable
    await _storageService.completeSession(
      sessionId,
      storage.CompletionStatus.cancelled,
    );
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final result = await _storageService.deleteSession(sessionId);
    if (result.isFailure) {
      throw Exception('Failed to delete session: ${result.error?.message}');
    }
  }

  @override
  void dispose() {
    // StorageService is managed by DI, don't dispose it here
  }

  // ===========================================================================
  // Helper Methods
  // ===========================================================================

  storage.QuizMode _mapQuizMode(QuizModeConfig mode) {
    return switch (mode) {
      StandardMode() => storage.QuizMode.normal,
      TimedMode() => storage.QuizMode.timed,
      LivesMode() => storage.QuizMode.survival,
      EndlessMode() => storage.QuizMode.endless,
      SurvivalMode() => storage.QuizMode.survival,
    };
  }

  storage.QuestionType _mapQuestionType(QuestionType type) {
    return switch (type) {
      ImageQuestion() => storage.QuestionType.image,
      TextQuestion() => storage.QuestionType.text,
      AudioQuestion() => storage.QuestionType.audio,
      VideoQuestion() => storage.QuestionType.video,
    };
  }

  storage.AnswerStatus _mapAnswerStatus(AnswerStatus status) {
    return switch (status) {
      AnswerStatus.correct => storage.AnswerStatus.correct,
      AnswerStatus.incorrect => storage.AnswerStatus.incorrect,
      AnswerStatus.skipped => storage.AnswerStatus.skipped,
      AnswerStatus.timeout => storage.AnswerStatus.timeout,
    };
  }

  storage.HintUsed _mapHintUsed(HintType? hintType) {
    if (hintType == null) return storage.HintUsed.none;

    return switch (hintType) {
      HintType.fiftyFifty => storage.HintUsed.fiftyFifty,
      HintType.skip => storage.HintUsed.skip,
      HintType.revealLetter => storage.HintUsed.none, // Not stored separately
      HintType.extraTime => storage.HintUsed.none, // Not stored separately
    };
  }

  storage.CompletionStatus _mapCompletionStatus(SessionCompletionStatus status) {
    return switch (status) {
      SessionCompletionStatus.completed => storage.CompletionStatus.completed,
      SessionCompletionStatus.cancelled => storage.CompletionStatus.cancelled,
      SessionCompletionStatus.timeout => storage.CompletionStatus.timeout,
      SessionCompletionStatus.failed => storage.CompletionStatus.failed,
    };
  }

  String _extractQuestionId(QuestionEntry entry) {
    return entry.otherOptions['id']?.toString() ?? _uuid.v4();
  }

  String? _extractQuestionContent(QuestionEntry entry) {
    return entry.otherOptions['content']?.toString() ??
        entry.otherOptions['text']?.toString() ??
        entry.otherOptions['name']?.toString();
  }

  String? _extractResourceUrl(QuestionEntry entry) {
    // First try to extract from the question type itself
    final type = entry.type;

    if (type is ImageQuestion) {
      return type.imagePath;
    } else if (type is AudioQuestion) {
      return type.audioPath;
    } else if (type is VideoQuestion) {
      return type.videoUrl;
    }

    // Fallback to otherOptions for backwards compatibility
    return entry.otherOptions['url']?.toString() ??
        entry.otherOptions['imageUrl']?.toString() ??
        entry.otherOptions['resourceUrl']?.toString();
  }

  storage.AnswerOption _createAnswerOption(QuestionEntry? entry, int index) {
    if (entry == null) {
      return storage.AnswerOption(
        id: 'option_$index',
        text: '',
      );
    }

    return storage.AnswerOption(
      id: _extractQuestionId(entry),
      text: _extractQuestionContent(entry) ?? 'Option ${index + 1}',
    );
  }

  /// Maps a [QuizLayoutConfig] to its string representation for storage.
  String _mapLayoutMode(QuizLayoutConfig layout) {
    return switch (layout) {
      ImageQuestionTextAnswersLayout() => 'imageQuestionTextAnswers',
      TextQuestionImageAnswersLayout() => 'textQuestionImageAnswers',
      TextQuestionTextAnswersLayout() => 'textQuestionTextAnswers',
      AudioQuestionTextAnswersLayout() => 'audioQuestionTextAnswers',
      MixedLayout() => 'mixed',
    };
  }
}
