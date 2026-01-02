import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StreakEvent', () {
    group('StreakExtendedEvent', () {
      test('creates event with correct properties', () {
        final event = StreakEvent.extended(
          previousStreak: 6,
          newStreak: 7,
          isNewRecord: true,
          nextMilestone: 14,
        );

        expect(event, isA<StreakExtendedEvent>());
        expect((event as StreakExtendedEvent).previousStreak, 6);
        expect(event.newStreak, 7);
        expect(event.isNewRecord, isTrue);
        expect(event.nextMilestone, 14);
      });

      test('eventName is correct', () {
        final event = StreakEvent.extended(
          previousStreak: 6,
          newStreak: 7,
          isNewRecord: false,
        );

        expect(event.eventName, 'streak_extended');
      });

      test('parameters include required fields', () {
        final event = StreakEvent.extended(
          previousStreak: 6,
          newStreak: 7,
          isNewRecord: true,
          nextMilestone: 14,
        );

        final params = event.parameters;

        expect(params['previous_streak'], 6);
        expect(params['new_streak'], 7);
        expect(params['streak_change'], 1);
        expect(params['is_new_record'], 1);
        expect(params['next_milestone'], 14);
        expect(params['days_to_milestone'], 7);
      });

      test('parameters exclude optional fields when null', () {
        final event = StreakEvent.extended(
          previousStreak: 6,
          newStreak: 7,
          isNewRecord: false,
        );

        final params = event.parameters;

        expect(params.containsKey('next_milestone'), isFalse);
        expect(params.containsKey('days_to_milestone'), isFalse);
        expect(params['is_new_record'], 0);
      });
    });

    group('StreakBrokenEvent', () {
      test('creates event with correct properties', () {
        final event = StreakEvent.broken(
          lostStreak: 15,
          longestStreak: 30,
          daysSinceLastPlay: 2,
        );

        expect(event, isA<StreakBrokenEvent>());
        expect((event as StreakBrokenEvent).lostStreak, 15);
        expect(event.longestStreak, 30);
        expect(event.daysSinceLastPlay, 2);
      });

      test('eventName is correct', () {
        final event = StreakEvent.broken(
          lostStreak: 15,
          longestStreak: 30,
          daysSinceLastPlay: 2,
        );

        expect(event.eventName, 'streak_broken');
      });

      test('parameters include all fields', () {
        final event = StreakEvent.broken(
          lostStreak: 30,
          longestStreak: 30,
          daysSinceLastPlay: 3,
        );

        final params = event.parameters;

        expect(params['lost_streak'], 30);
        expect(params['longest_streak'], 30);
        expect(params['days_since_last_play'], 3);
        expect(params['was_personal_best'], 1);
      });

      test('was_personal_best is 0 when not personal best', () {
        final event = StreakEvent.broken(
          lostStreak: 15,
          longestStreak: 30,
          daysSinceLastPlay: 2,
        );

        expect(event.parameters['was_personal_best'], 0);
      });
    });

    group('StreakMilestoneReachedEvent', () {
      test('creates event with correct properties', () {
        final event = StreakEvent.milestoneReached(
          milestoneDay: 30,
          currentStreak: 30,
          isNewRecord: true,
          nextMilestone: 50,
        );

        expect(event, isA<StreakMilestoneReachedEvent>());
        expect((event as StreakMilestoneReachedEvent).milestoneDay, 30);
        expect(event.currentStreak, 30);
        expect(event.isNewRecord, isTrue);
        expect(event.nextMilestone, 50);
      });

      test('eventName is correct', () {
        final event = StreakEvent.milestoneReached(
          milestoneDay: 7,
          currentStreak: 7,
          isNewRecord: true,
        );

        expect(event.eventName, 'streak_milestone');
      });

      test('parameters include required fields', () {
        final event = StreakEvent.milestoneReached(
          milestoneDay: 30,
          currentStreak: 30,
          isNewRecord: true,
          nextMilestone: 50,
        );

        final params = event.parameters;

        expect(params['milestone_day'], 30);
        expect(params['current_streak'], 30);
        expect(params['is_new_record'], 1);
        expect(params['next_milestone'], 50);
      });

      test('parameters exclude next_milestone when null', () {
        final event = StreakEvent.milestoneReached(
          milestoneDay: 365,
          currentStreak: 365,
          isNewRecord: true,
        );

        final params = event.parameters;

        expect(params.containsKey('next_milestone'), isFalse);
      });
    });

    group('StreakRestoredEvent', () {
      test('creates event with correct properties', () {
        final event = StreakEvent.restored(
          restoredStreak: 25,
          restoreMethod: 'freeze_token',
        );

        expect(event, isA<StreakRestoredEvent>());
        expect((event as StreakRestoredEvent).restoredStreak, 25);
        expect(event.restoreMethod, 'freeze_token');
      });

      test('eventName is correct', () {
        final event = StreakEvent.restored(
          restoredStreak: 10,
          restoreMethod: 'ad_watch',
        );

        expect(event.eventName, 'streak_restored');
      });

      test('parameters include all fields', () {
        final event = StreakEvent.restored(
          restoredStreak: 25,
          restoreMethod: 'freeze_token',
        );

        final params = event.parameters;

        expect(params['restored_streak'], 25);
        expect(params['restore_method'], 'freeze_token');
      });
    });

    group('inheritance', () {
      test('all event types extend AnalyticsEvent', () {
        final extended = StreakEvent.extended(
          previousStreak: 6,
          newStreak: 7,
          isNewRecord: false,
        );
        final broken = StreakEvent.broken(
          lostStreak: 10,
          longestStreak: 10,
          daysSinceLastPlay: 2,
        );
        final milestone = StreakEvent.milestoneReached(
          milestoneDay: 7,
          currentStreak: 7,
          isNewRecord: true,
        );
        final restored = StreakEvent.restored(
          restoredStreak: 5,
          restoreMethod: 'freeze_token',
        );

        expect(extended, isA<AnalyticsEvent>());
        expect(broken, isA<AnalyticsEvent>());
        expect(milestone, isA<AnalyticsEvent>());
        expect(restored, isA<AnalyticsEvent>());
      });

      test('all event types extend StreakEvent', () {
        final extended = StreakEvent.extended(
          previousStreak: 6,
          newStreak: 7,
          isNewRecord: false,
        );
        final broken = StreakEvent.broken(
          lostStreak: 10,
          longestStreak: 10,
          daysSinceLastPlay: 2,
        );
        final milestone = StreakEvent.milestoneReached(
          milestoneDay: 7,
          currentStreak: 7,
          isNewRecord: true,
        );
        final restored = StreakEvent.restored(
          restoredStreak: 5,
          restoreMethod: 'freeze_token',
        );

        expect(extended, isA<StreakEvent>());
        expect(broken, isA<StreakEvent>());
        expect(milestone, isA<StreakEvent>());
        expect(restored, isA<StreakEvent>());
      });
    });
  });
}
