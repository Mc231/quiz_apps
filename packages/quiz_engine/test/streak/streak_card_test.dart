import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../test_helpers.dart';

void main() {
  group('StreakCardData', () {
    test('creates empty data correctly', () {
      final data = StreakCardData.empty();
      expect(data.currentStreak, equals(0));
      expect(data.longestStreak, equals(0));
      expect(data.status, equals(StreakStatus.none));
      expect(data.nextMilestone, isNull);
      expect(data.milestoneProgress, equals(0.0));
    });

    test('creates data from StreakData', () {
      final streakData = StreakData(
        currentStreak: 7,
        longestStreak: 14,
        lastPlayDate: DateTime.now(),
        streakStartDate: DateTime.now().subtract(const Duration(days: 6)),
        totalDaysPlayed: 50,
      );

      final data = StreakCardData.fromStreakData(
        data: streakData,
        status: StreakStatus.active,
        nextMilestone: 14,
        milestoneProgress: 0.5,
      );

      expect(data.currentStreak, equals(7));
      expect(data.longestStreak, equals(14));
      expect(data.status, equals(StreakStatus.active));
      expect(data.nextMilestone, equals(14));
      expect(data.milestoneProgress, equals(0.5));
      expect(data.totalDaysPlayed, equals(50));
    });
  });

  group('StreakCard', () {
    testWidgets('displays current streak count', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 7,
              longestStreak: 14,
              status: StreakStatus.none,
            ),
          ),
        ),
      );
      // Use pump instead of pumpAndSettle to avoid animation controller issues
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('displays day streak label', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 10,
              longestStreak: 10,
              status: StreakStatus.none,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('day streak'), findsOneWidget);
    });

    testWidgets('shows progress bar when nextMilestone is set', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 5,
              longestStreak: 5,
              status: StreakStatus.none,
              nextMilestone: 7,
              milestoneProgress: 0.71,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Progress bar should be visible
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Next:'), findsOneWidget);
    });

    testWidgets('hides progress bar when showProgressBar is false',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 5,
              longestStreak: 5,
              status: StreakStatus.none,
              nextMilestone: 7,
              milestoneProgress: 0.5,
            ),
            style: const StreakCardStyle(showProgressBar: false),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows stats when showStats is true', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 7,
              longestStreak: 14,
              status: StreakStatus.none,
              totalDaysPlayed: 50,
            ),
            style: const StreakCardStyle(showStats: true),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Should show longest streak and total days
      expect(find.text('14'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 7,
              longestStreak: 7,
              status: StreakStatus.none,
            ),
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      await tester.tap(find.byType(StreakCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows chevron icon when onTap is provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 7,
              longestStreak: 7,
              status: StreakStatus.none,
            ),
            onTap: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('has semantics for accessibility', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakCard(
            data: const StreakCardData(
              currentStreak: 7,
              longestStreak: 14,
              status: StreakStatus.none,
            ),
            onTap: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Verify semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });

    group('status messages', () {
      testWidgets('shows "played today" message for active status',
          (tester) async {
        await tester.pumpWidget(
          wrapWithLocalizations(
            StreakCard(
              data: const StreakCardData(
                currentStreak: 5,
                longestStreak: 5,
                status: StreakStatus.active,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));

        expect(find.text('You played today!'), findsOneWidget);
      });

      testWidgets('shows "play today" message for atRisk status',
          (tester) async {
        await tester.pumpWidget(
          wrapWithLocalizations(
            StreakCard(
              data: const StreakCardData(
                currentStreak: 5,
                longestStreak: 5,
                status: StreakStatus.atRisk,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));

        expect(find.text('Play today to keep going!'), findsOneWidget);
      });

      testWidgets('shows "streak lost" message for broken status',
          (tester) async {
        await tester.pumpWidget(
          wrapWithLocalizations(
            StreakCard(
              data: const StreakCardData(
                currentStreak: 0,
                longestStreak: 5,
                status: StreakStatus.broken,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));

        expect(find.text('Streak lost'), findsOneWidget);
      });

      testWidgets('shows "start your streak" message for none status',
          (tester) async {
        await tester.pumpWidget(
          wrapWithLocalizations(
            StreakCard(
              data: const StreakCardData(
                currentStreak: 0,
                longestStreak: 0,
                status: StreakStatus.none,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));

        expect(find.text('Start your streak today!'), findsOneWidget);
      });
    });

    group('compact layout', () {
      testWidgets('uses compact layout when style is compact', (tester) async {
        await tester.pumpWidget(
          wrapWithLocalizations(
            StreakCard(
              data: const StreakCardData(
                currentStreak: 7,
                longestStreak: 7,
                status: StreakStatus.none,
              ),
              style: StreakCardStyle.compactStyle,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));

        // Compact layout should not show stats
        expect(find.byIcon(Icons.emoji_events_outlined), findsNothing);
      });
    });
  });
}
