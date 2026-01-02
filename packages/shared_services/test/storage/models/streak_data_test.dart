import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StreakData', () {
    final now = DateTime.now();
    final streakStart = now.subtract(const Duration(days: 5));

    test('creates instance with required fields', () {
      const streak = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        totalDaysPlayed: 25,
      );

      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 10);
      expect(streak.totalDaysPlayed, 25);
      expect(streak.lastPlayDate, isNull);
      expect(streak.streakStartDate, isNull);
    });

    test('creates instance with all fields', () {
      final streak = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        lastPlayDate: now,
        streakStartDate: streakStart,
        totalDaysPlayed: 25,
      );

      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 10);
      expect(streak.lastPlayDate, now);
      expect(streak.streakStartDate, streakStart);
      expect(streak.totalDaysPlayed, 25);
    });

    group('empty factory', () {
      test('creates default empty streak', () {
        final streak = StreakData.empty();

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.lastPlayDate, isNull);
        expect(streak.streakStartDate, isNull);
        expect(streak.totalDaysPlayed, 0);
      });
    });

    group('computed properties', () {
      test('hasPlayedBefore returns true when lastPlayDate is set', () {
        final streak = StreakData(
          currentStreak: 1,
          longestStreak: 1,
          lastPlayDate: now,
          totalDaysPlayed: 1,
        );

        expect(streak.hasPlayedBefore, true);
      });

      test('hasPlayedBefore returns false when lastPlayDate is null', () {
        final streak = StreakData.empty();

        expect(streak.hasPlayedBefore, false);
      });

      test('hasActiveStreak returns true when currentStreak > 0', () {
        const streak = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          totalDaysPlayed: 20,
        );

        expect(streak.hasActiveStreak, true);
      });

      test('hasActiveStreak returns false when currentStreak is 0', () {
        final streak = StreakData.empty();

        expect(streak.hasActiveStreak, false);
      });
    });

    group('toMap', () {
      test('creates correct database map with all fields', () {
        final streak = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          lastPlayDate: now,
          streakStartDate: streakStart,
          totalDaysPlayed: 25,
        );

        final map = streak.toMap();

        expect(map['current_streak'], 5);
        expect(map['longest_streak'], 10);
        expect(
          map['last_play_date'],
          now.millisecondsSinceEpoch ~/ 1000,
        );
        expect(
          map['streak_start_date'],
          streakStart.millisecondsSinceEpoch ~/ 1000,
        );
        expect(map['total_days_played'], 25);
      });

      test('creates map with null dates when not set', () {
        const streak = StreakData(
          currentStreak: 0,
          longestStreak: 0,
          totalDaysPlayed: 0,
        );

        final map = streak.toMap();

        expect(map['current_streak'], 0);
        expect(map['longest_streak'], 0);
        expect(map['last_play_date'], isNull);
        expect(map['streak_start_date'], isNull);
        expect(map['total_days_played'], 0);
      });
    });

    group('fromMap', () {
      test('creates StreakData from database map', () {
        final map = {
          'current_streak': 5,
          'longest_streak': 10,
          'last_play_date': now.millisecondsSinceEpoch ~/ 1000,
          'streak_start_date': streakStart.millisecondsSinceEpoch ~/ 1000,
          'total_days_played': 25,
        };

        final streak = StreakData.fromMap(map);

        expect(streak.currentStreak, 5);
        expect(streak.longestStreak, 10);
        expect(streak.totalDaysPlayed, 25);
        // Dates are converted from seconds, so we check they're close
        expect(streak.lastPlayDate, isNotNull);
        expect(streak.streakStartDate, isNotNull);
      });

      test('handles null dates in map', () {
        final map = {
          'current_streak': 0,
          'longest_streak': 5,
          'last_play_date': null,
          'streak_start_date': null,
          'total_days_played': 10,
        };

        final streak = StreakData.fromMap(map);

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 5);
        expect(streak.lastPlayDate, isNull);
        expect(streak.streakStartDate, isNull);
        expect(streak.totalDaysPlayed, 10);
      });

      test('handles missing fields with defaults', () {
        final map = <String, dynamic>{};

        final streak = StreakData.fromMap(map);

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.lastPlayDate, isNull);
        expect(streak.streakStartDate, isNull);
        expect(streak.totalDaysPlayed, 0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated currentStreak', () {
        final original = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          lastPlayDate: now,
          streakStartDate: streakStart,
          totalDaysPlayed: 25,
        );

        final copy = original.copyWith(currentStreak: 6);

        expect(copy.currentStreak, 6);
        expect(copy.longestStreak, 10);
        expect(copy.lastPlayDate, now);
        expect(copy.streakStartDate, streakStart);
        expect(copy.totalDaysPlayed, 25);
      });

      test('creates copy with updated longestStreak', () {
        final original = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          totalDaysPlayed: 25,
        );

        final copy = original.copyWith(longestStreak: 15);

        expect(copy.currentStreak, 5);
        expect(copy.longestStreak, 15);
        expect(copy.totalDaysPlayed, 25);
      });

      test('creates copy with updated dates', () {
        final original = StreakData.empty();
        final newDate = DateTime.now();

        final copy = original.copyWith(
          lastPlayDate: newDate,
          streakStartDate: newDate,
        );

        expect(copy.lastPlayDate, newDate);
        expect(copy.streakStartDate, newDate);
      });

      test('clears lastPlayDate when clearLastPlayDate is true', () {
        final original = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          lastPlayDate: now,
          totalDaysPlayed: 25,
        );

        final copy = original.copyWith(clearLastPlayDate: true);

        expect(copy.lastPlayDate, isNull);
        expect(copy.currentStreak, 5);
      });

      test('clears streakStartDate when clearStreakStartDate is true', () {
        final original = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          streakStartDate: streakStart,
          totalDaysPlayed: 25,
        );

        final copy = original.copyWith(clearStreakStartDate: true);

        expect(copy.streakStartDate, isNull);
        expect(copy.currentStreak, 5);
      });
    });

    group('equality', () {
      test('two StreakData with same values are equal', () {
        final streak1 = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          lastPlayDate: now,
          streakStartDate: streakStart,
          totalDaysPlayed: 25,
        );

        final streak2 = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          lastPlayDate: now,
          streakStartDate: streakStart,
          totalDaysPlayed: 25,
        );

        expect(streak1, streak2);
        expect(streak1.hashCode, streak2.hashCode);
      });

      test('two StreakData with different values are not equal', () {
        final streak1 = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          totalDaysPlayed: 25,
        );

        final streak2 = StreakData(
          currentStreak: 6,
          longestStreak: 10,
          totalDaysPlayed: 25,
        );

        expect(streak1, isNot(streak2));
      });

      test('identical instances are equal', () {
        final streak = StreakData.empty();
        expect(streak == streak, true);
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const streak = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          totalDaysPlayed: 25,
        );

        final str = streak.toString();

        expect(str, contains('StreakData'));
        expect(str, contains('currentStreak: 5'));
        expect(str, contains('longestStreak: 10'));
        expect(str, contains('totalDaysPlayed: 25'));
      });
    });

    group('round-trip serialization', () {
      test('toMap and fromMap preserve all data', () {
        final original = StreakData(
          currentStreak: 7,
          longestStreak: 14,
          lastPlayDate: now,
          streakStartDate: streakStart,
          totalDaysPlayed: 30,
        );

        final map = original.toMap();
        final restored = StreakData.fromMap(map);

        expect(restored.currentStreak, original.currentStreak);
        expect(restored.longestStreak, original.longestStreak);
        expect(restored.totalDaysPlayed, original.totalDaysPlayed);
        // Dates have second precision in storage
        expect(
          restored.lastPlayDate?.millisecondsSinceEpoch,
          closeTo(now.millisecondsSinceEpoch, 1000),
        );
      });
    });
  });
}
