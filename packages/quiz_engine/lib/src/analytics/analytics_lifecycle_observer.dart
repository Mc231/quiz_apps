import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_services/shared_services.dart';

/// A lifecycle observer that tracks app lifecycle events for analytics.
///
/// This observer handles:
/// - App launch tracking with cold start duration
/// - Session start/end tracking
/// - Background time tracking
/// - Anonymous user ID generation
/// - User property updates after quiz completion
///
/// ## Usage
///
/// Initialize early in your app startup:
///
/// ```dart
/// final startTime = DateTime.now();
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final analyticsService = FirebaseAnalyticsService();
///   await analyticsService.initialize();
///
///   final lifecycleObserver = AnalyticsLifecycleObserver(
///     analyticsService: analyticsService,
///   );
///
///   // Track app launch
///   await lifecycleObserver.trackAppLaunch(
///     startTime: startTime,
///     isFirstLaunch: prefs.getBool('first_launch') ?? true,
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Session Tracking
///
/// Sessions are automatically tracked when the app goes to foreground/background.
/// A new session starts when:
/// - The app is first launched
/// - The app returns from background after [sessionTimeoutDuration]
///
/// ## Anonymous User ID
///
/// The observer can generate and manage anonymous user IDs for tracking
/// users without requiring authentication:
///
/// ```dart
/// final userId = await lifecycleObserver.getOrCreateAnonymousUserId();
/// ```
class AnalyticsLifecycleObserver with WidgetsBindingObserver {
  /// Creates an [AnalyticsLifecycleObserver].
  ///
  /// [analyticsService] - The analytics service to use for logging.
  /// [sessionTimeoutDuration] - Duration after which a new session starts.
  /// [onSessionStart] - Callback when a new session starts.
  /// [onSessionEnd] - Callback when a session ends.
  AnalyticsLifecycleObserver({
    required this.analyticsService,
    this.sessionTimeoutDuration = const Duration(minutes: 30),
    this.onSessionStart,
    this.onSessionEnd,
  });

  /// The analytics service for logging events.
  final AnalyticsService analyticsService;

  /// Duration after which background time triggers a new session.
  final Duration sessionTimeoutDuration;

  /// Callback invoked when a new session starts.
  final void Function(String sessionId)? onSessionStart;

  /// Callback invoked when a session ends.
  final void Function(String sessionId, Duration duration)? onSessionEnd;

  // Session tracking state
  String? _currentSessionId;
  DateTime? _sessionStartTime;
  DateTime? _backgroundStartTime;
  int _screenViewCount = 0;
  int _interactionCount = 0;

  // Anonymous user ID storage key
  static const String _anonymousUserIdKey = 'anonymous_user_id';

  /// Whether the observer is currently active.
  bool _isActive = false;

  /// Returns the current session ID, if any.
  String? get currentSessionId => _currentSessionId;

  /// Returns whether a session is currently active.
  bool get hasActiveSession => _currentSessionId != null;

