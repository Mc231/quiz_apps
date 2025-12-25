/// Quiz session data model for database persistence.
library;

import '../database/tables/quiz_sessions_table.dart';

/// Represents the completion status of a quiz session.
enum CompletionStatus {
  /// The quiz was completed normally (all questions answered).
  completed('completed'),

  /// The user cancelled/exited the quiz early.
  cancelled('cancelled'),

  /// The quiz ended due to time running out.
  timeout('timeout'),

  /// The quiz failed (e.g., ran out of lives in survival mode).
  failed('failed');

  const CompletionStatus(this.value);

  /// The string value stored in the database.
  final String value;

  /// Creates a [CompletionStatus] from its database string value.
  static CompletionStatus fromString(String value) {
    return CompletionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CompletionStatus.cancelled,
    );
  }
}

/// Represents the quiz mode.
enum QuizMode {
  /// Standard quiz mode with no special rules.
  normal('normal'),

  /// Timed mode with a countdown timer.
  timed('timed'),

  /// Endless mode - questions keep coming.
  endless('endless'),

  /// Survival mode - limited lives/hearts.
  survival('survival');

  const QuizMode(this.value);

  /// The string value stored in the database.
  final String value;

  /// Creates a [QuizMode] from its database string value.
  static QuizMode fromString(String value) {
    return QuizMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => QuizMode.normal,
    );
  }
}

