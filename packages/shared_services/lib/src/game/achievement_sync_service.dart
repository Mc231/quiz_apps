import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../achievements/models/achievement.dart';
import '../achievements/services/achievement_service.dart';
import '../analytics/analytics_service.dart';
import '../analytics/events/interaction_event.dart';
import 'cloud_achievement_service.dart';
import 'game_service.dart';
import 'game_service_config.dart';

/// Result of syncing an achievement to the platform.
sealed class AchievementSyncResult {
  const AchievementSyncResult();

  /// Achievement was successfully synced.
  factory AchievementSyncResult.success({
    required String achievementId,
    bool? wasAlreadyUnlocked,
  }) = AchievementSyncSuccess;

  /// Achievement sync failed.
  factory AchievementSyncResult.failed({
    required String achievementId,
    required String error,
    String? errorCode,
  }) = AchievementSyncFailed;

  /// Achievement not found in configuration.
  factory AchievementSyncResult.notMapped({
    required String achievementId,
  }) = AchievementSyncNotMapped;

  /// User is not signed in.
  factory AchievementSyncResult.notSignedIn() = AchievementSyncNotSignedIn;

  /// Platform not supported.
  factory AchievementSyncResult.platformNotSupported() =
      AchievementSyncPlatformNotSupported;
}

/// Successful achievement sync.
class AchievementSyncSuccess extends AchievementSyncResult {
  const AchievementSyncSuccess({
    required this.achievementId,
    this.wasAlreadyUnlocked,
  });

  /// The achievement ID that was synced.
  final String achievementId;

  /// Whether the achievement was already unlocked on the platform.
  final bool? wasAlreadyUnlocked;
}

/// Achievement sync failed.
class AchievementSyncFailed extends AchievementSyncResult {
  const AchievementSyncFailed({
    required this.achievementId,
    required this.error,
    this.errorCode,
  });

  /// The achievement ID that failed.
  final String achievementId;

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// Achievement not found in configuration.
class AchievementSyncNotMapped extends AchievementSyncResult {
  const AchievementSyncNotMapped({
    required this.achievementId,
  });

  /// The achievement ID that was not found.
  final String achievementId;
}

/// User is not signed in.
class AchievementSyncNotSignedIn extends AchievementSyncResult {
  const AchievementSyncNotSignedIn();
}

/// Platform not supported.
class AchievementSyncPlatformNotSupported extends AchievementSyncResult {
  const AchievementSyncPlatformNotSupported();
}

/// Queued achievement for offline sync.
class _QueuedAchievement {
  const _QueuedAchievement({
    required this.achievementId,
    required this.timestamp,
    this.isIncremental = false,
    this.progress,
  });

  final String achievementId;
  final DateTime timestamp;
  final bool isIncremental;
  final int? progress;
}

/// Service for syncing local achievements to platform game services.
///
/// Bridges the local [AchievementService] with platform-specific cloud
/// achievement services (Game Center on iOS, Play Games on Android).
///
/// **Features:**
/// - Listens to [AchievementService.onAchievementsUnlocked] stream
/// - Maps internal achievement IDs to platform IDs via [GameServiceConfig]
/// - Syncs all previously unlocked achievements on sign-in
/// - Handles incremental achievements with progress reporting
/// - Offline queue with automatic retry
///
/// **Usage:**
/// ```dart
/// final syncService = AchievementSyncService(
///   config: gameServiceConfig,
///   gameService: gameCenterServices.gameService,
///   cloudAchievementService: gameCenterServices.cloudAchievementService,
///   achievementService: localAchievementService,
///   analyticsService: analytics,
/// );
///
/// await syncService.initialize();
///
/// // Service now automatically syncs achievements when they're unlocked
/// ```
class AchievementSyncService {
  /// Creates an [AchievementSyncService].
  AchievementSyncService({
    required this.config,
    required this.gameService,
    required this.cloudAchievementService,
    required this.achievementService,
    this.analyticsService,
    this.maxQueueSize = 100,
    this.retryDelaySeconds = 30,
  });

  /// Configuration containing achievement ID mappings.
  final GameServiceConfig config;

  /// Game service for checking sign-in status.
  final GameService gameService;

  /// Platform-specific cloud achievement service.
  final CloudAchievementService cloudAchievementService;

  /// Local achievement service to listen for unlocks.
  final AchievementService achievementService;

  /// Optional analytics service for tracking.
  final AnalyticsService? analyticsService;

  /// Maximum number of achievements to queue when offline.
  final int maxQueueSize;

  /// Delay in seconds before retrying failed syncs.
  final int retryDelaySeconds;

  /// Subscription to achievement unlocks.
  StreamSubscription<List<Achievement>>? _unlockSubscription;

  /// Queue for offline achievement syncs.
  final Queue<_QueuedAchievement> _offlineQueue = Queue<_QueuedAchievement>();

  /// Timer for retry attempts.
  Timer? _retryTimer;

