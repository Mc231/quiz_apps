import 'dart:io';

import 'package:games_services/games_services.dart' as gs;

import 'cloud_achievement_service.dart';

/// iOS Game Center implementation of [CloudAchievementService].
///
/// Provides achievement sync functionality through Apple's Game Center.
///
/// **Setup Required:**
/// 1. Enable Game Center capability in Xcode
/// 2. Create achievements in App Store Connect:
///    - Go to App Store Connect → Your App → Services → Game Center
///    - Add Achievements with unique IDs (Reference Name)
///    - Set point values and descriptions
/// 3. Map in-app achievement IDs to Game Center achievement IDs
///
/// **Achievement ID Mapping:**
/// Create a mapping from your in-app achievement IDs to Game Center IDs.
/// Game Center achievement IDs are configured in App Store Connect and
/// should match the format expected by your app.
///
/// On non-iOS platforms, this service will return appropriate fallback values.
class GameCenterAchievementService implements CloudAchievementService {
  /// Creates a new Game Center achievement service instance.
  ///
  /// [achievementIdMapping] maps in-app achievement IDs to Game Center IDs.
  /// If not provided, it assumes in-app IDs match Game Center IDs directly.
  GameCenterAchievementService({
    Map<String, String>? achievementIdMapping,
  }) : _achievementIdMapping = achievementIdMapping ?? const {};

  /// Mapping from in-app achievement IDs to Game Center achievement IDs.
  final Map<String, String> _achievementIdMapping;

  /// Whether the current platform supports Game Center.
  bool get isSupported => Platform.isIOS || Platform.isMacOS;

  /// Gets the Game Center achievement ID for an in-app achievement ID.
  ///
  /// Returns the mapped ID if available, otherwise returns the original ID.
  String _getGameCenterId(String achievementId) {
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

      final gameCenterId = _getGameCenterId(achievementId);

      final achievement = gs.Achievement(
        iOSID: gameCenterId,
        androidID: '', // Not used for Game Center
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
          errorMessage.contains('not signed in')) {
        return UnlockAchievementResult.notSignedIn();
      }

      if (errorMessage.contains('not found') ||
          errorMessage.contains('invalid')) {
        return UnlockAchievementResult.notFound();
      }

      return UnlockAchievementResult.failed(
        error: 'Failed to unlock achievement: $errorMessage',
        errorCode: 'GAME_CENTER_ERROR',
      );
    }
  }

  @override
  Future<IncrementAchievementResult> incrementAchievement(
    String achievementId, {
    int steps = 1,
  }) async {
    // Game Center doesn't support incremental achievements in the traditional sense.
    // Instead, it uses percentage-based progress.
    // This method interprets 'steps' as percentage points to add.
    //
    // For proper incremental achievements, use setAchievementProgress
    // with the total steps and current progress.

    if (!isSupported) {
      return IncrementAchievementResult.notSignedIn();
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return IncrementAchievementResult.notSignedIn();
      }

      // Get current progress to calculate new progress
      final currentAchievement = await getAchievement(achievementId);
      final currentProgress = currentAchievement?.currentSteps ?? 0;
      final totalSteps = currentAchievement?.totalSteps ?? 100;

      // Calculate new steps (capped at total)
      final newSteps = (currentProgress + steps).clamp(0, totalSteps);

      // Set the new progress
      return setAchievementProgress(achievementId, steps: newSteps);
    } on Exception catch (e) {
      return IncrementAchievementResult.failed(
        error: 'Failed to increment achievement: ${e.toString()}',
        errorCode: 'GAME_CENTER_ERROR',
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

      final gameCenterId = _getGameCenterId(achievementId);

      // Game Center uses percentages (0-100), not step counts
      // Assuming 100 total steps for percentage calculation
      const totalSteps = 100;
      final percentComplete = (steps / totalSteps * 100).clamp(0.0, 100.0);

      final achievement = gs.Achievement(
        iOSID: gameCenterId,
        androidID: '', // Not used for Game Center
        percentComplete: percentComplete,
      );

      final result = await gs.Achievements.unlock(achievement: achievement);

      if (result != null && result.contains('error')) {
        if (result.contains('not found')) {
          return IncrementAchievementResult.notFound();
        }
        return IncrementAchievementResult.failed(
          error: result,
          errorCode: 'INCREMENT_ERROR',
        );
      }

      final isUnlocked = percentComplete >= 100.0;

      return IncrementAchievementResult.success(
        currentSteps: steps,
        totalSteps: totalSteps,
        isUnlocked: isUnlocked,
      );
    } on Exception catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('not authenticated') ||
          errorMessage.contains('not signed in')) {
        return IncrementAchievementResult.notSignedIn();
      }

      if (errorMessage.contains('not found') ||
          errorMessage.contains('invalid')) {
        return IncrementAchievementResult.notFound();
      }

      return IncrementAchievementResult.failed(
        error: 'Failed to set achievement progress: $errorMessage',
        errorCode: 'GAME_CENTER_ERROR',
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
          unlockedAt: null, // Game Center doesn't provide unlock timestamp
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
    final gameCenterId = _getGameCenterId(achievementId);

    try {
      return achievements.firstWhere(
        (a) => a.achievementId == gameCenterId,
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
    // Game Center doesn't have a concept of hidden achievements that can be
    // revealed separately. All achievements are visible from the start.
    // This method is a no-op for Game Center.
    return isSupported;
  }
}