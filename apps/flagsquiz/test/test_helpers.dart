import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

/// Wraps a widget with the necessary providers for testing.
///
/// This includes:
/// - MaterialApp with localization delegates
/// - QuizServicesProvider with mock services
Widget wrapWithServices(
  Widget child, {
  AnalyticsService? screenAnalyticsService,
  QuizAnalyticsService? quizAnalyticsService,
  SettingsService? settingsService,
  StorageService? storageService,
  AchievementService? achievementService,
  AdsService? adsService,
}) {
  final effectiveScreenAnalytics =
      screenAnalyticsService ?? NoOpAnalyticsService();
  final effectiveQuizAnalytics =
      quizAnalyticsService ?? NoOpQuizAnalyticsService();
  final effectiveSettings = settingsService ?? _MockSettingsService();
  final effectiveStorage = storageService ?? _MockStorageService();
  final effectiveAchievements = achievementService ?? _MockAchievementService();
  final effectiveResourceManager = ResourceManager(
    config: ResourceConfig.standard(),
    repository: InMemoryResourceRepository(),
  );
  final effectiveAdsService = adsService ?? NoAdsService();

  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: QuizServicesProvider(
      services: QuizServices(
        screenAnalyticsService: effectiveScreenAnalytics,
        quizAnalyticsService: effectiveQuizAnalytics,
        settingsService: effectiveSettings,
        storageService: effectiveStorage,
        achievementService: effectiveAchievements,
        resourceManager: effectiveResourceManager,
        adsService: effectiveAdsService,
      ),
      child: child,
    ),
  );
}

/// Mock settings service for testing.
class _MockSettingsService extends Fake implements SettingsService {}

/// Mock storage service for testing.
class _MockStorageService extends Fake implements StorageService {}

/// Mock achievement service for testing.
class _MockAchievementService extends Fake implements AchievementService {}
