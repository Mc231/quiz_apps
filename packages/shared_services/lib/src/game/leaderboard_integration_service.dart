import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../analytics/analytics_service.dart';
import '../analytics/events/interaction_event.dart';
import 'game_service.dart';
import 'game_service_config.dart';
import 'leaderboard_config.dart';
import 'leaderboard_service.dart';

/// Result of a leaderboard score submission attempt.
sealed class LeaderboardSubmitResult {
  const LeaderboardSubmitResult();

  /// Score was successfully submitted.
  factory LeaderboardSubmitResult.success({
    required String leaderboardId,
    int? newRank,
    bool? isNewHighScore,
  }) = LeaderboardSubmitSuccess;

  /// Score submission failed.
  factory LeaderboardSubmitResult.failed({
    required String leaderboardId,
    required String error,
    String? errorCode,
  }) = LeaderboardSubmitFailed;

  /// User is not signed in.
  factory LeaderboardSubmitResult.notSignedIn() = LeaderboardSubmitNotSignedIn;

  /// Leaderboard not found in configuration.
  factory LeaderboardSubmitResult.notConfigured({
    required String leaderboardId,
  }) = LeaderboardSubmitNotConfigured;

  /// Platform not supported.
  factory LeaderboardSubmitResult.platformNotSupported() =
      LeaderboardSubmitPlatformNotSupported;
}

/// Successful leaderboard submission.
class LeaderboardSubmitSuccess extends LeaderboardSubmitResult {
  const LeaderboardSubmitSuccess({
    required this.leaderboardId,
    this.newRank,
    this.isNewHighScore,
  });

  /// The leaderboard ID that was submitted to.
  final String leaderboardId;

  /// The player's new rank (if available).
  final int? newRank;

  /// Whether this was a new high score (if available).
  final bool? isNewHighScore;
}

/// Leaderboard submission failed.
class LeaderboardSubmitFailed extends LeaderboardSubmitResult {
  const LeaderboardSubmitFailed({
    required this.leaderboardId,
    required this.error,
    this.errorCode,
  });

  /// The leaderboard ID that failed.
  final String leaderboardId;

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// User is not signed in.
class LeaderboardSubmitNotSignedIn extends LeaderboardSubmitResult {
  const LeaderboardSubmitNotSignedIn();
}

/// Leaderboard not found in configuration.
class LeaderboardSubmitNotConfigured extends LeaderboardSubmitResult {
  const LeaderboardSubmitNotConfigured({
    required this.leaderboardId,
  });

  /// The leaderboard ID that was not found.
  final String leaderboardId;
}

/// Platform not supported.
class LeaderboardSubmitPlatformNotSupported extends LeaderboardSubmitResult {
  const LeaderboardSubmitPlatformNotSupported();
}

/// Queued score for offline submission.
class _QueuedScore {
  const _QueuedScore({
    required this.leaderboardId,
    required this.score,
    required this.timestamp,
    this.categoryId,
    this.quizId,
  });

  final String leaderboardId;
  final int score;
  final DateTime timestamp;
  final String? categoryId;
  final String? quizId;
}

/// Service for orchestrating leaderboard score submissions.
///
/// Provides a unified API for submitting scores to platform leaderboards
/// (Game Center on iOS, Play Games on Android) with:
/// - Platform detection and service selection
/// - Internal ID to platform ID mapping via [GameServiceConfig]
/// - Offline queue with automatic retry
/// - Analytics tracking
///
/// **Usage:**
/// ```dart
/// final service = LeaderboardIntegrationService(
///   config: gameServiceConfig,
///   gameService: gameCenterServices.gameService,
///   leaderboardService: gameCenterServices.leaderboardService,
///   analyticsService: analytics,
/// );
///
/// await service.initialize();
///
/// // Submit score after quiz completion
/// final result = await service.submitScore(
///   leaderboardId: 'europe',
///   score: 85,
///   categoryId: 'europe',
///   quizId: 'quiz-123',
/// );
/// ```
class LeaderboardIntegrationService {
  /// Creates a [LeaderboardIntegrationService].
  LeaderboardIntegrationService({
    required this.config,
    required this.gameService,
    required this.leaderboardService,
    this.analyticsService,
    this.maxQueueSize = 50,
    this.retryDelaySeconds = 30,
  });

  /// Configuration containing leaderboard mappings.
  final GameServiceConfig config;

  /// Game service for checking sign-in status.
  final GameService gameService;

  /// Platform-specific leaderboard service.
  final LeaderboardService leaderboardService;

  /// Optional analytics service for tracking.
  final AnalyticsService? analyticsService;

  /// Maximum number of scores to queue when offline.
  final int maxQueueSize;

  /// Delay in seconds before retrying failed submissions.
  final int retryDelaySeconds;

  /// Queue for offline score submissions.
  final Queue<_QueuedScore> _offlineQueue = Queue<_QueuedScore>();

  /// Timer for retry attempts.
  Timer? _retryTimer;

  /// Whether the service is currently processing the queue.
  bool _isProcessingQueue = false;

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Whether the current platform is supported.
  bool get isSupported => Platform.isIOS || Platform.isMacOS || Platform.isAndroid;

  /// Number of queued scores pending submission.
  int get pendingSubmissions => _offlineQueue.length;

  /// Initializes the service.
  ///
  /// Call this once at app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Process any queued scores from previous session
    await _processQueue();
  }

