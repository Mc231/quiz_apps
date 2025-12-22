import 'package:quiz_engine_core/src/model/question.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';

/// Represents an answer to a quiz question.
///
/// The `Answer` class encapsulates a user's selected option for a given
/// quiz question. It provides a method to check if the selected option
/// is correct by comparing it with the correct answer from the `Question`
/// object. This class is useful in quiz or game applications where users
/// select answers to multiple-choice questions.
///
/// Example usage:
/// ```dart
/// Country selectedCountry = Country(name: 'France');
/// Question question = Question(answer: Country(name: 'France'), options: [selectedCountry, ...]);
///
/// Answer answer = Answer(selectedCountry, question);
/// print('Is the answer correct? ${answer.isCorrect}'); // Output: Is the answer correct? true
/// ```
class Answer {
  /// The option selected by the user.
  final QuestionEntry selectedOption;

  /// The question for which the answer is provided.
  final Question question;

  /// Whether this answer was caused by a timeout (time expiration).
  final bool isTimeout;

  /// Creates an `Answer<T>` with the given [selectedOption] and [question].
  ///
  /// [selectedOption] is the choice made by the user.
  /// [question] is the question object that includes the correct answer
  /// and other options.
  /// [isTimeout] indicates if this answer was due to time expiration (default: false).
  Answer(
    this.selectedOption,
    this.question, {
    this.isTimeout = false,
  });

  /// Checks if the selected option is the correct answer.
  ///
  /// This getter compares the [selectedOption] with the correct answer
  /// in the [question]. It returns `true` if the selected option matches
  /// the correct answer and the answer was not caused by a timeout.
  /// Timeouts are always counted as incorrect, regardless of the selected option.
  bool get isCorrect => !isTimeout && question.answer == selectedOption;
}
