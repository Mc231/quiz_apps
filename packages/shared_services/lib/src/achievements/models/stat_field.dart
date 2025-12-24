/// Fields from statistics that can be used for achievement triggers.
///
/// These correspond to fields in [GlobalStatistics], [QuizSession],
/// and other statistics models.
enum StatField {
  // === Global Statistics - Session Counts ===

  /// Total number of quiz sessions started.
  totalSessions,

  /// Total number of completed quiz sessions.
  totalCompletedSessions,

  /// Total number of cancelled quiz sessions.
  totalCancelledSessions,

  // === Global Statistics - Question Counts ===

  /// Total questions answered across all sessions.
  totalQuestionsAnswered,

  /// Total correct answers across all sessions.
  totalCorrectAnswers,

  /// Total incorrect answers across all sessions.
  totalIncorrectAnswers,

  /// Total skipped questions across all sessions.
  totalSkippedQuestions,

  // === Global Statistics - Time ===

  /// Total time played in seconds.
  totalTimePlayedSeconds,

  // === Global Statistics - Hints ===

  /// Total 50/50 hints used.
  totalHints5050Used,

  /// Total skip hints used.
  totalHintsSkipUsed,

  // === Global Statistics - Scores ===

  /// Average score percentage across all sessions.
  averageScorePercentage,

  /// Best score percentage ever achieved.
  bestScorePercentage,

  /// Total number of perfect score sessions.
  totalPerfectScores,

  // === Global Statistics - Streaks ===

  /// Current streak of consecutive correct answers.
  currentStreak,

  /// Best streak of consecutive correct answers ever.
  bestStreak,

  /// Consecutive days played.
  consecutiveDaysPlayed,

  // === Session-specific fields ===

  /// Score percentage of current session.
  sessionScorePercentage,

  /// Duration of current session in seconds.
  sessionDurationSeconds,

  /// Lives used in current session.
  sessionLivesUsed,

  /// Hints used in current session (5050 + skip).
  sessionHintsUsed,

  /// Skipped questions in current session.
  sessionSkippedQuestions,

  /// Whether current session is perfect (100%).
  sessionIsPerfect,

  // === Derived/Calculated fields ===

  /// Number of sessions with 90%+ score.
  sessionsWithScore90Plus,

  /// Number of sessions with 95%+ score.
  sessionsWithScore95Plus,

  /// Number of sessions completed without hints.
  sessionsWithoutHints,

  /// Number of quick answers (under 2 seconds).
  quickAnswersCount,

  /// Consecutive perfect scores.
  consecutivePerfectScores,
}

/// Extension providing field metadata.
extension StatFieldExtension on StatField {
  /// Whether this field comes from GlobalStatistics.
  bool get isGlobalStat => switch (this) {
        StatField.totalSessions => true,
        StatField.totalCompletedSessions => true,
        StatField.totalCancelledSessions => true,
        StatField.totalQuestionsAnswered => true,
        StatField.totalCorrectAnswers => true,
        StatField.totalIncorrectAnswers => true,
        StatField.totalSkippedQuestions => true,
        StatField.totalTimePlayedSeconds => true,
        StatField.totalHints5050Used => true,
        StatField.totalHintsSkipUsed => true,
        StatField.averageScorePercentage => true,
        StatField.bestScorePercentage => true,
        StatField.totalPerfectScores => true,
        StatField.currentStreak => true,
        StatField.bestStreak => true,
        StatField.consecutiveDaysPlayed => true,
        StatField.sessionsWithScore90Plus => true,
        StatField.sessionsWithScore95Plus => true,
        StatField.sessionsWithoutHints => true,
        StatField.quickAnswersCount => true,
        StatField.consecutivePerfectScores => true,
        _ => false,
      };

  /// Whether this field comes from QuizSession.
  bool get isSessionStat => switch (this) {
        StatField.sessionScorePercentage => true,
        StatField.sessionDurationSeconds => true,
        StatField.sessionLivesUsed => true,
        StatField.sessionHintsUsed => true,
        StatField.sessionSkippedQuestions => true,
        StatField.sessionIsPerfect => true,
        _ => false,
      };
}
