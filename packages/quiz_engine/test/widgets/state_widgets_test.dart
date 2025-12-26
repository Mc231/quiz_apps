import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('displays circular progress indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoadingIndicator(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoadingIndicator(message: 'Loading data...'),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('hides message when not provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoadingIndicator(),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('small size creates smaller indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoadingIndicator.small(),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, 20.0);
      expect(sizedBox.height, 20.0);
    });

    testWidgets('large size creates larger indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoadingIndicator.large(),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, 48.0);
      expect(sizedBox.height, 48.0);
    });

    testWidgets('uses custom color when provided', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        wrapWithLocalizations(
          const LoadingIndicator(color: customColor),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(
        (indicator.valueColor as AlwaysStoppedAnimation<Color>).value,
        customColor,
      );
    });
  });

  group('LoadingIndicatorSize', () {
    test('has all expected values', () {
      expect(LoadingIndicatorSize.values.length, 3);
      expect(LoadingIndicatorSize.values, contains(LoadingIndicatorSize.small));
      expect(
          LoadingIndicatorSize.values, contains(LoadingIndicatorSize.medium));
      expect(LoadingIndicatorSize.values, contains(LoadingIndicatorSize.large));
    });
  });

  group('ErrorStateWidget', () {
    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const ErrorStateWidget(message: 'An error occurred'),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const ErrorStateWidget(message: 'Failed to load data'),
        ),
      );

      expect(find.text('Failed to load data'), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const ErrorStateWidget(
            title: 'Error Title',
            message: 'Error message',
          ),
        ),
      );

      expect(find.text('Error Title'), findsOneWidget);
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'An error occurred',
            onRetry: () {},
            retryLabel: 'Retry', // Use explicit label to avoid localization
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const ErrorStateWidget(message: 'An error occurred'),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'An error occurred',
            onRetry: () {
              retryTapped = true;
            },
            retryLabel: 'Retry', // Use explicit label to avoid localization
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });

    testWidgets('uses custom retry label when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'An error occurred',
            onRetry: () {},
            retryLabel: 'Try Again',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('uses custom icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const ErrorStateWidget(
            message: 'An error occurred',
            icon: Icons.warning,
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('hides icon when showIcon is false', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const ErrorStateWidget(
            message: 'An error occurred',
            showIcon: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('network factory creates widget with wifi_off icon',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget.network(),
        ),
      );

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('server factory creates widget with cloud_off icon',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget.server(),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('displays icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const EmptyStateWidget(
            icon: Icons.history,
            title: 'No History',
          ),
        ),
      );

      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const EmptyStateWidget(
            icon: Icons.history,
            title: 'No History Yet',
          ),
        ),
      );

      expect(find.text('No History Yet'), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const EmptyStateWidget(
            icon: Icons.history,
            title: 'No History',
            message: 'Complete some quizzes to see your history.',
          ),
        ),
      );

      expect(
          find.text('Complete some quizzes to see your history.'), findsOneWidget);
    });

    testWidgets('shows action button when onAction and actionLabel provided',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          EmptyStateWidget(
            icon: Icons.history,
            title: 'No History',
            onAction: () {},
            actionLabel: 'Start Quiz',
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);
    });

    testWidgets('hides action button when onAction is null', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          const EmptyStateWidget(
            icon: Icons.history,
            title: 'No History',
            actionLabel: 'Start Quiz',
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('calls onAction when action button is tapped', (tester) async {
      var actionTapped = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          EmptyStateWidget(
            icon: Icons.history,
            title: 'No History',
            onAction: () {
              actionTapped = true;
            },
            actionLabel: 'Start Quiz',
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(actionTapped, isTrue);
    });

    testWidgets('shows action icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          EmptyStateWidget(
            icon: Icons.history,
            title: 'No History',
            onAction: () {},
            actionLabel: 'Start Quiz',
            actionIcon: Icons.play_arrow,
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('noResults factory creates search_off icon', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          EmptyStateWidget.noResults(),
        ),
      );

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('compact factory creates smaller widget', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          EmptyStateWidget.compact(
            icon: Icons.inbox,
            title: 'No Items',
          ),
        ),
      );

      // Widget should render successfully
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No Items'), findsOneWidget);
    });

    testWidgets('noData factory creates widget with custom icon',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          EmptyStateWidget.noData(
            icon: Icons.analytics,
            title: 'No Statistics',
            message: 'Play some quizzes to see stats.',
          ),
        ),
      );

      expect(find.byIcon(Icons.analytics), findsOneWidget);
      expect(find.text('No Statistics'), findsOneWidget);
      expect(find.text('Play some quizzes to see stats.'), findsOneWidget);
    });
  });
}
