import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/theme/game_resource_theme.dart';
import 'package:quiz_engine/src/widgets/game_resource_button.dart';
import 'package:quiz_engine/src/widgets/game_resource_panel.dart';

void main() {
  group('GameResourceConfig', () {
    test('creates with required and optional parameters', () {
      final config = GameResourceConfig(
        count: 3,
        onTap: () {},
        enabled: false,
        tooltip: 'Test tooltip',
        semanticLabel: 'Test label',
      );

      expect(config.count, 3);
      expect(config.onTap, isNotNull);
      expect(config.enabled, false);
      expect(config.tooltip, 'Test tooltip');
      expect(config.semanticLabel, 'Test label');
    });

    test('enabled defaults to true', () {
      const config = GameResourceConfig(count: 3);
      expect(config.enabled, true);
    });

    test('copyWith creates copy with specified values', () {
      const original = GameResourceConfig(
        count: 3,
        enabled: true,
        tooltip: 'Original',
      );

      final copy = original.copyWith(count: 5, tooltip: 'Updated');

      expect(copy.count, 5);
      expect(copy.enabled, true); // unchanged
      expect(copy.tooltip, 'Updated');
    });
  });

  group('GameResourcePanel', () {
    Widget buildTestWidget({
      GameResourceConfig? lives,
      GameResourceConfig? fiftyFifty,
      GameResourceConfig? skip,
      GameResourceTheme? theme,
      MainAxisAlignment alignment = MainAxisAlignment.center,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GameResourcePanel(
            lives: lives,
            fiftyFifty: fiftyFifty,
            skip: skip,
            theme: theme,
            alignment: alignment,
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('displays all three resources when provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          lives: const GameResourceConfig(count: 3),
          fiftyFifty: const GameResourceConfig(count: 2),
          skip: const GameResourceConfig(count: 1),
        ));

        expect(find.byType(GameResourceButton), findsNWidgets(3));
        expect(find.text('3'), findsOneWidget); // lives count
        expect(find.text('2'), findsOneWidget); // 50/50 count
        expect(find.text('1'), findsOneWidget); // skip count
      });

      testWidgets('displays only lives when others are null', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          lives: const GameResourceConfig(count: 3),
        ));

        expect(find.byType(GameResourceButton), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('displays only fiftyFifty when others are null',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          fiftyFifty: const GameResourceConfig(count: 2),
        ));

        expect(find.byType(GameResourceButton), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('displays only skip when others are null', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          skip: const GameResourceConfig(count: 1),
        ));

        expect(find.byType(GameResourceButton), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('displays empty row when no resources provided',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(GameResourceButton), findsNothing);
        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('uses custom icons', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameResourcePanel(
                lives: const GameResourceConfig(count: 3),
                livesIcon: Icons.heart_broken,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.heart_broken), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets('uses center alignment by default', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          lives: const GameResourceConfig(count: 3),
        ));

        final row = tester.widget<Row>(find.byType(Row));
        expect(row.mainAxisAlignment, MainAxisAlignment.center);
      });

      testWidgets('uses provided alignment', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          lives: const GameResourceConfig(count: 3),
          alignment: MainAxisAlignment.end,
        ));

        final row = tester.widget<Row>(find.byType(Row));
        expect(row.mainAxisAlignment, MainAxisAlignment.end);
      });

      testWidgets('adds spacing between resources', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          lives: const GameResourceConfig(count: 3),
          fiftyFifty: const GameResourceConfig(count: 2),
        ));

        // There should be a SizedBox for spacing
        expect(find.byType(SizedBox), findsWidgets);
      });
    });

    group('theming', () {
      testWidgets('uses standard theme by default', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          lives: const GameResourceConfig(count: 3),
        ));

        // Widget should render without errors
        expect(find.byType(GameResourcePanel), findsOneWidget);
      });

      testWidgets('uses provided theme', (tester) async {
        final customTheme = GameResourceTheme.compact();
        await tester.pumpWidget(buildTestWidget(
          lives: const GameResourceConfig(count: 3),
          theme: customTheme,
        ));

        expect(find.byType(GameResourcePanel), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('calls onTap for lives', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestWidget(
          lives: GameResourceConfig(count: 3, onTap: () => tapped = true),
        ));

        await tester.tap(find.byType(GameResourceButton));
        await tester.pump();

        expect(tapped, true);
      });

      testWidgets('calls onTap for each resource independently',
          (tester) async {
        var livesTapped = 0;
        var fiftyFiftyTapped = 0;
        var skipTapped = 0;

        await tester.pumpWidget(buildTestWidget(
          lives: GameResourceConfig(count: 3, onTap: () => livesTapped++),
          fiftyFifty:
              GameResourceConfig(count: 2, onTap: () => fiftyFiftyTapped++),
          skip: GameResourceConfig(count: 1, onTap: () => skipTapped++),
        ));

        final buttons = find.byType(GameResourceButton);

        // Tap each button
        await tester.tap(buttons.at(0)); // lives
        await tester.pump();
        await tester.tap(buttons.at(1)); // fiftyFifty
        await tester.pump();
        await tester.tap(buttons.at(2)); // skip
        await tester.pump();

        expect(livesTapped, 1);
        expect(fiftyFiftyTapped, 1);
        expect(skipTapped, 1);
      });
    });

    group('compact factory', () {
      testWidgets('creates panel with compact theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameResourcePanel.compact(
                lives: const GameResourceConfig(count: 3),
              ),
            ),
          ),
        );

        expect(find.byType(GameResourcePanel), findsOneWidget);
        expect(find.byType(GameResourceButton), findsOneWidget);
      });
    });
  });

  group('GameResourcePanelData', () {
    test('creates with default icons', () {
      const data = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
      );

      expect(data.livesIcon, Icons.favorite);
      expect(data.fiftyFiftyIcon, Icons.filter_2);
      expect(data.skipIcon, Icons.skip_next);
    });

    test('toPanel creates GameResourcePanel with correct config', () {
      const data = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
        fiftyFifty: GameResourceConfig(count: 2),
      );

      final panel = data.toPanel();

      expect(panel.lives?.count, 3);
      expect(panel.fiftyFifty?.count, 2);
      expect(panel.skip, isNull);
    });

    test('toPanel accepts theme parameter', () {
      const data = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
      );

      final theme = GameResourceTheme.compact();
      final panel = data.toPanel(theme: theme);

      expect(panel.theme, theme);
    });

    test('hasResources returns true when any resource is set', () {
      const dataWithLives = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
      );
      expect(dataWithLives.hasResources, true);

      const dataWithFiftyFifty = GameResourcePanelData(
        fiftyFifty: GameResourceConfig(count: 2),
      );
      expect(dataWithFiftyFifty.hasResources, true);

      const dataWithSkip = GameResourcePanelData(
        skip: GameResourceConfig(count: 1),
      );
      expect(dataWithSkip.hasResources, true);
    });

    test('hasResources returns false when no resources are set', () {
      const data = GameResourcePanelData();
      expect(data.hasResources, false);
    });

    test('copyWith creates copy with specified values', () {
      const original = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
        livesIcon: Icons.favorite,
      );

      final copy = original.copyWith(
        fiftyFifty: const GameResourceConfig(count: 2),
        livesIcon: Icons.heart_broken,
      );

      expect(copy.lives?.count, 3); // unchanged
      expect(copy.fiftyFifty?.count, 2); // added
      expect(copy.livesIcon, Icons.heart_broken); // changed
    });

    test('copyWith can clear resources', () {
      const original = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
        fiftyFifty: GameResourceConfig(count: 2),
      );

      final copy = original.copyWith(clearLives: true);

      expect(copy.lives, isNull);
      expect(copy.fiftyFifty?.count, 2); // unchanged
    });

    test('equality works correctly', () {
      const data1 = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
      );
      const data2 = GameResourcePanelData(
        lives: GameResourceConfig(count: 3),
      );
      const data3 = GameResourcePanelData(
        lives: GameResourceConfig(count: 5),
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
      expect(data1.hashCode, equals(data2.hashCode));
    });
  });
}
