import 'answer.dart';
import 'config/quiz_mode_config.dart';
import 'config/scoring_strategy.dart';

/// Represents the results of a completed quiz session.
///
/// This class contains all the data about a completed quiz,
/// including scores, timing, and individual answers.
class QuizResults {
  /// Creates a [QuizResults] instance.
  const QuizResults({
    required this.sessionId,
    required this.quizId,
    required this.quizName,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedAnswers,
    required this.timedOutAnswers,
    required this.durationSeconds,
    required this.modeConfig,
    required this.answers,
    this.hintsUsed5050 = 0,
    this.hintsUsedSkip = 0,
    this.score = 0,
    this.scoreBreakdown,
    this.layoutMode,
  });

  /// The unique session ID (from storage).
  final String? sessionId;

  /// The quiz identifier (e.g., "flags_europe", "capitals_asia").
  final String quizId;

  /// Human-readable name of the quiz.
  final String quizName;

  /// When the quiz was completed.
  final DateTime completedAt;

  /// Total number of questions in the quiz.
  final int totalQuestions;

  /// Number of correctly answered questions.
  final int correctAnswers;

  /// Number of incorrectly answered questions.
  final int incorrectAnswers;

  /// Number of skipped questions (using skip hint).
  final int skippedAnswers;

  /// Number of questions that timed out.
  final int timedOutAnswers;

  /// Total duration of the quiz in seconds.
  final int durationSeconds;

  /// The quiz mode configuration that was used.
  final QuizModeConfig modeConfig;

  /// List of all answers given during the quiz.
  final List<Answer> answers;

  /// Number of 50/50 hints used.
  final int hintsUsed5050;

  /// Number of skip hints used.
  final int hintsUsedSkip;

  /// Total score earned in this quiz session.
  final int score;

  /// Breakdown of the score (base points + bonus points).
  final ScoreBreakdownData? scoreBreakdown;

  /// The layout mode used for this quiz session.
  final String? layoutMode;

  /// Total hints used (50/50 + skip).
  int get totalHintsUsed => hintsUsed5050 + hintsUsedSkip;

  /// The score as a percentage (0-100).
  double get scorePercentage {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Whether this is a perfect score (100%).
  bool get isPerfectScore => correctAnswers == totalQuestions;

  /// Number of stars earned based on score percentage.
  ///
  /// - 5 stars: 100%
  /// - 4 stars: 80-99%
  /// - 3 stars: 60-79%
  /// - 2 stars: 40-59%
  /// - 1 star: 20-39%
  /// - 0 stars: 0-19%
  int get starRating {
    final percentage = scorePercentage;
    if (percentage >= 100) return 5;
    if (percentage >= 80) return 4;
    if (percentage >= 60) return 3;
    if (percentage >= 40) return 2;
    if (percentage >= 20) return 1;
    return 0;
  }

  /// Formatted duration string (e.g., "2m 30s" or "45s").
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// List of wrong answers (incorrect + timed out, excluding skipped).
  List<Answer> get wrongAnswers {
    return answers.where((a) => !a.isCorrect && !a.isSkipped).toList();
  }

  /// Creates a copy of this QuizResults with the given fields replaced.
  QuizResults copyWith({
    String? sessionId,
    String? quizId,
    String? quizName,
    DateTime? completedAt,
    int? totalQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
    int? skippedAnswers,
    int? timedOutAnswers,
    int? durationSeconds,
    QuizModeConfig? modeConfig,
    List<Answer>? answers,
    int? hintsUsed5050,
    int? hintsUsedSkip,
    int? score,
    ScoreBreakdownData? scoreBreakdown,
    String? layoutMode,
  }) {
    return QuizResults(
      sessionId: sessionId ?? this.sessionId,
      quizId: quizId ?? this.quizId,
      quizName: quizName ?? this.quizName,
      completedAt: completedAt ?? this.completedAt,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      skippedAnswers: skippedAnswers ?? this.skippedAnswers,
      timedOutAnswers: timedOutAnswers ?? this.timedOutAnswers,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      modeConfig: modeConfig ?? this.modeConfig,
      answers: answers ?? this.answers,
      hintsUsed5050: hintsUsed5050 ?? this.hintsUsed5050,
      hintsUsedSkip: hintsUsedSkip ?? this.hintsUsedSkip,
      score: score ?? this.score,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      layoutMode: layoutMode ?? this.layoutMode,
    );
  }

  @override
  String toString() {
    return 'QuizResults('
        'sessionId: $sessionId, '
        'quizId: $quizId, '
        'quizName: $quizName, '
        'correct: $correctAnswers/$totalQuestions (${scorePercentage.toStringAsFixed(1)}%), '
        'score: $score pts, '
        'stars: $starRating, '
        'duration: $formattedDuration'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizResults &&
        other.sessionId == sessionId &&
        other.quizId == quizId &&
        other.quizName == quizName &&
        other.completedAt == completedAt &&
        other.totalQuestions == totalQuestions &&
        other.correctAnswers == correctAnswers &&
        other.incorrectAnswers == incorrectAnswers &&
        other.skippedAnswers == skippedAnswers &&
        other.timedOutAnswers == timedOutAnswers &&
        other.durationSeconds == durationSeconds &&
        other.modeConfig == modeConfig &&
        other.hintsUsed5050 == hintsUsed5050 &&
        other.hintsUsedSkip == hintsUsedSkip &&
        other.score == score;
  }

  @override
  int get hashCode {
    return Object.hash(
      sessionId,
      quizId,
      quizName,
      completedAt,
      totalQuestions,
      correctAnswers,
      incorrectAnswers,
      skippedAnswers,
      timedOutAnswers,
      durationSeconds,
      modeConfig,
      hintsUsed5050,
      hintsUsedSkip,
      score,
    );
  }
}
