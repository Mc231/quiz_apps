import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('HintEvent', () {
    group('FiftyFiftyUsedEvent', () {
      test('creates with correct event name', () {
        const event = FiftyFiftyUsedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          hintsRemaining: 2,
          eliminatedOptions: ['Germany', 'Spain'],
        );

        expect(event.eventName, equals('hint_fifty_fifty_used'));
        expect(event.quizId, equals('quiz-123'));
      });

      test('includes eliminated options as comma-separated string', () {
        const event = FiftyFiftyUsedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          hintsRemaining: 2,
          eliminatedOptions: ['Germany', 'Spain'],
        );

        expect(event.parameters['eliminated_options'], equals('Germany,Spain'));
        expect(event.parameters['eliminated_count'], equals(2));
        expect(event.parameters['hints_remaining'], equals(2));
      });

      test('factory constructor works', () {
        final event = HintEvent.fiftyFiftyUsed(
          quizId: 'quiz-456',
          questionId: 'q3',
          questionIndex: 2,
          hintsRemaining: 1,
          eliminatedOptions: ['Italy', 'Portugal'],
        );

        expect(event, isA<FiftyFiftyUsedEvent>());
      });
    });

    group('SkipUsedEvent', () {
      test('creates with correct event name', () {
        const event = SkipUsedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 8,
          hintsRemaining: 1,
          timeBeforeSkip: Duration(seconds: 10),
        );

        expect(event.eventName, equals('hint_skip_used'));
      });

      test('includes time before skip in milliseconds', () {
        const event = SkipUsedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 8,
          hintsRemaining: 0,
          timeBeforeSkip: Duration(seconds: 5, milliseconds: 500),
        );

        expect(event.parameters['time_before_skip_ms'], equals(5500));
        expect(event.parameters['hints_remaining'], equals(0));
      });

      test('factory constructor works', () {
        final event = HintEvent.skipUsed(
          quizId: 'quiz-789',
          questionId: 'q15',
          questionIndex: 14,
          hintsRemaining: 2,
          timeBeforeSkip: const Duration(seconds: 3),
        );

        expect(event, isA<SkipUsedEvent>());
      });
    });

    group('HintUnavailableTappedEvent', () {
      test('creates with correct event name', () {
        const event = HintUnavailableTappedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 10,
          hintType: 'fifty_fifty',
        );

        expect(event.eventName, equals('hint_unavailable_tapped'));
      });

      test('includes hint type', () {
        const event = HintUnavailableTappedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 10,
          hintType: 'skip',
          totalHintsUsed: 5,
        );

        expect(event.parameters['hint_type'], equals('skip'));
        expect(event.parameters['total_hints_used'], equals(5));
      });

      test('does not include optional parameter when null', () {
        const event = HintUnavailableTappedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 10,
          hintType: 'fifty_fifty',
        );

        expect(event.parameters.containsKey('total_hints_used'), isFalse);
      });

      test('factory constructor works', () {
        final event = HintEvent.unavailableTapped(
          quizId: 'quiz-456',
          questionId: 'q20',
          questionIndex: 19,
          hintType: 'fifty_fifty',
        );

        expect(event, isA<HintUnavailableTappedEvent>());
      });
    });

    group('HintTimerWarningEvent', () {
      test('creates with correct event name', () {
        const event = HintTimerWarningEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          secondsRemaining: 10,
          warningLevel: 'warning',
        );

        expect(event.eventName, equals('hint_timer_warning'));
      });

      test('includes warning level', () {
        const event = HintTimerWarningEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          secondsRemaining: 5,
          warningLevel: 'critical',
        );

        expect(event.parameters['seconds_remaining'], equals(5));
        expect(event.parameters['warning_level'], equals('critical'));
      });

      test('factory constructor works', () {
        final event = HintEvent.timerWarning(
          quizId: 'quiz-789',
          questionId: 'q10',
          questionIndex: 9,
          secondsRemaining: 3,
          warningLevel: 'critical',
        );

        expect(event, isA<HintTimerWarningEvent>());
      });
    });
  });

  group('HintEvent base class', () {
    test('all hint events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const FiftyFiftyUsedEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          hintsRemaining: 2,
          eliminatedOptions: ['A', 'B'],
        ),
        const SkipUsedEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          hintsRemaining: 1,
          timeBeforeSkip: Duration(seconds: 5),
        ),
        const HintUnavailableTappedEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          hintType: 'skip',
        ),
        const HintTimerWarningEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          secondsRemaining: 10,
          warningLevel: 'warning',
        ),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });

    test('all hint events have quizId', () {
      final events = <HintEvent>[
        const FiftyFiftyUsedEvent(
          quizId: 'quiz-test',
          questionId: 'q1',
          questionIndex: 0,
          hintsRemaining: 2,
          eliminatedOptions: ['A', 'B'],
        ),
        const SkipUsedEvent(
          quizId: 'quiz-test',
          questionId: 'q1',
          questionIndex: 0,
          hintsRemaining: 1,
          timeBeforeSkip: Duration(seconds: 5),
        ),
      ];

      for (final event in events) {
        expect(event.quizId, equals('quiz-test'));
      }
    });
  });
}