/// A quiz session record stored in the database.
class QuizSession {
  /// Creates a new [QuizSession].
  const QuizSession({
    required this.id,
    required this.quizName,
    required this.quizId,
    required this.quizType,
    this.quizCategory,
    required this.totalQuestions,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.totalFailed,
    required this.totalSkipped,
    required this.scorePercentage,
    this.livesUsed = 0,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    required this.completionStatus,
    required this.mode,
    this.timeLimitSeconds,
    this.hintsUsed5050 = 0,
    this.hintsUsedSkip = 0,
    this.bestStreak = 0,
    required this.appVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for the session.
  final String id;

  /// Display name of the quiz.
  final String quizName;

  /// Unique identifier of the quiz definition.
  final String quizId;

  /// Type of quiz (e.g., 'flags', 'capitals').
  final String quizType;

  /// Category within the quiz type (e.g., 'europe', 'asia').
  final String? quizCategory;

  /// Total number of questions in the quiz.
  final int totalQuestions;

  /// Number of questions answered.
  final int totalAnswered;

  /// Number of correct answers.
  final int totalCorrect;

  /// Number of incorrect answers.
  final int totalFailed;

  /// Number of skipped questions.
  final int totalSkipped;

  /// Score as a percentage (0.0 to 100.0).
  final double scorePercentage;

  /// Number of lives/hearts used (for survival mode).
  final int livesUsed;

  /// When the quiz session started.
  final DateTime startTime;

  /// When the quiz session ended (null if not completed).
  final DateTime? endTime;

  /// Duration of the quiz in seconds (null if not completed).
  final int? durationSeconds;

  /// How the quiz session ended.
  final CompletionStatus completionStatus;

  /// The quiz mode used.
  final QuizMode mode;

  /// Time limit in seconds (null if no time limit).
  final int? timeLimitSeconds;

  /// Number of 50/50 hints used.
  final int hintsUsed5050;

  /// Number of skip hints used.
  final int hintsUsedSkip;

  /// Best streak of consecutive correct answers in this session.
  final int bestStreak;

  /// App version when the quiz was played.
  final String appVersion;

  /// When the record was created.
  final DateTime createdAt;

  /// When the record was last updated.
  final DateTime updatedAt;

  /// Whether this session has a perfect score.
  bool get isPerfectScore => scorePercentage >= 100.0;

  /// Whether this session is completed (not cancelled or failed).
  bool get isCompleted => completionStatus == CompletionStatus.completed;

  /// Creates a [QuizSession] from a database map.
  factory QuizSession.fromMap(Map<String, dynamic> map) {
    return QuizSession(
      id: map[QuizSessionsColumns.id] as String,
      quizName: map[QuizSessionsColumns.quizName] as String,
      quizId: map[QuizSessionsColumns.quizId] as String,
      quizType: map[QuizSessionsColumns.quizType] as String,
      quizCategory: map[QuizSessionsColumns.quizCategory] as String?,
      totalQuestions: map[QuizSessionsColumns.totalQuestions] as int,
      totalAnswered: map[QuizSessionsColumns.totalAnswered] as int,
      totalCorrect: map[QuizSessionsColumns.totalCorrect] as int,
      totalFailed: map[QuizSessionsColumns.totalFailed] as int,
      totalSkipped: map[QuizSessionsColumns.totalSkipped] as int,
      scorePercentage: (map[QuizSessionsColumns.scorePercentage] as num).toDouble(),
      livesUsed: (map[QuizSessionsColumns.livesUsed] as int?) ?? 0,
      startTime: DateTime.fromMillisecondsSinceEpoch(
        (map[QuizSessionsColumns.startTime] as int) * 1000,
      ),
      endTime: map[QuizSessionsColumns.endTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map[QuizSessionsColumns.endTime] as int) * 1000,
            )
          : null,
      durationSeconds: map[QuizSessionsColumns.durationSeconds] as int?,
      completionStatus: CompletionStatus.fromString(
        map[QuizSessionsColumns.completionStatus] as String,
      ),
      mode: QuizMode.fromString(map[QuizSessionsColumns.mode] as String),
      timeLimitSeconds: map[QuizSessionsColumns.timeLimitSeconds] as int?,
      hintsUsed5050: (map[QuizSessionsColumns.hintsUsed5050] as int?) ?? 0,
      hintsUsedSkip: (map[QuizSessionsColumns.hintsUsedSkip] as int?) ?? 0,
      bestStreak: (map[QuizSessionsColumns.bestStreak] as int?) ?? 0,
      appVersion: map[QuizSessionsColumns.appVersion] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map[QuizSessionsColumns.createdAt] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map[QuizSessionsColumns.updatedAt] as int) * 1000,
      ),
    );
  }

  /// Converts this [QuizSession] to a database map.
  Map<String, dynamic> toMap() {
    return {
      QuizSessionsColumns.id: id,
      QuizSessionsColumns.quizName: quizName,
      QuizSessionsColumns.quizId: quizId,
      QuizSessionsColumns.quizType: quizType,
      QuizSessionsColumns.quizCategory: quizCategory,
      QuizSessionsColumns.totalQuestions: totalQuestions,
      QuizSessionsColumns.totalAnswered: totalAnswered,
      QuizSessionsColumns.totalCorrect: totalCorrect,
      QuizSessionsColumns.totalFailed: totalFailed,
      QuizSessionsColumns.totalSkipped: totalSkipped,
      QuizSessionsColumns.scorePercentage: scorePercentage,
      QuizSessionsColumns.livesUsed: livesUsed,
      QuizSessionsColumns.startTime: startTime.millisecondsSinceEpoch ~/ 1000,
      QuizSessionsColumns.endTime:
          endTime != null ? endTime!.millisecondsSinceEpoch ~/ 1000 : null,
      QuizSessionsColumns.durationSeconds: durationSeconds,
      QuizSessionsColumns.completionStatus: completionStatus.value,
      QuizSessionsColumns.mode: mode.value,
      QuizSessionsColumns.timeLimitSeconds: timeLimitSeconds,
      QuizSessionsColumns.hintsUsed5050: hintsUsed5050,
      QuizSessionsColumns.hintsUsedSkip: hintsUsedSkip,
      QuizSessionsColumns.bestStreak: bestStreak,
      QuizSessionsColumns.appVersion: appVersion,
      QuizSessionsColumns.createdAt: createdAt.millisecondsSinceEpoch ~/ 1000,
      QuizSessionsColumns.updatedAt: updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy of this [QuizSession] with the given fields replaced.
  QuizSession copyWith({
    String? id,
    String? quizName,
    String? quizId,
    String? quizType,
    String? quizCategory,
    int? totalQuestions,
    int? totalAnswered,
    int? totalCorrect,
    int? totalFailed,
    int? totalSkipped,
    double? scorePercentage,
    int? livesUsed,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    CompletionStatus? completionStatus,
    QuizMode? mode,
    int? timeLimitSeconds,
    int? hintsUsed5050,
    int? hintsUsedSkip,
    int? bestStreak,
    String? appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizSession(
      id: id ?? this.id,
      quizName: quizName ?? this.quizName,
      quizId: quizId ?? this.quizId,
      quizType: quizType ?? this.quizType,
      quizCategory: quizCategory ?? this.quizCategory,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalFailed: totalFailed ?? this.totalFailed,
      totalSkipped: totalSkipped ?? this.totalSkipped,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      livesUsed: livesUsed ?? this.livesUsed,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completionStatus: completionStatus ?? this.completionStatus,
      mode: mode ?? this.mode,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      hintsUsed5050: hintsUsed5050 ?? this.hintsUsed5050,
      hintsUsedSkip: hintsUsedSkip ?? this.hintsUsedSkip,
      bestStreak: bestStreak ?? this.bestStreak,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizSession(id: $id, quizName: $quizName, score: $scorePercentage%, status: ${completionStatus.value})';
  }
}