  /// Whether the service is currently processing the queue.
  bool _isProcessingQueue = false;

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Whether the current platform is supported.
  bool get isSupported =>
      Platform.isIOS || Platform.isMacOS || Platform.isAndroid;

  /// Number of queued achievements pending sync.
  int get pendingSyncs => _offlineQueue.length;

  /// Initializes the service and starts listening for achievement unlocks.
  ///
  /// Call this once at app startup after all services are ready.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Start listening to achievement unlocks
    _unlockSubscription = achievementService.onAchievementsUnlocked.listen(
      _handleAchievementsUnlocked,
    );

    // Process any queued achievements from previous session
    await _processQueue();
  }

  /// Syncs all previously unlocked achievements to the platform.
  ///
  /// Call this when the user signs in to catch up on any missed syncs.
  /// Returns the number of achievements successfully synced.
  Future<int> syncAllUnlocked() async {
    if (!isSupported || !config.isEnabled) {
      return 0;
    }

    // Check if signed in
    final isSignedIn = await gameService.isSignedIn();
    if (!isSignedIn) {
      return 0;
    }

    // Get all unlocked achievement IDs from local service
    final allProgress = await achievementService.getAllProgress();
    final unlockedIds = allProgress
        .where((p) => p.isUnlocked)
        .map((p) => p.achievementId)
        .toList();

    if (unlockedIds.isEmpty) {
      return 0;
    }

    int syncedCount = 0;
    for (final achievementId in unlockedIds) {
      final result = await syncAchievement(achievementId);
      if (result is AchievementSyncSuccess) {
        syncedCount++;
      }
    }

    return syncedCount;
  }

  /// Syncs a specific achievement to the platform.
  ///
  /// [achievementId] is the internal achievement ID.
  Future<AchievementSyncResult> syncAchievement(String achievementId) async {
    if (!isSupported) {
      return AchievementSyncResult.platformNotSupported();
    }

    if (!config.isEnabled) {
      return AchievementSyncResult.platformNotSupported();
    }

    // Get the platform-specific ID
    final platformId = config.getPlatformAchievementId(achievementId);
    if (platformId == null) {
      // Achievement not mapped - this is not necessarily an error,
      // some achievements may be local-only
      return AchievementSyncResult.notMapped(achievementId: achievementId);
    }

    // Check sign-in status
    final isSignedIn = await gameService.isSignedIn();
    if (!isSignedIn) {
      _queueAchievement(achievementId: achievementId);
      return AchievementSyncResult.notSignedIn();
    }

    // Unlock the achievement on the platform
    final result = await cloudAchievementService.unlockAchievement(platformId);

    // Handle result
    switch (result) {
      case UnlockAchievementSuccess(:final wasAlreadyUnlocked):
        await _trackSync(
          achievementId: achievementId,
          success: true,
          wasAlreadyUnlocked: wasAlreadyUnlocked,
        );
        return AchievementSyncResult.success(
          achievementId: achievementId,
          wasAlreadyUnlocked: wasAlreadyUnlocked,
        );

      case UnlockAchievementFailed(:final error, :final errorCode):
        // Queue for retry if it's a transient error
        if (_isTransientError(errorCode)) {
          _queueAchievement(achievementId: achievementId);
        }
        await _trackSync(
          achievementId: achievementId,
          success: false,
          error: error,
        );
        return AchievementSyncResult.failed(
          achievementId: achievementId,
          error: error,
          errorCode: errorCode,
        );

      case UnlockAchievementNotFound():
        // Achievement doesn't exist on the platform
        await _trackSync(
          achievementId: achievementId,
          success: false,
          error: 'Achievement not found on platform',
        );
        return AchievementSyncResult.failed(
          achievementId: achievementId,
          error: 'Achievement not found on platform',
          errorCode: 'NOT_FOUND',
        );

      case UnlockAchievementNotSignedIn():
        _queueAchievement(achievementId: achievementId);
        return AchievementSyncResult.notSignedIn();
    }
  }

