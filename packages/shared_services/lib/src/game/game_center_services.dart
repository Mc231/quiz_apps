import 'dart:io';

import 'cloud_achievement_service.dart';
import 'game_center_achievement_service.dart';
import 'game_center_leaderboard_service.dart';
import 'game_center_service.dart';
import 'game_service.dart';
import 'leaderboard_service.dart';

/// A combined implementation providing all Game Center services.
///
/// This is a convenience class that creates and manages instances of all
/// Game Center service implementations:
/// - [GameCenterService] for authentication and player info
/// - [GameCenterLeaderboardService] for leaderboards
/// - [GameCenterAchievementService] for cloud achievements
///
/// **Usage:**
/// ```dart
/// final gameCenterServices = GameCenterServices();
///
/// // Access individual services
/// final signInResult = await gameCenterServices.gameService.signIn();
/// await gameCenterServices.leaderboardService.submitScore(
///   leaderboardId: 'my_leaderboard',
///   score: 1000,
/// );
/// await gameCenterServices.cloudAchievementService.unlockAchievement('first_win');
/// ```
///
/// **Setup Required:**
/// 1. Enable Game Center capability in Xcode
/// 2. Configure leaderboards and achievements in App Store Connect
/// 3. Test with a sandbox account on a real device
class GameCenterServices {
  /// Creates Game Center services with optional achievement ID mapping.
  ///
  /// [achievementIdMapping] maps in-app achievement IDs to Game Center IDs.
  /// This is useful when your in-app achievement IDs differ from those
  /// configured in App Store Connect.
  GameCenterServices({
    Map<String, String>? achievementIdMapping,
  })  : _gameService = GameCenterService(),
        _leaderboardService = GameCenterLeaderboardService(),
        _cloudAchievementService = GameCenterAchievementService(
          achievementIdMapping: achievementIdMapping,
        );

  final GameCenterService _gameService;
  final GameCenterLeaderboardService _leaderboardService;
  final GameCenterAchievementService _cloudAchievementService;

  /// Whether the current platform supports Game Center.
  bool get isSupported => Platform.isIOS || Platform.isMacOS;

  /// Game service for authentication and player info.
  GameService get gameService => _gameService;

  /// Leaderboard service for score submission and retrieval.
  LeaderboardService get leaderboardService => _leaderboardService;

  /// Cloud achievement service for syncing achievements.
  CloudAchievementService get cloudAchievementService =>
      _cloudAchievementService;

  /// Signs in to Game Center and returns the result.
  ///
  /// This is a convenience method that delegates to [gameService.signIn].
  Future<SignInResult> signIn() => _gameService.signIn();

  /// Checks if the user is signed in to Game Center.
  ///
  /// This is a convenience method that delegates to [gameService.isSignedIn].
  Future<bool> isSignedIn() => _gameService.isSignedIn();

  /// Gets the player's avatar as base64-encoded string (if available).
  ///
  /// This is the raw image data from Game Center.
  String? get playerAvatarBase64 => _gameService.playerAvatarBase64;

  /// Clears cached player data, forcing a refresh on next access.
  void clearCache() {
    _gameService.clearCache();
  }
}