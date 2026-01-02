import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../test_helpers.dart';

void main() {
  group('StreakBadge', () {
    testWidgets('displays streak count', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadge(
            streakCount: 7,
            status: StreakStatus.active,
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('displays day streak label by default', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadge(
            streakCount: 10,
            status: StreakStatus.active,
          ),
        ),
      );

      expect(find.text('day streak'), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadge(
            streakCount: 10,
            status: StreakStatus.active,
            style: StreakBadgeStyle(showLabel: false),
          ),
        ),
      );

      expect(find.text('day streak'), findsNothing);
    });

    testWidgets('displays flame icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadge(
            streakCount: 5,
            status: StreakStatus.active,
          ),
        ),
      );

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakBadge(
            streakCount: 3,
            status: StreakStatus.active,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(StreakBadge));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('small size has smaller icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadge(
            streakCount: 5,
            status: StreakStatus.active,
            size: StreakBadgeSize.small,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(icon.size, equals(24));
    });

    testWidgets('large size has larger icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadge(
            streakCount: 5,
            status: StreakStatus.active,
            size: StreakBadgeSize.large,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(icon.size, equals(48));
    });

    testWidgets('has semantics for accessibility', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakBadge(
            streakCount: 7,
            status: StreakStatus.active,
            style: const StreakBadgeStyle(showAnimation: false),
            onTap: () {},
          ),
        ),
      );

      // Verify semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });

    group('StreakStatus colors', () {
      testWidgets('active status shows orange flame', (tester) async {
        await tester.pumpWidget(
          wrapWithLocalizations(
            const StreakBadge(
              streakCount: 5,
              status: StreakStatus.active,
              style: StreakBadgeStyle(showAnimation: false),
            ),
          ),
        );

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.local_fire_department),
        );
        expect(icon.color, equals(Colors.orange));
      });

      testWidgets('atRisk status shows amber flame', (tester) async {
        await tester.pumpWidget(
          wrapWithLocalizations(
            const StreakBadge(
              streakCount: 5,
              status: StreakStatus.atRisk,
              style: StreakBadgeStyle(showAnimation: false),
            ),
          ),
        );

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.local_fire_department),
        );
        expect(icon.color, equals(Colors.amber));
      });
    });
  });

  group('StreakBadgeCompact', () {
    testWidgets('displays streak count', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadgeCompact(
            streakCount: 7,
            status: StreakStatus.active,
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('displays flame icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadgeCompact(
            streakCount: 5,
            status: StreakStatus.active,
          ),
        ),
      );

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithLocalizations(
          StreakBadgeCompact(
            streakCount: 3,
            status: StreakStatus.active,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(StreakBadgeCompact));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const StreakBadgeCompact(
            streakCount: 5,
            status: StreakStatus.active,
            size: 30.0,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(icon.size, equals(30.0));
    });
  });
}
