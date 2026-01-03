import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import '../mocks/mock_analytics_service.dart';

export '../mocks/mock_analytics_service.dart';

/// A mock SettingsService for testing.
class MockSettingsService implements SettingsService {
  QuizSettings _settings = QuizSettings.defaultSettings();
  final _controller = StreamController<QuizSettings>.broadcast();

  @override
  QuizSettings get currentSettings => _settings;

  @override
  Stream<QuizSettings> get settingsStream => _controller.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> updateSettings(QuizSettings newSettings) async {
    _settings = newSettings;
    _controller.add(_settings);
  }

  @override
  Future<bool> toggleSound() async {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    _controller.add(_settings);
    return _settings.soundEnabled;
  }

  @override
  Future<bool> toggleHaptic() async {
    _settings = _settings.copyWith(hapticEnabled: !_settings.hapticEnabled);
    _controller.add(_settings);
    return _settings.hapticEnabled;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    _controller.add(_settings);
  }

  @override
  Future<void> setPreferredLayoutMode(String? modeId) async {
    _settings = modeId == null
        ? _settings.copyWith(clearPreferredLayoutModeId: true)
        : _settings.copyWith(preferredLayoutModeId: modeId);
    _controller.add(_settings);
  }

  @override
  Future<void> setChallengeLayoutMode(String? modeId) async {
    _settings = modeId == null
        ? _settings.copyWith(clearPreferredChallengeLayoutModeId: true)
        : _settings.copyWith(preferredChallengeLayoutModeId: modeId);
    _controller.add(_settings);
  }

  @override
  Future<QuizSettings> resetToDefaults() async {
    _settings = QuizSettings.defaultSettings();
    _controller.add(_settings);
    return _settings;
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// A mock StorageService for testing.
///
/// Uses noSuchMethod to handle the many abstract methods without
/// requiring explicit implementations for all of them.
class MockStorageService implements StorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Return appropriate default values for common method signatures
    final memberName = invocation.memberName.toString();

    if (memberName.contains('watch')) {
      // Return empty streams for watch methods
      return const Stream.empty();
    }

    if (invocation.isMethod) {
      // Return successful empty/default results for most methods
      return Future.value(const StorageResult.success(null));
    }

    return null;
  }

  @override
  void clearCache() {}

  @override
  void dispose() {}
}

/// A mock AchievementService for testing.
///
/// Uses noSuchMethod to handle all abstract methods.
class MockAchievementService implements AchievementService {
  final _achievementsUnlockedController =
      StreamController<List<Achievement>>.broadcast();

  @override
  Stream<List<Achievement>> get onAchievementsUnlocked =>
      _achievementsUnlockedController.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();

    // Handle getter properties
    if (memberName.contains('allAchievements')) {
      return <Achievement>[];
    }
    if (memberName.contains('achievementUnlockedStream')) {
      return const Stream<UnlockedAchievement>.empty();
    }
    if (memberName.contains('totalPoints')) {
      return 0;
    }
    if (memberName.contains('analyticsService')) {
      return NoOpAnalyticsService();
    }
    if (memberName.contains('categoryDataProvider') ||
        memberName.contains('challengeDataProvider')) {
      return null;
    }

    // Handle method calls
    if (invocation.isMethod) {
      if (memberName.contains('getUnlockedAchievements') ||
          memberName.contains('getLockedAchievements') ||
          memberName.contains('getVisibleAchievements') ||
          memberName.contains('getSortedAchievements') ||
          memberName.contains('getPendingNotifications') ||
          memberName.contains('checkAfterSession') ||
          memberName.contains('checkAll') ||
          memberName.contains('checkAchievements')) {
        return Future.value(<Achievement>[]);
      }
      if (memberName.contains('getAllProgress')) {
        return Future.value(<AchievementProgress>[]);
      }
      if (memberName.contains('getAchievementsByTier')) {
        return <AchievementTier, List<Achievement>>{};
      }
      if (memberName.contains('isAchievementUnlocked') ||
          memberName.contains('isUnlocked')) {
        return false;
      }
      if (memberName.contains('getAchievementProgress') ||
          memberName.contains('getProgress')) {
        return Future.value(0.0);
      }
      if (memberName.contains('getUnlockedCount') ||
          memberName.contains('getTotalPoints')) {
        return Future.value(0);
      }
      if (memberName.contains('getUnlockedAchievement')) {
        return null;
      }
      if (memberName.contains('initialize') ||
          memberName.contains('resetAllAchievements') ||
          memberName.contains('resetAll') ||
          memberName.contains('markNotificationShown') ||
          memberName.contains('markAllNotificationsShown')) {
        return Future<void>.value();
      }

      // Default for other methods
      return Future.value(null);
    }

