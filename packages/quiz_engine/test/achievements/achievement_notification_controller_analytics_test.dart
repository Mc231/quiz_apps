import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import '../mocks/mock_analytics_service.dart';

/// Wraps a widget with services and properly handles overlay attachment.
/// Returns a widget that attaches the controller to the overlay.
Widget wrapWithServicesAndOverlay(
  MockAnalyticsService analyticsService,
  AchievementNotificationController controller,
) {
  return MaterialApp(
    localizationsDelegates: const [
      QuizLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Builder(
      builder: (context) {
        // Attach controller in next frame when overlay is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.attach(Overlay.of(context));
        });
        return QuizServicesProvider(
          services: QuizServices(
            screenAnalyticsService: analyticsService,
            quizAnalyticsService: NoOpQuizAnalyticsService(),
            settingsService: _MockSettingsService(),
            storageService: _MockStorageService(),
            achievementService: _MockAchievementService(),
            resourceManager: ResourceManager(
              config: ResourceConfig.standard(),
              repository: InMemoryResourceRepository(),
            ),
            adsService: NoAdsService(),
            iapService: NoOpIAPService(),
          ),
          child: const Scaffold(body: Text('Test')),
        );
      },
    ),
  );
}

class _MockSettingsService extends Fake implements SettingsService {}
class _MockStorageService extends Fake implements StorageService {}
class _MockAchievementService extends Fake implements AchievementService {}

void main() {
  group('AchievementNotificationController Analytics Integration', () {
    late MockAnalyticsService analyticsService;
    late AchievementNotificationController controller;

    Achievement createTestAchievement({
      String id = 'test_achievement',
      int points = 50,
    }) {
      return Achievement(
        id: id,
        name: (_) => 'Test Achievement',
        description: (_) => 'Test Description',
        icon: '🏆',
        tier: AchievementTier.rare,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalSessions,
          target: 10,
        ),
      );
    }

    setUp(() async {
      analyticsService = MockAnalyticsService();
      await analyticsService.initialize(); // Required for logEvent to work
    });

    tearDown(() {
      controller.dispose();
      analyticsService.dispose();
    });

    testWidgets('tracks notification shown event', (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
        style: const AchievementNotificationStyle(
          displayDuration: Duration(seconds: 3),
        ),
      );

      await tester.pumpWidget(
        wrapWithServicesAndOverlay(analyticsService, controller),
      );
      await tester.pumpAndSettle(); // Allow post-frame callback to execute

      // Note: rare tier = 50 points
      final achievement = createTestAchievement(
        id: 'first_win',
      );

      // Verify controller is attached and show returns true
      final showResult = controller.show(achievement);
      expect(showResult, isTrue, reason: 'Controller should be attached to overlay');
      await tester.pump();

      // Verify notification shown event was logged
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as AchievementEvent;
      expect(event.eventName, 'achievement_notification_shown');
      expect(event.parameters['achievement_id'], 'first_win');
      expect(event.parameters['achievement_name'], 'first_win');
      expect(event.parameters['points_awarded'], 50); // rare tier = 50 points
      expect(
        event.parameters['display_duration_ms'],
        const Duration(seconds: 3).inMilliseconds,
      );
    });

    // Note: Tap event tests are in achievement_notification_test.dart
    // They use a simpler overlay setup that avoids positioning issues

    testWidgets('tracks multiple notifications shown', (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
      );

      await tester.pumpWidget(
        wrapWithServicesAndOverlay(analyticsService, controller),
      );
      await tester.pumpAndSettle(); // Allow post-frame callback to execute

      final achievement1 = createTestAchievement(id: 'achievement_1');
      final achievement2 = createTestAchievement(id: 'achievement_2');

      // Show first notification
      controller.show(achievement1);
      await tester.pump();

      // Queue second notification
      controller.show(achievement2);
      await tester.pump();

      // First event should be logged immediately
      expect(analyticsService.loggedEvents.length, 1);
      expect(
        analyticsService.loggedEvents.first.parameters['achievement_id'],
        'achievement_1',
      );

      // Dismiss first notification
      controller.dismiss();
      await tester.pump(const Duration(milliseconds: 300));

      // Second event should be logged
      expect(analyticsService.loggedEvents.length, 2);
      expect(
        analyticsService.loggedEvents[1].parameters['achievement_id'],
        'achievement_2',
      );
    });

    testWidgets('does not track when using NoOp analytics service',
        (tester) async {
      controller = AchievementNotificationController(
          analyticsService: NoOpAnalyticsService() // NoOp analytics service
      );

      await tester.pumpWidget(
        wrapWithServicesAndOverlay(analyticsService, controller),
      );
      await tester.pumpAndSettle(); // Allow post-frame callback to execute

      final achievement = createTestAchievement();

      controller.show(achievement);
      await tester.pump();

      // Verify no events were logged to our mock (controller uses NoOp)
      expect(analyticsService.loggedEvents, isEmpty);
    });

    testWidgets('tracks notification shown with different tiers',
        (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
      );

      await tester.pumpWidget(
        wrapWithServicesAndOverlay(analyticsService, controller),
      );
      await tester.pumpAndSettle(); // Allow post-frame callback to execute

      final commonAchievement = Achievement(
        id: 'common',
        name: (_) => 'Common',
        description: (_) => 'Common achievement',
        icon: '🥉',
        tier: AchievementTier.common,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalSessions,
          target: 1,
        ),
      );

      controller.show(commonAchievement);
      await tester.pump();

      final event = analyticsService.loggedEvents.first as AchievementEvent;
      expect(event.parameters['achievement_id'], 'common');
      expect(event.parameters['points_awarded'], 10); // Common tier points
    });

    // Note: Time tracking tests are covered in achievement_notification_test.dart

    testWidgets('tracks notification for queued achievements', (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
        maxQueueSize: 5,
      );

      await tester.pumpWidget(
        wrapWithServicesAndOverlay(analyticsService, controller),
      );
      await tester.pumpAndSettle(); // Allow post-frame callback to execute

      // Show multiple achievements
      for (int i = 0; i < 3; i++) {
        controller.show(createTestAchievement(id: 'achievement_$i'));
        await tester.pump();
      }

      // First should be shown immediately
      expect(analyticsService.loggedEvents.length, 1);

      // Dismiss to show next
      controller.dismiss();
      await tester.pump(const Duration(milliseconds: 300));

      // Second should be shown
      expect(analyticsService.loggedEvents.length, 2);

      // Dismiss to show last
      controller.dismiss();
      await tester.pump(const Duration(milliseconds: 300));

      // Third should be shown
      expect(analyticsService.loggedEvents.length, 3);

      // Verify all were tracked
      expect(
        analyticsService.loggedEvents[0].parameters['achievement_id'],
        'achievement_0',
      );
      expect(
        analyticsService.loggedEvents[1].parameters['achievement_id'],
        'achievement_1',
      );
      expect(
        analyticsService.loggedEvents[2].parameters['achievement_id'],
        'achievement_2',
      );
    });
  });
}
