/// Daily statistics data model for database persistence.
library;

import '../database/tables/daily_statistics_table.dart';

/// Pre-aggregated daily statistics for fast charting and trend analysis.
class DailyStatistics {
  /// Creates a new [DailyStatistics].
  const DailyStatistics({
    required this.id,
    required this.date,
    this.sessionsPlayed = 0,
    this.sessionsCompleted = 0,
    this.sessionsCancelled = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.skippedAnswers = 0,
    this.timePlayedSeconds = 0,
    this.averageScorePercentage = 0,
    this.bestScorePercentage = 0,
    this.perfectScores = 0,
    this.hints5050Used = 0,
    this.hintsSkipUsed = 0,
    this.livesUsed = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for this daily record.
  final String id;

  /// The date in YYYY-MM-DD format.
  final String date;

  /// Number of sessions played on this day.
  final int sessionsPlayed;

  /// Number of sessions completed on this day.
  final int sessionsCompleted;

  /// Number of sessions cancelled on this day.
  final int sessionsCancelled;

  /// Number of questions answered on this day.
  final int questionsAnswered;

  /// Number of correct answers on this day.
  final int correctAnswers;

  /// Number of incorrect answers on this day.
  final int incorrectAnswers;

  /// Number of skipped answers on this day.
  final int skippedAnswers;

  /// Time played in seconds on this day.
  final int timePlayedSeconds;

  /// Average score percentage on this day.
  final double averageScorePercentage;

  /// Best score percentage on this day.
  final double bestScorePercentage;

  /// Number of perfect scores on this day.
  final int perfectScores;

  /// Number of 50/50 hints used on this day.
  final int hints5050Used;

  /// Number of skip hints used on this day.
  final int hintsSkipUsed;

  /// Number of lives used on this day.
  final int livesUsed;

  /// When this record was created.
  final DateTime createdAt;

  /// When this record was last updated.
  final DateTime updatedAt;

  /// The date as a DateTime object.
  DateTime get dateTime => DateTime.parse(date);

  /// Time played as a Duration.
  Duration get timePlayed => Duration(seconds: timePlayedSeconds);

  /// Accuracy percentage for this day.
  double get accuracy {
    if (questionsAnswered == 0) return 0;
    return (correctAnswers / questionsAnswered) * 100;
  }

  /// Completion rate for this day.
  double get completionRate {
    if (sessionsPlayed == 0) return 0;
    return (sessionsCompleted / sessionsPlayed) * 100;
  }

  /// Formats a DateTime to YYYY-MM-DD string.
  static String formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Generates a unique ID for a date.
  static String generateId(DateTime dateTime) {
    return 'daily_${formatDate(dateTime)}';
  }

  /// Creates an empty [DailyStatistics] for a new day.
  factory DailyStatistics.empty({required DateTime date}) {
    final now = DateTime.now();
    final dateStr = formatDate(date);
    return DailyStatistics(
      id: 'daily_$dateStr',
      date: dateStr,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a [DailyStatistics] from a database map.
  factory DailyStatistics.fromMap(Map<String, dynamic> map) {
    return DailyStatistics(
      id: map[DailyStatisticsColumns.id] as String,
      date: map[DailyStatisticsColumns.date] as String,
      sessionsPlayed:
          (map[DailyStatisticsColumns.sessionsPlayed] as int?) ?? 0,
      sessionsCompleted:
          (map[DailyStatisticsColumns.sessionsCompleted] as int?) ?? 0,
      sessionsCancelled:
          (map[DailyStatisticsColumns.sessionsCancelled] as int?) ?? 0,
      questionsAnswered:
          (map[DailyStatisticsColumns.questionsAnswered] as int?) ?? 0,
      correctAnswers:
          (map[DailyStatisticsColumns.correctAnswers] as int?) ?? 0,
      incorrectAnswers:
          (map[DailyStatisticsColumns.incorrectAnswers] as int?) ?? 0,
      skippedAnswers:
          (map[DailyStatisticsColumns.skippedAnswers] as int?) ?? 0,
      timePlayedSeconds:
          (map[DailyStatisticsColumns.timePlayedSeconds] as int?) ?? 0,
      averageScorePercentage:
          (map[DailyStatisticsColumns.averageScorePercentage] as num?)
                  ?.toDouble() ??
              0,
      bestScorePercentage:
          (map[DailyStatisticsColumns.bestScorePercentage] as num?)
                  ?.toDouble() ??
              0,
      perfectScores:
          (map[DailyStatisticsColumns.perfectScores] as int?) ?? 0,
      hints5050Used:
          (map[DailyStatisticsColumns.hints5050Used] as int?) ?? 0,
      hintsSkipUsed:
          (map[DailyStatisticsColumns.hintsSkipUsed] as int?) ?? 0,
      livesUsed: (map[DailyStatisticsColumns.livesUsed] as int?) ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map[DailyStatisticsColumns.createdAt] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map[DailyStatisticsColumns.updatedAt] as int) * 1000,
      ),
    );
  }

  /// Converts this [DailyStatistics] to a database map.
  Map<String, dynamic> toMap() {
    return {
      DailyStatisticsColumns.id: id,
      DailyStatisticsColumns.date: date,
      DailyStatisticsColumns.sessionsPlayed: sessionsPlayed,
      DailyStatisticsColumns.sessionsCompleted: sessionsCompleted,
      DailyStatisticsColumns.sessionsCancelled: sessionsCancelled,
      DailyStatisticsColumns.questionsAnswered: questionsAnswered,
      DailyStatisticsColumns.correctAnswers: correctAnswers,
      DailyStatisticsColumns.incorrectAnswers: incorrectAnswers,
      DailyStatisticsColumns.skippedAnswers: skippedAnswers,
      DailyStatisticsColumns.timePlayedSeconds: timePlayedSeconds,
      DailyStatisticsColumns.averageScorePercentage: averageScorePercentage,
      DailyStatisticsColumns.bestScorePercentage: bestScorePercentage,
      DailyStatisticsColumns.perfectScores: perfectScores,
      DailyStatisticsColumns.hints5050Used: hints5050Used,
      DailyStatisticsColumns.hintsSkipUsed: hintsSkipUsed,
      DailyStatisticsColumns.livesUsed: livesUsed,
      DailyStatisticsColumns.createdAt:
          createdAt.millisecondsSinceEpoch ~/ 1000,
      DailyStatisticsColumns.updatedAt:
          updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy of this [DailyStatistics] with the given fields replaced.
  DailyStatistics copyWith({
    String? id,
    String? date,
    int? sessionsPlayed,
    int? sessionsCompleted,
    int? sessionsCancelled,
    int? questionsAnswered,
    int? correctAnswers,
    int? incorrectAnswers,
    int? skippedAnswers,
    int? timePlayedSeconds,
    double? averageScorePercentage,
    double? bestScorePercentage,
    int? perfectScores,
    int? hints5050Used,
    int? hintsSkipUsed,
    int? livesUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyStatistics(
      id: id ?? this.id,
      date: date ?? this.date,
      sessionsPlayed: sessionsPlayed ?? this.sessionsPlayed,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      sessionsCancelled: sessionsCancelled ?? this.sessionsCancelled,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      skippedAnswers: skippedAnswers ?? this.skippedAnswers,
      timePlayedSeconds: timePlayedSeconds ?? this.timePlayedSeconds,
      averageScorePercentage:
          averageScorePercentage ?? this.averageScorePercentage,
      bestScorePercentage: bestScorePercentage ?? this.bestScorePercentage,
      perfectScores: perfectScores ?? this.perfectScores,
      hints5050Used: hints5050Used ?? this.hints5050Used,
      hintsSkipUsed: hintsSkipUsed ?? this.hintsSkipUsed,
      livesUsed: livesUsed ?? this.livesUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyStatistics && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DailyStatistics(date: $date, sessions: $sessionsPlayed, avgScore: $averageScorePercentage%)';
  }
}
