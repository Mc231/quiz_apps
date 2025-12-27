import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../mocks/mock_analytics_service.dart';
import '../test_helpers.dart';

void main() {
  group('ErrorStateWidget Analytics Integration', () {
    late MockAnalyticsService analyticsService;

    setUp(() {
      analyticsService = MockAnalyticsService();
    });

    tearDown(() {
      analyticsService.dispose();
    });

    testWidgets('tracks retry tapped event', (tester) async {
      bool retryWasCalled = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Failed to load data',
            onRetry: () => retryWasCalled = true,
            analyticsService: analyticsService,
            errorType: 'data_load',
            errorContext: 'quiz_screen',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap retry button
      final retryButton = find.widgetWithText(FilledButton, 'Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      // Verify retry callback was called
      expect(retryWasCalled, true);

      // Verify event was logged
      expect(analyticsService.loggedEvents.length, 1);
      final event = analyticsService.loggedEvents.first as ErrorEvent;
      expect(event.eventName, 'error_retry_tapped');
      expect(event.parameters['error_type'], 'data_load');
      expect(event.parameters['context'], 'quiz_screen');
      expect(event.parameters['attempt_number'], 1);
      expect(event.parameters.containsKey('time_since_error'), true);

      final timeSinceError = event.parameters['time_since_error'] as Duration;
      expect(timeSinceError.inMilliseconds, greaterThan(0));
    });

    testWidgets('tracks multiple retry attempts', (tester) async {
      int retryCount = 0;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Network error',
            onRetry: () => retryCount++,
            analyticsService: analyticsService,
            errorType: 'network',
            errorContext: 'settings',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final retryButton = find.widgetWithText(FilledButton, 'Retry');

      // First retry
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(analyticsService.loggedEvents.length, 1);
      expect(
        analyticsService.loggedEvents[0].parameters['attempt_number'],
        1,
      );

      // Second retry
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(analyticsService.loggedEvents.length, 2);
      expect(
        analyticsService.loggedEvents[1].parameters['attempt_number'],
        2,
      );

      // Third retry
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(analyticsService.loggedEvents.length, 3);
      expect(
        analyticsService.loggedEvents[2].parameters['attempt_number'],
        3,
      );

      // Verify callback was called 3 times
      expect(retryCount, 3);
    });

    testWidgets('tracks network error retry', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget.network(
            onRetry: () {},
            analyticsService: analyticsService,
            errorContext: 'quiz_list',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      final event = analyticsService.loggedEvents.first as ErrorEvent;
      expect(event.parameters['error_type'], 'network');
      expect(event.parameters['context'], 'quiz_list');
    });

    testWidgets('tracks server error retry', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget.server(
            onRetry: () {},
            analyticsService: analyticsService,
            errorContext: 'leaderboard',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      final event = analyticsService.loggedEvents.first as ErrorEvent;
      expect(event.parameters['error_type'], 'server');
      expect(event.parameters['context'], 'leaderboard');
    });

    testWidgets('uses unknown for missing error type and context',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Generic error',
            onRetry: () {},
            analyticsService: analyticsService,
            // No errorType or errorContext provided
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      final event = analyticsService.loggedEvents.first as ErrorEvent;
      expect(event.parameters['error_type'], 'unknown');
      expect(event.parameters['context'], 'unknown');
    });

    testWidgets('does not track when analytics service is null',
        (tester) async {
      bool retryWasCalled = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Error',
            onRetry: () => retryWasCalled = true,
            analyticsService: NoOpAnalyticsService(), // No analytics service
            errorType: 'test',
            errorContext: 'test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      // Verify retry was called but no events logged
      expect(retryWasCalled, true);
      expect(analyticsService.loggedEvents, isEmpty);
    });

    testWidgets('does not track when onRetry is null', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Error',
            // No onRetry callback
            analyticsService: analyticsService,
            errorType: 'test',
            errorContext: 'test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Retry button should not exist
      expect(find.widgetWithText(FilledButton, 'Retry'), findsNothing);

      // No events should be logged
      expect(analyticsService.loggedEvents, isEmpty);
    });

    testWidgets('tracks time since error accurately', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Error',
            onRetry: () {},
            analyticsService: analyticsService,
            errorType: 'test',
            errorContext: 'test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Wait a bit before retrying
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      final event = analyticsService.loggedEvents.first as ErrorEvent;
      final timeSinceError = event.parameters['time_since_error'] as Duration;

      // Should be at least 500ms
      expect(timeSinceError.inMilliseconds, greaterThanOrEqualTo(500));
      // But not absurdly long
      expect(timeSinceError.inSeconds, lessThan(10));
    });

    testWidgets('tracks custom error type and context', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Custom error message',
            onRetry: () {},
            analyticsService: analyticsService,
            errorType: 'custom_api_error',
            errorContext: 'user_profile_screen',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      final event = analyticsService.loggedEvents.first as ErrorEvent;
      expect(event.parameters['error_type'], 'custom_api_error');
      expect(event.parameters['context'], 'user_profile_screen');
    });

    testWidgets('increments attempt number on same error instance',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            message: 'Persistent error',
            onRetry: () {},
            analyticsService: analyticsService,
            errorType: 'persistent',
            errorContext: 'sync',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Retry multiple times
      for (int i = 1; i <= 5; i++) {
        await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
        await tester.pumpAndSettle();

        expect(analyticsService.loggedEvents.length, i);
        final event = analyticsService.loggedEvents.last as ErrorEvent;
        expect(event.parameters['attempt_number'], i);
      }
    });

    testWidgets('resets attempt counter when widget rebuilds', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            key: const ValueKey('error_1'),
            message: 'First error',
            onRetry: () {},
            analyticsService: analyticsService,
            errorType: 'first',
            errorContext: 'test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First retry
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(analyticsService.loggedEvents.length, 1);
      expect(
        analyticsService.loggedEvents[0].parameters['attempt_number'],
        1,
      );

      // Rebuild with new widget (new error)
      await tester.pumpWidget(
        wrapWithLocalizations(
          ErrorStateWidget(
            key: const ValueKey('error_2'),
            message: 'Second error',
            onRetry: () {},
            analyticsService: analyticsService,
            errorType: 'second',
            errorContext: 'test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Retry on new widget - should start at attempt 1 again
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(analyticsService.loggedEvents.length, 2);
      expect(
        analyticsService.loggedEvents[1].parameters['attempt_number'],
        1,
      );
    });
  });
}