  /// Returns the current session duration.
  Duration? get currentSessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// Initializes the lifecycle observer.
  ///
  /// Call this method early in your app startup to start tracking.
  void initialize() {
    if (_isActive) return;
    _isActive = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Disposes the lifecycle observer.
  ///
  /// Call this when the observer is no longer needed.
  void dispose() {
    if (!_isActive) return;
    _isActive = false;
    WidgetsBinding.instance.removeObserver(this);

    // End current session if active
    if (hasActiveSession) {
      _endCurrentSession(exitReason: 'app_disposed');
    }
  }

  // ============ App Launch Tracking ============

  /// Tracks the app launch event.
  ///
  /// [startTime] - The time when the app started (capture before runApp).
  /// [isFirstLaunch] - Whether this is the first launch of the app.
  /// [launchType] - Optional launch type (e.g., 'cold', 'warm', 'hot').
  /// [previousVersion] - Previous app version if upgrading.
  Future<void> trackAppLaunch({
    required DateTime startTime,
    required bool isFirstLaunch,
    String? launchType,
    String? previousVersion,
  }) async {
    final coldStartDuration = DateTime.now().difference(startTime);

    await analyticsService.logEvent(
      PerformanceEvent.appLaunch(
        coldStartDuration: coldStartDuration,
        isFirstLaunch: isFirstLaunch,
        launchType: launchType ?? 'cold',
        previousVersion: previousVersion,
      ),
    );

    // Start a new session on app launch
    await startNewSession(entryPoint: 'app_launch');
  }

  // ============ Session Tracking ============

  /// Starts a new session.
  ///
  /// [entryPoint] - How the session was started (e.g., 'app_launch', 'foreground').
  /// [deviceInfo] - Optional device information to include.
  Future<void> startNewSession({
    String? entryPoint,
    Map<String, dynamic>? deviceInfo,
  }) async {
    // End previous session if exists
    if (hasActiveSession) {
      await _endCurrentSession(exitReason: 'new_session');
    }

    _currentSessionId = _generateSessionId();
    _sessionStartTime = DateTime.now();
    _screenViewCount = 0;
    _interactionCount = 0;

    await analyticsService.logEvent(
      PerformanceEvent.sessionStart(
        sessionId: _currentSessionId!,
        startTime: _sessionStartTime!,
        entryPoint: entryPoint,
        deviceInfo: deviceInfo,
      ),
    );

    onSessionStart?.call(_currentSessionId!);
  }

  /// Ends the current session.
  Future<void> _endCurrentSession({String? exitReason}) async {
    if (!hasActiveSession) return;

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);

    await analyticsService.logEvent(
      PerformanceEvent.sessionEnd(
        sessionId: _currentSessionId!,
        sessionDuration: sessionDuration,
        screenViewCount: _screenViewCount,
        interactionCount: _interactionCount,
        exitReason: exitReason,
      ),
    );

    onSessionEnd?.call(_currentSessionId!, sessionDuration);

    _currentSessionId = null;
    _sessionStartTime = null;
  }

  /// Increments the screen view count for the current session.
  void incrementScreenViews() {
    _screenViewCount++;
  }

  /// Increments the interaction count for the current session.
  void incrementInteractions() {
    _interactionCount++;
  }

