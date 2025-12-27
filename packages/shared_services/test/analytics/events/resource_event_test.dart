import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ResourceEvent', () {
    group('LifeLostEvent', () {
      test('creates with correct event name', () {
        const event = LifeLostEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          livesRemaining: 2,
          livesTotal: 3,
          reason: 'incorrect_answer',
        );

        expect(event.eventName, equals('resource_life_lost'));
        expect(event.quizId, equals('quiz-123'));
      });

      test('includes all parameters', () {
        const event = LifeLostEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          livesRemaining: 2,
          livesTotal: 3,
          reason: 'incorrect_answer',
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'question_id': 'q1',
          'question_index': 5,
          'lives_remaining': 2,
          'lives_total': 3,
          'reason': 'incorrect_answer',
        });
      });

      test('factory constructor works', () {
        final event = ResourceEvent.lifeLost(
          quizId: 'quiz-456',
          questionId: 'q10',
          questionIndex: 9,
          livesRemaining: 1,
          livesTotal: 3,
          reason: 'timeout',
        );

        expect(event, isA<LifeLostEvent>());
      });
    });

    group('LivesDepletedEvent', () {
      test('creates with correct event name', () {
        const event = LivesDepletedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          questionsAnswered: 8,
          totalQuestions: 20,
          correctAnswers: 5,
          scorePercentage: 62.5,
          duration: Duration(minutes: 3),
        );

        expect(event.eventName, equals('resource_lives_depleted'));
      });

      test('calculates completion percentage correctly', () {
        const event = LivesDepletedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          questionsAnswered: 10,
          totalQuestions: 20,
          correctAnswers: 7,
          scorePercentage: 70.0,
          duration: Duration(minutes: 4),
        );

        expect(event.parameters['completion_percentage'], equals('50.0'));
        expect(event.parameters['duration_seconds'], equals(240));
      });

      test('handles zero total questions', () {
        const event = LivesDepletedEvent(
          quizId: 'quiz-123',
          quizName: 'Empty Quiz',
          categoryId: 'test',
          questionsAnswered: 0,
          totalQuestions: 0,
          correctAnswers: 0,
          scorePercentage: 0.0,
          duration: Duration.zero,
        );

        expect(event.parameters['completion_percentage'], equals('0.0'));
      });

      test('factory constructor works', () {
        final event = ResourceEvent.livesDepleted(
          quizId: 'quiz-789',
          quizName: 'World Flags',
          categoryId: 'world',
          questionsAnswered: 15,
          totalQuestions: 50,
          correctAnswers: 12,
          scorePercentage: 80.0,
          duration: const Duration(minutes: 5),
        );

        expect(event, isA<LivesDepletedEvent>());
      });
    });

    group('ResourceButtonTappedEvent', () {
      test('creates with correct event name', () {
        const event = ResourceButtonTappedEvent(
          quizId: 'quiz-123',
          resourceType: 'lives',
          currentAmount: 2,
          isAvailable: true,
          context: 'quiz_screen',
        );

        expect(event.eventName, equals('resource_button_tapped'));
      });

      test('includes all parameters', () {
        const event = ResourceButtonTappedEvent(
          quizId: 'quiz-123',
          resourceType: 'hints',
          currentAmount: 0,
          isAvailable: false,
          context: 'quiz_header',
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'resource_type': 'hints',
          'current_amount': 0,
          'is_available': false,
          'context': 'quiz_header',
        });
      });

      test('factory constructor works', () {
        final event = ResourceEvent.buttonTapped(
          quizId: 'quiz-456',
          resourceType: 'fifty_fifty',
          currentAmount: 3,
          isAvailable: true,
          context: 'hints_panel',
        );

        expect(event, isA<ResourceButtonTappedEvent>());
      });
    });

    group('ResourceAddedEvent', () {
      test('creates with correct event name', () {
        const event = ResourceAddedEvent(
          quizId: 'quiz-123',
          resourceType: 'lives',
          amountAdded: 1,
          newTotal: 3,
          source: 'rewarded_ad',
        );

        expect(event.eventName, equals('resource_added'));
      });

      test('includes all parameters', () {
        const event = ResourceAddedEvent(
          quizId: 'quiz-123',
          resourceType: 'hints',
          amountAdded: 5,
          newTotal: 8,
          source: 'purchase',
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'resource_type': 'hints',
          'amount_added': 5,
          'new_total': 8,
          'source': 'purchase',
        });
      });

      test('factory constructor works', () {
        final event = ResourceEvent.added(
          quizId: 'quiz-789',
          resourceType: 'skip_hints',
          amountAdded: 2,
          newTotal: 5,
          source: 'daily_bonus',
        );

        expect(event, isA<ResourceAddedEvent>());
      });
    });
  });

  group('ResourceEvent base class', () {
    test('all resource events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const LifeLostEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          livesRemaining: 2,
          livesTotal: 3,
          reason: 'incorrect',
        ),
        const LivesDepletedEvent(
          quizId: 'q1',
          quizName: 'Test',
          categoryId: 'cat1',
          questionsAnswered: 5,
          totalQuestions: 10,
          correctAnswers: 2,
          scorePercentage: 40.0,
          duration: Duration(minutes: 2),
        ),
        const ResourceButtonTappedEvent(
          quizId: 'q1',
          resourceType: 'lives',
          currentAmount: 1,
          isAvailable: true,
          context: 'quiz',
        ),
        const ResourceAddedEvent(
          quizId: 'q1',
          resourceType: 'hints',
          amountAdded: 1,
          newTotal: 4,
          source: 'bonus',
        ),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });

    test('all resource events have quizId', () {
      final events = <ResourceEvent>[
        const LifeLostEvent(
          quizId: 'quiz-test',
          questionId: 'q1',
          questionIndex: 0,
          livesRemaining: 2,
          livesTotal: 3,
          reason: 'incorrect',
        ),
        const ResourceAddedEvent(
          quizId: 'quiz-test',
          resourceType: 'hints',
          amountAdded: 1,
          newTotal: 4,
          source: 'bonus',
        ),
      ];

      for (final event in events) {
        expect(event.quizId, equals('quiz-test'));
      }
    });
  });
}
