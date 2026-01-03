import 'dart:io';

import 'package:games_services/games_services.dart' as gs;

import 'cloud_achievement_service.dart';

/// Android Google Play Games implementation of [CloudAchievementService].
///
/// Provides achievement sync functionality through Google Play Games.
///
/// **Setup Required:**
/// 1. Enable Play Games Services in Google Play Console
/// 2. Create achievements in Play Games Services:
///    - Go to Play Console → Play Games Services → Setup & Management
///    - Add Achievements with unique IDs
///    - Set point values, descriptions, and icons
/// 3. Map in-app achievement IDs to Play Games achievement IDs
///
/// **Achievement ID Mapping:**
/// Create a mapping from your in-app achievement IDs to Play Games IDs.
/// Play Games achievement IDs are configured in Play Console and should
/// match the format expected by your app.
///
/// **Incremental Achievements:**
/// Unlike Game Center which uses percentage-based progress, Play Games
/// supports true incremental achievements with step counts. Use
/// [incrementAchievement] to add steps and [setAchievementProgress]
/// to set absolute step values.
///
/// On non-Android platforms, this service will return appropriate fallback values.
class PlayGamesAchievementService implements CloudAchievementService {
  /// Creates a new Play Games achievement service instance.
  ///
  /// [achievementIdMapping] maps in-app achievement IDs to Play Games IDs.
  /// If not provided, it assumes in-app IDs match Play Games IDs directly.
  PlayGamesAchievementService({
    Map<String, String>? achievementIdMapping,
  }) : _achievementIdMapping = achievementIdMapping ?? const {};

  /// Mapping from in-app achievement IDs to Play Games achievement IDs.
  final Map<String, String> _achievementIdMapping;

  /// Whether the current platform supports Play Games.
  bool get isSupported => Platform.isAndroid;

  /// Gets the Play Games achievement ID for an in-app achievement ID.
  ///
  /// Returns the mapped ID if available, otherwise returns the original ID.
  String _getPlayGamesId(String achievementId) {
    return _achievementIdMapping[achievementId] ?? achievementId;
  }

