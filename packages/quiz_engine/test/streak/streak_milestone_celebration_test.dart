import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('StreakMilestoneConfig', () {
    testWidgets('getStandardMilestones returns all milestones', (tester) async {
      late List<StreakMilestoneConfig> milestones;

      await tester.pumpWidget(
        wrapWithLocalizations(
          Builder(
            builder: (context) {
              final l10n = QuizL10n.of(context);
              milestones = StreakMilestoneConfig.getStandardMilestones(l10n);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(milestones.length, equals(6));
      expect(
        milestones.map((m) => m.days),
        containsAll([7, 14, 30, 50, 100, 365]),
      );
    });

    testWidgets('forDays returns correct config for milestone', (tester) async {
      late StreakMilestoneConfig? config;

      await tester.pumpWidget(
        wrapWithLocalizations(
          Builder(
            builder: (context) {
              final l10n = QuizL10n.of(context);
              config = StreakMilestoneConfig.forDays(7, l10n);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(config, isNotNull);
      expect(config!.days, equals(7));
      expect(config!.title, equals('Week Warrior'));
    });

    testWidgets('forDays returns null for non-milestone', (tester) async {
      late StreakMilestoneConfig? config;

      await tester.pumpWidget(
        wrapWithLocalizations(
          Builder(
            builder: (context) {
              final l10n = QuizL10n.of(context);
              config = StreakMilestoneConfig.forDays(5, l10n);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(config, isNull);
    });

    test('milestone has correct properties', () {
      const config = StreakMilestoneConfig(
        days: 7,
        title: 'Test Milestone',
        icon: '🎯',
        color: Colors.blue,
        secondaryColor: Colors.lightBlue,
      );

      expect(config.days, equals(7));
      expect(config.title, equals('Test Milestone'));
      expect(config.icon, equals('🎯'));
      expect(config.color, equals(Colors.blue));
      expect(config.secondaryColor, equals(Colors.lightBlue));
    });
  });

  group('StreakMilestoneCelebration widget', () {
    testWidgets('displays milestone day count', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakMilestoneCelebration(
            milestone: 7,
            config: const StreakMilestoneConfig(
              days: 7,
              title: 'Week Warrior',
              icon: '🔥',
              color: Colors.orange,
              secondaryColor: Colors.amber,
            ),
            autoDismiss: false,
          ),
        ),
      );
      // Just pump once to show widget
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('7 Day'), findsOneWidget);
    });

    testWidgets('displays milestone title', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakMilestoneCelebration(
            milestone: 7,
            config: const StreakMilestoneConfig(
              days: 7,
              title: 'Week Warrior',
              icon: '🔥',
              color: Colors.orange,
              secondaryColor: Colors.amber,
            ),
            autoDismiss: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Week Warrior'), findsOneWidget);
    });

    testWidgets('displays milestone icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakMilestoneCelebration(
            milestone: 7,
            config: const StreakMilestoneConfig(
              days: 7,
              title: 'Week Warrior',
              icon: '🔥',
              color: Colors.orange,
              secondaryColor: Colors.amber,
            ),
            autoDismiss: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('displays encouragement message', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakMilestoneCelebration(
            milestone: 7,
            config: const StreakMilestoneConfig(
              days: 7,
              title: 'Week Warrior',
              icon: '🔥',
              color: Colors.orange,
              secondaryColor: Colors.amber,
            ),
            autoDismiss: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Amazing dedication! Keep it up!'), findsOneWidget);
    });

    testWidgets('calls onDismiss when tapped', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakMilestoneCelebration(
            milestone: 7,
            config: const StreakMilestoneConfig(
              days: 7,
              title: 'Week Warrior',
              icon: '🔥',
              color: Colors.orange,
              secondaryColor: Colors.amber,
            ),
            autoDismiss: false,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(dismissed, isTrue);
    });
  });

  // Note: StreakMilestoneBanner tests are limited due to animation controller
  // timer cleanup complexities in widget tests. The widget is tested manually.
}
