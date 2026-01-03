/// Result of a score submission.
sealed class SubmitScoreResult {
  const SubmitScoreResult();

  /// Score was successfully submitted.
  factory SubmitScoreResult.success({
    int? newRank,
    bool? isNewHighScore,
  }) = SubmitScoreSuccess;

  /// Score submission failed.
  factory SubmitScoreResult.failed({
    required String error,
    String? errorCode,
  }) = SubmitScoreFailed;

  /// User is not signed in.
  factory SubmitScoreResult.notSignedIn() = SubmitScoreNotSignedIn;
}

/// Successful score submission result.
class SubmitScoreSuccess extends SubmitScoreResult {
  const SubmitScoreSuccess({
    this.newRank,
    this.isNewHighScore,
  });

  /// The player's new rank on the leaderboard (if available).
  final int? newRank;

  /// Whether this was a new personal high score (if available).
  final bool? isNewHighScore;
}

/// Score submission failed.
class SubmitScoreFailed extends SubmitScoreResult {
  const SubmitScoreFailed({
    required this.error,
    this.errorCode,
  });

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// Score submission failed because user is not signed in.
class SubmitScoreNotSignedIn extends SubmitScoreResult {
  const SubmitScoreNotSignedIn();
}

/// A single entry on a leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerId,
    required this.displayName,
    required this.score,
    required this.rank,
    this.avatarUrl,
    this.formattedScore,
    this.timestamp,
  });

  /// Unique player identifier.
  final String playerId;

  /// Player's display name.
  final String displayName;

  /// The score value.
  final int score;

  /// The player's rank on the leaderboard.
  final int rank;

  /// URL to player's avatar image (if available).
  final String? avatarUrl;

  /// Formatted score string from the platform (if available).
  final String? formattedScore;

  /// When the score was achieved (if available).
  final DateTime? timestamp;

  @override
  String toString() =>
      'LeaderboardEntry(rank: $rank, displayName: $displayName, score: $score)';
}

/// The player's own score and rank on a leaderboard.
class PlayerScore {
  const PlayerScore({
    required this.score,
    required this.rank,
    this.formattedScore,
    this.timestamp,
  });

  /// The player's score value.
  final int score;

  /// The player's rank on the leaderboard.
  final int rank;

  /// Formatted score string from the platform (if available).
  final String? formattedScore;

  /// When the score was achieved (if available).
  final DateTime? timestamp;

  @override
  String toString() => 'PlayerScore(rank: $rank, score: $score)';
}

/// Time span for leaderboard queries.
enum LeaderboardTimeSpan {
  /// All-time scores.
  allTime,

  /// Scores from this week.
  weekly,

  /// Scores from today.
  daily,
}

/// Platform-agnostic interface for leaderboard services.
///
/// Provides score submission and retrieval for game platforms
/// such as Game Center (iOS) and Google Play Games (Android).
abstract interface class LeaderboardService {
  /// Submits a score to the specified leaderboard.
  ///
  /// [leaderboardId] is the platform-specific identifier for the leaderboard.
  /// [score] is the score value to submit.
  ///
  /// Returns a [SubmitScoreResult] indicating success or failure.
  Future<SubmitScoreResult> submitScore({
    required String leaderboardId,
    required int score,
  });

  /// Gets the top scores from the specified leaderboard.
  ///
  /// [leaderboardId] is the platform-specific identifier for the leaderboard.
  /// [count] is the maximum number of entries to retrieve.
  /// [timeSpan] filters scores by time period.
  ///
  /// Returns a list of [LeaderboardEntry] objects, or an empty list if
  /// the leaderboard is unavailable.
  Future<List<LeaderboardEntry>> getTopScores({
    required String leaderboardId,
    required int count,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  });

  /// Gets the current player's score and rank on the specified leaderboard.
  ///
  /// [leaderboardId] is the platform-specific identifier for the leaderboard.
  /// [timeSpan] filters scores by time period.
  ///
  /// Returns the player's [PlayerScore], or `null` if the player has no
  /// score on the leaderboard or is not signed in.
  Future<PlayerScore?> getPlayerScore({
    required String leaderboardId,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  });

  /// Opens the platform's native leaderboard UI.
  ///
  /// [leaderboardId] is the platform-specific identifier for the leaderboard.
  /// If `null`, opens the leaderboard list showing all leaderboards.
  ///
  /// Returns `true` if the UI was successfully opened, `false` otherwise.
  Future<bool> showLeaderboard({String? leaderboardId});

  /// Opens the platform's native leaderboard list UI.
  ///
  /// Shows all available leaderboards for the game.
  ///
  /// Returns `true` if the UI was successfully opened, `false` otherwise.
  Future<bool> showAllLeaderboards();
}