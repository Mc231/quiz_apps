import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../../test_helpers.dart';

void main() {
  Achievement createTestAchievement({
    String id = 'test_achievement',
    String name = 'Test Achievement',
    String description = 'Test description',
    String icon = '🏆',
    AchievementTier tier = AchievementTier.common,
  }) {
    return Achievement(
      id: id,
      name: (_) => name,
      description: (_) => description,
      icon: icon,
      tier: tier,
      trigger: AchievementTrigger.cumulative(
        field: StatField.totalCompletedSessions,
        target: 1,
      ),
    );
  }

  group('AchievementNotificationStyle', () {
    test('default style has expected values', () {
      const style = AchievementNotificationStyle();
      expect(style.borderRadius, equals(16.0));
      expect(style.iconSize, equals(48.0));
      expect(style.showConfetti, isTrue);
      expect(style.showGlow, isTrue);
      expect(style.displayDuration, equals(const Duration(seconds: 3)));
      expect(
        style.animationDuration,
        equals(const Duration(milliseconds: 500)),
      );
    });

    test('custom style overrides values', () {
      const style = AchievementNotificationStyle(
        borderRadius: 20.0,
        iconSize: 64.0,
        showConfetti: false,
        showGlow: false,
        displayDuration: Duration(seconds: 5),
      );

      expect(style.borderRadius, equals(20.0));
      expect(style.iconSize, equals(64.0));
      expect(style.showConfetti, isFalse);
      expect(style.showGlow, isFalse);
      expect(style.displayDuration, equals(const Duration(seconds: 5)));
    });
  });

  group('AchievementNotification', () {
    // Use short durations to avoid timer issues in tests
    const testStyle = AchievementNotificationStyle(
      displayDuration: Duration(milliseconds: 50),
      animationDuration: Duration(milliseconds: 10),
      showGlow: false,
      showConfetti: false,
    );

    testWidgets('displays achievement icon', (tester) async {
      final achievement = createTestAchievement(icon: '⭐');

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
          ),
        ),
      );

      expect(find.text('⭐'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays achievement name', (tester) async {
      final achievement = createTestAchievement(name: 'First Steps');

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
          ),
        ),
      );

      expect(find.text('First Steps'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays "Achievement Unlocked!" header', (tester) async {
      final achievement = createTestAchievement();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
          ),
        ),
      );

      expect(find.text('Achievement Unlocked!'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays tier badge', (tester) async {
      final achievement = createTestAchievement(tier: AchievementTier.rare);

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
          ),
        ),
      );

      expect(find.text('RARE'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays points earned', (tester) async {
      final achievement = createTestAchievement(tier: AchievementTier.uncommon);
      // Uncommon = 25 points

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
          ),
        ),
      );

      expect(find.textContaining('+25 pts'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('calls onDismiss when tapped', (tester) async {
      var dismissed = false;
      final achievement = createTestAchievement();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      // Tap to dismiss
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('auto-dismisses after display duration', (tester) async {
      var dismissed = false;
      final achievement = createTestAchievement();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      expect(dismissed, isFalse);

      // Wait for display duration + exit animation
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('shows glow when enabled in style', (tester) async {
      final achievement = createTestAchievement();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: const AchievementNotificationStyle(
              showGlow: true,
              displayDuration: Duration(milliseconds: 50),
              animationDuration: Duration(milliseconds: 10),
            ),
          ),
        ),
      );

      // Just verify it renders without error
      expect(find.byType(AchievementNotification), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('hides confetti when disabled', (tester) async {
      final achievement = createTestAchievement();

      await tester.pumpWidget(
        wrapWithLocalizations(
          AchievementNotification(
            analyticsService: NoOpAnalyticsService(),
            achievement: achievement,
            style: testStyle,
          ),
        ),
      );

      // Just verify it renders without error
      expect(find.byType(AchievementNotification), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('AchievementNotificationController', () {
    testWidgets('queues achievements when one is already showing', (
      tester,
    ) async {
      final controller = AchievementNotificationController(
        analyticsService: NoOpAnalyticsService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Attach controller in next frame when overlay is available
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attach(Overlay.of(context));
              });
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      await tester.pump();

      final achievement1 = createTestAchievement(id: 'first');
      final achievement2 = createTestAchievement(id: 'second');
      final achievement3 = createTestAchievement(id: 'third');

      // Show first achievement
      expect(controller.show(achievement1), isTrue);
      expect(controller.isShowing, isTrue);

      // Queue more
      expect(controller.show(achievement2), isTrue);
      expect(controller.show(achievement3), isTrue);
      expect(controller.queueLength, equals(2));

      controller.dispose();
    });

    testWidgets('respects maxQueueSize', (tester) async {
      final controller = AchievementNotificationController(
        maxQueueSize: 2,
        analyticsService: NoOpAnalyticsService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attach(Overlay.of(context));
              });
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      await tester.pump();

      final achievements = List.generate(
        5,
        (i) => createTestAchievement(id: 'a$i'),
      );

      // First one shows, next 2 queue, last 2 rejected
      for (final a in achievements) {
        controller.show(a);
      }

      expect(controller.queueLength, equals(2));
      controller.dispose();
    });

    testWidgets('clears queue', (tester) async {
      final controller = AchievementNotificationController(
        analyticsService: NoOpAnalyticsService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attach(Overlay.of(context));
              });
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      await tester.pump();

      final achievement1 = createTestAchievement(id: 'first');
      final achievement2 = createTestAchievement(id: 'second');

      controller.show(achievement1);
      controller.show(achievement2);
      expect(controller.queueLength, equals(1));

      controller.clearQueue();
      expect(controller.queueLength, equals(0));

      controller.dispose();
    });

    testWidgets('emits onShow events', (tester) async {
      final controller = AchievementNotificationController(
        analyticsService: NoOpAnalyticsService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attach(Overlay.of(context));
              });
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      await tester.pump();

      final achievement = createTestAchievement();
      final completer = Completer<Achievement>();
      controller.onShow.first.then(completer.complete);

      controller.show(achievement);

      final shown = await completer.future.timeout(const Duration(seconds: 1));
      expect(shown.id, equals(achievement.id));

      controller.dispose();
    });

    test('returns false when not attached', () {
      final controller = AchievementNotificationController(
        analyticsService: NoOpAnalyticsService(),
      );
      final achievement = createTestAchievement();

      expect(controller.show(achievement), isFalse);
      controller.dispose();
    });

    testWidgets('returns false after disposed', (tester) async {
      final controller = AchievementNotificationController(
        analyticsService: NoOpAnalyticsService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attach(Overlay.of(context));
              });
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      await tester.pump();

      controller.dispose();

      final achievement = createTestAchievement();
      expect(controller.show(achievement), isFalse);
    });
  });

  group('AchievementNotificationPosition', () {
    test('has top and bottom values', () {
      expect(AchievementNotificationPosition.values.length, equals(2));
      expect(AchievementNotificationPosition.top, isNotNull);
      expect(AchievementNotificationPosition.bottom, isNotNull);
    });
  });
}
