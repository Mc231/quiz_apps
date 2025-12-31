import '../../model/question.dart';
import '../../model/question_entry.dart';
import '../../model/quiz_results.dart';
import '../../model/config/hint_config.dart';
import '../../model/config/quiz_layout_config.dart';

/// An abstract class representing the state of a quiz.
///
/// This class is **fully generic**, meaning it can work with any type of quiz data (`T`).
/// It serves as a base type for managing different states within the quiz.
sealed class QuizState {
  factory QuizState.loading() = LoadingState;
  factory QuizState.question(
    Question question,
    int progress,
    int total, {
    int? remainingLives,
    int? questionTimeRemaining,
    int? totalTimeRemaining,
    HintState? hintState,
    Set<QuestionEntry>? disabledOptions,
    QuizLayoutConfig? resolvedLayout,
  }) = QuestionState;
  factory QuizState.answerFeedback(
    Question question,
    QuestionEntry selectedAnswer,
    bool isCorrect,
    int progress,
    int total, {
    int? remainingLives,
    int? questionTimeRemaining,
    int? totalTimeRemaining,
    HintState? hintState,
    QuizLayoutConfig? resolvedLayout,
  }) = AnswerFeedbackState;
  factory QuizState.completed(QuizResults results) = QuizCompletedState;
  const QuizState();
}

/// A state representing the loading phase of the quiz.
class LoadingState extends QuizState {}

/// A state representing the question phase of the quiz.
///
class QuestionState extends QuizState {
  /// The current question being presented to the player.
  final Question question;

  /// The number of questions the player has answered so far.
  final int progress;

  /// The total number of questions in the game.
  final int total;

  /// The number of remaining lives (null if lives mode is not enabled).
  final int? remainingLives;

  /// The remaining time for the current question in seconds (null if not in timed mode).
  final int? questionTimeRemaining;

  /// The remaining total time for the entire quiz in seconds (null if no total time limit).
  final int? totalTimeRemaining;

  /// The current state of available hints.
  final HintState? hintState;

  /// Options that are disabled (e.g., from using 50/50 hint).
  final Set<QuestionEntry> disabledOptions;

  /// The resolved layout configuration for this question.
  ///
  /// This is a concrete layout (not [MixedLayout]) that has been resolved
  /// for this specific question index. Used to determine how the question
  /// and answers are displayed.
  final QuizLayoutConfig? resolvedLayout;

  /// Computes the percentage of progress made through the quiz.
  double get percentageProgress =>
      total == 0 ? 0 : (progress / total).toDouble();

  /// Creates a new `QuestionState` with the given question, progress, and total.
  QuestionState(
    this.question,
    this.progress,
    this.total, {
    this.remainingLives,
    this.questionTimeRemaining,
    this.totalTimeRemaining,
    this.hintState,
    Set<QuestionEntry>? disabledOptions,
    this.resolvedLayout,
  }) : disabledOptions = disabledOptions ?? {};
}

/// A state representing the answer feedback phase after the player has answered a question.
///
/// This state shows visual feedback (correct/incorrect) before moving to the next question.
/// The duration of this state is controlled by `UIBehaviorConfig.answerFeedbackDuration`.
class AnswerFeedbackState extends QuizState {
  /// The question that was answered.
  final Question question;

  /// The answer option selected by the player.
  final QuestionEntry selectedAnswer;

  /// Whether the selected answer was correct.
  final bool isCorrect;

  /// The number of questions the player has answered so far.
  final int progress;

  /// The total number of questions in the game.
  final int total;

  /// The number of remaining lives (null if lives mode is not enabled).
  final int? remainingLives;

  /// The remaining time for the current question in seconds (null if not in timed mode).
  final int? questionTimeRemaining;

  /// The remaining total time for the entire quiz in seconds (null if no total time limit).
  final int? totalTimeRemaining;

  /// The current state of available hints (preserved from question state).
  final HintState? hintState;

  /// The resolved layout configuration for this question.
  ///
  /// Preserved from the [QuestionState] for consistent display during feedback.
  final QuizLayoutConfig? resolvedLayout;

  /// Computes the percentage of progress made through the quiz.
  double get percentageProgress =>
      total == 0 ? 0 : (progress / total).toDouble();

  /// Creates a new `AnswerFeedbackState` with the given data.
  AnswerFeedbackState(
    this.question,
    this.selectedAnswer,
    this.isCorrect,
    this.progress,
    this.total, {
    this.remainingLives,
    this.questionTimeRemaining,
    this.totalTimeRemaining,
    this.hintState,
    this.resolvedLayout,
  });
}

/// A state representing the completion of the quiz.
///
/// This state is emitted when the quiz has finished and contains
/// the final results including score, statistics, and all answers.
class QuizCompletedState extends QuizState {
  /// The results of the completed quiz.
  final QuizResults results;

  /// Creates a new `QuizCompletedState` with the given results.
  QuizCompletedState(this.results);
}
