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
///   rateAppService: rateAppService,
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
    required this.iapService,
    this.rateAppService,
  });

  /// Creates a [QuizServices] with no-op implementations for analytics, ads, and IAP.
  ///
  /// Useful for testing or development when analytics, ads, and IAP aren't needed.
  factory QuizServices.noOp({
    required SettingsService settingsService,
    required StorageService storageService,
    required AchievementService achievementService,
    required ResourceManager resourceManager,
    RateAppService? rateAppService,
  }) {
    return QuizServices(
      settingsService: settingsService,
      storageService: storageService,
      achievementService: achievementService,
      screenAnalyticsService: NoOpAnalyticsService(),
      quizAnalyticsService: NoOpQuizAnalyticsService(),
      resourceManager: resourceManager,
      adsService: NoAdsService(),
      iapService: NoOpIAPService(),
      rateAppService: rateAppService,
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

  /// Service for managing in-app purchases.
  ///
  /// Provides:
  /// - Consumable products (lives, hints, bundles)
  /// - Non-consumable products (remove_ads)
  /// - Subscription management
  /// - Purchase restoration
  ///
  /// Use [NoOpIAPService] for testing or when IAP is disabled.
  final IAPService iapService;

  /// Service for managing in-app rating prompts.
  ///
  /// Provides:
  /// - Condition checking based on user engagement
  /// - Native rating dialog display
  /// - User response tracking and persistence
  ///
  /// Optional - when null, rate app prompts are disabled.
  final RateAppService? rateAppService;

  /// Creates a copy of this [QuizServices] with the given fields replaced.
  QuizServices copyWith({
    SettingsService? settingsService,
    StorageService? storageService,
    AchievementService? achievementService,
    AnalyticsService? screenAnalyticsService,
    QuizAnalyticsService? quizAnalyticsService,
    ResourceManager? resourceManager,
    AdsService? adsService,
    IAPService? iapService,
    RateAppService? rateAppService,
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
      iapService: iapService ?? this.iapService,
      rateAppService: rateAppService ?? this.rateAppService,
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
          adsService == other.adsService &&
          iapService == other.iapService &&
          rateAppService == other.rateAppService;

  @override
  int get hashCode => Object.hash(
        settingsService,
        storageService,
        achievementService,
        screenAnalyticsService,
        quizAnalyticsService,
        resourceManager,
        adsService,
        iapService,
        rateAppService,
      );
}