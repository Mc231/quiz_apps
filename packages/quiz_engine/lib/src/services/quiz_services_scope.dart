import 'package:flutter/widgets.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'quiz_services.dart';
import 'quiz_services_provider.dart';

/// A widget that allows overriding specific services from the parent [QuizServicesProvider].
///
/// This is particularly useful for testing, where you might want to override
/// only specific services with mock implementations while keeping the rest.
///
/// ## Usage
///
/// ```dart
/// // Override only the storage service for testing
/// QuizServicesScope(
///   storageService: MockStorageService(),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Behavior
///
/// - Services that are not explicitly overridden will be inherited from the
///   parent [QuizServicesProvider].
/// - If no parent provider exists, the widget will throw an error.
/// - If you need to provide all services from scratch, use [QuizServicesProvider]
///   directly instead.
class QuizServicesScope extends StatelessWidget {
  /// Creates a [QuizServicesScope] that overrides specific services.
  ///
  /// At least one service must be provided. If you need to provide all services,
  /// use [QuizServicesProvider] directly.
  const QuizServicesScope({
    super.key,
    this.settingsService,
    this.storageService,
    this.achievementService,
    this.screenAnalyticsService,
    this.quizAnalyticsService,
    this.resourceManager,
    this.adsService,
    required this.child,
  });

  /// The settings service override, or null to inherit from parent.
  final SettingsService? settingsService;

  /// The storage service override, or null to inherit from parent.
  final StorageService? storageService;

  /// The achievement service override, or null to inherit from parent.
  final AchievementService? achievementService;

  /// The screen analytics service override, or null to inherit from parent.
  final AnalyticsService? screenAnalyticsService;

  /// The quiz analytics service override, or null to inherit from parent.
  final QuizAnalyticsService? quizAnalyticsService;

  /// The resource manager override, or null to inherit from parent.
  final ResourceManager? resourceManager;

  /// The ads service override, or null to inherit from parent.
  final AdsService? adsService;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parentServices = QuizServicesProvider.of(context);

    final scopedServices = QuizServices(
      settingsService: settingsService ?? parentServices.settingsService,
      storageService: storageService ?? parentServices.storageService,
      achievementService:
          achievementService ?? parentServices.achievementService,
      screenAnalyticsService:
          screenAnalyticsService ?? parentServices.screenAnalyticsService,
      quizAnalyticsService:
          quizAnalyticsService ?? parentServices.quizAnalyticsService,
      resourceManager: resourceManager ?? parentServices.resourceManager,
      adsService: adsService ?? parentServices.adsService,
    );

    return QuizServicesProvider(
      services: scopedServices,
      child: child,
    );
  }
}
