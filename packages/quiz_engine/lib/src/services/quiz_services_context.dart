import 'package:flutter/widgets.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'quiz_services.dart';
import 'quiz_services_provider.dart';

/// Extension on [BuildContext] for convenient access to [QuizServices].
///
/// This extension provides shortcuts to access services without having to
/// call `QuizServicesProvider.of(context)` every time.
///
/// ## Usage
///
/// ```dart
/// // Access the full services container
/// final services = context.services;
///
/// // Or access individual services directly
/// final settings = context.settingsService;
/// final storage = context.storageService;
/// final achievements = context.achievementService;
/// final screenAnalytics = context.screenAnalyticsService;
/// final quizAnalytics = context.quizAnalyticsService;
/// final resources = context.resourceManager;
/// ```
///
/// ## Nullable Access
///
/// Use nullable getters when the provider might not be in the tree:
///
/// ```dart
/// final services = context.maybeServices;
/// if (services != null) {
///   // Use services
/// }
/// ```
extension QuizServicesContext on BuildContext {
  /// Returns the [QuizServices] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  QuizServices get services => QuizServicesProvider.of(this);

  /// Returns the [QuizServices] from the closest [QuizServicesProvider] ancestor,
  /// or null if no such ancestor exists.
  QuizServices? get maybeServices => QuizServicesProvider.maybeOf(this);

  /// Returns the [SettingsService] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  SettingsService get settingsService => services.settingsService;

  /// Returns the [StorageService] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  StorageService get storageService => services.storageService;

  /// Returns the [AchievementService] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  AchievementService get achievementService => services.achievementService;

  /// Returns the screen [AnalyticsService] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  AnalyticsService get screenAnalyticsService =>
      services.screenAnalyticsService;

  /// Returns the [QuizAnalyticsService] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  QuizAnalyticsService get quizAnalyticsService =>
      services.quizAnalyticsService;

  /// Returns the [ResourceManager] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  ResourceManager get resourceManager => services.resourceManager;
}
