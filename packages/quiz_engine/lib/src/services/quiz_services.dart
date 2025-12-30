import 'package:flutter/foundation.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

/// Immutable container for all core services used by quiz widgets.
///
/// This class provides a centralized location for all services that widgets
/// need to access. It's designed to be passed down the widget tree via
/// [QuizServicesProvider] and accessed through context extensions.
///
/// ## Usage
///
/// ```dart
/// final services = QuizServices(
///   settingsService: settingsService,
///   storageService: storageService,
///   achievementService: achievementService,
///   screenAnalyticsService: analyticsService,
///   quizAnalyticsService: quizAnalyticsService,
///   resourceManager: resourceManager,
/// );
///
/// // Wrap your widget tree
/// QuizServicesProvider(
///   services: services,
///   child: MyApp(),
/// )
/// ```
///
/// ## Factory Constructors
///
/// For testing or development, use the factory constructors:
///
/// ```dart
/// // No-op services for testing
/// final testServices = QuizServices.noOp(storageService: mockStorage);
/// ```
@immutable
class QuizServices {
  /// Creates a [QuizServices] with all required services.
  const QuizServices({
    required this.settingsService,
    required this.storageService,
    required this.achievementService,
    required this.screenAnalyticsService,
    required this.quizAnalyticsService,
    required this.resourceManager,
    required this.adsService,
  });

  /// Creates a [QuizServices] with no-op implementations for analytics and ads.
  ///
  /// Useful for testing or development when analytics and ads aren't needed.
  factory QuizServices.noOp({
    required SettingsService settingsService,
    required StorageService storageService,
    required AchievementService achievementService,
    required ResourceManager resourceManager,
  }) {
    return QuizServices(
      settingsService: settingsService,
      storageService: storageService,
      achievementService: achievementService,
      screenAnalyticsService: NoOpAnalyticsService(),
      quizAnalyticsService: NoOpQuizAnalyticsService(),
      resourceManager: resourceManager,
      adsService: NoAdsService(),
    );
  }

  /// Service for managing quiz settings (sound, haptics, etc.).
  final SettingsService settingsService;

  /// Service for persistent storage of quiz sessions and statistics.
  final StorageService storageService;

  /// Service for managing achievements and unlocks.
  final AchievementService achievementService;

  /// Service for screen/navigation analytics tracking.
  final AnalyticsService screenAnalyticsService;

  /// Service for quiz-specific analytics events.
  final QuizAnalyticsService quizAnalyticsService;

  /// Resource manager for tracking hints, lives, and skips.
  ///
  /// Manages:
  /// - Daily free limits with midnight reset
  /// - Permanent purchased resources
  /// - Resource consumption during gameplay
  ///
  /// For testing or when persistence isn't needed, use [InMemoryResourceRepository].
  final ResourceManager resourceManager;

  /// Service for managing advertisements.
  ///
  /// Provides:
  /// - Banner ad loading and display
  /// - Interstitial ad management
  /// - Rewarded ad functionality
  /// - Premium/ad-free state management
  ///
  /// Use [NoAdsService] for testing or premium users.
  final AdsService adsService;

  /// Creates a copy of this [QuizServices] with the given fields replaced.
  QuizServices copyWith({
    SettingsService? settingsService,
    StorageService? storageService,
    AchievementService? achievementService,
    AnalyticsService? screenAnalyticsService,
    QuizAnalyticsService? quizAnalyticsService,
    ResourceManager? resourceManager,
    AdsService? adsService,
  }) {
    return QuizServices(
      settingsService: settingsService ?? this.settingsService,
      storageService: storageService ?? this.storageService,
      achievementService: achievementService ?? this.achievementService,
      screenAnalyticsService:
          screenAnalyticsService ?? this.screenAnalyticsService,
      quizAnalyticsService: quizAnalyticsService ?? this.quizAnalyticsService,
      resourceManager: resourceManager ?? this.resourceManager,
      adsService: adsService ?? this.adsService,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizServices &&
          runtimeType == other.runtimeType &&
          settingsService == other.settingsService &&
          storageService == other.storageService &&
          achievementService == other.achievementService &&
          screenAnalyticsService == other.screenAnalyticsService &&
          quizAnalyticsService == other.quizAnalyticsService &&
          resourceManager == other.resourceManager &&
          adsService == other.adsService;

  @override
  int get hashCode => Object.hash(
        settingsService,
        storageService,
        achievementService,
        screenAnalyticsService,
        quizAnalyticsService,
        resourceManager,
        adsService,
      );
}