  /// Submits a score to a leaderboard.
  ///
  /// [leaderboardId] is the internal leaderboard ID (e.g., 'europe', 'global').
  /// [score] is the score value to submit.
  /// [categoryId] and [quizId] are optional context for analytics.
  ///
  /// If the user is offline or not signed in, the score is queued for later.
  Future<LeaderboardSubmitResult> submitScore({
    required String leaderboardId,
    required int score,
    String? categoryId,
    String? quizId,
  }) async {
    if (!isSupported) {
      return LeaderboardSubmitResult.platformNotSupported();
    }

    if (!config.isEnabled) {
      return LeaderboardSubmitResult.platformNotSupported();
    }

    // Find the leaderboard configuration
    final leaderboardConfig = config.getLeaderboard(leaderboardId);
    if (leaderboardConfig == null) {
      return LeaderboardSubmitResult.notConfigured(leaderboardId: leaderboardId);
    }

    // Get the platform-specific ID
    final platformId = _getPlatformId(leaderboardConfig);
    if (platformId == null) {
      return LeaderboardSubmitResult.notConfigured(leaderboardId: leaderboardId);
    }

    // Check sign-in status
    final isSignedIn = await gameService.isSignedIn();
    if (!isSignedIn) {
      // Queue for later
      _queueScore(
        leaderboardId: leaderboardId,
        score: score,
        categoryId: categoryId,
        quizId: quizId,
      );
      return LeaderboardSubmitResult.notSignedIn();
    }

    // Submit the score
    final result = await leaderboardService.submitScore(
      leaderboardId: platformId,
      score: score,
    );

    // Handle result
    switch (result) {
      case SubmitScoreSuccess():
        await _trackSubmission(
          leaderboardId: leaderboardId,
          score: score,
          success: true,
          categoryId: categoryId,
          quizId: quizId,
        );
        return LeaderboardSubmitResult.success(
          leaderboardId: leaderboardId,
          newRank: result.newRank,
          isNewHighScore: result.isNewHighScore,
        );

      case SubmitScoreFailed(:final error, :final errorCode):
        // Queue for retry if it's a transient error
        if (_isTransientError(errorCode)) {
          _queueScore(
            leaderboardId: leaderboardId,
            score: score,
            categoryId: categoryId,
            quizId: quizId,
          );
        }
        await _trackSubmission(
          leaderboardId: leaderboardId,
          score: score,
          success: false,
          error: error,
          categoryId: categoryId,
          quizId: quizId,
        );
        return LeaderboardSubmitResult.failed(
          leaderboardId: leaderboardId,
          error: error,
          errorCode: errorCode,
        );

      case SubmitScoreNotSignedIn():
        _queueScore(
          leaderboardId: leaderboardId,
          score: score,
          categoryId: categoryId,
          quizId: quizId,
        );
        return LeaderboardSubmitResult.notSignedIn();
    }
  }

  /// Submits scores to multiple leaderboards.
  ///
  /// Useful when a quiz result should be submitted to both global and
  /// category-specific leaderboards.
  Future<List<LeaderboardSubmitResult>> submitToMultiple({
    required List<String> leaderboardIds,
    required int score,
    String? categoryId,
    String? quizId,
  }) async {
    final results = <LeaderboardSubmitResult>[];

    for (final leaderboardId in leaderboardIds) {
      final result = await submitScore(
        leaderboardId: leaderboardId,
        score: score,
        categoryId: categoryId,
        quizId: quizId,
      );
      results.add(result);
    }

    return results;
  }

  /// Processes the offline queue.
  ///
  /// Call this when connectivity is restored or user signs in.
  Future<void> processQueue() async {
    await _processQueue();
  }

  /// Clears all queued scores.
  void clearQueue() {
    _offlineQueue.clear();
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Gets the platform-specific leaderboard ID.
  String? _getPlatformId(LeaderboardConfig leaderboardConfig) {
    if (Platform.isIOS || Platform.isMacOS) {
      return leaderboardConfig.gameCenterId;
    } else if (Platform.isAndroid) {
      return leaderboardConfig.playGamesId;
    }
    return null;
  }

  /// Queues a score for later submission.
  void _queueScore({
    required String leaderboardId,
    required int score,
    String? categoryId,
    String? quizId,
  }) {
    // Remove oldest if queue is full
    while (_offlineQueue.length >= maxQueueSize) {
      _offlineQueue.removeFirst();
    }

    _offlineQueue.add(_QueuedScore(
      leaderboardId: leaderboardId,
      score: score,
      timestamp: DateTime.now(),
      categoryId: categoryId,
      quizId: quizId,
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

  /// Processes queued scores.
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

      // Process all queued scores
      final toProcess = List<_QueuedScore>.from(_offlineQueue);
      _offlineQueue.clear();

      for (final queued in toProcess) {
        final result = await submitScore(
          leaderboardId: queued.leaderboardId,
          score: queued.score,
          categoryId: queued.categoryId,
          quizId: queued.quizId,
        );

        // If still failing, it will be re-queued by submitScore
        if (result is LeaderboardSubmitNotSignedIn) {
          // User signed out during processing, stop
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

  /// Tracks a leaderboard submission for analytics.
  Future<void> _trackSubmission({
    required String leaderboardId,
    required int score,
    required bool success,
    String? error,
    String? categoryId,
    String? quizId,
  }) async {
    final analytics = analyticsService;
    if (analytics == null) return;

    await analytics.logEvent(
      InteractionEvent.buttonTapped(
        buttonName: 'leaderboard_submit',
        context: leaderboardId,
        extra: {
          'score': score,
          'success': success,
          if (error != null) 'error': error,
          if (categoryId != null) 'category_id': categoryId,
          if (quizId != null) 'quiz_id': quizId,
          'platform': Platform.operatingSystem,
        },
      ),
    );
  }

  /// Disposes of resources.
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _offlineQueue.clear();
  }
}
