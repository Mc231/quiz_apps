import 'dart:typed_data';

import 'cloud_achievement_service.dart';
import 'game_service.dart';
import 'leaderboard_service.dart';

/// No-op implementation of [GameService] for unsupported platforms.
///
/// All methods return appropriate "not available" responses without
/// throwing errors, allowing the app to gracefully handle unsupported
/// platforms.
class NoOpGameService implements GameService {
  const NoOpGameService();

  @override
  Future<SignInResult> signIn() async {
    return SignInResult.notAuthenticated();
  }

  @override
  Future<void> signOut() async {
    // No-op
  }

  @override
  Future<bool> isSignedIn() async {
    return false;
  }

  @override
  Future<String?> getPlayerId() async {
    return null;
  }

  @override
  Future<String?> getPlayerDisplayName() async {
    return null;
  }

  @override
  Future<Uint8List?> getPlayerAvatar() async {
    return null;
  }

  @override
  Future<PlayerInfo?> getPlayerInfo() async {
    return null;
  }
}

/// No-op implementation of [LeaderboardService] for unsupported platforms.
///
/// All methods return appropriate "not available" responses without
/// throwing errors, allowing the app to gracefully handle unsupported
/// platforms.
class NoOpLeaderboardService implements LeaderboardService {
  const NoOpLeaderboardService();

  @override
  Future<SubmitScoreResult> submitScore({
    required String leaderboardId,
    required int score,
  }) async {
    return SubmitScoreResult.notSignedIn();
  }

  @override
  Future<List<LeaderboardEntry>> getTopScores({
    required String leaderboardId,
    required int count,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  }) async {
    return const [];
  }

  @override
  Future<PlayerScore?> getPlayerScore({
    required String leaderboardId,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  }) async {
    return null;
  }

  @override
  Future<bool> showLeaderboard({String? leaderboardId}) async {
    return false;
  }

  @override
  Future<bool> showAllLeaderboards() async {
    return false;
  }
}

/// No-op implementation of [CloudAchievementService] for unsupported platforms.
///
/// All methods return appropriate "not available" responses without
/// throwing errors, allowing the app to gracefully handle unsupported
/// platforms.
class NoOpCloudAchievementService implements CloudAchievementService {
  const NoOpCloudAchievementService();

  @override
  Future<UnlockAchievementResult> unlockAchievement(
    String achievementId,
  ) async {
    return UnlockAchievementResult.notSignedIn();
  }

  @override
  Future<IncrementAchievementResult> incrementAchievement(
    String achievementId, {
    int steps = 1,
  }) async {
    return IncrementAchievementResult.notSignedIn();
  }

  @override
  Future<IncrementAchievementResult> setAchievementProgress(
    String achievementId, {
    required int steps,
  }) async {
    return IncrementAchievementResult.notSignedIn();
  }

  @override
  Future<List<CloudAchievementInfo>> getAchievements() async {
    return const [];
  }

  @override
  Future<CloudAchievementInfo?> getAchievement(String achievementId) async {
    return null;
  }

  @override
  Future<bool> showAchievements() async {
    return false;
  }

  @override
  Future<bool> revealAchievement(String achievementId) async {
    return false;
  }
}

/// A combined no-op implementation providing all game services.
///
/// Useful for quickly providing all game services on unsupported platforms.
class NoOpGameServices {
  const NoOpGameServices._();

  /// Singleton instance.
  static const instance = NoOpGameServices._();

  /// No-op game service.
  static const GameService gameService = NoOpGameService();

  /// No-op leaderboard service.
  static const LeaderboardService leaderboardService = NoOpLeaderboardService();

  /// No-op cloud achievement service.
  static const CloudAchievementService cloudAchievementService =
      NoOpCloudAchievementService();
}