  @override
  Future<UnlockAchievementResult> unlockAchievement(
    String achievementId,
  ) async {
    if (!isSupported) {
      return UnlockAchievementResult.notSignedIn();
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return UnlockAchievementResult.notSignedIn();
      }

      final playGamesId = _getPlayGamesId(achievementId);

      final achievement = gs.Achievement(
        iOSID: '', // Not used for Play Games
        androidID: playGamesId,
        percentComplete: 100.0,
      );

      final result = await gs.Achievements.unlock(achievement: achievement);

      if (result != null && result.contains('error')) {
        if (result.contains('not found')) {
          return UnlockAchievementResult.notFound();
        }
        return UnlockAchievementResult.failed(
          error: result,
          errorCode: 'UNLOCK_ERROR',
        );
      }

      return UnlockAchievementResult.success();
    } on Exception catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('not authenticated') ||
          errorMessage.contains('not signed in') ||
          errorMessage.contains('SIGN_IN_REQUIRED')) {
        return UnlockAchievementResult.notSignedIn();
      }

      if (errorMessage.contains('not found') ||
          errorMessage.contains('invalid')) {
        return UnlockAchievementResult.notFound();
      }

      return UnlockAchievementResult.failed(
        error: 'Failed to unlock achievement: $errorMessage',
        errorCode: 'PLAY_GAMES_ERROR',
      );
    }
  }

  @override
  Future<IncrementAchievementResult> incrementAchievement(
    String achievementId, {
    int steps = 1,
  }) async {
    if (!isSupported) {
      return IncrementAchievementResult.notSignedIn();
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return IncrementAchievementResult.notSignedIn();
      }

      final playGamesId = _getPlayGamesId(achievementId);

      // Play Games supports true incremental achievements
      final achievement = gs.Achievement(
        iOSID: '', // Not used for Play Games
        androidID: playGamesId,
        steps: steps,
      );

      final result = await gs.Achievements.increment(achievement: achievement);

      if (result != null && result.contains('error')) {
        if (result.contains('not found')) {
          return IncrementAchievementResult.notFound();
        }
        return IncrementAchievementResult.failed(
          error: result,
          errorCode: 'INCREMENT_ERROR',
        );
      }

      // Get updated achievement info to return current progress
      final updatedAchievement = await getAchievement(achievementId);

      return IncrementAchievementResult.success(
        currentSteps: updatedAchievement?.currentSteps ?? steps,
        totalSteps: updatedAchievement?.totalSteps ?? 100,
        isUnlocked: updatedAchievement?.isUnlocked ?? false,
      );
    } on Exception catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('not authenticated') ||
          errorMessage.contains('not signed in') ||
          errorMessage.contains('SIGN_IN_REQUIRED')) {
        return IncrementAchievementResult.notSignedIn();
      }

      if (errorMessage.contains('not found') ||
          errorMessage.contains('invalid')) {
        return IncrementAchievementResult.notFound();
      }

      return IncrementAchievementResult.failed(
        error: 'Failed to increment achievement: $errorMessage',
        errorCode: 'PLAY_GAMES_ERROR',
      );
    }
  }

  @override
  Future<IncrementAchievementResult> setAchievementProgress(
    String achievementId, {
    required int steps,
  }) async {
    if (!isSupported) {
      return IncrementAchievementResult.notSignedIn();
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return IncrementAchievementResult.notSignedIn();
      }

      final playGamesId = _getPlayGamesId(achievementId);

      // Get current achievement info to calculate how many steps to add
      final currentAchievement = await getAchievement(achievementId);
      final currentSteps = currentAchievement?.currentSteps ?? 0;
      final totalSteps = currentAchievement?.totalSteps ?? 100;

      // Calculate steps needed to reach target (Play Games only allows increment)
      final stepsToAdd = steps - currentSteps;

      if (stepsToAdd <= 0) {
        // Already at or past this progress, return current state
        return IncrementAchievementResult.success(
          currentSteps: currentSteps,
          totalSteps: totalSteps,
          isUnlocked: currentAchievement?.isUnlocked ?? false,
        );
      }

      // Increment by the difference
      final achievement = gs.Achievement(
        iOSID: '', // Not used for Play Games
        androidID: playGamesId,
        steps: stepsToAdd,
      );

      final result = await gs.Achievements.increment(achievement: achievement);

      if (result != null && result.contains('error')) {
        if (result.contains('not found')) {
          return IncrementAchievementResult.notFound();
        }
        return IncrementAchievementResult.failed(
          error: result,
          errorCode: 'SET_PROGRESS_ERROR',
        );
      }

      // Check if now unlocked
      final isUnlocked = steps >= totalSteps;

      return IncrementAchievementResult.success(
        currentSteps: steps,
        totalSteps: totalSteps,
        isUnlocked: isUnlocked,
      );
    } on Exception catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('not authenticated') ||
          errorMessage.contains('not signed in') ||
          errorMessage.contains('SIGN_IN_REQUIRED')) {
        return IncrementAchievementResult.notSignedIn();
      }

      if (errorMessage.contains('not found') ||
          errorMessage.contains('invalid')) {
        return IncrementAchievementResult.notFound();
      }

      return IncrementAchievementResult.failed(
        error: 'Failed to set achievement progress: $errorMessage',
        errorCode: 'PLAY_GAMES_ERROR',
      );
    }
  }

  @override
  Future<List<CloudAchievementInfo>> getAchievements() async {
    if (!isSupported) {
      return const [];
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return const [];
      }

      final achievements = await gs.Achievements.loadAchievements();

      if (achievements == null) {
        return const [];
      }

      return achievements.map((achievement) {
        return CloudAchievementInfo(
          achievementId: achievement.id,
          name: achievement.name,
          description: achievement.description,
          isUnlocked: achievement.unlocked,
          currentSteps: achievement.completedSteps,
          totalSteps: achievement.totalSteps,
          unlockedAt: null, // Play Games doesn't provide unlock timestamp
          iconUrl: achievement.unlockedImage, // Base64 encoded image
        );
      }).toList();
    } on Exception {
      return const [];
    }
  }

  @override
  Future<CloudAchievementInfo?> getAchievement(String achievementId) async {
    if (!isSupported) {
      return null;
    }

    final achievements = await getAchievements();
    final playGamesId = _getPlayGamesId(achievementId);

    try {
      return achievements.firstWhere(
        (a) => a.achievementId == playGamesId,
      );
    } on StateError {
      return null;
    }
  }

  @override
  Future<bool> showAchievements() async {
    if (!isSupported) {
      return false;
    }

    try {
      final result = await gs.Achievements.showAchievements();
      return result == null || !result.contains('error');
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> revealAchievement(String achievementId) async {
    if (!isSupported) {
      return false;
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return false;
      }

      final playGamesId = _getPlayGamesId(achievementId);

      // Play Games supports hidden achievements that can be revealed
      // We use the reveal method if available, otherwise use increment with 0
      // to reveal without changing progress
      final achievement = gs.Achievement(
        iOSID: '', // Not used for Play Games
        androidID: playGamesId,
        steps: 0, // Reveal without incrementing
      );

      // Try to increment by 0 to reveal
      final result = await gs.Achievements.increment(achievement: achievement);

      return result == null || !result.contains('error');
    } on Exception {
      return false;
    }
  }
}
