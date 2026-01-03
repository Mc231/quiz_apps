import 'leaderboard_score_type.dart';

/// Configuration for a single leaderboard.
///
/// Maps internal leaderboard identifiers to platform-specific IDs
/// (Game Center for iOS, Play Games for Android).
class LeaderboardConfig {
  /// Creates a [LeaderboardConfig].
  const LeaderboardConfig({
    required this.id,
    this.gameCenterId,
    this.playGamesId,
    this.scoreType = LeaderboardScoreType.highScore,
  });

  /// Internal leaderboard identifier.
  ///
  /// Used within the app to reference this leaderboard.
  /// Examples: 'global', 'europe', 'asia', 'speed_run'
  final String id;

  /// iOS Game Center leaderboard ID.
  ///
  /// Configured in App Store Connect under Game Center.
  /// Example: 'grp.com.yourapp.leaderboard.global'
  final String? gameCenterId;

  /// Android Play Games leaderboard ID.
  ///
  /// Configured in Google Play Console under Play Games Services.
  /// Example: 'CgkI_example_leaderboard'
  final String? playGamesId;

  /// How scores are compared on this leaderboard.
  ///
  /// Defaults to [LeaderboardScoreType.highScore].
  final LeaderboardScoreType scoreType;

  /// Returns the platform ID for iOS (Game Center).
  String? get iosId => gameCenterId;

  /// Returns the platform ID for Android (Play Games).
  String? get androidId => playGamesId;

  /// Checks if this leaderboard is configured for iOS.
  bool get hasIosSupport => gameCenterId != null && gameCenterId!.isNotEmpty;

  /// Checks if this leaderboard is configured for Android.
  bool get hasAndroidSupport => playGamesId != null && playGamesId!.isNotEmpty;

  /// Creates a copy with the given fields replaced.
  LeaderboardConfig copyWith({
    String? id,
    String? gameCenterId,
    String? playGamesId,
    LeaderboardScoreType? scoreType,
  }) {
    return LeaderboardConfig(
      id: id ?? this.id,
      gameCenterId: gameCenterId ?? this.gameCenterId,
      playGamesId: playGamesId ?? this.playGamesId,
      scoreType: scoreType ?? this.scoreType,
    );
  }

  @override
  String toString() {
    return 'LeaderboardConfig(id: $id, gameCenterId: $gameCenterId, '
        'playGamesId: $playGamesId, scoreType: $scoreType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardConfig &&
        other.id == id &&
        other.gameCenterId == gameCenterId &&
        other.playGamesId == playGamesId &&
        other.scoreType == scoreType;
  }

  @override
  int get hashCode {
    return Object.hash(id, gameCenterId, playGamesId, scoreType);
  }
}
