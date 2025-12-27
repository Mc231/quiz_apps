import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../analytics_event.dart';
import '../analytics_service.dart';

/// Firebase Analytics implementation for production analytics.
///
/// Provides integration with Firebase Analytics for event tracking,
/// user properties, screen views, and more.
///
/// ## Usage
/// ```dart
/// final analyticsService = FirebaseAnalyticsService();
/// await analyticsService.initialize();
///
/// // Log an event
/// await analyticsService.logEvent(
///   QuizEvent.started(
///     quizId: 'quiz-123',
///     categoryId: 'flags',
///     questionCount: 10,
///     quizMode: 'standard',
///   ),
/// );
///
/// // Set user property
/// await analyticsService.setUserProperty(
///   name: AnalyticsUserProperties.totalQuizzesTaken,
///   value: '42',
/// );
/// ```
///
/// ## Firebase Event Name Constraints
/// - Event names must be 1-40 characters
/// - Can only contain alphanumeric characters and underscores
/// - Must start with an alphabetic character
/// - Reserved prefixes: firebase_, google_, ga_
///
/// ## Firebase Parameter Constraints
/// - Parameter names: 1-40 characters
/// - String parameter values: up to 100 characters
/// - Up to 25 parameters per event
class FirebaseAnalyticsService implements AnalyticsService {
  /// Creates a Firebase Analytics service.
  ///
  /// [firebaseAnalytics] - Optional custom instance for testing.
  /// [enableDebugLogging] - Whether to log events to console in debug mode.
  FirebaseAnalyticsService({
    FirebaseAnalytics? firebaseAnalytics,
    this.enableDebugLogging = kDebugMode,
  }) : _analytics = firebaseAnalytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  /// Whether to log events to console in debug mode.
  final bool enableDebugLogging;

  bool _isEnabled = true;
  bool _isInitialized = false;

