import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../mocks/mock_analytics_service.dart';
import '../test_helpers.dart';

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

    setUp(() {
      analyticsService = MockAnalyticsService();
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
        wrapWithLocalizations(Container()),
      );

      controller.attach(Overlay.of(tester.element(find.byType(Container))));

      final achievement = createTestAchievement(
        id: 'first_win',
        points: 10,
      );

      // Show notification
      controller.show(achievement);
      await tester.pump();

      // Verify notification shown event was logged
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as AchievementEvent;
      expect(event.eventName, 'achievement_notification_shown');
      expect(event.parameters['achievement_id'], 'first_win');
      expect(event.parameters['achievement_name'], 'first_win');
      expect(event.parameters['points_awarded'], 10);
      expect(
        event.parameters['display_duration'],
        const Duration(seconds: 3),
      );
    });

    testWidgets('tracks notification tapped event', (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(Container()),
      );

      controller.attach(Overlay.of(tester.element(find.byType(Container))));

      final achievement = createTestAchievement(id: 'tappable', points: 25);

      controller.show(achievement);
      await tester.pump();

      // Clear the shown event
      analyticsService.reset();

      // Tap the notification
      final notification = find.byType(AchievementNotification);
      expect(notification, findsOneWidget);

      await tester.tap(notification);
      await tester.pumpAndSettle();

      // Verify notification tapped event was logged
      final tappedEvents = analyticsService.loggedEvents
          .whereType<AchievementEvent>()
          .where((e) => e.eventName == 'achievement_notification_tapped')
          .toList();

      expect(tappedEvents.length, 1);
      final event = tappedEvents.first;
      expect(event.parameters['achievement_id'], 'tappable');
      expect(event.parameters['achievement_name'], 'tappable');
      expect(event.parameters['points_awarded'], 25);

      // Verify time_visible is present and reasonable
      expect(event.parameters.containsKey('time_visible'), true);
      final timeVisible = event.parameters['time_visible'] as Duration;
      expect(timeVisible.inMilliseconds, greaterThan(0));
      expect(timeVisible.inSeconds, lessThan(10)); // Should be quick
    });

    testWidgets('tracks multiple notifications shown', (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(Container()),
      );

      controller.attach(Overlay.of(tester.element(find.byType(Container))));

      final achievement1 = createTestAchievement(id: 'achievement_1', points: 10);
      final achievement2 = createTestAchievement(id: 'achievement_2', points: 20);

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

    testWidgets('does not track when analytics service is null',
        (tester) async {
      controller = AchievementNotificationController(
          analyticsService: NoOpAnalyticsService()// No analytics service
      );

      await tester.pumpWidget(
        wrapWithLocalizations(Container()),
      );

      controller.attach(Overlay.of(tester.element(find.byType(Container))));

      final achievement = createTestAchievement();

      controller.show(achievement);
      await tester.pump();

      // Verify no events were logged
      expect(analyticsService.loggedEvents, isEmpty);
    });

    testWidgets('tracks notification shown with different tiers',
        (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(Container()),
      );

      controller.attach(Overlay.of(tester.element(find.byType(Container))));

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

    testWidgets('tracks tap event time correctly', (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(Container()),
      );

      controller.attach(Overlay.of(tester.element(find.byType(Container))));

      final achievement = createTestAchievement();

      controller.show(achievement);
      await tester.pump();

      analyticsService.reset();

      // Wait a bit before tapping
      await tester.pump(const Duration(milliseconds: 100));

      // Tap notification
      await tester.tap(find.byType(AchievementNotification));
      await tester.pumpAndSettle();

      final tappedEvent = analyticsService.loggedEvents
          .whereType<AchievementEvent>()
          .firstWhere((e) => e.eventName == 'achievement_notification_tapped');

      final timeVisible = tappedEvent.parameters['time_visible'] as Duration;
      expect(timeVisible.inMilliseconds, greaterThanOrEqualTo(100));
    });

    testWidgets('tracks notification for queued achievements', (tester) async {
      controller = AchievementNotificationController(
        analyticsService: analyticsService,
        maxQueueSize: 5,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(Container()),
      );

      controller.attach(Overlay.of(tester.element(find.byType(Container))));

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
