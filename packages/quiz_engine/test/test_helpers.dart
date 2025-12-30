import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

/// Test title for quiz tests.
const testQuizTitle = 'Test Quiz';

/// Wraps a widget with the necessary localization delegates for testing.
///
/// This is required because quiz widgets use QuizL10n.of(context) to get
/// localized strings.
Widget wrapWithLocalizations(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      QuizLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

/// Wraps a widget with localizations and QuizServicesProvider for testing.
///
/// Use this when testing widgets that require analytics services from context.
Widget wrapWithServices(
  Widget child, {
  AnalyticsService? screenAnalyticsService,
  QuizAnalyticsService? quizAnalyticsService,
  SettingsService? settingsService,
  StorageService? storageService,
  AchievementService? achievementService,
  ResourceManager? resourceManager,
  AdsService? adsService,
}) {
  final effectiveScreenAnalytics = screenAnalyticsService ?? NoOpAnalyticsService();
  final effectiveQuizAnalytics = quizAnalyticsService ?? NoOpQuizAnalyticsService();
  final effectiveSettings = settingsService ?? _MockSettingsService();
  final effectiveStorage = storageService ?? _MockStorageService();
  final effectiveAchievements = achievementService ?? _MockAchievementService();
  final effectiveResourceManager = resourceManager ?? _createDefaultResourceManager();
  final effectiveAdsService = adsService ?? NoAdsService();

  return MaterialApp(
    localizationsDelegates: const [
      QuizLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
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
      child: Scaffold(body: child),
    ),
  );
}

/// Creates a default ResourceManager with in-memory storage for testing.
ResourceManager _createDefaultResourceManager() {
  return ResourceManager(
    config: ResourceConfig.standard(),
    repository: InMemoryResourceRepository(),
  );
}

/// Mock settings service for testing.
///
/// Uses noSuchMethod to handle all interface methods.
class _MockSettingsService extends Fake implements SettingsService {}

/// Mock storage service for testing.
///
/// Uses noSuchMethod to handle all interface methods.
class _MockStorageService extends Fake implements StorageService {}

/// Mock achievement service for testing.
///
/// Uses noSuchMethod to handle all interface methods.
class _MockAchievementService extends Fake implements AchievementService {}