  /// Firebase Analytics observer for navigation tracking.
  ///
  /// Add this to your app's navigatorObservers to automatically
  /// track screen views.
  ///
  /// ```dart
  /// MaterialApp(
  ///   navigatorObservers: [
  ///     firebaseAnalyticsService.observer,
  ///   ],
  /// )
  /// ```
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
        analytics: _analytics,
        nameExtractor: _extractScreenName,
      );

  @override
  bool get isEnabled => _isEnabled && _isInitialized;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    try {
      // Set default event parameters that apply to all events
      await _analytics.setDefaultEventParameters({
        'app_mode': kDebugMode ? 'debug' : 'release',
      });

      _isInitialized = true;
      _debugLog('Firebase Analytics initialized');
    } catch (e, stackTrace) {
      _debugLog('Failed to initialize Firebase Analytics: $e');
      developer.log(
        'Firebase Analytics initialization error',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
      // Don't rethrow - allow app to continue without analytics
      _isInitialized = true;
    }
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!isEnabled) return;

    try {
      final eventName = _sanitizeEventName(event.eventName);
      final parameters = _sanitizeParameters(event.parameters);

      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );

      _debugLog('Event logged: $eventName', parameters);
    } catch (e, stackTrace) {
      _debugLog('Failed to log event ${event.eventName}: $e');
      developer.log(
        'Failed to log event: ${event.eventName}',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics.logScreenView(
        screenName: _sanitizeScreenName(screenName),
        screenClass: screenClass,
      );

      _debugLog('Screen view: $screenName (class: $screenClass)');
    } catch (e, stackTrace) {
      _debugLog('Failed to log screen view $screenName: $e');
      developer.log(
        'Failed to log screen view: $screenName',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!isEnabled) return;

    try {
      final sanitizedName = _sanitizePropertyName(name);
      final sanitizedValue = value != null ? _truncateString(value, 36) : null;

      await _analytics.setUserProperty(
        name: sanitizedName,
        value: sanitizedValue,
      );

      _debugLog('User property set: $sanitizedName = $sanitizedValue');
    } catch (e, stackTrace) {
      _debugLog('Failed to set user property $name: $e');
      developer.log(
        'Failed to set user property: $name',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!isEnabled) return;

    try {
      await _analytics.setUserId(id: userId);
      _debugLog('User ID set: ${userId ?? "(cleared)"}');
    } catch (e, stackTrace) {
      _debugLog('Failed to set user ID: $e');
      developer.log(
        'Failed to set user ID',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();
      _debugLog('Analytics data reset');
    } catch (e, stackTrace) {
      _debugLog('Failed to reset analytics data: $e');
      developer.log(
        'Failed to reset analytics data',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      _isEnabled = enabled;
      _debugLog('Analytics collection ${enabled ? "enabled" : "disabled"}');
    } catch (e, stackTrace) {
      _debugLog('Failed to set analytics collection enabled: $e');
      developer.log(
        'Failed to set analytics collection enabled',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    _debugLog('Firebase Analytics service disposed');
  }

  // ============ Firebase-Specific Methods ============

  /// Sets the current user's consent status.
  ///
  /// Call this to update consent status when user changes their preferences.
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
    bool? adUserDataConsentGranted,
  }) async {
    try {
      await _analytics.setConsent(
        adStorageConsentGranted: adStorageConsentGranted,
        analyticsStorageConsentGranted: analyticsStorageConsentGranted,
        adUserDataConsentGranted: adUserDataConsentGranted,
      );
      _debugLog('Consent updated');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to set consent',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  /// Sets the session timeout duration.
  ///
  /// Default is 30 minutes.
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    try {
      await _analytics.setSessionTimeoutDuration(timeout);
      _debugLog('Session timeout set to ${timeout.inMinutes} minutes');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to set session timeout',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseAnalyticsService',
      );
    }
  }

  /// Gets the app instance ID.
  ///
  /// Returns null if analytics is not initialized or disabled.
  Future<String?> getAppInstanceId() async {
    try {
      return await _analytics.appInstanceId;
    } catch (e) {
      _debugLog('Failed to get app instance ID: $e');
      return null;
    }
  }

  // ============ Event Name and Parameter Sanitization ============

  /// Sanitizes an event name to comply with Firebase constraints.
  ///
  /// - Truncates to 40 characters
  /// - Replaces invalid characters with underscores
  /// - Ensures it starts with a letter
  /// - Converts to lowercase (recommended by Firebase)
  String _sanitizeEventName(String name) {
    var sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_'); // Remove consecutive underscores

    // Ensure it starts with a letter
    if (sanitized.isNotEmpty && !RegExp(r'^[a-z]').hasMatch(sanitized)) {
      sanitized = 'e_$sanitized';
    }

    // Truncate to 40 characters
    return _truncateString(sanitized, 40);
  }

  /// Sanitizes a screen name for Firebase.
  String _sanitizeScreenName(String name) {
    return _truncateString(name, 100);
  }

  /// Sanitizes a property name for Firebase.
  String _sanitizePropertyName(String name) {
    var sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    if (sanitized.isNotEmpty && !RegExp(r'^[a-z]').hasMatch(sanitized)) {
      sanitized = 'p_$sanitized';
    }

    return _truncateString(sanitized, 24);
  }

  /// Sanitizes event parameters for Firebase.
  ///
  /// - Limits to 25 parameters
  /// - Truncates parameter names to 40 characters
  /// - Truncates string values to 100 characters
  /// - Converts non-primitive types to strings
  Map<String, Object>? _sanitizeParameters(Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return null;

    final sanitized = <String, Object>{};
    var count = 0;

    for (final entry in parameters.entries) {
      if (count >= 25) break; // Firebase limit

      final key = _sanitizeParameterName(entry.key);
      final value = _sanitizeParameterValue(entry.value);

      if (value != null) {
        sanitized[key] = value;
        count++;
      }
    }

    return sanitized.isEmpty ? null : sanitized;
  }

  /// Sanitizes a parameter name.
  String _sanitizeParameterName(String name) {
    var sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    return _truncateString(sanitized, 40);
  }

  /// Sanitizes a parameter value.
  Object? _sanitizeParameterValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return _truncateString(value, 100);
    }

    if (value is int || value is double || value is bool) {
      return value;
    }

    if (value is List || value is Map) {
      // Convert complex types to JSON string (truncated)
      return _truncateString(value.toString(), 100);
    }

    // Convert other types to string
    return _truncateString(value.toString(), 100);
  }

  /// Truncates a string to the specified maximum length.
  String _truncateString(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength);
  }

  /// Extracts screen name from route settings.
  String? _extractScreenName(RouteSettings settings) {
    return settings.name;
  }

  /// Logs a debug message if debug logging is enabled.
  void _debugLog(String message, [Map<String, Object>? parameters]) {
    if (!enableDebugLogging) return;

    final buffer = StringBuffer('[FirebaseAnalytics] $message');
    if (parameters != null && parameters.isNotEmpty) {
      buffer.writeln();
      for (final entry in parameters.entries) {
        buffer.writeln('  ${entry.key}: ${entry.value}');
      }
    }

    developer.log(buffer.toString(), name: 'FirebaseAnalyticsService');
  }

  // ============ Firebase Standard Events ============
  // These map to Firebase's predefined event types for better analytics.

  /// Logs a purchase event using Firebase's standard ecommerce event.
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
    String? coupon,
    List<AnalyticsEventItem>? items,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics.logPurchase(
        currency: currency,
        value: value,
        transactionId: transactionId,
        coupon: coupon,
        items: items,
      );
      _debugLog('Purchase logged: $value $currency');
    } catch (e) {
      _debugLog('Failed to log purchase: $e');
    }
  }

  /// Logs an app open event.
  Future<void> logAppOpen() async {
    if (!isEnabled) return;

    try {
      await _analytics.logAppOpen();
      _debugLog('App open logged');
    } catch (e) {
      _debugLog('Failed to log app open: $e');
    }
  }

  /// Logs a share event.
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method,
      );
      _debugLog('Share logged: $contentType - $itemId via $method');
    } catch (e) {
      _debugLog('Failed to log share: $e');
    }
  }

  /// Logs an unlock achievement event.
  Future<void> logUnlockAchievement({
    required String achievementId,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics.logUnlockAchievement(id: achievementId);
      _debugLog('Achievement unlocked: $achievementId');
    } catch (e) {
      _debugLog('Failed to log achievement: $e');
    }
  }

  /// Logs a level up event.
  Future<void> logLevelUp({
    required int level,
    String? character,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics.logLevelUp(level: level, character: character);
      _debugLog('Level up: $level');
    } catch (e) {
      _debugLog('Failed to log level up: $e');
    }
  }

  /// Logs a post score event.
  Future<void> logPostScore({
    required int score,
    int? level,
    String? character,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics.logPostScore(
        score: score,
        level: level,
        character: character,
      );
      _debugLog('Score posted: $score');
    } catch (e) {
      _debugLog('Failed to log score: $e');
    }
  }

  /// Logs a tutorial begin event.
  Future<void> logTutorialBegin() async {
    if (!isEnabled) return;

    try {
      await _analytics.logTutorialBegin();
      _debugLog('Tutorial begin');
    } catch (e) {
      _debugLog('Failed to log tutorial begin: $e');
    }
  }

  /// Logs a tutorial complete event.
  Future<void> logTutorialComplete() async {
    if (!isEnabled) return;

    try {
      await _analytics.logTutorialComplete();
      _debugLog('Tutorial complete');
    } catch (e) {
      _debugLog('Failed to log tutorial complete: $e');
    }
  }
}
