import 'analytics_event.dart';

/// Abstract analytics service interface.
///
/// Defines the contract for all analytics implementations.
/// Implementations include:
/// - [ConsoleAnalyticsService] - Development logging
/// - [NoOpAnalyticsService] - Testing (silent)
/// - FirebaseAnalyticsService - Production (Sprint 9.1.4)
/// - CompositeAnalyticsService - Multi-provider (Sprint 9.1.5)
abstract class AnalyticsService {
  /// Whether analytics is enabled.
  bool get isEnabled;

  /// Initializes the analytics service.
  ///
  /// Should be called once during app startup.
  Future<void> initialize();

  /// Logs an analytics event.
  ///
  /// [event] - The event to log (sealed class instance).
  Future<void> logEvent(AnalyticsEvent event);

  /// Sets the current screen for screen tracking.
  ///
  /// [screenName] - The name of the screen.
  /// [screenClass] - Optional screen class name.
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  });

  /// Sets a user property.
  ///
  /// [name] - The property name.
  /// [value] - The property value (null to clear).
  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  /// Sets the user ID for analytics.
  ///
  /// [userId] - The user ID (null to clear).
  Future<void> setUserId(String? userId);

  /// Resets all analytics data (user properties, user ID).
  ///
  /// Use when user logs out or requests data deletion.
  Future<void> resetAnalyticsData();

  /// Enables or disables analytics collection.
  ///
  /// [enabled] - Whether to enable analytics.
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Disposes the analytics service.
  void dispose();
}

/// User properties that can be set on the analytics service.
///
/// These are common properties tracked across the app.
abstract class AnalyticsUserProperties {
  static const String totalQuizzesTaken = 'total_quizzes_taken';
  static const String totalCorrectAnswers = 'total_correct_answers';
  static const String averageScore = 'average_score';
  static const String bestStreak = 'best_streak';
  static const String achievementsUnlocked = 'achievements_unlocked';
  static const String totalPoints = 'total_points';
  static const String favoriteCategory = 'favorite_category';
  static const String preferredQuizMode = 'preferred_quiz_mode';
  static const String soundEffectsEnabled = 'sound_effects_enabled';
  static const String hapticFeedbackEnabled = 'haptic_feedback_enabled';
  static const String isPremiumUser = 'is_premium_user';
  static const String appVersion = 'app_version';
  static const String firstOpenDate = 'first_open_date';
  static const String daysActive = 'days_active';
}
