/// Result of unlocking an achievement.
sealed class UnlockAchievementResult {
  const UnlockAchievementResult();

  /// Achievement was successfully unlocked.
  factory UnlockAchievementResult.success({
    bool? wasAlreadyUnlocked,
  }) = UnlockAchievementSuccess;

  /// Achievement unlock failed.
  factory UnlockAchievementResult.failed({
    required String error,
    String? errorCode,
  }) = UnlockAchievementFailed;

  /// Achievement not found on the platform.
  factory UnlockAchievementResult.notFound() = UnlockAchievementNotFound;

  /// User is not signed in.
  factory UnlockAchievementResult.notSignedIn() = UnlockAchievementNotSignedIn;
}

/// Successful achievement unlock.
class UnlockAchievementSuccess extends UnlockAchievementResult {
  const UnlockAchievementSuccess({
    this.wasAlreadyUnlocked,
  });

  /// Whether the achievement was already unlocked before this call.
  final bool? wasAlreadyUnlocked;
}

/// Achievement unlock failed.
class UnlockAchievementFailed extends UnlockAchievementResult {
  const UnlockAchievementFailed({
    required this.error,
    this.errorCode,
  });

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// Achievement not found on the platform.
class UnlockAchievementNotFound extends UnlockAchievementResult {
  const UnlockAchievementNotFound();
}

/// User is not signed in.
class UnlockAchievementNotSignedIn extends UnlockAchievementResult {
  const UnlockAchievementNotSignedIn();
}

/// Result of incrementing an achievement.
sealed class IncrementAchievementResult {
  const IncrementAchievementResult();

  /// Achievement was successfully incremented.
  factory IncrementAchievementResult.success({
    required int currentSteps,
    required int totalSteps,
    required bool isUnlocked,
  }) = IncrementAchievementSuccess;

  /// Achievement increment failed.
  factory IncrementAchievementResult.failed({
    required String error,
    String? errorCode,
  }) = IncrementAchievementFailed;

  /// Achievement not found on the platform.
  factory IncrementAchievementResult.notFound() = IncrementAchievementNotFound;

  /// User is not signed in.
  factory IncrementAchievementResult.notSignedIn() =
      IncrementAchievementNotSignedIn;
}

/// Successful achievement increment.
class IncrementAchievementSuccess extends IncrementAchievementResult {
  const IncrementAchievementSuccess({
    required this.currentSteps,
    required this.totalSteps,
    required this.isUnlocked,
  });

  /// Current progress steps.
  final int currentSteps;

  /// Total steps required for unlock.
  final int totalSteps;

  /// Whether the achievement is now unlocked.
  final bool isUnlocked;

  /// Progress as a percentage (0.0 to 1.0).
  double get progress => totalSteps > 0 ? currentSteps / totalSteps : 0.0;
}

/// Achievement increment failed.
class IncrementAchievementFailed extends IncrementAchievementResult {
  const IncrementAchievementFailed({
    required this.error,
    this.errorCode,
  });

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// Achievement not found on the platform.
class IncrementAchievementNotFound extends IncrementAchievementResult {
  const IncrementAchievementNotFound();
}

/// User is not signed in.
class IncrementAchievementNotSignedIn extends IncrementAchievementResult {
  const IncrementAchievementNotSignedIn();
}

/// Information about a cloud achievement.
class CloudAchievementInfo {
  const CloudAchievementInfo({
    required this.achievementId,
    required this.name,
    this.description,
    this.isUnlocked = false,
    this.currentSteps,
    this.totalSteps,
    this.unlockedAt,
    this.iconUrl,
  });

  /// Platform-specific achievement identifier.
  final String achievementId;

  /// Achievement name.
  final String name;

  /// Achievement description.
  final String? description;

  /// Whether the achievement is unlocked.
  final bool isUnlocked;

  /// Current progress steps (for incremental achievements).
  final int? currentSteps;

  /// Total steps required (for incremental achievements).
  final int? totalSteps;

  /// When the achievement was unlocked.
  final DateTime? unlockedAt;

  /// URL to achievement icon.
  final String? iconUrl;

  /// Whether this is an incremental achievement.
  bool get isIncremental => totalSteps != null && totalSteps! > 1;

  /// Progress as a percentage (0.0 to 1.0).
  double get progress {
    if (isUnlocked) return 1.0;
    if (currentSteps == null || totalSteps == null || totalSteps == 0) {
      return 0.0;
    }
    return currentSteps! / totalSteps!;
  }

  @override
  String toString() =>
      'CloudAchievementInfo(id: $achievementId, name: $name, unlocked: $isUnlocked)';
}

/// Platform-agnostic interface for cloud achievement services.
///
/// Provides achievement unlock and progress tracking for game platforms
/// such as Game Center (iOS) and Google Play Games (Android).
///
/// This service syncs achievements with the platform's cloud service,
/// separate from the local in-app achievement tracking.
abstract interface class CloudAchievementService {
  /// Unlocks an achievement.
  ///
  /// [achievementId] is the platform-specific identifier for the achievement.
  ///
  /// Returns an [UnlockAchievementResult] indicating success or failure.
  Future<UnlockAchievementResult> unlockAchievement(String achievementId);

  /// Increments progress on an incremental achievement.
  ///
  /// [achievementId] is the platform-specific identifier for the achievement.
  /// [steps] is the number of steps to increment (defaults to 1).
  ///
  /// Returns an [IncrementAchievementResult] with the new progress.
  Future<IncrementAchievementResult> incrementAchievement(
    String achievementId, {
    int steps = 1,
  });

  /// Sets progress on an incremental achievement to a specific value.
  ///
  /// [achievementId] is the platform-specific identifier for the achievement.
  /// [steps] is the number of steps to set the progress to.
  ///
  /// Note: Progress can only increase; setting a lower value has no effect.
  ///
  /// Returns an [IncrementAchievementResult] with the new progress.
  Future<IncrementAchievementResult> setAchievementProgress(
    String achievementId, {
    required int steps,
  });

  /// Gets information about all achievements for the current player.
  ///
  /// Returns a list of [CloudAchievementInfo] objects, or an empty list
  /// if achievements are unavailable.
  Future<List<CloudAchievementInfo>> getAchievements();

  /// Gets information about a specific achievement.
  ///
  /// [achievementId] is the platform-specific identifier for the achievement.
  ///
  /// Returns the [CloudAchievementInfo], or `null` if not found.
  Future<CloudAchievementInfo?> getAchievement(String achievementId);

  /// Opens the platform's native achievements UI.
  ///
  /// Returns `true` if the UI was successfully opened, `false` otherwise.
  Future<bool> showAchievements();

  /// Reveals a hidden achievement.
  ///
  /// [achievementId] is the platform-specific identifier for the achievement.
  ///
  /// Some platforms support hidden achievements that are revealed when
  /// the player makes progress. This method explicitly reveals them.
  ///
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> revealAchievement(String achievementId);
}