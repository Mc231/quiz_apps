import '../../model/question.dart';
import '../../model/question_entry.dart';
import '../../model/config/hint_config.dart';

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
  }) = AnswerFeedbackState;
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
  });
}
