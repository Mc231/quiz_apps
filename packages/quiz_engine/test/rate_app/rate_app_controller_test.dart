import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

// Mocks
class MockRateAppService extends Mock implements RateAppService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class FakeAnalyticsEvent extends Fake implements AnalyticsEvent {}

void main() {
  late MockRateAppService mockRateAppService;
  late MockAnalyticsService mockAnalyticsService;

  setUpAll(() {
    registerFallbackValue(FakeAnalyticsEvent());
  });

  setUp(() {
    mockRateAppService = MockRateAppService();
    mockAnalyticsService = MockAnalyticsService();

    // Default stubs
    when(() => mockAnalyticsService.logEvent(any())).thenAnswer((_) async {});
  });

  /// Creates a test RateAppState with a first launch date 5 days ago.
  RateAppState createTestState({
    int promptCount = 0,
    int declineCount = 0,
    bool hasRated = false,
  }) {
    return RateAppState(
      firstLaunchDate: DateTime.now().subtract(const Duration(days: 5)),
      promptCount: promptCount,
      declineCount: declineCount,
      hasRated: hasRated,
    );
  }

  group('RateAppController', () {
    test('returns notConfigured when rateAppService is null', () async {
      final controller = RateAppController(
        rateAppService: null,
        analyticsService: mockAnalyticsService,
        appName: 'Test App',
      );

      final result = await controller.maybeShowRateApp(
        context: _createMockContext(),
        quizScore: 80,
        completedQuizzes: 10,
      );

      expect(result, RateAppFlowResult.notConfigured);
      verifyNever(() => mockAnalyticsService.logEvent(any()));
    });

    test('returns conditionsNotMet when shouldShowPrompt returns false',
        () async {
      when(() => mockRateAppService.shouldShowPrompt(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(false);
      when(() => mockRateAppService.getBlockingReason(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn('score_too_low');
      when(() => mockRateAppService.state).thenReturn(createTestState(
        promptCount: 1,
      ));

      final controller = RateAppController(
        rateAppService: mockRateAppService,
        analyticsService: mockAnalyticsService,
        appName: 'Test App',
      );

      final result = await controller.maybeShowRateApp(
        context: _createMockContext(),
        quizScore: 50,
        completedQuizzes: 10,
      );

      expect(result, RateAppFlowResult.conditionsNotMet);

      // Verify conditions checked event was logged
      final captured =
          verify(() => mockAnalyticsService.logEvent(captureAny())).captured;
      expect(captured, hasLength(1));
      final event = captured.first as RateAppEvent;
      expect(event.eventName, 'rate_app_conditions_checked');
      expect(event.parameters['should_show'], false);
      expect(event.parameters['blocking_reason'], 'score_too_low');
    });

    testWidgets('shows love dialog when conditions are met', (tester) async {
      // Set up conditions to be met
      when(() => mockRateAppService.shouldShowPrompt(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(true);
      when(() => mockRateAppService.getBlockingReason(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(null);
      when(() => mockRateAppService.state).thenReturn(createTestState());
      when(() => mockRateAppService.recordUserDismissed())
          .thenAnswer((_) async {});

      late BuildContext capturedContext;
      late RateAppFlowResult flowResult;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizLocalizationsDelegate(),
          ],
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final controller = RateAppController(
                      rateAppService: mockRateAppService,
                      analyticsService: mockAnalyticsService,
                      appName: 'Test App',
                    );
                    flowResult = await controller.maybeShowRateApp(
                      context: capturedContext,
                      quizScore: 80,
                      completedQuizzes: 10,
                    );
                  },
                  child: const Text('Show Rate App'),
                ),
              );
            },
          ),
        ),
      );

      // Tap to trigger rate app flow
      await tester.tap(find.text('Show Rate App'));
      await tester.pumpAndSettle();

      // Love dialog should be shown
      expect(find.text('Are you enjoying Test App?'), findsOneWidget);

      // Verify conditions checked and love dialog shown events were logged
      verify(() => mockAnalyticsService.logEvent(any())).called(2);

      // Dismiss dialog
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      expect(flowResult, RateAppFlowResult.dismissed);
    });

    testWidgets('logs love dialog dismissed event when dismissed',
        (tester) async {
      when(() => mockRateAppService.shouldShowPrompt(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(true);
      when(() => mockRateAppService.getBlockingReason(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(null);
      when(() => mockRateAppService.state).thenReturn(createTestState(
        promptCount: 1,
      ));
      when(() => mockRateAppService.recordUserDismissed())
          .thenAnswer((_) async {});

      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizLocalizationsDelegate(),
          ],
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final controller = RateAppController(
                      rateAppService: mockRateAppService,
                      analyticsService: mockAnalyticsService,
                      appName: 'Test App',
                    );
                    await controller.maybeShowRateApp(
                      context: capturedContext,
                      quizScore: 80,
                      completedQuizzes: 10,
                    );
                  },
                  child: const Text('Show Rate App'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Rate App'));
      await tester.pumpAndSettle();

      // Dismiss dialog
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Verify dismissed event was logged
      final captured =
          verify(() => mockAnalyticsService.logEvent(captureAny())).captured;

      // Should have: conditions_checked, love_dialog_shown, love_dialog_dismissed
      expect(captured.length, 3);

      final dismissedEvent = captured[2] as RateAppEvent;
      expect(dismissedEvent.eventName, 'rate_app_love_dialog_dismissed');

      // Verify recordUserDismissed was called
      verify(() => mockRateAppService.recordUserDismissed()).called(1);
    });

    testWidgets('shows feedback dialog when user responds negatively',
        (tester) async {
      when(() => mockRateAppService.shouldShowPrompt(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(true);
      when(() => mockRateAppService.getBlockingReason(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(null);
      when(() => mockRateAppService.state).thenReturn(createTestState(
        promptCount: 1,
      ));
      when(() => mockRateAppService.recordUserDeclined())
          .thenAnswer((_) async {});

      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizLocalizationsDelegate(),
          ],
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final controller = RateAppController(
                      rateAppService: mockRateAppService,
                      analyticsService: mockAnalyticsService,
                      appName: 'Test App',
                      feedbackEmail: 'feedback@test.com',
                    );
                    await controller.maybeShowRateApp(
                      context: capturedContext,
                      quizScore: 80,
                      completedQuizzes: 10,
                    );
                  },
                  child: const Text('Show Rate App'),
                ),
              );
            },
          ),
        ),
      );

      // Show rate app flow
      await tester.tap(find.text('Show Rate App'));
      await tester.pumpAndSettle();

      // Tap "Not Really" in love dialog
      await tester.tap(find.text('Not Really'));
      await tester.pumpAndSettle();

      // Feedback dialog should appear
      expect(find.text("We'd love to hear from you"), findsOneWidget);

      // Verify negative event was logged
      final captured =
          verify(() => mockAnalyticsService.logEvent(captureAny())).captured;

      // Should have: conditions_checked, love_dialog_shown, love_dialog_negative, feedback_dialog_shown
      expect(captured.length, greaterThanOrEqualTo(4));

      final negativeEvent = captured.firstWhere(
        (e) => (e as RateAppEvent).eventName == 'rate_app_love_dialog_negative',
      ) as RateAppEvent;
      expect(negativeEvent.parameters['prompt_count'], 2);
    });

    testWidgets('logs feedback submitted when user sends feedback',
        (tester) async {
      when(() => mockRateAppService.shouldShowPrompt(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(true);
      when(() => mockRateAppService.getBlockingReason(
            quizScore: any(named: 'quizScore'),
            completedQuizzes: any(named: 'completedQuizzes'),
          )).thenReturn(null);
      when(() => mockRateAppService.state).thenReturn(createTestState(
        promptCount: 1,
        declineCount: 1,
      ));
      when(() => mockRateAppService.recordUserDeclined())
          .thenAnswer((_) async {});
      when(() => mockRateAppService.recordFeedbackSubmitted())
          .thenAnswer((_) async {});

      late BuildContext capturedContext;
      late RateAppFlowResult flowResult;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizLocalizationsDelegate(),
          ],
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final controller = RateAppController(
                      rateAppService: mockRateAppService,
                      analyticsService: mockAnalyticsService,
                      appName: 'Test App',
                      feedbackEmail: 'feedback@test.com',
                    );
                    flowResult = await controller.maybeShowRateApp(
                      context: capturedContext,
                      quizScore: 80,
                      completedQuizzes: 10,
                    );
                  },
                  child: const Text('Show Rate App'),
                ),
              );
            },
          ),
        ),
      );

      // Show rate app flow
      await tester.tap(find.text('Show Rate App'));
      await tester.pumpAndSettle();

      // Tap "Not Really"
      await tester.tap(find.text('Not Really'));
      await tester.pumpAndSettle();

      // Tap "Send Feedback"
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(flowResult, RateAppFlowResult.feedback);

      // Verify feedback submitted event
      final captured =
          verify(() => mockAnalyticsService.logEvent(captureAny())).captured;
      final submittedEvent = captured.firstWhere(
        (e) => (e as RateAppEvent).eventName == 'rate_app_feedback_submitted',
      ) as RateAppEvent;
      expect(submittedEvent.parameters['decline_count'], 1);

      // Verify recordFeedbackSubmitted was called
      verify(() => mockRateAppService.recordFeedbackSubmitted()).called(1);
    });
  });

  group('RateAppFlowResult', () {
    test('has all expected values', () {
      expect(
          RateAppFlowResult.values,
          containsAll([
            RateAppFlowResult.notConfigured,
            RateAppFlowResult.conditionsNotMet,
            RateAppFlowResult.rated,
            RateAppFlowResult.feedback,
            RateAppFlowResult.declined,
            RateAppFlowResult.dismissed,
            RateAppFlowResult.error,
          ]));
    });
  });
}

/// Creates a mock BuildContext for non-widget tests.
BuildContext _createMockContext() {
  return _MockBuildContext();
}

class _MockBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => false;
}
