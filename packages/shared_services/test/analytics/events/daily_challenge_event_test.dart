import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('DailyChallengeEvent', () {
    group('DailyChallengeStartedEvent', () {
      test('creates event with correct name and parameters', () {
        final event = DailyChallengeEvent.started(
          challengeId: 'challenge-2024-01-15',
          categoryId: 'eu',
          totalQuestions: 10,
          timeLimitSeconds: 120,
          currentStreak: 5,
        );

        expect(event.eventName, 'daily_challenge_started');
        expect(event.parameters, {
          'challenge_id': 'challenge-2024-01-15',
          'category_id': 'eu',
          'total_questions': 10,
          'time_limit_seconds': 120,
          'current_streak': 5,
          'has_time_limit': 1,
        });
      });

      test('creates event without time limit', () {
        final event = DailyChallengeEvent.started(
          challengeId: 'challenge-2024-01-15',
          categoryId: 'all',
          totalQuestions: 10,
          currentStreak: 0,
        );

        expect(event.parameters['has_time_limit'], 0);
        expect(event.parameters.containsKey('time_limit_seconds'), false);
      });
    });

    group('DailyChallengeCompletedEvent', () {
      test('creates event with correct name and all parameters', () {
        final event = DailyChallengeEvent.completed(
          challengeId: 'challenge-2024-01-15',
          categoryId: 'eu',
          score: 1500,
          correctCount: 10,
          totalQuestions: 10,
          completionTimeSeconds: 45,
          streakBonus: 50,
          timeBonus: 30,
          isPerfect: true,
          currentStreak: 6,
          isEarlyBird: true,
        );

        expect(event.eventName, 'daily_challenge_completed');
        expect(event.parameters['challenge_id'], 'challenge-2024-01-15');
        expect(event.parameters['category_id'], 'eu');
        expect(event.parameters['score'], 1500);
        expect(event.parameters['correct_count'], 10);
        expect(event.parameters['total_questions'], 10);
        expect(event.parameters['score_percentage'], 100.0);
        expect(event.parameters['completion_time_seconds'], 45);
        expect(event.parameters['streak_bonus'], 50);
        expect(event.parameters['time_bonus'], 30);
        expect(event.parameters['is_perfect'], 1);
        expect(event.parameters['current_streak'], 6);
        expect(event.parameters['is_early_bird'], 1);
      });

      test('calculates correct score percentage', () {
        final event = DailyChallengeEvent.completed(
          challengeId: 'challenge-2024-01-15',
          categoryId: 'eu',
          score: 700,
          correctCount: 7,
          totalQuestions: 10,
          completionTimeSeconds: 60,
          streakBonus: 0,
          timeBonus: 0,
          isPerfect: false,
          currentStreak: 1,
          isEarlyBird: false,
        );

        expect(event.parameters['score_percentage'], 70.0);
        expect(event.parameters['is_perfect'], 0);
        expect(event.parameters['is_early_bird'], 0);
      });

      test('handles zero questions gracefully', () {
        final event = DailyChallengeEvent.completed(
          challengeId: 'challenge-2024-01-15',
          categoryId: 'eu',
          score: 0,
          correctCount: 0,
          totalQuestions: 0,
          completionTimeSeconds: 0,
          streakBonus: 0,
          timeBonus: 0,
          isPerfect: false,
          currentStreak: 0,
          isEarlyBird: false,
        );

        expect(event.parameters['score_percentage'], 0);
      });
    });

    group('DailyChallengeRankedEvent', () {
      test('creates event with correct name and parameters', () {
        final event = DailyChallengeEvent.ranked(
          challengeId: 'challenge-2024-01-15',
          rank: 1,
          totalParticipants: 100,
          score: 1500,
          isTopTen: true,
          isTopThree: true,
          isFirst: true,
        );

        expect(event.eventName, 'daily_challenge_ranked');
        expect(event.parameters['challenge_id'], 'challenge-2024-01-15');
        expect(event.parameters['rank'], 1);
        expect(event.parameters['total_participants'], 100);
        expect(event.parameters['score'], 1500);
        expect(event.parameters['percentile'], 100);
        expect(event.parameters['is_top_ten'], 1);
        expect(event.parameters['is_top_three'], 1);
        expect(event.parameters['is_first'], 1);
      });

      test('calculates correct percentile for middle rank', () {
        final event = DailyChallengeEvent.ranked(
          challengeId: 'challenge-2024-01-15',
          rank: 50,
          totalParticipants: 100,
          score: 800,
          isTopTen: false,
          isTopThree: false,
          isFirst: false,
        );

        expect(event.parameters['percentile'], 51);
        expect(event.parameters['is_top_ten'], 0);
        expect(event.parameters['is_top_three'], 0);
        expect(event.parameters['is_first'], 0);
      });

      test('handles zero participants gracefully', () {
        final event = DailyChallengeEvent.ranked(
          challengeId: 'challenge-2024-01-15',
          rank: 1,
          totalParticipants: 0,
          score: 1000,
          isTopTen: true,
          isTopThree: true,
          isFirst: true,
        );

        expect(event.parameters['percentile'], 0);
      });
    });

    group('DailyChallengeSkippedEvent', () {
      test('creates event with correct name and parameters', () {
        final event = DailyChallengeEvent.skipped(
          challengeId: 'challenge-2024-01-15',
          categoryId: 'as',
          currentStreak: 10,
        );

        expect(event.eventName, 'daily_challenge_skipped');
        expect(event.parameters['challenge_id'], 'challenge-2024-01-15');
        expect(event.parameters['category_id'], 'as');
        expect(event.parameters['current_streak'], 10);
        expect(event.parameters['streak_lost'], 1);
      });

      test('shows streak_lost as 0 when no streak', () {
        final event = DailyChallengeEvent.skipped(
          challengeId: 'challenge-2024-01-15',
          categoryId: 'as',
          currentStreak: 0,
        );

        expect(event.parameters['streak_lost'], 0);
      });
    });
  });
}