  // ============ Background Time Tracking ============

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _onAppBackgrounded();
      case AppLifecycleState.resumed:
        _onAppForegrounded();
      case AppLifecycleState.detached:
        _onAppDetached();
      case AppLifecycleState.hidden:
        // Treat hidden same as paused
        _onAppBackgrounded();
    }
  }

  void _onAppBackgrounded() {
    _backgroundStartTime = DateTime.now();
  }

  Future<void> _onAppForegrounded() async {
    if (_backgroundStartTime == null) return;

    final backgroundDuration =
        DateTime.now().difference(_backgroundStartTime!);
    _backgroundStartTime = null;

    // Check if we need to start a new session
    if (backgroundDuration >= sessionTimeoutDuration) {
      await _endCurrentSession(exitReason: 'session_timeout');
      await startNewSession(entryPoint: 'foreground_after_timeout');
    }
  }

  void _onAppDetached() {
    // End session when app is detached
    if (hasActiveSession) {
      _endCurrentSession(exitReason: 'app_detached');
    }
  }

  /// Returns the duration the app was in the background.
  ///
  /// Returns null if the app is not currently in the background.
  Duration? get backgroundDuration {
    if (_backgroundStartTime == null) return null;
    return DateTime.now().difference(_backgroundStartTime!);
  }

  // ============ Anonymous User ID ============

  /// Generates or retrieves an anonymous user ID.
  ///
  /// Uses [storageProvider] to persist the ID across app launches.
  /// If no ID exists, generates a new UUID-like ID.
  ///
  /// [storageProvider] - A function to get stored values.
  /// [storageSetter] - A function to set stored values.
  Future<String> getOrCreateAnonymousUserId({
    required Future<String?> Function(String key) storageProvider,
    required Future<void> Function(String key, String value) storageSetter,
  }) async {
    // Try to get existing ID
    final existingId = await storageProvider(_anonymousUserIdKey);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    // Generate new ID
    final newId = generateAnonymousUserId();
    await storageSetter(_anonymousUserIdKey, newId);
    await analyticsService.setUserId(newId);

    return newId;
  }

  /// Generates a new anonymous user ID.
  ///
  /// Format: `anon_XXXXXXXX-XXXX-4XXX-YXXX-XXXXXXXXXXXX`
  /// Where X is a random hex digit and Y is 8, 9, A, or B.
  static String generateAnonymousUserId() {
    final random = Random.secure();

    String randomHex(int length) {
      const hexDigits = '0123456789abcdef';
      return List.generate(
        length,
        (_) => hexDigits[random.nextInt(16)],
      ).join();
    }

    // Generate UUID v4-like format
    final part1 = randomHex(8);
    final part2 = randomHex(4);
    final part3 = '4${randomHex(3)}'; // Version 4
    final part4 =
        '${['8', '9', 'a', 'b'][random.nextInt(4)]}${randomHex(3)}'; // Variant
    final part5 = randomHex(12);

    return 'anon_$part1-$part2-$part3-$part4-$part5';
  }

  /// Sets the anonymous user ID on the analytics service.
  Future<void> setAnonymousUserId(String userId) async {
    await analyticsService.setUserId(userId);
  }

  /// Clears the anonymous user ID (e.g., when user logs in).
  Future<void> clearAnonymousUserId({
    required Future<void> Function(String key) storageRemover,
  }) async {
    await storageRemover(_anonymousUserIdKey);
    await analyticsService.setUserId(null);
  }

  // ============ User Properties ============

  /// Updates user properties after quiz completion.
  ///
  /// This method updates cumulative user properties based on quiz results.
  /// Properties are batched and sent together for efficiency.
  ///
  /// [totalQuizzesTaken] - Total number of quizzes completed.
  /// [totalCorrectAnswers] - Total correct answers across all quizzes.
  /// [averageScore] - Average score percentage.
  /// [bestStreak] - Best correct answer streak.
  /// [totalPoints] - Total points earned.
  /// [favoriteCategory] - Most played category ID.
  /// [preferredQuizMode] - Most used quiz mode.
  Future<void> updateUserPropertiesAfterQuiz({
    int? totalQuizzesTaken,
    int? totalCorrectAnswers,
    double? averageScore,
    int? bestStreak,
    int? totalPoints,
    String? favoriteCategory,
    String? preferredQuizMode,
  }) async {
    if (totalQuizzesTaken != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.totalQuizzesTaken,
        value: totalQuizzesTaken.toString(),
      );
    }

    if (totalCorrectAnswers != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.totalCorrectAnswers,
        value: totalCorrectAnswers.toString(),
      );
    }

    if (averageScore != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.averageScore,
        value: averageScore.toStringAsFixed(1),
      );
    }

    if (bestStreak != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.bestStreak,
        value: bestStreak.toString(),
      );
    }

    if (totalPoints != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.totalPoints,
        value: totalPoints.toString(),
      );
    }

    if (favoriteCategory != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.favoriteCategory,
        value: favoriteCategory,
      );
    }

    if (preferredQuizMode != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.preferredQuizMode,
        value: preferredQuizMode,
      );
    }
  }

  /// Updates achievement-related user properties.
  ///
  /// [achievementsUnlocked] - Number of achievements unlocked.
  Future<void> updateAchievementProperties({
    required int achievementsUnlocked,
  }) async {
    await analyticsService.setUserProperty(
      name: AnalyticsUserProperties.achievementsUnlocked,
      value: achievementsUnlocked.toString(),
    );
  }

  /// Updates settings-related user properties.
  ///
  /// [soundEffectsEnabled] - Whether sound effects are enabled.
  /// [hapticFeedbackEnabled] - Whether haptic feedback is enabled.
  Future<void> updateSettingsProperties({
    bool? soundEffectsEnabled,
    bool? hapticFeedbackEnabled,
  }) async {
    if (soundEffectsEnabled != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.soundEffectsEnabled,
        value: soundEffectsEnabled.toString(),
      );
    }

    if (hapticFeedbackEnabled != null) {
      await analyticsService.setUserProperty(
        name: AnalyticsUserProperties.hapticFeedbackEnabled,
        value: hapticFeedbackEnabled.toString(),
      );
    }
  }

  /// Updates premium status user property.
  ///
  /// [isPremium] - Whether the user is a premium user.
  Future<void> updatePremiumStatus({required bool isPremium}) async {
    await analyticsService.setUserProperty(
      name: AnalyticsUserProperties.isPremiumUser,
      value: isPremium.toString(),
    );
  }

  /// Updates app version user property.
  ///
  /// [version] - The current app version.
  Future<void> updateAppVersion({required String version}) async {
    await analyticsService.setUserProperty(
      name: AnalyticsUserProperties.appVersion,
      value: version,
    );
  }

  /// Updates first open date user property.
  ///
  /// [date] - The first open date.
  Future<void> updateFirstOpenDate({required DateTime date}) async {
    await analyticsService.setUserProperty(
      name: AnalyticsUserProperties.firstOpenDate,
      value: date.toIso8601String().split('T').first,
    );
  }

  /// Updates days active user property.
  ///
  /// [daysActive] - Number of unique days the user has been active.
  Future<void> updateDaysActive({required int daysActive}) async {
    await analyticsService.setUserProperty(
      name: AnalyticsUserProperties.daysActive,
      value: daysActive.toString(),
    );
  }

  // ============ Helpers ============

  /// Generates a unique session ID.
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(0xFFFF);
    return '${timestamp.toRadixString(36)}_${random.toRadixString(16)}';
  }
}

