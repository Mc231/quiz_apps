import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('AchievementEvent', () {
    group('AchievementUnlockedEvent', () {
      test('creates with correct event name', () {
        const event = AchievementUnlockedEvent(
          achievementId: 'first_quiz',
          achievementName: 'First Quiz',
          achievementCategory: 'beginner',
          pointsAwarded: 100,
          totalPoints: 100,
          unlockedCount: 1,
          totalAchievements: 50,
        );

        expect(event.eventName, equals('achievement_unlocked'));
      });

      test('includes all required parameters', () {
        const event = AchievementUnlockedEvent(
          achievementId: 'perfect_score',
          achievementName: 'Perfect Score',
          achievementCategory: 'mastery',
          pointsAwarded: 500,
          totalPoints: 1500,
          unlockedCount: 10,
          totalAchievements: 50,
        );

        expect(event.parameters['achievement_id'], equals('perfect_score'));
        expect(event.parameters['achievement_name'], equals('Perfect Score'));
        expect(event.parameters['achievement_category'], equals('mastery'));
        expect(event.parameters['points_awarded'], equals(500));
        expect(event.parameters['total_points'], equals(1500));
        expect(event.parameters['unlocked_count'], equals(10));
        expect(event.parameters['total_achievements'], equals(50));
      });

      test('calculates unlock percentage correctly', () {
        const event = AchievementUnlockedEvent(
          achievementId: 'streak_5',
          achievementName: 'Streak Master',
          achievementCategory: 'streaks',
          pointsAwarded: 200,
          totalPoints: 800,
          unlockedCount: 25,
          totalAchievements: 100,
        );

        expect(event.parameters['unlock_percentage'], equals('25.0'));
      });

      test('handles zero total achievements', () {
        const event = AchievementUnlockedEvent(
          achievementId: 'test',
          achievementName: 'Test',
          achievementCategory: 'test',
          pointsAwarded: 0,
          totalPoints: 0,
          unlockedCount: 0,
          totalAchievements: 0,
        );

        expect(event.parameters['unlock_percentage'], equals('0.0'));
      });

      test('includes optional trigger quiz when provided', () {
        const event = AchievementUnlockedEvent(
          achievementId: 'europe_master',
          achievementName: 'Europe Master',
          achievementCategory: 'regional',
          pointsAwarded: 300,
          totalPoints: 1200,
          unlockedCount: 15,
          totalAchievements: 50,
          triggerQuizId: 'quiz-europe-123',
        );

        expect(event.parameters['trigger_quiz_id'], equals('quiz-europe-123'));
      });

      test('factory constructor works', () {
        final event = AchievementEvent.unlocked(
          achievementId: 'speedster',
          achievementName: 'Speedster',
          achievementCategory: 'speed',
          pointsAwarded: 150,
          totalPoints: 500,
          unlockedCount: 5,
          totalAchievements: 50,
        );

        expect(event, isA<AchievementUnlockedEvent>());
      });
    });

    group('AchievementNotificationShownEvent', () {
      test('creates with correct event name', () {
        const event = AchievementNotificationShownEvent(
          achievementId: 'first_quiz',
          achievementName: 'First Quiz',
          pointsAwarded: 100,
          displayDuration: Duration(seconds: 3),
        );

        expect(event.eventName, equals('achievement_notification_shown'));
      });

      test('includes display duration in milliseconds', () {
        const event = AchievementNotificationShownEvent(
          achievementId: 'streak_10',
          achievementName: 'Streak 10',
          pointsAwarded: 250,
          displayDuration: Duration(seconds: 5),
        );

        expect(event.parameters['display_duration_ms'], equals(5000));
      });

      test('factory constructor works', () {
        final event = AchievementEvent.notificationShown(
          achievementId: 'perfectionist',
          achievementName: 'Perfectionist',
          pointsAwarded: 500,
          displayDuration: const Duration(seconds: 4),
        );

        expect(event, isA<AchievementNotificationShownEvent>());
      });
    });

    group('AchievementNotificationTappedEvent', () {
      test('creates with correct event name', () {
        const event = AchievementNotificationTappedEvent(
          achievementId: 'first_quiz',
          achievementName: 'First Quiz',
          timeToTap: Duration(milliseconds: 1500),
        );

        expect(event.eventName, equals('achievement_notification_tapped'));
      });

      test('includes time to tap in milliseconds', () {
        const event = AchievementNotificationTappedEvent(
          achievementId: 'quick_learner',
          achievementName: 'Quick Learner',
          timeToTap: Duration(seconds: 2, milliseconds: 300),
        );

        expect(event.parameters['time_to_tap_ms'], equals(2300));
      });

      test('factory constructor works', () {
        final event = AchievementEvent.notificationTapped(
          achievementId: 'explorer',
          achievementName: 'Explorer',
          timeToTap: const Duration(milliseconds: 800),
        );

        expect(event, isA<AchievementNotificationTappedEvent>());
      });
    });

    group('AchievementDetailViewedEvent', () {
      test('creates with correct event name', () {
        const event = AchievementDetailViewedEvent(
          achievementId: 'first_quiz',
          achievementName: 'First Quiz',
          achievementCategory: 'beginner',
          isUnlocked: true,
        );

        expect(event.eventName, equals('achievement_detail_viewed'));
      });

      test('includes all required parameters', () {
        const event = AchievementDetailViewedEvent(
          achievementId: 'world_traveler',
          achievementName: 'World Traveler',
          achievementCategory: 'exploration',
          isUnlocked: false,
        );

        expect(event.parameters, {
          'achievement_id': 'world_traveler',
          'achievement_name': 'World Traveler',
          'achievement_category': 'exploration',
          'is_unlocked': false,
        });
      });

      test('includes optional progress when provided', () {
        const event = AchievementDetailViewedEvent(
          achievementId: 'quiz_100',
          achievementName: 'Quiz 100',
          achievementCategory: 'milestones',
          isUnlocked: false,
          progress: 0.75,
        );

        expect(event.parameters['progress'], equals(0.75));
      });

      test('factory constructor works', () {
        final event = AchievementEvent.detailViewed(
          achievementId: 'champion',
          achievementName: 'Champion',
          achievementCategory: 'elite',
          isUnlocked: true,
        );

        expect(event, isA<AchievementDetailViewedEvent>());
      });
    });

    group('AchievementFilteredEvent', () {
      test('creates with correct event name', () {
        const event = AchievementFilteredEvent(
          filterType: 'category',
          filterValue: 'beginner',
          resultCount: 10,
          totalCount: 50,
        );

        expect(event.eventName, equals('achievement_filtered'));
      });

      test('includes all parameters', () {
        const event = AchievementFilteredEvent(
          filterType: 'status',
          filterValue: 'unlocked',
          resultCount: 25,
          totalCount: 100,
        );

        expect(event.parameters, {
          'filter_type': 'status',
          'filter_value': 'unlocked',
          'result_count': 25,
          'total_count': 100,
        });
      });

      test('factory constructor works', () {
        final event = AchievementEvent.filtered(
          filterType: 'points',
          filterValue: 'high_value',
          resultCount: 5,
          totalCount: 50,
        );

        expect(event, isA<AchievementFilteredEvent>());
      });
    });
  });

  group('AchievementEvent base class', () {
    test('all achievement events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const AchievementUnlockedEvent(
          achievementId: 'test',
          achievementName: 'Test',
          achievementCategory: 'test',
          pointsAwarded: 100,
          totalPoints: 100,
          unlockedCount: 1,
          totalAchievements: 10,
        ),
        const AchievementNotificationShownEvent(
          achievementId: 'test',
          achievementName: 'Test',
          pointsAwarded: 100,
          displayDuration: Duration(seconds: 3),
        ),
        const AchievementNotificationTappedEvent(
          achievementId: 'test',
          achievementName: 'Test',
          timeToTap: Duration(seconds: 1),
        ),
        const AchievementDetailViewedEvent(
          achievementId: 'test',
          achievementName: 'Test',
          achievementCategory: 'test',
          isUnlocked: true,
        ),
        const AchievementFilteredEvent(
          filterType: 'category',
          filterValue: 'all',
          resultCount: 50,
          totalCount: 50,
        ),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });
  });
}
