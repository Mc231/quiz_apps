/// Global statistics data model for database persistence.
library;

import '../database/migrations/migration_v2.dart';
import '../database/tables/statistics_tables.dart';

/// Aggregate statistics across all quiz sessions.
class GlobalStatistics {
  /// Creates a new [GlobalStatistics].
  const GlobalStatistics({
    this.totalSessions = 0,
    this.totalCompletedSessions = 0,
    this.totalCancelledSessions = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.totalIncorrectAnswers = 0,
    this.totalSkippedQuestions = 0,
    this.totalTimePlayedSeconds = 0,
    this.totalHints5050Used = 0,
    this.totalHintsSkipUsed = 0,
    this.averageScorePercentage = 0,
    this.bestScorePercentage = 0,
    this.worstScorePercentage = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalPerfectScores = 0,
    this.firstSessionDate,
    this.lastSessionDate,
    // V2 fields for achievements
    this.consecutiveDaysPlayed = 0,
    this.lastPlayDate,
    this.quickAnswersCount = 0,
    this.sessionsNoHints = 0,
    this.highScore90Count = 0,
    this.highScore95Count = 0,
    this.totalAchievementsUnlocked = 0,
    this.totalAchievementPoints = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total number of quiz sessions started.
  final int totalSessions;

  /// Total number of completed quiz sessions.
  final int totalCompletedSessions;

  /// Total number of cancelled quiz sessions.
  final int totalCancelledSessions;

  /// Total questions answered across all sessions.
  final int totalQuestionsAnswered;

  /// Total correct answers across all sessions.
  final int totalCorrectAnswers;

  /// Total incorrect answers across all sessions.
  final int totalIncorrectAnswers;

  /// Total skipped questions across all sessions.
  final int totalSkippedQuestions;

  /// Total time played in seconds.
  final int totalTimePlayedSeconds;

  /// Total 50/50 hints used.
  final int totalHints5050Used;

  /// Total skip hints used.
  final int totalHintsSkipUsed;

  /// Average score percentage across all completed sessions.
  final double averageScorePercentage;

  /// Best score percentage ever achieved.
  final double bestScorePercentage;

  /// Worst score percentage (excluding cancelled sessions).
  final double worstScorePercentage;

  /// Current streak of consecutive correct answers.
  final int currentStreak;

  /// Best streak of consecutive correct answers ever.
  final int bestStreak;

  /// Total number of perfect score sessions.
  final int totalPerfectScores;

  /// Date of the first quiz session.
  final DateTime? firstSessionDate;

  /// Date of the most recent quiz session.
  final DateTime? lastSessionDate;

  // === V2 Fields for Achievements ===

  /// Number of consecutive days the user has played.
  final int consecutiveDaysPlayed;

  /// Last date the user played (YYYY-MM-DD format for comparison).
  final String? lastPlayDate;

  /// Total number of quick answers (under 2 seconds).
  final int quickAnswersCount;

  /// Total sessions completed without using hints.
  final int sessionsNoHints;

  /// Total sessions with 90%+ score.
  final int highScore90Count;

  /// Total sessions with 95%+ score.
  final int highScore95Count;

  /// Total achievements unlocked (cached for quick display).
  final int totalAchievementsUnlocked;

  /// Total achievement points (cached for quick display).
  final int totalAchievementPoints;

  /// When this record was created.
  final DateTime createdAt;

  /// When this record was last updated.
  final DateTime updatedAt;

  /// Total time played as a Duration.
  Duration get totalTimePlayed => Duration(seconds: totalTimePlayedSeconds);

  /// Overall accuracy percentage.
  double get overallAccuracy {
    if (totalQuestionsAnswered == 0) return 0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }

  /// Completion rate percentage.
  double get completionRate {
    if (totalSessions == 0) return 0;
    return (totalCompletedSessions / totalSessions) * 100;
  }

  /// Creates an empty [GlobalStatistics] for new users.
  factory GlobalStatistics.empty() {
    final now = DateTime.now();
    return GlobalStatistics(
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a [GlobalStatistics] from a database map.
  factory GlobalStatistics.fromMap(Map<String, dynamic> map) {
    return GlobalStatistics(
      totalSessions:
          (map[GlobalStatisticsColumns.totalSessions] as int?) ?? 0,
      totalCompletedSessions:
          (map[GlobalStatisticsColumns.totalCompletedSessions] as int?) ?? 0,
      totalCancelledSessions:
          (map[GlobalStatisticsColumns.totalCancelledSessions] as int?) ?? 0,
      totalQuestionsAnswered:
          (map[GlobalStatisticsColumns.totalQuestionsAnswered] as int?) ?? 0,
      totalCorrectAnswers:
          (map[GlobalStatisticsColumns.totalCorrectAnswers] as int?) ?? 0,
      totalIncorrectAnswers:
          (map[GlobalStatisticsColumns.totalIncorrectAnswers] as int?) ?? 0,
      totalSkippedQuestions:
          (map[GlobalStatisticsColumns.totalSkippedQuestions] as int?) ?? 0,
      totalTimePlayedSeconds:
          (map[GlobalStatisticsColumns.totalTimePlayedSeconds] as int?) ?? 0,
      totalHints5050Used:
          (map[GlobalStatisticsColumns.totalHints5050Used] as int?) ?? 0,
      totalHintsSkipUsed:
          (map[GlobalStatisticsColumns.totalHintsSkipUsed] as int?) ?? 0,
      averageScorePercentage:
          (map[GlobalStatisticsColumns.averageScorePercentage] as num?)
                  ?.toDouble() ??
              0,
      bestScorePercentage:
          (map[GlobalStatisticsColumns.bestScorePercentage] as num?)
                  ?.toDouble() ??
              0,
      worstScorePercentage:
          (map[GlobalStatisticsColumns.worstScorePercentage] as num?)
                  ?.toDouble() ??
              0,
      currentStreak:
          (map[GlobalStatisticsColumns.currentStreak] as int?) ?? 0,
      bestStreak: (map[GlobalStatisticsColumns.bestStreak] as int?) ?? 0,
      totalPerfectScores:
          (map[GlobalStatisticsColumns.totalPerfectScores] as int?) ?? 0,
      firstSessionDate: map[GlobalStatisticsColumns.firstSessionDate] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map[GlobalStatisticsColumns.firstSessionDate] as int) * 1000,
            )
          : null,
      lastSessionDate: map[GlobalStatisticsColumns.lastSessionDate] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map[GlobalStatisticsColumns.lastSessionDate] as int) * 1000,
            )
          : null,
      // V2 fields
      consecutiveDaysPlayed:
          (map[GlobalStatisticsColumnsV2.consecutiveDaysPlayed] as int?) ?? 0,
      lastPlayDate: map[GlobalStatisticsColumnsV2.lastPlayDate] as String?,
      quickAnswersCount:
          (map[GlobalStatisticsColumnsV2.quickAnswersCount] as int?) ?? 0,
      sessionsNoHints:
          (map[GlobalStatisticsColumnsV2.sessionsNoHints] as int?) ?? 0,
      highScore90Count:
          (map[GlobalStatisticsColumnsV2.highScore90Count] as int?) ?? 0,
      highScore95Count:
          (map[GlobalStatisticsColumnsV2.highScore95Count] as int?) ?? 0,
      totalAchievementsUnlocked:
          (map[GlobalStatisticsColumnsV2.totalAchievementsUnlocked] as int?) ??
              0,
      totalAchievementPoints:
          (map[GlobalStatisticsColumnsV2.totalAchievementPoints] as int?) ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map[GlobalStatisticsColumns.createdAt] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map[GlobalStatisticsColumns.updatedAt] as int) * 1000,
      ),
    );
  }

  /// Converts this [GlobalStatistics] to a database map.
  Map<String, dynamic> toMap() {
    return {
      GlobalStatisticsColumns.id: 1,
      GlobalStatisticsColumns.totalSessions: totalSessions,
      GlobalStatisticsColumns.totalCompletedSessions: totalCompletedSessions,
      GlobalStatisticsColumns.totalCancelledSessions: totalCancelledSessions,
      GlobalStatisticsColumns.totalQuestionsAnswered: totalQuestionsAnswered,
      GlobalStatisticsColumns.totalCorrectAnswers: totalCorrectAnswers,
      GlobalStatisticsColumns.totalIncorrectAnswers: totalIncorrectAnswers,
      GlobalStatisticsColumns.totalSkippedQuestions: totalSkippedQuestions,
      GlobalStatisticsColumns.totalTimePlayedSeconds: totalTimePlayedSeconds,
      GlobalStatisticsColumns.totalHints5050Used: totalHints5050Used,
      GlobalStatisticsColumns.totalHintsSkipUsed: totalHintsSkipUsed,
      GlobalStatisticsColumns.averageScorePercentage: averageScorePercentage,
      GlobalStatisticsColumns.bestScorePercentage: bestScorePercentage,
      GlobalStatisticsColumns.worstScorePercentage: worstScorePercentage,
      GlobalStatisticsColumns.currentStreak: currentStreak,
      GlobalStatisticsColumns.bestStreak: bestStreak,
      GlobalStatisticsColumns.totalPerfectScores: totalPerfectScores,
      GlobalStatisticsColumns.firstSessionDate: firstSessionDate != null
          ? firstSessionDate!.millisecondsSinceEpoch ~/ 1000
          : null,
      GlobalStatisticsColumns.lastSessionDate: lastSessionDate != null
          ? lastSessionDate!.millisecondsSinceEpoch ~/ 1000
          : null,
      // V2 fields
      GlobalStatisticsColumnsV2.consecutiveDaysPlayed: consecutiveDaysPlayed,
      GlobalStatisticsColumnsV2.lastPlayDate: lastPlayDate,
      GlobalStatisticsColumnsV2.quickAnswersCount: quickAnswersCount,
      GlobalStatisticsColumnsV2.sessionsNoHints: sessionsNoHints,
      GlobalStatisticsColumnsV2.highScore90Count: highScore90Count,
      GlobalStatisticsColumnsV2.highScore95Count: highScore95Count,
      GlobalStatisticsColumnsV2.totalAchievementsUnlocked:
          totalAchievementsUnlocked,
      GlobalStatisticsColumnsV2.totalAchievementPoints: totalAchievementPoints,
      GlobalStatisticsColumns.createdAt:
          createdAt.millisecondsSinceEpoch ~/ 1000,
      GlobalStatisticsColumns.updatedAt:
          updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy of this [GlobalStatistics] with the given fields replaced.
  GlobalStatistics copyWith({
    int? totalSessions,
    int? totalCompletedSessions,
    int? totalCancelledSessions,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    int? totalIncorrectAnswers,
    int? totalSkippedQuestions,
    int? totalTimePlayedSeconds,
    int? totalHints5050Used,
    int? totalHintsSkipUsed,
    double? averageScorePercentage,
    double? bestScorePercentage,
    double? worstScorePercentage,
    int? currentStreak,
    int? bestStreak,
    int? totalPerfectScores,
    DateTime? firstSessionDate,
    DateTime? lastSessionDate,
    // V2 fields
    int? consecutiveDaysPlayed,
    String? lastPlayDate,
    int? quickAnswersCount,
    int? sessionsNoHints,
    int? highScore90Count,
    int? highScore95Count,
    int? totalAchievementsUnlocked,
    int? totalAchievementPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GlobalStatistics(
      totalSessions: totalSessions ?? this.totalSessions,
      totalCompletedSessions:
          totalCompletedSessions ?? this.totalCompletedSessions,
      totalCancelledSessions:
          totalCancelledSessions ?? this.totalCancelledSessions,
      totalQuestionsAnswered:
          totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalIncorrectAnswers:
          totalIncorrectAnswers ?? this.totalIncorrectAnswers,
      totalSkippedQuestions:
          totalSkippedQuestions ?? this.totalSkippedQuestions,
      totalTimePlayedSeconds:
          totalTimePlayedSeconds ?? this.totalTimePlayedSeconds,
      totalHints5050Used: totalHints5050Used ?? this.totalHints5050Used,
      totalHintsSkipUsed: totalHintsSkipUsed ?? this.totalHintsSkipUsed,
      averageScorePercentage:
          averageScorePercentage ?? this.averageScorePercentage,
      bestScorePercentage: bestScorePercentage ?? this.bestScorePercentage,
      worstScorePercentage: worstScorePercentage ?? this.worstScorePercentage,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalPerfectScores: totalPerfectScores ?? this.totalPerfectScores,
      firstSessionDate: firstSessionDate ?? this.firstSessionDate,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      // V2 fields
      consecutiveDaysPlayed:
          consecutiveDaysPlayed ?? this.consecutiveDaysPlayed,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      quickAnswersCount: quickAnswersCount ?? this.quickAnswersCount,
      sessionsNoHints: sessionsNoHints ?? this.sessionsNoHints,
      highScore90Count: highScore90Count ?? this.highScore90Count,
      highScore95Count: highScore95Count ?? this.highScore95Count,
      totalAchievementsUnlocked:
          totalAchievementsUnlocked ?? this.totalAchievementsUnlocked,
      totalAchievementPoints:
          totalAchievementPoints ?? this.totalAchievementPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'GlobalStatistics(sessions: $totalSessions, avgScore: $averageScorePercentage%)';
  }
}
