/// Quiz analytics service for tracking quiz events.
///
/// This abstract interface defines the contract for quiz analytics operations.
/// Implementations connect to the actual analytics backend (e.g., shared_services).
///
/// The interface is designed to be minimal and focused on quiz-specific events,
/// allowing the quiz engine to remain decoupled from analytics implementations.
library;

import '../model/config/quiz_mode_config.dart';
import '../model/question.dart';
import '../model/question_entry.dart';
import '../model/quiz_results.dart';

/// Interface for quiz analytics operations.
///
/// Implementations of this interface should handle the actual analytics
/// logging (e.g., Firebase Analytics, Amplitude, etc.).
abstract class QuizAnalyticsService {
  // ============ Quiz Lifecycle Events ============

  /// Tracks when a quiz is started.
  Future<void> trackQuizStarted({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String categoryName,
    required QuizModeConfig modeConfig,
    required int totalQuestions,
    int? initialLives,
    int? initialHints,
  });

  /// Tracks when a quiz is completed (all questions answered).
  Future<void> trackQuizCompleted({
    required QuizResults results,
  });

  /// Tracks when a quiz is cancelled (user exited early).
  Future<void> trackQuizCancelled({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required Duration timeSpent,
  });

  /// Tracks when a quiz fails (lives depleted).
  Future<void> trackQuizFailed({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required Duration duration,
    required String reason,
  });

  /// Tracks when a quiz times out (total time expired).
  Future<void> trackQuizTimeout({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
  });

  /// Tracks when a quiz is paused (app went to background).
  Future<void> trackQuizPaused({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
  });

  /// Tracks when a quiz is resumed (app returned to foreground).
  Future<void> trackQuizResumed({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
    required Duration pauseDuration,
  });

  // ============ Question Events ============

  /// Tracks when a question is displayed.
  Future<void> trackQuestionDisplayed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int totalQuestions,
    int? timeLimit,
  });

  /// Tracks when a question is answered.
  Future<void> trackQuestionAnswered({
    required String quizId,
    required Question question,
    required int questionIndex,
    required bool isCorrect,
    required Duration responseTime,
    required QuestionEntry selectedAnswer,
    int? currentStreak,
    int? livesRemaining,
  });

  /// Tracks when a question is skipped.
  Future<void> trackQuestionSkipped({
    required String quizId,
    required Question question,
    required int questionIndex,
    required Duration timeBeforeSkip,
    required bool usedHint,
    int? hintsRemaining,
  });

  /// Tracks when a question times out.
  Future<void> trackQuestionTimeout({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int timeLimit,
    int? livesRemaining,
  });

  /// Tracks when a user selects an answer option.
  Future<void> trackOptionSelected({
    required String quizId,
    required Question question,
    required int questionIndex,
    required QuestionEntry selectedOption,
    required int optionIndex,
    required Duration timeSinceDisplayed,
  });

  /// Tracks when answer feedback is shown to the user.
  Future<void> trackFeedbackShown({
    required String quizId,
    required Question question,
    required int questionIndex,
    required bool wasCorrect,
    required Duration feedbackDuration,
  });

  // ============ Hint Events ============

  /// Tracks when a 50/50 hint is used.
  Future<void> trackHintFiftyFiftyUsed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required List<QuestionEntry> eliminatedOptions,
  });

  /// Tracks when a skip hint is used.
  Future<void> trackHintSkipUsed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required Duration timeBeforeSkip,
  });

  // ============ Resource Events ============

  /// Tracks when a life is lost.
  Future<void> trackLifeLost({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int livesRemaining,
    required int livesTotal,
    required String reason,
  });

  /// Tracks when all lives are depleted.
  Future<void> trackLivesDepleted({
    required String quizId,
    required String quizName,
    required String categoryId,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required Duration duration,
  });

  /// Disposes of resources.
  void dispose();
}

/// A no-op implementation of [QuizAnalyticsService].
///
/// Use this when analytics is disabled or for testing.
class NoOpQuizAnalyticsService implements QuizAnalyticsService {
  @override
  Future<void> trackQuizStarted({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String categoryName,
    required QuizModeConfig modeConfig,
    required int totalQuestions,
    int? initialLives,
    int? initialHints,
  }) async {}

  @override
  Future<void> trackQuizCompleted({required QuizResults results}) async {}

  @override
  Future<void> trackQuizCancelled({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required Duration timeSpent,
  }) async {}

  @override
  Future<void> trackQuizFailed({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required Duration duration,
    required String reason,
  }) async {}

  @override
  Future<void> trackQuizTimeout({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
  }) async {}

  @override
  Future<void> trackQuizPaused({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
  }) async {}

  @override
  Future<void> trackQuizResumed({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
    required Duration pauseDuration,
  }) async {}

  @override
  Future<void> trackQuestionDisplayed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int totalQuestions,
    int? timeLimit,
  }) async {}

  @override
  Future<void> trackQuestionAnswered({
    required String quizId,
    required Question question,
    required int questionIndex,
    required bool isCorrect,
    required Duration responseTime,
    required QuestionEntry selectedAnswer,
    int? currentStreak,
    int? livesRemaining,
  }) async {}

  @override
  Future<void> trackQuestionSkipped({
    required String quizId,
    required Question question,
    required int questionIndex,
    required Duration timeBeforeSkip,
    required bool usedHint,
    int? hintsRemaining,
  }) async {}

  @override
  Future<void> trackQuestionTimeout({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int timeLimit,
    int? livesRemaining,
  }) async {}

  @override
  Future<void> trackOptionSelected({
    required String quizId,
    required Question question,
    required int questionIndex,
    required QuestionEntry selectedOption,
    required int optionIndex,
    required Duration timeSinceDisplayed,
  }) async {}

  @override
  Future<void> trackFeedbackShown({
    required String quizId,
    required Question question,
    required int questionIndex,
    required bool wasCorrect,
    required Duration feedbackDuration,
  }) async {}

  @override
  Future<void> trackHintFiftyFiftyUsed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required List<QuestionEntry> eliminatedOptions,
  }) async {}

  @override
  Future<void> trackHintSkipUsed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required Duration timeBeforeSkip,
  }) async {}

  @override
  Future<void> trackLifeLost({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int livesRemaining,
    required int livesTotal,
    required String reason,
  }) async {}

  @override
  Future<void> trackLivesDepleted({
    required String quizId,
    required String quizName,
    required String categoryId,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required Duration duration,
  }) async {}

  @override
  void dispose() {}
}
