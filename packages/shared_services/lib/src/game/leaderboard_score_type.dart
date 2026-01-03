/// How scores are compared on a leaderboard.
enum LeaderboardScoreType {
  /// Higher scores are better (most common).
  ///
  /// Examples: quiz scores, points, correct answers
  highScore,

  /// Lower times are better.
  ///
  /// Examples: completion time, speed runs
  lowestTime,

  /// Scores are summed over time.
  ///
  /// Examples: lifetime total points, cumulative correct answers
  cumulative,
}
