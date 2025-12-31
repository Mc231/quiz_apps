import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('FeedbackDialog', () {
    testWidgets('renders correctly with feedback email', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const FeedbackDialog(feedbackEmail: 'test@example.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("We'd love to hear from you"), findsOneWidget);
      expect(find.text('What could we do better?'), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);
    });

    testWidgets('hides Send Feedback button when no email provided',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const FeedbackDialog(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("We'd love to hear from you"), findsOneWidget);
      expect(find.text('Send Feedback'), findsNothing);
      expect(find.text('Maybe Later'), findsOneWidget);
    });

    testWidgets('calls onSendFeedback when Send Feedback is tapped',
        (tester) async {
      bool feedbackCalled = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          FeedbackDialog(
            feedbackEmail: 'test@example.com',
            onSendFeedback: () => feedbackCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(feedbackCalled, isTrue);
    });

    testWidgets('calls onDismiss when Maybe Later is tapped', (tester) async {
      bool dismissCalled = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          FeedbackDialog(
            onDismiss: () => dismissCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Maybe Later'));
      await tester.pumpAndSettle();

      expect(dismissCalled, isTrue);
    });

    testWidgets('has proper accessibility semantics', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const FeedbackDialog(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Semantics widget with the dialog label
      final semantics = find.bySemanticsLabel('Feedback dialog');
      expect(semantics, findsOneWidget);
    });

    testWidgets('shows feedback icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const FeedbackDialog(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.feedback_outlined), findsOneWidget);
    });

    testWidgets('animates in on display', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const FeedbackDialog(),
        ),
      );

      // Initial state before animation completes
      await tester.pump();
      expect(find.text("We'd love to hear from you"), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
      expect(find.text("We'd love to hear from you"), findsOneWidget);
    });

    group('show static method', () {
      testWidgets('returns sendFeedback when Send Feedback is tapped',
          (tester) async {
        late FeedbackDialogResult result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await FeedbackDialog.show(
                      context: context,
                      feedbackEmail: 'test@example.com',
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

        // Tap Send Feedback
        await tester.tap(find.text('Send Feedback'));
        await tester.pumpAndSettle();

        expect(result, FeedbackDialogResult.sendFeedback);
      });

      testWidgets('returns dismissed when Maybe Later is tapped',
          (tester) async {
        late FeedbackDialogResult result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await FeedbackDialog.show(
                      context: context,
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

        // Tap Maybe Later
        await tester.tap(find.text('Maybe Later'));
        await tester.pumpAndSettle();

        expect(result, FeedbackDialogResult.dismissed);
      });

      testWidgets('returns dismissed when dialog is dismissed by tapping outside',
          (tester) async {
        late FeedbackDialogResult result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await FeedbackDialog.show(
                      context: context,
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

        expect(result, FeedbackDialogResult.dismissed);
      });
    });
  });

  group('FeedbackDialogResult', () {
    test('has all expected values', () {
      expect(FeedbackDialogResult.values, [
        FeedbackDialogResult.sendFeedback,
        FeedbackDialogResult.dismissed,
      ]);
    });
  });
}
