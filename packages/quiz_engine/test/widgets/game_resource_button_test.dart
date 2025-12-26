import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/theme/game_resource_theme.dart';
import 'package:quiz_engine/src/widgets/game_resource_button.dart';

void main() {
  group('GameResourceButton', () {
    Widget buildTestWidget({
      IconData icon = Icons.favorite,
      int count = 3,
      GameResourceType resourceType = GameResourceType.lives,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
      bool enabled = true,
      String? semanticLabel,
      String? tooltip,
      GameResourceTheme? theme,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: GameResourceButton(
              icon: icon,
              count: count,
              resourceType: resourceType,
              onTap: onTap,
              onLongPress: onLongPress,
              enabled: enabled,
              semanticLabel: semanticLabel,
              tooltip: tooltip,
              theme: theme,
            ),
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('displays icon with correct icon data', (tester) async {
        await tester.pumpWidget(buildTestWidget(icon: Icons.favorite));

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('displays count in badge', (tester) async {
        await tester.pumpWidget(buildTestWidget(count: 5));

        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('displays 0 when count is zero', (tester) async {
        await tester.pumpWidget(buildTestWidget(count: 0));

        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('uses custom theme when provided', (tester) async {
        final customTheme = GameResourceTheme.compact();
        await tester.pumpWidget(buildTestWidget(theme: customTheme));

        // Widget should render without errors with custom theme
        expect(find.byType(GameResourceButton), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('calls onTap when tapped and enabled', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestWidget(
          onTap: () => tapped = true,
          enabled: true,
          count: 3,
        ));

        await tester.tap(find.byType(GameResourceButton));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('does not call onTap when disabled', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestWidget(
          onTap: () => tapped = true,
          enabled: false,
        ));

        await tester.tap(find.byType(GameResourceButton));
        await tester.pump();

        expect(tapped, isFalse);
      });

      testWidgets('does not call onTap when count is zero', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestWidget(
          onTap: () => tapped = true,
          count: 0,
        ));

        await tester.tap(find.byType(GameResourceButton));
        await tester.pump();

        expect(tapped, isFalse);
      });

      testWidgets('calls onLongPress when long pressed', (tester) async {
        var longPressed = false;
        await tester.pumpWidget(buildTestWidget(
          onLongPress: () => longPressed = true,
        ));

        await tester.longPress(find.byType(GameResourceButton));
        await tester.pump();

        expect(longPressed, isTrue);
      });
    });

    group('tooltip', () {
      testWidgets('shows tooltip overlay on long press', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          tooltip: 'Test tooltip message',
        ));

        await tester.longPress(find.byType(GameResourceButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Test tooltip message'), findsOneWidget);

        // Flush auto-dismiss timer (3 seconds) and animation (200ms)
        await tester.pump(const Duration(seconds: 4));
      });

      testWidgets('does not show tooltip without tooltip property',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.longPress(find.byType(GameResourceButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // No tooltip text should appear
        expect(find.text('Test tooltip message'), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('has semantic label when provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          semanticLabel: '3 lives remaining',
        ));

        // Verify Semantics widget is present with the label
        final semantics = find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.label == '3 lives remaining');
        expect(semantics, findsOneWidget);
      });

      testWidgets('semantic indicates button', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          semanticLabel: 'Lives',
        ));

        // Verify the widget has button semantics
        final semantics = find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.button == true);
        expect(semantics, findsOneWidget);
      });

      testWidgets('semantic enabled is false when count is 0', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          count: 0,
          semanticLabel: 'Lives',
        ));

        // Verify Semantics indicates disabled state
        final semantics = find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.enabled == false);
        expect(semantics, findsOneWidget);
      });
    });

    group('animations', () {
      // Use a theme with animations disabled to avoid pumpAndSettle timeouts
      GameResourceTheme themeWithoutPulse() => const GameResourceTheme(
            enablePulseOnLastResource: false,
            enableShakeOnDepletion: false,
          );

      testWidgets('scale animation triggers on tap down', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          count: 3,
          theme: themeWithoutPulse(),
        ));

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(GameResourceButton)),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // The widget should be rendering (animation started)
        expect(find.byType(GameResourceButton), findsOneWidget);

        await gesture.up();
        await tester.pump(const Duration(milliseconds: 200));
      });

      testWidgets('badge animation triggers on count change', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          count: 3,
          theme: themeWithoutPulse(),
        ));
        await tester.pump();

        // Change count
        await tester.pumpWidget(buildTestWidget(
          count: 2,
          theme: themeWithoutPulse(),
        ));
        await tester.pump(const Duration(milliseconds: 150));

        // Widget should still render during animation
        expect(find.byType(GameResourceButton), findsOneWidget);
        expect(find.text('2'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 500));
      });

      testWidgets('pulse animation starts when count is 1', (tester) async {
        // Use default theme with pulse enabled
        await tester.pumpWidget(buildTestWidget(count: 3));
        await tester.pump();

        // Change to count 1
        await tester.pumpWidget(buildTestWidget(count: 1));
        await tester.pump(const Duration(milliseconds: 400));

        // Widget should be rendering with pulse animation
        expect(find.byType(GameResourceButton), findsOneWidget);
        expect(find.text('1'), findsOneWidget);

        // Don't use pumpAndSettle with repeating animations
      });

      testWidgets('shake animation triggers on depletion', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          count: 1,
          theme: themeWithoutPulse(),
        ));
        await tester.pump();

        // Deplete (count goes to 0)
        await tester.pumpWidget(buildTestWidget(
          count: 0,
          theme: themeWithoutPulse(),
        ));
        await tester.pump(const Duration(milliseconds: 200));

        // Widget should be rendering
        expect(find.byType(GameResourceButton), findsOneWidget);
        expect(find.text('0'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 500));
      });
    });

    group('different resource types', () {
      testWidgets('renders lives type correctly', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          icon: Icons.favorite,
          resourceType: GameResourceType.lives,
        ));

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('renders fiftyFifty type correctly', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          icon: Icons.looks_two,
          resourceType: GameResourceType.fiftyFifty,
        ));

        expect(find.byIcon(Icons.looks_two), findsOneWidget);
      });

      testWidgets('renders skip type correctly', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          icon: Icons.skip_next,
          resourceType: GameResourceType.skip,
        ));

        expect(find.byIcon(Icons.skip_next), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('handles large count numbers', (tester) async {
        await tester.pumpWidget(buildTestWidget(count: 999));

        expect(find.text('999'), findsOneWidget);
      });

      testWidgets('handles rapid count changes', (tester) async {
        await tester.pumpWidget(buildTestWidget(count: 5));

        for (int i = 4; i >= 0; i--) {
          await tester.pumpWidget(buildTestWidget(count: i));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('disposes animation controllers properly', (tester) async {
        await tester.pumpWidget(buildTestWidget(count: 3));
        await tester.pumpAndSettle();

        // Remove widget - should dispose without errors
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: SizedBox()),
          ),
        );
        await tester.pumpAndSettle();

        // No errors should occur during disposal
        expect(find.byType(GameResourceButton), findsNothing);
      });
    });
  });
}
