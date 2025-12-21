import '../../model/question.dart';

/// An abstract class representing the state of a quiz.
///
/// This class is **fully generic**, meaning it can work with any type of quiz data (`T`).
/// It serves as a base type for managing different states within the quiz.
sealed class QuizState {
  factory QuizState.loading() = LoadingState;
  factory QuizState.question(Question question, int progress, int total) = QuestionState;
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

  /// Computes the percentage of progress made through the quiz.
  double get percentageProgress => total == 0 ? 0 : (progress / total).toDouble();

  /// Creates a new `QuestionState` with the given question, progress, and total.
  QuestionState(this.question, this.progress, this.total);
}