  /// Reports progress on an incremental achievement.
  ///
  /// [achievementId] is the internal achievement ID.
  /// [currentProgress] is the current progress value.
  /// [totalRequired] is the total required for completion.
  Future<AchievementSyncResult> reportProgress({
    required String achievementId,
    required int currentProgress,
    required int totalRequired,
  }) async {
    if (!isSupported || !config.isEnabled) {
      return AchievementSyncResult.platformNotSupported();
    }

    // Get the platform-specific ID
    final platformId = config.getPlatformAchievementId(achievementId);
    if (platformId == null) {
      return AchievementSyncResult.notMapped(achievementId: achievementId);
    }

    // Check sign-in status
    final isSignedIn = await gameService.isSignedIn();
    if (!isSignedIn) {
      _queueAchievement(
        achievementId: achievementId,
        isIncremental: true,
        progress: currentProgress,
      );
      return AchievementSyncResult.notSignedIn();
    }

    // Calculate steps for the platform
    // Both Game Center and Play Games support progress reporting
    final result = await cloudAchievementService.setAchievementProgress(
      platformId,
      steps: currentProgress,
    );

    switch (result) {
      case IncrementAchievementSuccess(:final isUnlocked):
        await _trackSync(
          achievementId: achievementId,
          success: true,
          isProgress: true,
          progress: currentProgress,
          total: totalRequired,
        );
        return AchievementSyncResult.success(
          achievementId: achievementId,
          wasAlreadyUnlocked: isUnlocked,
        );

      case IncrementAchievementFailed(:final error, :final errorCode):
        if (_isTransientError(errorCode)) {
          _queueAchievement(
            achievementId: achievementId,
            isIncremental: true,
            progress: currentProgress,
          );
        }
        await _trackSync(
          achievementId: achievementId,
          success: false,
          error: error,
          isProgress: true,
        );
        return AchievementSyncResult.failed(
          achievementId: achievementId,
          error: error,
          errorCode: errorCode,
        );

      case IncrementAchievementNotFound():
        return AchievementSyncResult.failed(
          achievementId: achievementId,
          error: 'Achievement not found on platform',
          errorCode: 'NOT_FOUND',
        );

      case IncrementAchievementNotSignedIn():
        _queueAchievement(
          achievementId: achievementId,
          isIncremental: true,
          progress: currentProgress,
        );
        return AchievementSyncResult.notSignedIn();
    }
  }

  /// Processes the offline queue.
  ///
  /// Call this when connectivity is restored or user signs in.
  Future<void> processQueue() async {
    await _processQueue();
  }

  /// Clears all queued achievements.
  void clearQueue() {
    _offlineQueue.clear();
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Handles achievements unlocked from the local service.
  void _handleAchievementsUnlocked(List<Achievement> achievements) {
    for (final achievement in achievements) {
      // Sync each achievement asynchronously (fire and forget)
      syncAchievement(achievement.id);
    }
  }

  /// Queues an achievement for later sync.
  void _queueAchievement({
    required String achievementId,
    bool isIncremental = false,
    int? progress,
  }) {
    // Remove any existing queue entry for this achievement
    _offlineQueue.removeWhere((a) => a.achievementId == achievementId);

    // Remove oldest if queue is full
    while (_offlineQueue.length >= maxQueueSize) {
      _offlineQueue.removeFirst();
    }

    _offlineQueue.add(_QueuedAchievement(
      achievementId: achievementId,
      timestamp: DateTime.now(),
      isIncremental: isIncremental,
      progress: progress,
    ));

    // Start retry timer if not already running
    _startRetryTimer();
  }

  /// Starts or restarts the retry timer.
  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer(
      Duration(seconds: retryDelaySeconds),
      _processQueue,
    );
  }

  /// Processes queued achievements.
  Future<void> _processQueue() async {
    if (_isProcessingQueue || _offlineQueue.isEmpty) {
      return;
    }

    _isProcessingQueue = true;

    try {
      // Check if signed in
      final isSignedIn = await gameService.isSignedIn();
      if (!isSignedIn) {
        _startRetryTimer();
        return;
      }

      // Process all queued achievements
      final toProcess = List<_QueuedAchievement>.from(_offlineQueue);
      _offlineQueue.clear();

      for (final queued in toProcess) {
        AchievementSyncResult result;

        if (queued.isIncremental && queued.progress != null) {
          // For incremental achievements, we need to get the total
          // This is a simplified approach - in production you might want
          // to store the total in the queue as well
          result = await reportProgress(
            achievementId: queued.achievementId,
            currentProgress: queued.progress!,
            totalRequired: 100, // Default, will be overridden by platform
          );
        } else {
          result = await syncAchievement(queued.achievementId);
        }

        // If still failing due to sign-in, stop processing
        if (result is AchievementSyncNotSignedIn) {
          break;
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Checks if an error is transient and should be retried.
  bool _isTransientError(String? errorCode) {
    if (errorCode == null) return true;

    // Network and server errors are transient
    return errorCode.contains('NETWORK') ||
        errorCode.contains('TIMEOUT') ||
        errorCode.contains('SERVER') ||
        errorCode.contains('UNAVAILABLE');
  }

  /// Tracks an achievement sync for analytics.
  Future<void> _trackSync({
    required String achievementId,
    required bool success,
    String? error,
    bool? wasAlreadyUnlocked,
    bool isProgress = false,
    int? progress,
    int? total,
  }) async {
    final analytics = analyticsService;
    if (analytics == null) return;

    await analytics.logEvent(
      InteractionEvent.buttonTapped(
        buttonName: isProgress ? 'achievement_progress' : 'achievement_sync',
        context: achievementId,
        extra: {
          'success': success,
          if (error != null) 'error': error,
          if (wasAlreadyUnlocked != null)
            'was_already_unlocked': wasAlreadyUnlocked,
          if (progress != null) 'progress': progress,
          if (total != null) 'total': total,
          'platform': Platform.operatingSystem,
        },
      ),
    );
  }

  /// Disposes of resources.
  void dispose() {
    _unlockSubscription?.cancel();
    _unlockSubscription = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _offlineQueue.clear();
    _initialized = false;
  }
}