    return null;
  }

  @override
  void dispose() {
    _achievementsUnlockedController.close();
  }
}

/// A mock QuizAnalyticsService for testing.
///
/// Uses noSuchMethod to handle all tracking methods.
class MockQuizAnalyticsService implements QuizAnalyticsService {
  final List<Map<String, dynamic>> events = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();

    if (memberName.contains('track')) {
      // Record the event
      events.add({
        'method': memberName,
        'positionalArgs': invocation.positionalArguments,
        'namedArgs': invocation.namedArguments,
      });
      return Future<void>.value();
    }

    return null;
  }

  void clear() {
    events.clear();
  }
}

/// Creates a [QuizServices] instance with mock implementations for testing.
///
/// All services are mocked by default. You can pass custom implementations
/// to override specific services.
QuizServices createMockQuizServices({
  SettingsService? settingsService,
  StorageService? storageService,
  AchievementService? achievementService,
  AnalyticsService? screenAnalyticsService,
  QuizAnalyticsService? quizAnalyticsService,
  ResourceManager? resourceManager,
  AdsService? adsService,
  IAPService? iapService,
}) {
  return QuizServices(
    settingsService: settingsService ?? MockSettingsService(),
    storageService: storageService ?? MockStorageService(),
    achievementService: achievementService ?? MockAchievementService(),
    screenAnalyticsService: screenAnalyticsService ?? MockAnalyticsService(),
    quizAnalyticsService: quizAnalyticsService ?? MockQuizAnalyticsService(),
    resourceManager: resourceManager ?? _createTestResourceManager(),
    adsService: adsService ?? NoAdsService(),
    iapService: iapService ?? NoOpIAPService(),
  );
}

/// Creates a default ResourceManager with in-memory storage for testing.
ResourceManager _createTestResourceManager() {
  return ResourceManager(
    config: ResourceConfig.standard(),
    repository: InMemoryResourceRepository(),
  );
}

/// Wraps a widget with [QuizServicesProvider] using mock services for testing.
///
/// This is a convenience function for widget tests that need access to
/// [QuizServices] through the context.
///
/// ## Usage
///
/// ```dart
/// testWidgets('my test', (tester) async {
///   await tester.pumpWidget(
///     wrapWithQuizServices(
///       child: MyWidget(),
///     ),
///   );
/// });
/// ```
///
/// You can also provide custom mock services:
///
/// ```dart
/// final mockSettings = MockSettingsService();
/// await tester.pumpWidget(
///   wrapWithQuizServices(
///     settingsService: mockSettings,
///     child: MyWidget(),
///   ),
/// );
/// ```
Widget wrapWithQuizServices({
  required Widget child,
  SettingsService? settingsService,
  StorageService? storageService,
  AchievementService? achievementService,
  AnalyticsService? screenAnalyticsService,
  QuizAnalyticsService? quizAnalyticsService,
  QuizServices? services,
  ThemeData? theme,
  List<LocalizationsDelegate<dynamic>>? localizationsDelegates,
}) {
  final effectiveServices = services ??
      createMockQuizServices(
        settingsService: settingsService,
        storageService: storageService,
        achievementService: achievementService,
        screenAnalyticsService: screenAnalyticsService,
        quizAnalyticsService: quizAnalyticsService,
      );

  return QuizServicesProvider(
    services: effectiveServices,
    child: MaterialApp(
      theme: theme,
      localizationsDelegates: localizationsDelegates ??
          const [
            QuizLocalizationsDelegate(),
          ],
      home: Scaffold(body: child),
    ),
  );
}