/// Extension to provide lifecycle observer integration with AnalyticsService.
extension AnalyticsServiceLifecycleExtension on AnalyticsService {
  /// Creates an [AnalyticsLifecycleObserver] for this service.
  AnalyticsLifecycleObserver createLifecycleObserver({
    Duration sessionTimeoutDuration = const Duration(minutes: 30),
    void Function(String sessionId)? onSessionStart,
    void Function(String sessionId, Duration duration)? onSessionEnd,
  }) {
    return AnalyticsLifecycleObserver(
      analyticsService: this,
      sessionTimeoutDuration: sessionTimeoutDuration,
      onSessionStart: onSessionStart,
      onSessionEnd: onSessionEnd,
    );
  }
}

/// A widget that provides [AnalyticsLifecycleObserver] to its descendants.
///
/// Use this widget high in your widget tree to make the lifecycle observer
/// accessible throughout your app.
///
/// ```dart
/// AnalyticsLifecycleProvider(
///   observer: lifecycleObserver,
///   child: MaterialApp(...),
/// )
/// ```
class AnalyticsLifecycleProvider extends InheritedWidget {
  /// Creates an [AnalyticsLifecycleProvider].
  const AnalyticsLifecycleProvider({
    super.key,
    required this.observer,
    required super.child,
  });

  /// The lifecycle observer to provide.
  final AnalyticsLifecycleObserver observer;

  /// Returns the [AnalyticsLifecycleObserver] from the nearest ancestor.
  ///
  /// Throws if no [AnalyticsLifecycleProvider] is found.
  static AnalyticsLifecycleObserver of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AnalyticsLifecycleProvider>();
    assert(
      provider != null,
      'No AnalyticsLifecycleProvider found in context',
    );
    return provider!.observer;
  }

  /// Returns the [AnalyticsLifecycleObserver] from the nearest ancestor,
  /// or null if not found.
  static AnalyticsLifecycleObserver? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AnalyticsLifecycleProvider>();
    return provider?.observer;
  }

  @override
  bool updateShouldNotify(AnalyticsLifecycleProvider oldWidget) {
    return observer != oldWidget.observer;
  }
}
