import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('QuestionEvent', () {
    group('QuestionDisplayedEvent', () {
      test('creates with correct event name', () {
        const event = QuestionDisplayedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          totalQuestions: 20,
          questionType: 'image',
          optionCount: 4,
        );

        expect(event.eventName, equals('question_displayed'));
        expect(event.quizId, equals('quiz-123'));
      });

      test('includes all required parameters', () {
        const event = QuestionDisplayedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          totalQuestions: 20,
          questionType: 'text',
          optionCount: 4,
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'question_id': 'q1',
          'question_index': 5,
          'total_questions': 20,
          'question_type': 'text',
          'option_count': 4,
        });
      });

      test('includes optional time limit when provided', () {
        const event = QuestionDisplayedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          totalQuestions: 20,
          questionType: 'image',
          optionCount: 4,
          timeLimit: 30,
        );

        expect(event.parameters['time_limit'], equals(30));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.displayed(
          quizId: 'quiz-456',
          questionId: 'q2',
          questionIndex: 10,
          totalQuestions: 50,
          questionType: 'audio',
          optionCount: 6,
        );

        expect(event, isA<QuestionDisplayedEvent>());
      });
    });

    group('QuestionAnsweredEvent', () {
      test('creates with correct event name', () {
        const event = QuestionAnsweredEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          isCorrect: true,
          responseTime: Duration(seconds: 3),
          selectedAnswer: 'France',
          correctAnswer: 'France',
        );

        expect(event.eventName, equals('question_answered'));
      });

      test('includes response time in milliseconds', () {
        const event = QuestionAnsweredEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          isCorrect: false,
          responseTime: Duration(seconds: 5, milliseconds: 500),
          selectedAnswer: 'Germany',
          correctAnswer: 'France',
        );

        expect(event.parameters['response_time_ms'], equals(5500));
        expect(event.parameters['is_correct'], equals(0));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.answered(
          quizId: 'quiz-789',
          questionId: 'q5',
          questionIndex: 4,
          isCorrect: true,
          responseTime: const Duration(seconds: 2),
          selectedAnswer: 'Italy',
          correctAnswer: 'Italy',
        );

        expect(event, isA<QuestionAnsweredEvent>());
      });
    });

    group('QuestionCorrectEvent', () {
      test('creates with correct event name', () {
        const event = QuestionCorrectEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          responseTime: Duration(seconds: 2),
          currentStreak: 5,
        );

        expect(event.eventName, equals('question_correct'));
      });

      test('includes streak and optional points', () {
        const event = QuestionCorrectEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 3,
          responseTime: Duration(seconds: 1),
          currentStreak: 4,
          pointsEarned: 100,
          bonusPoints: 25,
        );

        expect(event.parameters['current_streak'], equals(4));
        expect(event.parameters['points_earned'], equals(100));
        expect(event.parameters['bonus_points'], equals(25));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.correct(
          quizId: 'quiz-456',
          questionId: 'q10',
          questionIndex: 9,
          responseTime: const Duration(milliseconds: 1500),
          currentStreak: 10,
        );

        expect(event, isA<QuestionCorrectEvent>());
      });
    });

    group('QuestionIncorrectEvent', () {
      test('creates with correct event name', () {
        const event = QuestionIncorrectEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          responseTime: Duration(seconds: 8),
          selectedAnswer: 'Spain',
          correctAnswer: 'Portugal',
        );

        expect(event.eventName, equals('question_incorrect'));
      });

      test('includes selected and correct answers', () {
        const event = QuestionIncorrectEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          responseTime: Duration(seconds: 8),
          selectedAnswer: 'Spain',
          correctAnswer: 'Portugal',
          livesRemaining: 2,
        );

        expect(event.parameters['selected_answer'], equals('Spain'));
        expect(event.parameters['correct_answer'], equals('Portugal'));
        expect(event.parameters['lives_remaining'], equals(2));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.incorrect(
          quizId: 'quiz-789',
          questionId: 'q15',
          questionIndex: 14,
          responseTime: const Duration(seconds: 10),
          selectedAnswer: 'Brazil',
          correctAnswer: 'Argentina',
        );

        expect(event, isA<QuestionIncorrectEvent>());
      });
    });

    group('QuestionSkippedEvent', () {
      test('creates with correct event name', () {
        const event = QuestionSkippedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 3,
          timeBeforeSkip: Duration(seconds: 5),
          usedHint: true,
        );

        expect(event.eventName, equals('question_skipped'));
      });

      test('includes hint usage info', () {
        const event = QuestionSkippedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 3,
          timeBeforeSkip: Duration(seconds: 5),
          usedHint: true,
          hintsRemaining: 2,
        );

        expect(event.parameters['used_hint'], equals(1));
        expect(event.parameters['hints_remaining'], equals(2));
        expect(event.parameters['time_before_skip_ms'], equals(5000));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.skipped(
          quizId: 'quiz-456',
          questionId: 'q8',
          questionIndex: 7,
          timeBeforeSkip: const Duration(seconds: 3),
          usedHint: false,
        );

        expect(event, isA<QuestionSkippedEvent>());
      });
    });

    group('QuestionTimeoutEvent', () {
      test('creates with correct event name', () {
        const event = QuestionTimeoutEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 10,
          timeLimit: 30,
          correctAnswer: 'Japan',
        );

        expect(event.eventName, equals('question_timeout'));
      });

      test('includes time limit and correct answer', () {
        const event = QuestionTimeoutEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 10,
          timeLimit: 30,
          correctAnswer: 'Japan',
          livesRemaining: 1,
        );

        expect(event.parameters['time_limit'], equals(30));
        expect(event.parameters['correct_answer'], equals('Japan'));
        expect(event.parameters['lives_remaining'], equals(1));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.timeout(
          quizId: 'quiz-789',
          questionId: 'q20',
          questionIndex: 19,
          timeLimit: 15,
          correctAnswer: 'China',
        );

        expect(event, isA<QuestionTimeoutEvent>());
      });
    });

    group('QuestionFeedbackShownEvent', () {
      test('creates with correct event name', () {
        const event = QuestionFeedbackShownEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          wasCorrect: true,
          feedbackDuration: Duration(milliseconds: 1500),
        );

        expect(event.eventName, equals('question_feedback_shown'));
      });

      test('includes feedback details', () {
        const event = QuestionFeedbackShownEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 5,
          wasCorrect: false,
          feedbackDuration: Duration(seconds: 2),
        );

        expect(event.parameters['was_correct'], equals(0));
        expect(event.parameters['feedback_duration_ms'], equals(2000));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.feedbackShown(
          quizId: 'quiz-456',
          questionId: 'q12',
          questionIndex: 11,
          wasCorrect: true,
          feedbackDuration: const Duration(milliseconds: 1000),
        );

        expect(event, isA<QuestionFeedbackShownEvent>());
      });
    });

    group('QuestionOptionSelectedEvent', () {
      test('creates with correct event name', () {
        const event = QuestionOptionSelectedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          selectedOption: 'France',
          optionIndex: 2,
          timeSinceDisplayed: Duration(seconds: 2),
          isFirstSelection: true,
        );

        expect(event.eventName, equals('question_option_selected'));
      });

      test('includes selection details', () {
        const event = QuestionOptionSelectedEvent(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 3,
          selectedOption: 'Germany',
          optionIndex: 1,
          timeSinceDisplayed: Duration(seconds: 5),
          isFirstSelection: false,
          changeCount: 2,
        );

        expect(event.parameters['selected_option'], equals('Germany'));
        expect(event.parameters['option_index'], equals(1));
        expect(event.parameters['time_since_displayed_ms'], equals(5000));
        expect(event.parameters['is_first_selection'], equals(0));
        expect(event.parameters['change_count'], equals(2));
      });

      test('factory constructor works', () {
        final event = QuestionEvent.optionSelected(
          quizId: 'quiz-789',
          questionId: 'q5',
          questionIndex: 4,
          selectedOption: 'Italy',
          optionIndex: 0,
          timeSinceDisplayed: const Duration(milliseconds: 800),
          isFirstSelection: true,
        );

        expect(event, isA<QuestionOptionSelectedEvent>());
      });
    });
  });

  group('QuestionEvent base class', () {
    test('all question events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const QuestionDisplayedEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          totalQuestions: 10,
          questionType: 'image',
          optionCount: 4,
        ),
        const QuestionAnsweredEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          isCorrect: true,
          responseTime: Duration(seconds: 2),
          selectedAnswer: 'A',
          correctAnswer: 'A',
        ),
        const QuestionSkippedEvent(
          quizId: 'q1',
          questionId: 'q1',
          questionIndex: 0,
          timeBeforeSkip: Duration(seconds: 3),
          usedHint: false,
        ),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });

    test('all question events have quizId', () {
      final events = <QuestionEvent>[
        const QuestionDisplayedEvent(
          quizId: 'quiz-test',
          questionId: 'q1',
          questionIndex: 0,
          totalQuestions: 10,
          questionType: 'image',
          optionCount: 4,
        ),
        const QuestionCorrectEvent(
          quizId: 'quiz-test',
          questionId: 'q1',
          questionIndex: 0,
          responseTime: Duration(seconds: 1),
          currentStreak: 1,
        ),
      ];

      for (final event in events) {
        expect(event.quizId, equals('quiz-test'));
      }
    });
  });
}
