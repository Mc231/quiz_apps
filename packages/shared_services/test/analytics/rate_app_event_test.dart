import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('RateAppEvent', () {
    group('conditionsChecked', () {
      test('creates event with all parameters', () {
        final event = RateAppEvent.conditionsChecked(
          shouldShow: true,
          blockingReason: null,
          completedQuizzes: 10,
          quizScore: 85,
          daysSinceInstall: 14,
          promptCount: 1,
          declineCount: 0,
        );

        expect(event.eventName, 'rate_app_conditions_checked');
        expect(event.parameters['should_show'], true);
        expect(event.parameters['completed_quizzes'], 10);
        expect(event.parameters['quiz_score'], 85);
        expect(event.parameters['days_since_install'], 14);
        expect(event.parameters['prompt_count'], 1);
        expect(event.parameters['decline_count'], 0);
        expect(event.parameters.containsKey('blocking_reason'), false);
      });

      test('includes blocking reason when provided', () {
        final event = RateAppEvent.conditionsChecked(
          shouldShow: false,
          blockingReason: 'Not enough quizzes completed',
          completedQuizzes: 3,
          quizScore: 50,
          daysSinceInstall: 2,
          promptCount: 0,
          declineCount: 0,
        );

        expect(event.parameters['should_show'], false);
        expect(event.parameters['blocking_reason'], 'Not enough quizzes completed');
      });
    });

    group('loveDialogShown', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.loveDialogShown(
          completedQuizzes: 10,
          quizScore: 85,
          promptCount: 2,
        );

        expect(event.eventName, 'rate_app_love_dialog_shown');
        expect(event.parameters['completed_quizzes'], 10);
        expect(event.parameters['quiz_score'], 85);
        expect(event.parameters['prompt_count'], 2);
      });
    });

    group('loveDialogPositive', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.loveDialogPositive(
          promptCount: 2,
          timeToRespond: const Duration(milliseconds: 2500),
        );

        expect(event.eventName, 'rate_app_love_dialog_positive');
        expect(event.parameters['prompt_count'], 2);
        expect(event.parameters['time_to_respond_ms'], 2500);
      });
    });

    group('loveDialogNegative', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.loveDialogNegative(
          promptCount: 2,
          declineCount: 1,
          timeToRespond: const Duration(milliseconds: 1800),
        );

        expect(event.eventName, 'rate_app_love_dialog_negative');
        expect(event.parameters['prompt_count'], 2);
        expect(event.parameters['decline_count'], 1);
        expect(event.parameters['time_to_respond_ms'], 1800);
      });
    });

    group('loveDialogDismissed', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.loveDialogDismissed(
          promptCount: 2,
          timeToRespond: const Duration(seconds: 5),
        );

        expect(event.eventName, 'rate_app_love_dialog_dismissed');
        expect(event.parameters['prompt_count'], 2);
        expect(event.parameters['time_to_respond_ms'], 5000);
      });
    });

    group('nativeDialogShown', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.nativeDialogShown(
          promptCount: 2,
        );

        expect(event.eventName, 'rate_app_native_dialog_shown');
        expect(event.parameters['prompt_count'], 2);
      });
    });

    group('nativeDialogCompleted', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.nativeDialogCompleted(
          promptCount: 2,
        );

        expect(event.eventName, 'rate_app_native_dialog_completed');
        expect(event.parameters['prompt_count'], 2);
      });
    });

    group('nativeDialogUnavailable', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.nativeDialogUnavailable(
          platform: 'web',
        );

        expect(event.eventName, 'rate_app_native_dialog_unavailable');
        expect(event.parameters['platform'], 'web');
      });
    });

    group('feedbackDialogShown', () {
      test('creates event with email', () {
        final event = RateAppEvent.feedbackDialogShown(
          declineCount: 1,
          feedbackEmail: 'support@app.com',
        );

        expect(event.eventName, 'rate_app_feedback_dialog_shown');
        expect(event.parameters['decline_count'], 1);
        expect(event.parameters['has_feedback_email'], true);
      });

      test('creates event without email', () {
        final event = RateAppEvent.feedbackDialogShown(
          declineCount: 1,
        );

        expect(event.parameters['has_feedback_email'], false);
      });
    });

    group('feedbackSubmitted', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.feedbackSubmitted(
          declineCount: 1,
          timeToRespond: const Duration(milliseconds: 3000),
        );

        expect(event.eventName, 'rate_app_feedback_submitted');
        expect(event.parameters['decline_count'], 1);
        expect(event.parameters['time_to_respond_ms'], 3000);
      });
    });

    group('feedbackDismissed', () {
      test('creates event with correct parameters', () {
        final event = RateAppEvent.feedbackDismissed(
          declineCount: 1,
          timeToRespond: const Duration(milliseconds: 3000),
        );

        expect(event.eventName, 'rate_app_feedback_dismissed');
        expect(event.parameters['decline_count'], 1);
        expect(event.parameters['time_to_respond_ms'], 3000);
      });
    });

    group('type checking', () {
      test('all events are RateAppEvent', () {
        final events = <AnalyticsEvent>[
          RateAppEvent.conditionsChecked(
            shouldShow: true,
            completedQuizzes: 10,
            quizScore: 85,
            daysSinceInstall: 14,
            promptCount: 1,
            declineCount: 0,
          ),
          RateAppEvent.loveDialogShown(
            completedQuizzes: 10,
            quizScore: 85,
            promptCount: 2,
          ),
          RateAppEvent.loveDialogPositive(
            promptCount: 2,
            timeToRespond: const Duration(milliseconds: 2500),
          ),
          RateAppEvent.loveDialogNegative(
            promptCount: 2,
            declineCount: 1,
            timeToRespond: const Duration(milliseconds: 1800),
          ),
          RateAppEvent.loveDialogDismissed(
            promptCount: 2,
            timeToRespond: const Duration(seconds: 5),
          ),
          RateAppEvent.nativeDialogShown(promptCount: 2),
          RateAppEvent.nativeDialogCompleted(promptCount: 2),
          RateAppEvent.nativeDialogUnavailable(platform: 'web'),
          RateAppEvent.feedbackDialogShown(declineCount: 1),
          RateAppEvent.feedbackSubmitted(
            declineCount: 1,
            timeToRespond: const Duration(milliseconds: 3000),
          ),
          RateAppEvent.feedbackDismissed(
            declineCount: 1,
            timeToRespond: const Duration(milliseconds: 3000),
          ),
        ];

        for (final event in events) {
          expect(event, isA<RateAppEvent>());
          expect(event, isA<AnalyticsEvent>());
        }

        // Verify we have all 11 events
        expect(events.length, 11);
      });

      test('events can be pattern matched', () {
        final event = RateAppEvent.loveDialogPositive(
          promptCount: 2,
          timeToRespond: const Duration(milliseconds: 2500),
        ) as RateAppEvent;

        final result = switch (event) {
          RateAppConditionsCheckedEvent() => 'conditions',
          RateAppLoveDialogShownEvent() => 'shown',
          RateAppLoveDialogPositiveEvent() => 'positive',
          RateAppLoveDialogNegativeEvent() => 'negative',
          RateAppLoveDialogDismissedEvent() => 'dismissed',
          RateAppNativeDialogShownEvent() => 'native_shown',
          RateAppNativeDialogCompletedEvent() => 'native_completed',
          RateAppNativeDialogUnavailableEvent() => 'native_unavailable',
          RateAppFeedbackDialogShownEvent() => 'feedback_shown',
          RateAppFeedbackSubmittedEvent() => 'feedback_submitted',
          RateAppFeedbackDismissedEvent() => 'feedback_dismissed',
        };

        expect(result, 'positive');
      });
    });

    group('event names follow snake_case convention', () {
      test('all event names are snake_case', () {
        final events = [
          RateAppEvent.conditionsChecked(
            shouldShow: true,
            completedQuizzes: 10,
            quizScore: 85,
            daysSinceInstall: 14,
            promptCount: 1,
            declineCount: 0,
          ),
          RateAppEvent.loveDialogShown(
            completedQuizzes: 10,
            quizScore: 85,
            promptCount: 2,
          ),
          RateAppEvent.loveDialogPositive(
            promptCount: 2,
            timeToRespond: const Duration(milliseconds: 2500),
          ),
          RateAppEvent.nativeDialogShown(promptCount: 2),
          RateAppEvent.feedbackDialogShown(declineCount: 1),
        ];

        for (final event in events) {
          expect(event.eventName, matches(RegExp(r'^[a-z_]+$')));
          expect(event.eventName.startsWith('rate_app_'), true);
        }
      });
    });
  });
}
