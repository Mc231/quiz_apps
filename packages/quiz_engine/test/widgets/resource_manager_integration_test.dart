import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/theme/game_resource_theme.dart';
import 'package:quiz_engine/src/widgets/game_resource_button.dart';
import 'package:quiz_engine/src/widgets/game_resource_panel.dart';

void main() {
  group('GameResourceConfig onDepletedTap', () {
    test('creates config with onDepletedTap callback', () {
      var depletedTapped = false;
      final config = GameResourceConfig(
        count: 0,
        onTap: () {},
        onDepletedTap: () => depletedTapped = true,
        enabled: false,
      );

      expect(config.count, 0);
      expect(config.onDepletedTap, isNotNull);

      config.onDepletedTap?.call();
      expect(depletedTapped, true);
    });

    test('copyWith preserves onDepletedTap', () {
      var depletedTapped = false;
      final original = GameResourceConfig(
        count: 0,
        onDepletedTap: () => depletedTapped = true,
        enabled: false,
      );

      final copy = original.copyWith(count: 1);

      expect(copy.count, 1);
      expect(copy.onDepletedTap, isNotNull);

      copy.onDepletedTap?.call();
      expect(depletedTapped, true);
    });

    test('copyWith can update onDepletedTap', () {
      var firstCallback = false;
      var secondCallback = false;

      final original = GameResourceConfig(
        count: 0,
        onDepletedTap: () => firstCallback = true,
        enabled: false,
      );

      final copy = original.copyWith(
        onDepletedTap: () => secondCallback = true,
      );

      copy.onDepletedTap?.call();
      expect(firstCallback, false);
      expect(secondCallback, true);
    });
  });

  group('GameResourceButton depleted state interaction', () {
    Widget buildTestWidget({
      required int count,
      bool enabled = true,
      VoidCallback? onTap,
      VoidCallback? onDepletedTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GameResourceButton(
            icon: Icons.favorite,
            count: count,
            resourceType: GameResourceType.lives,
            onTap: onTap,
            onDepletedTap: onDepletedTap,
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('calls onTap when enabled and tapped', (tester) async {
      var tapped = false;
      var depletedTapped = false;

      await tester.pumpWidget(buildTestWidget(
        count: 3,
        enabled: true,
        onTap: () => tapped = true,
        onDepletedTap: () => depletedTapped = true,
      ));

      await tester.tap(find.byType(GameResourceButton));
      await tester.pump();

      expect(tapped, true);
      expect(depletedTapped, false);
    });

    testWidgets('calls onDepletedTap when disabled and count is 0',
        (tester) async {
      var tapped = false;
      var depletedTapped = false;

      await tester.pumpWidget(buildTestWidget(
        count: 0,
        enabled: false,
        onTap: () => tapped = true,
        onDepletedTap: () => depletedTapped = true,
      ));

      await tester.tap(find.byType(GameResourceButton));
      await tester.pump();

      expect(tapped, false);
      expect(depletedTapped, true);
    });

    testWidgets('does nothing when disabled and no onDepletedTap provided',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(buildTestWidget(
        count: 0,
        enabled: false,
        onTap: () => tapped = true,
        onDepletedTap: null,
      ));

      await tester.tap(find.byType(GameResourceButton));
      await tester.pump();

      expect(tapped, false);
    });
  });

  group('GameResourcePanel depleted resource behavior', () {
    Widget buildTestWidget({
      GameResourceConfig? lives,
      GameResourceConfig? fiftyFifty,
      GameResourceConfig? skip,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GameResourcePanel(
            lives: lives,
            fiftyFifty: fiftyFifty,
            skip: skip,
          ),
        ),
      );
    }

    testWidgets('depleted lives button triggers onDepletedTap', (tester) async {
      var depletedTapped = false;

      await tester.pumpWidget(buildTestWidget(
        lives: GameResourceConfig(
          count: 0,
          onTap: null,
          onDepletedTap: () => depletedTapped = true,
          enabled: false,
        ),
      ));

      await tester.tap(find.byType(GameResourceButton));
      await tester.pump();

      expect(depletedTapped, true);
    });

    testWidgets('depleted 50/50 button triggers onDepletedTap',
        (tester) async {
      var depletedTapped = false;

      await tester.pumpWidget(buildTestWidget(
        fiftyFifty: GameResourceConfig(
          count: 0,
          onTap: () {},
          onDepletedTap: () => depletedTapped = true,
          enabled: false,
        ),
      ));

      await tester.tap(find.byType(GameResourceButton));
      await tester.pump();

      expect(depletedTapped, true);
    });

    testWidgets('depleted skip button triggers onDepletedTap', (tester) async {
      var depletedTapped = false;

      await tester.pumpWidget(buildTestWidget(
        skip: GameResourceConfig(
          count: 0,
          onTap: () {},
          onDepletedTap: () => depletedTapped = true,
          enabled: false,
        ),
      ));

      await tester.tap(find.byType(GameResourceButton));
      await tester.pump();

      expect(depletedTapped, true);
    });

    testWidgets('multiple depleted resources each have independent callbacks',
        (tester) async {
      var livesDepletedTapped = 0;
      var fiftyFiftyDepletedTapped = 0;
      var skipDepletedTapped = 0;

      await tester.pumpWidget(buildTestWidget(
        lives: GameResourceConfig(
          count: 0,
          onDepletedTap: () => livesDepletedTapped++,
          enabled: false,
        ),
        fiftyFifty: GameResourceConfig(
          count: 0,
          onDepletedTap: () => fiftyFiftyDepletedTapped++,
          enabled: false,
        ),
        skip: GameResourceConfig(
          count: 0,
          onDepletedTap: () => skipDepletedTapped++,
          enabled: false,
        ),
      ));

      final buttons = find.byType(GameResourceButton);

      await tester.tap(buttons.at(0)); // lives
      await tester.pump();
      await tester.tap(buttons.at(1)); // fiftyFifty
      await tester.pump();
      await tester.tap(buttons.at(2)); // skip
      await tester.pump();

      expect(livesDepletedTapped, 1);
      expect(fiftyFiftyDepletedTapped, 1);
      expect(skipDepletedTapped, 1);
    });
  });

  group('GameResourcePanelData with onDepletedTap', () {
    test('toPanel passes onDepletedTap to panel correctly', () {
      var depletedTapped = false;
      final data = GameResourcePanelData(
        lives: GameResourceConfig(
          count: 0,
          onDepletedTap: () => depletedTapped = true,
          enabled: false,
        ),
      );

      final panel = data.toPanel();

      expect(panel.lives?.onDepletedTap, isNotNull);
      panel.lives?.onDepletedTap?.call();
      expect(depletedTapped, true);
    });

    test('copyWith preserves onDepletedTap in nested config', () {
      var depletedTapped = false;
      final original = GameResourcePanelData(
        lives: GameResourceConfig(
          count: 0,
          onDepletedTap: () => depletedTapped = true,
          enabled: false,
        ),
      );

      final copy = original.copyWith(
        fiftyFifty: const GameResourceConfig(count: 2),
      );

      expect(copy.lives?.onDepletedTap, isNotNull);
      copy.lives?.onDepletedTap?.call();
      expect(depletedTapped, true);
    });
  });

  group('Resource restoration flow', () {
    testWidgets('enabled resource uses onTap, depleted uses onDepletedTap',
        (tester) async {
      var enabledTapped = false;
      var depletedTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Enabled resource with count > 0
                GameResourceButton(
                  icon: Icons.favorite,
                  count: 3,
                  resourceType: GameResourceType.lives,
                  enabled: true,
                  onTap: () => enabledTapped = true,
                  onDepletedTap: () {}, // Should not be called
                ),
                // Depleted resource with count = 0
                GameResourceButton(
                  icon: Icons.favorite,
                  count: 0,
                  resourceType: GameResourceType.lives,
                  enabled: false,
                  onTap: () {}, // Should not be called
                  onDepletedTap: () => depletedTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      final buttons = find.byType(GameResourceButton);

      // Tap enabled button
      await tester.tap(buttons.at(0));
      await tester.pump();
      expect(enabledTapped, true);
      expect(depletedTapped, false);

      // Reset
      enabledTapped = false;

      // Tap depleted button
      await tester.tap(buttons.at(1));
      await tester.pump();
      expect(enabledTapped, false);
      expect(depletedTapped, true);
    });
  });
}