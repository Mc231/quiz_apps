import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('QuizEvent', () {
    group('QuizStartedEvent', () {
      test('creates with correct event name', () {
        const event = QuizStartedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          categoryName: 'Europe',
          mode: 'standard',
          totalQuestions: 20,
        );

        expect(event.eventName, equals('quiz_started'));
        expect(event.quizId, equals('quiz-123'));
      });

      test('includes all required parameters', () {
        const event = QuizStartedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          categoryName: 'Europe',
          mode: 'standard',
          totalQuestions: 20,
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'quiz_name': 'European Flags',
          'category_id': 'europe',
          'category_name': 'Europe',
          'mode': 'standard',
          'total_questions': 20,
        });
      });

      test('includes optional parameters when provided', () {
        const event = QuizStartedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          categoryName: 'Europe',
          mode: 'lives',
          totalQuestions: 20,
          initialLives: 3,
          initialHints: 5,
          timeLimit: 300,
        );

        expect(event.parameters['initial_lives'], equals(3));
        expect(event.parameters['initial_hints'], equals(5));
        expect(event.parameters['time_limit'], equals(300));
      });

      test('factory constructor works', () {
        final event = QuizEvent.started(
          quizId: 'quiz-456',
          quizName: 'World Flags',
          categoryId: 'world',
          categoryName: 'World',
          mode: 'timed',
          totalQuestions: 50,
        );

        expect(event, isA<QuizStartedEvent>());
        expect(event.quizId, equals('quiz-456'));
      });
    });

    group('QuizCompletedEvent', () {
      test('creates with correct event name', () {
        const event = QuizCompletedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'standard',
          totalQuestions: 20,
          correctAnswers: 18,
          incorrectAnswers: 2,
          skippedQuestions: 0,
          scorePercentage: 90.0,
          duration: Duration(minutes: 5),
          hintsUsed: 1,
        );

        expect(event.eventName, equals('quiz_completed'));
      });

      test('includes all required parameters', () {
        const event = QuizCompletedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'standard',
          totalQuestions: 20,
          correctAnswers: 18,
          incorrectAnswers: 2,
          skippedQuestions: 0,
          scorePercentage: 90.0,
          duration: Duration(minutes: 5),
          hintsUsed: 1,
        );

        expect(event.parameters['quiz_id'], equals('quiz-123'));
        expect(event.parameters['correct_answers'], equals(18));
        expect(event.parameters['duration_seconds'], equals(300));
        expect(event.parameters['is_perfect_score'], isFalse);
      });

      test('marks perfect score correctly', () {
        const event = QuizCompletedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'standard',
          totalQuestions: 20,
          correctAnswers: 20,
          incorrectAnswers: 0,
          skippedQuestions: 0,
          scorePercentage: 100.0,
          duration: Duration(minutes: 3),
          hintsUsed: 0,
          isPerfectScore: true,
          starRating: 3,
        );

        expect(event.parameters['is_perfect_score'], isTrue);
        expect(event.parameters['star_rating'], equals(3));
      });

      test('factory constructor works', () {
        final event = QuizEvent.completed(
          quizId: 'quiz-789',
          quizName: 'Asian Flags',
          categoryId: 'asia',
          mode: 'timed',
          totalQuestions: 30,
          correctAnswers: 25,
          incorrectAnswers: 5,
          skippedQuestions: 0,
          scorePercentage: 83.3,
          duration: const Duration(minutes: 10),
          hintsUsed: 2,
        );

        expect(event, isA<QuizCompletedEvent>());
      });
    });

    group('QuizCancelledEvent', () {
      test('creates with correct event name', () {
        const event = QuizCancelledEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'standard',
          questionsAnswered: 5,
          totalQuestions: 20,
          timeSpent: Duration(minutes: 2),
        );

        expect(event.eventName, equals('quiz_cancelled'));
      });

      test('calculates completion percentage correctly', () {
        const event = QuizCancelledEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'standard',
          questionsAnswered: 10,
          totalQuestions: 20,
          timeSpent: Duration(minutes: 3),
        );

        expect(event.parameters['completion_percentage'], equals('50.0'));
      });

      test('handles zero total questions', () {
        const event = QuizCancelledEvent(
          quizId: 'quiz-123',
          quizName: 'Empty Quiz',
          categoryId: 'test',
          mode: 'standard',
          questionsAnswered: 0,
          totalQuestions: 0,
          timeSpent: Duration.zero,
        );

        expect(event.parameters['completion_percentage'], equals('0.0'));
      });

      test('factory constructor works', () {
        final event = QuizEvent.cancelled(
          quizId: 'quiz-456',
          quizName: 'World Flags',
          categoryId: 'world',
          mode: 'lives',
          questionsAnswered: 8,
          totalQuestions: 25,
          timeSpent: const Duration(minutes: 4),
        );

        expect(event, isA<QuizCancelledEvent>());
      });
    });

    group('QuizTimeoutEvent', () {
      test('creates with correct event name', () {
        const event = QuizTimeoutEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'timed',
          questionsAnswered: 15,
          totalQuestions: 20,
          correctAnswers: 12,
          scorePercentage: 80.0,
        );

        expect(event.eventName, equals('quiz_timeout'));
      });

      test('includes all parameters', () {
        const event = QuizTimeoutEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'timed',
          questionsAnswered: 15,
          totalQuestions: 20,
          correctAnswers: 12,
          scorePercentage: 80.0,
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'quiz_name': 'European Flags',
          'category_id': 'europe',
          'mode': 'timed',
          'questions_answered': 15,
          'total_questions': 20,
          'correct_answers': 12,
          'score_percentage': 80.0,
        });
      });

      test('factory constructor works', () {
        final event = QuizEvent.timeout(
          quizId: 'quiz-789',
          quizName: 'Asian Flags',
          categoryId: 'asia',
          mode: 'timed',
          questionsAnswered: 10,
          totalQuestions: 30,
          correctAnswers: 8,
          scorePercentage: 80.0,
        );

        expect(event, isA<QuizTimeoutEvent>());
      });
    });

    group('QuizFailedEvent', () {
      test('creates with correct event name', () {
        const event = QuizFailedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'lives',
          questionsAnswered: 8,
          totalQuestions: 20,
          correctAnswers: 5,
          scorePercentage: 62.5,
          duration: Duration(minutes: 3),
          reason: 'lives_depleted',
        );

        expect(event.eventName, equals('quiz_failed'));
      });

      test('includes reason in parameters', () {
        const event = QuizFailedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'lives',
          questionsAnswered: 8,
          totalQuestions: 20,
          correctAnswers: 5,
          scorePercentage: 62.5,
          duration: Duration(minutes: 3),
          reason: 'lives_depleted',
        );

        expect(event.parameters['reason'], equals('lives_depleted'));
        expect(event.parameters['duration_seconds'], equals(180));
      });

      test('factory constructor works', () {
        final event = QuizEvent.failed(
          quizId: 'quiz-456',
          quizName: 'World Flags',
          categoryId: 'world',
          mode: 'endless',
          questionsAnswered: 25,
          totalQuestions: 0,
          correctAnswers: 24,
          scorePercentage: 96.0,
          duration: const Duration(minutes: 8),
          reason: 'first_wrong_answer',
        );

        expect(event, isA<QuizFailedEvent>());
      });
    });

    group('QuizPausedEvent', () {
      test('creates with correct event name', () {
        const event = QuizPausedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          currentQuestion: 5,
          totalQuestions: 20,
        );

        expect(event.eventName, equals('quiz_paused'));
      });

      test('includes all parameters', () {
        const event = QuizPausedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          currentQuestion: 10,
          totalQuestions: 20,
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'quiz_name': 'European Flags',
          'current_question': 10,
          'total_questions': 20,
        });
      });

      test('factory constructor works', () {
        final event = QuizEvent.paused(
          quizId: 'quiz-789',
          quizName: 'Asian Flags',
          currentQuestion: 15,
          totalQuestions: 30,
        );

        expect(event, isA<QuizPausedEvent>());
      });
    });

    group('QuizResumedEvent', () {
      test('creates with correct event name', () {
        const event = QuizResumedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          currentQuestion: 5,
          totalQuestions: 20,
          pauseDuration: Duration(seconds: 30),
        );

        expect(event.eventName, equals('quiz_resumed'));
      });

      test('includes pause duration in parameters', () {
        const event = QuizResumedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          currentQuestion: 10,
          totalQuestions: 20,
          pauseDuration: Duration(minutes: 2),
        );

        expect(event.parameters['pause_duration_seconds'], equals(120));
      });

      test('factory constructor works', () {
        final event = QuizEvent.resumed(
          quizId: 'quiz-456',
          quizName: 'World Flags',
          currentQuestion: 8,
          totalQuestions: 25,
          pauseDuration: const Duration(seconds: 45),
        );

        expect(event, isA<QuizResumedEvent>());
      });
    });

    group('QuizChallengeStartedEvent', () {
      test('creates with correct event name', () {
        const event = QuizChallengeStartedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          challengeId: 'challenge-001',
          challengeName: 'Speed Master',
          difficulty: 'hard',
          targetScore: 90,
        );

        expect(event.eventName, equals('quiz_challenge_started'));
      });

      test('includes all parameters', () {
        const event = QuizChallengeStartedEvent(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          challengeId: 'challenge-001',
          challengeName: 'Speed Master',
          difficulty: 'hard',
          targetScore: 90,
        );

        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'quiz_name': 'European Flags',
          'challenge_id': 'challenge-001',
          'challenge_name': 'Speed Master',
          'difficulty': 'hard',
          'target_score': 90,
        });
      });

      test('factory constructor works', () {
        final event = QuizEvent.challengeStarted(
          quizId: 'quiz-789',
          quizName: 'World Capitals',
          challengeId: 'challenge-002',
          challengeName: 'Perfect Run',
          difficulty: 'extreme',
          targetScore: 100,
        );

        expect(event, isA<QuizChallengeStartedEvent>());
      });
    });
  });

  group('QuizEvent base class', () {
    test('all quiz events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const QuizStartedEvent(
          quizId: 'q1',
          quizName: 'Test',
          categoryId: 'cat1',
          categoryName: 'Category',
          mode: 'standard',
          totalQuestions: 10,
        ),
        const QuizCompletedEvent(
          quizId: 'q1',
          quizName: 'Test',
          categoryId: 'cat1',
          mode: 'standard',
          totalQuestions: 10,
          correctAnswers: 8,
          incorrectAnswers: 2,
          skippedQuestions: 0,
          scorePercentage: 80.0,
          duration: Duration(minutes: 5),
          hintsUsed: 0,
        ),
        const QuizCancelledEvent(
          quizId: 'q1',
          quizName: 'Test',
          categoryId: 'cat1',
          mode: 'standard',
          questionsAnswered: 5,
          totalQuestions: 10,
          timeSpent: Duration(minutes: 2),
        ),
        const QuizPausedEvent(
          quizId: 'q1',
          quizName: 'Test',
          currentQuestion: 3,
          totalQuestions: 10,
        ),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });

    test('all quiz events have quizId', () {
      final events = <QuizEvent>[
        const QuizStartedEvent(
          quizId: 'quiz-test',
          quizName: 'Test',
          categoryId: 'cat1',
          categoryName: 'Category',
          mode: 'standard',
          totalQuestions: 10,
        ),
        const QuizPausedEvent(
          quizId: 'quiz-test',
          quizName: 'Test',
          currentQuestion: 3,
          totalQuestions: 10,
        ),
      ];

      for (final event in events) {
        expect(event.quizId, equals('quiz-test'));
      }
    });
  });
}
