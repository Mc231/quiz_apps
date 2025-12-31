import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('LoveDialog', () {
    testWidgets('renders correctly with app name', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoveDialog(appName: 'Test App'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Are you enjoying Test App?'), findsOneWidget);
      expect(find.text('Yes!'), findsOneWidget);
      expect(find.text('Not Really'), findsOneWidget);
    });

    testWidgets('renders app icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoveDialog(
            appName: 'Test App',
            appIcon: Icon(Icons.quiz, key: Key('app-icon')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('app-icon')), findsOneWidget);
    });

    testWidgets('calls onPositive when Yes button is tapped', (tester) async {
      bool positiveCalled = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          LoveDialog(
            appName: 'Test App',
            onPositive: () => positiveCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes!'));
      await tester.pumpAndSettle();

      expect(positiveCalled, isTrue);
    });

    testWidgets('calls onNegative when Not Really button is tapped',
        (tester) async {
      bool negativeCalled = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          LoveDialog(
            appName: 'Test App',
            onNegative: () => negativeCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not Really'));
      await tester.pumpAndSettle();

      expect(negativeCalled, isTrue);
    });

    testWidgets('has proper accessibility semantics', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoveDialog(appName: 'Test App'),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Semantics widget with the dialog label
      final semantics = find.bySemanticsLabel('App rating dialog');
      expect(semantics, findsOneWidget);
    });

    testWidgets('animates in on display', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoveDialog(appName: 'Test App'),
        ),
      );

      // Initial state before animation completes
      await tester.pump();
      expect(find.text('Are you enjoying Test App?'), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
      expect(find.text('Are you enjoying Test App?'), findsOneWidget);
    });

    group('show static method', () {
      testWidgets('returns positive when Yes is tapped', (tester) async {
        late LoveDialogResult result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await LoveDialog.show(
                      context: context,
                      appName: 'Test App',
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // Tap to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap Yes
        await tester.tap(find.text('Yes!'));
        await tester.pumpAndSettle();

        expect(result, LoveDialogResult.positive);
      });

      testWidgets('returns negative when Not Really is tapped', (tester) async {
        late LoveDialogResult result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await LoveDialog.show(
                      context: context,
                      appName: 'Test App',
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // Tap to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap Not Really
        await tester.tap(find.text('Not Really'));
        await tester.pumpAndSettle();

        expect(result, LoveDialogResult.negative);
      });

      testWidgets('returns dismissed when dialog is dismissed', (tester) async {
        late LoveDialogResult result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await LoveDialog.show(
                      context: context,
                      appName: 'Test App',
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // Tap to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Dismiss by tapping outside
        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();

        expect(result, LoveDialogResult.dismissed);
      });

      testWidgets('shows app icon when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await LoveDialog.show(
                      context: context,
                      appName: 'Test App',
                      appIcon: const Icon(Icons.star, key: Key('test-icon')),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // Tap to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('test-icon')), findsOneWidget);
      });
    });
  });

  group('LoveDialogResult', () {
    test('has all expected values', () {
      expect(LoveDialogResult.values, [
        LoveDialogResult.positive,
        LoveDialogResult.negative,
        LoveDialogResult.dismissed,
      ]);
    });
  });
}
