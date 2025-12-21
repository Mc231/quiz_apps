import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/random_pick_result.dart';

/// Represents a question with an answer and multiple options.
///
/// The `Question` class is used to model a question in a quiz or game,
/// including the correct answer and a list of options from which the
/// user can choose. It supports creation from both explicit values and
/// random generation results, making it versatile for different quiz
/// scenarios.
///
/// This class is useful for applications involving quizzes, trivia games,
/// or any interactive content requiring question-and-answer formats.
///
class Question {
  /// The correct answer to the question.
  final QuestionEntry answer;

  /// The list of options available for the question.
  final List<QuestionEntry> options;

  /// Creates a `Question` with the specified [answer] and [options].
  ///
  /// [answer] is the correct option among the list of [options].
  /// [options] is a list containing the possible answers to choose from,
  /// including the correct answer.
  Question(this.answer, this.options);

  /// Creates a `Question` from a `RandomPickResult`.
  ///
  /// This constructor initializes a `Question` using the `answer` and
  /// `options` from a `RandomPickResult`. It allows easy conversion from
  /// random selection results to structured questions.
  ///
  /// [result] is the `RandomPickResult` containing the answer and options
  /// for the question.
  Question.fromRandomResult(RandomPickResult result)
      : this(result.answer, result.options);
}