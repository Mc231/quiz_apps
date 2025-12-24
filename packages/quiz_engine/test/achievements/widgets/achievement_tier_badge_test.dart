import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../../test_helpers.dart';

void main() {
  group('AchievementTierBadge', () {
    testWidgets('displays tier label by default', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementTierBadge(tier: AchievementTier.common),
        ),
      );

      expect(find.text('Common'), findsOneWidget);
    });

    testWidgets('displays tier icon when showIcon is true', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementTierBadge(
            tier: AchievementTier.rare,
            showIcon: true,
          ),
        ),
      );

      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('Rare'), findsOneWidget);
    });

    testWidgets('iconOnly constructor shows only icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementTierBadge.iconOnly(tier: AchievementTier.epic),
        ),
      );

      expect(find.text('💜'), findsOneWidget);
      expect(find.text('Epic'), findsNothing);
    });

    testWidgets('full constructor shows icon and label', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementTierBadge.full(tier: AchievementTier.legendary),
        ),
      );

      expect(find.text('💎'), findsOneWidget);
      expect(find.text('Legendary'), findsOneWidget);
    });

    testWidgets('respects size parameter', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementTierBadge(
            tier: AchievementTier.uncommon,
            size: AchievementTierBadgeSize.large,
          ),
        ),
      );

      expect(find.text('Uncommon'), findsOneWidget);
    });

    testWidgets('uses tier color for text', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementTierBadge(tier: AchievementTier.rare),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Rare'));
      final style = textWidget.style;
      expect(style?.color, equals(AchievementTier.rare.color));
    });
  });

  group('AchievementPointsBadge', () {
    testWidgets('displays points value', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementPointsBadge(points: 50),
        ),
      );

      expect(find.text('50 pts'), findsOneWidget);
    });

    testWidgets('respects size parameter', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementPointsBadge(
            points: 100,
            size: AchievementTierBadgeSize.large,
          ),
        ),
      );

      expect(find.text('100 pts'), findsOneWidget);
    });

    testWidgets('uses custom color when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const AchievementPointsBadge(
            points: 25,
            color: Colors.red,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('25 pts'));
      final style = textWidget.style;
      expect(style?.color, equals(Colors.red));
    });
  });
}
