import '../widgets/question_review_widget.dart';

/// Data model for session details.
class SessionDetailData {
  /// Creates a [SessionDetailData].
  const SessionDetailData({
    required this.id,
    required this.quizName,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalSkipped,
    required this.scorePercentage,
    required this.completionStatus,
    required this.startTime,
    required this.questions,
    this.durationSeconds,
    this.quizCategory,
  });

  /// Unique session ID.
  final String id;

  /// Display name of the quiz.
  final String quizName;

  /// Total questions in the session.
  final int totalQuestions;

  /// Number of correct answers.
  final int totalCorrect;

  /// Number of incorrect answers.
  final int totalIncorrect;

  /// Number of skipped questions.
  final int totalSkipped;

  /// Score as percentage.
  final double scorePercentage;

  /// Completion status.
  final String completionStatus;

  /// When the session started.
  final DateTime startTime;

  /// Duration in seconds.
  final int? durationSeconds;

  /// Optional quiz category.
  final String? quizCategory;

  /// List of answered questions.
  final List<ReviewedQuestion> questions;

  /// Whether this is a perfect score.
  bool get isPerfectScore => scorePercentage >= 100.0;

  /// Count of wrong answers.
  int get wrongAnswersCount =>
      questions.where((q) => !q.isCorrect && !q.isSkipped).length;
}

/// Filter mode for displaying questions.
enum QuestionFilterMode {
  /// Show all questions.
  all,

  /// Show only wrong answers.
  wrongOnly,
}
