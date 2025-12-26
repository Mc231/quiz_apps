import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/widgets/adaptive_resource_panel.dart';
import 'package:quiz_engine/src/widgets/game_resource_button.dart';
import 'package:quiz_engine/src/widgets/game_resource_panel.dart';

void main() {
  group('ResourcePanelPlacement', () {
    test('has correct values', () {
      expect(ResourcePanelPlacement.values.length, 2);
      expect(ResourcePanelPlacement.values, contains(ResourcePanelPlacement.appBar));
      expect(ResourcePanelPlacement.values, contains(ResourcePanelPlacement.belowAppBar));
    });
  });

  group('getResourcePanelPlacement', () {
    testWidgets('returns belowAppBar for mobile portrait', (tester) async {
      late ResourcePanelPlacement placement;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              placement = getResourcePanelPlacement(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(placement, ResourcePanelPlacement.belowAppBar);
    });

    testWidgets('returns appBar for mobile landscape', (tester) async {
      late ResourcePanelPlacement placement;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 400)),
          child: Builder(
            builder: (context) {
              placement = getResourcePanelPlacement(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(placement, ResourcePanelPlacement.appBar);
    });

    testWidgets('returns appBar for tablet', (tester) async {
      late ResourcePanelPlacement placement;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: Builder(
            builder: (context) {
              placement = getResourcePanelPlacement(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(placement, ResourcePanelPlacement.appBar);
    });

    testWidgets('returns appBar for desktop', (tester) async {
      late ResourcePanelPlacement placement;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1920, 1080)),
          child: Builder(
            builder: (context) {
              placement = getResourcePanelPlacement(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(placement, ResourcePanelPlacement.appBar);
    });

    testWidgets('returns belowAppBar for watch', (tester) async {
      late ResourcePanelPlacement placement;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(200, 200)),
          child: Builder(
            builder: (context) {
              placement = getResourcePanelPlacement(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(placement, ResourcePanelPlacement.belowAppBar);
    });
  });

  group('AdaptiveResourcePanel', () {
    const testData = GameResourcePanelData(
      lives: GameResourceConfig(count: 3),
      fiftyFifty: GameResourceConfig(count: 2),
    );

    Widget buildForSize(Size size, {
      required ResourcePanelPlacement targetPlacement,
      GameResourcePanelData? data,
      EdgeInsets padding = EdgeInsets.zero,
      BoxDecoration? decoration,
    }) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          home: Scaffold(
            body: AdaptiveResourcePanel(
              data: data ?? testData,
              targetPlacement: targetPlacement,
              padding: padding,
              decoration: decoration,
            ),
          ),
        ),
      );
    }

    group('visibility based on placement', () {
      testWidgets('shows panel when placement matches', (tester) async {
        // Mobile portrait = belowAppBar
        await tester.pumpWidget(buildForSize(
          const Size(400, 800),
          targetPlacement: ResourcePanelPlacement.belowAppBar,
        ));

        expect(find.byType(GameResourceButton), findsWidgets);
      });

      testWidgets('hides panel when placement does not match', (tester) async {
        // Mobile portrait = belowAppBar, but targeting appBar
        await tester.pumpWidget(buildForSize(
          const Size(400, 800),
          targetPlacement: ResourcePanelPlacement.appBar,
        ));

        expect(find.byType(GameResourceButton), findsNothing);
        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('shows appBar panel on tablet', (tester) async {
        await tester.pumpWidget(buildForSize(
          const Size(800, 1200),
          targetPlacement: ResourcePanelPlacement.appBar,
        ));

        expect(find.byType(GameResourceButton), findsWidgets);
      });

      testWidgets('hides belowAppBar panel on tablet', (tester) async {
        await tester.pumpWidget(buildForSize(
          const Size(800, 1200),
          targetPlacement: ResourcePanelPlacement.belowAppBar,
        ));

        expect(find.byType(GameResourceButton), findsNothing);
      });
    });

    group('empty data handling', () {
      testWidgets('hides when data has no resources', (tester) async {
        await tester.pumpWidget(buildForSize(
          const Size(400, 800),
          targetPlacement: ResourcePanelPlacement.belowAppBar,
          data: const GameResourcePanelData(), // Empty
        ));

        expect(find.byType(GameResourceButton), findsNothing);
      });
    });

    group('styling', () {
      testWidgets('applies padding when provided', (tester) async {
        await tester.pumpWidget(buildForSize(
          const Size(400, 800),
          targetPlacement: ResourcePanelPlacement.belowAppBar,
          padding: const EdgeInsets.all(16),
        ));

        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('applies decoration for belowAppBar placement', (tester) async {
        await tester.pumpWidget(buildForSize(
          const Size(400, 800),
          targetPlacement: ResourcePanelPlacement.belowAppBar,
          decoration: const BoxDecoration(color: Colors.red),
        ));

        // Find DecoratedBox with our specific red decoration
        final decoratedBox = find.byWidgetPredicate((widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.red);
        expect(decoratedBox, findsOneWidget);
      });
    });

    group('factory constructors', () {
      testWidgets('forAppBar creates appBar placement with compact theme',
          (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 400)), // landscape
            child: MaterialApp(
              home: Scaffold(
                body: AdaptiveResourcePanel.forAppBar(data: testData),
              ),
            ),
          ),
        );

        // Should render on landscape mobile
        expect(find.byType(GameResourceButton), findsWidgets);
      });

      testWidgets('forBody creates belowAppBar placement with standard theme',
          (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)), // portrait
            child: MaterialApp(
              home: Scaffold(
                body: AdaptiveResourcePanel.forBody(data: testData),
              ),
            ),
          ),
        );

        // Should render on portrait mobile
        expect(find.byType(GameResourceButton), findsWidgets);
      });
    });
  });

  group('AdaptiveResourcePanelScope', () {
    const testData = GameResourcePanelData(
      lives: GameResourceConfig(count: 3),
    );

    testWidgets('provides both appBar and body panels to builder',
        (tester) async {
      Widget? capturedAppBarPanel;
      Widget? capturedBodyPanel;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: AdaptiveResourcePanelScope(
              data: testData,
              builder: (context, appBarPanel, bodyPanel) {
                capturedAppBarPanel = appBarPanel;
                capturedBodyPanel = bodyPanel;
                return Column(
                  children: [appBarPanel, bodyPanel],
                );
              },
            ),
          ),
        ),
      );

      expect(capturedAppBarPanel, isA<AdaptiveResourcePanel>());
      expect(capturedBodyPanel, isA<AdaptiveResourcePanel>());
    });

    testWidgets('body panel shows on portrait, appBar hidden', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: AdaptiveResourcePanelScope(
              data: testData,
              builder: (context, appBarPanel, bodyPanel) {
                return Column(
                  children: [appBarPanel, bodyPanel],
                );
              },
            ),
          ),
        ),
      );

      // Only body should have resource buttons (portrait)
      expect(find.byType(GameResourceButton), findsOneWidget);
    });
  });

  group('ResourcePanelPlacementExtension', () {
    testWidgets('resourcePanelPlacement returns correct value', (tester) async {
      late ResourcePanelPlacement placement;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              placement = context.resourcePanelPlacement;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(placement, ResourcePanelPlacement.belowAppBar);
    });

    testWidgets('shouldShowResourcesInAppBar works correctly', (tester) async {
      late bool shouldShow;

      // Portrait mobile
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              shouldShow = context.shouldShowResourcesInAppBar;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(shouldShow, false);

      // Landscape mobile
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 400)),
          child: Builder(
            builder: (context) {
              shouldShow = context.shouldShowResourcesInAppBar;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(shouldShow, true);
    });

    testWidgets('shouldShowResourcesBelowAppBar works correctly',
        (tester) async {
      late bool shouldShow;

      // Portrait mobile
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              shouldShow = context.shouldShowResourcesBelowAppBar;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(shouldShow, true);

      // Tablet
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: Builder(
            builder: (context) {
              shouldShow = context.shouldShowResourcesBelowAppBar;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(shouldShow, false);
    });
  });
}
