import '../../model/answer.dart';
import '../../model/question.dart';
import '../../model/question_entry.dart';
import '../../storage/quiz_storage_service.dart';

/// Processes answers and creates Answer objects.
///
/// This manager is responsible for:
/// - Creating Answer objects from user selections
/// - Creating timeout answers
/// - Creating skipped answers
/// - Determining answer correctness
class QuizAnswerProcessor {
  /// Creates a new answer processor.
  QuizAnswerProcessor();

  /// Creates a regular answer from user selection.
  ///
  /// [selectedItem] - The option selected by the user
  /// [question] - The current question
  ///
  /// Returns the created Answer with correctness determined.
  Answer createAnswer(QuestionEntry selectedItem, Question question) {
    return Answer(selectedItem, question);
  }

  /// Creates a timeout answer.
  ///
  /// [question] - The question that timed out
  ///
  /// Returns an Answer marked as timed out.
  Answer createTimeoutAnswer(Question question) {
    return Answer(
      question.answer,
      question,
      isTimeout: true,
    );
  }

  /// Creates a skipped answer.
  ///
  /// [question] - The question that was skipped
  ///
  /// Returns an Answer marked as skipped.
  Answer createSkippedAnswer(Question question) {
    return Answer(
      question.answer,
      question,
      isSkipped: true,
    );
  }

  /// Determines the storage status for an answer.
  ///
  /// [answer] - The answer to get status for
  ///
  /// Returns the appropriate AnswerStatus for storage.
  AnswerStatus getAnswerStatus(Answer answer) {
    if (answer.isSkipped) {
      return AnswerStatus.skipped;
    }
    if (answer.isTimeout) {
      return AnswerStatus.timeout;
    }
    return answer.isCorrect ? AnswerStatus.correct : AnswerStatus.incorrect;
  }

  /// Creates answer data for regular answers.
  ///
  /// [selectedItem] - The option selected by the user
  /// [question] - The current question
  ///
  /// Returns a record with answer details for further processing.
  ({Answer answer, bool isCorrect, AnswerStatus status}) processUserAnswer(
    QuestionEntry selectedItem,
    Question question,
  ) {
    final answer = createAnswer(selectedItem, question);
    return (
      answer: answer,
      isCorrect: answer.isCorrect,
      status: getAnswerStatus(answer),
    );
  }

  /// Creates answer data for timeout.
  ///
  /// [question] - The question that timed out
  ///
  /// Returns a record with timeout answer details.
  ({Answer answer, bool isCorrect, AnswerStatus status}) processTimeout(
    Question question,
  ) {
    final answer = createTimeoutAnswer(question);
    return (
      answer: answer,
      isCorrect: false,
      status: AnswerStatus.timeout,
    );
  }

  /// Creates answer data for skip.
  ///
  /// [question] - The question that was skipped
  ///
  /// Returns a record with skip answer details.
  ({Answer answer, bool isCorrect, AnswerStatus status}) processSkip(
    Question question,
  ) {
    final answer = createSkippedAnswer(question);
    return (
      answer: answer,
      isCorrect: false,
      status: AnswerStatus.skipped,
    );
  }
}
