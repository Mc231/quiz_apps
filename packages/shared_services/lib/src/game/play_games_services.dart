import 'dart:io';

import 'cloud_achievement_service.dart';
import 'game_service.dart';
import 'leaderboard_service.dart';
import 'play_games_achievement_service.dart';
import 'play_games_leaderboard_service.dart';
import 'play_games_service.dart';

/// A combined implementation providing all Google Play Games services.
///
/// This is a convenience class that creates and manages instances of all
/// Play Games service implementations:
/// - [PlayGamesService] for authentication and player info
/// - [PlayGamesLeaderboardService] for leaderboards
/// - [PlayGamesAchievementService] for cloud achievements
///
/// **Usage:**
/// ```dart
/// final playGamesServices = PlayGamesServices();
///
/// // Access individual services
/// final signInResult = await playGamesServices.gameService.signIn();
/// await playGamesServices.leaderboardService.submitScore(
///   leaderboardId: 'my_leaderboard',
///   score: 1000,
/// );
/// await playGamesServices.cloudAchievementService.unlockAchievement('first_win');
/// ```
///
/// **Setup Required:**
/// 1. Enable Play Games Services in Google Play Console
/// 2. Configure OAuth 2.0 credentials
/// 3. Create leaderboards and achievements in Play Console
/// 4. Add Play Games configuration to AndroidManifest.xml
/// 5. Test with a test account on a real device
class PlayGamesServices {
  /// Creates Play Games services with optional achievement ID mapping.
  ///
  /// [achievementIdMapping] maps in-app achievement IDs to Play Games IDs.
  /// This is useful when your in-app achievement IDs differ from those
  /// configured in Google Play Console.
  PlayGamesServices({
    Map<String, String>? achievementIdMapping,
  })  : _gameService = PlayGamesService(),
        _leaderboardService = PlayGamesLeaderboardService(),
        _cloudAchievementService = PlayGamesAchievementService(
          achievementIdMapping: achievementIdMapping,
        );

  final PlayGamesService _gameService;
  final PlayGamesLeaderboardService _leaderboardService;
  final PlayGamesAchievementService _cloudAchievementService;

  /// Whether the current platform supports Play Games.
  bool get isSupported => Platform.isAndroid;

  /// Game service for authentication and player info.
  GameService get gameService => _gameService;

  /// Leaderboard service for score submission and retrieval.
  LeaderboardService get leaderboardService => _leaderboardService;

  /// Cloud achievement service for syncing achievements.
  CloudAchievementService get cloudAchievementService =>
      _cloudAchievementService;

  /// Signs in to Play Games and returns the result.
  ///
  /// This is a convenience method that delegates to [gameService.signIn].
  Future<SignInResult> signIn() => _gameService.signIn();

  /// Signs out from Play Games.
  ///
  /// Note: The games_services package doesn't support programmatic sign-out.
  /// Users must sign out through Google Play Games settings on Android.
  /// This method clears cached player data.
  Future<void> signOut() => _gameService.signOut();

  /// Checks if the user is signed in to Play Games.
  ///
  /// This is a convenience method that delegates to [gameService.isSignedIn].
  Future<bool> isSignedIn() => _gameService.isSignedIn();

  /// Gets the player's avatar as base64-encoded string (if available).
  ///
  /// This is the raw image data from Play Games.
  String? get playerAvatarBase64 => _gameService.playerAvatarBase64;

  /// Clears cached player data, forcing a refresh on next access.
  void clearCache() {
    _gameService.clearCache();
  }
}
