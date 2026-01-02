import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StreakService', () {
    group('StreakServiceImpl instantiation', () {
      test('can be instantiated with repository', () {
        final repository = _MockStreakRepository();

        expect(
          () => StreakServiceImpl(repository: repository),
          returnsNormally,
        );
      });

      test('can be instantiated with custom config', () {
        final repository = _MockStreakRepository();

        expect(
          () => StreakServiceImpl(
            repository: repository,
            config: const StreakConfig(gracePeriodHours: 4),
          ),
          returnsNormally,
        );
      });

      test('can be instantiated with custom clock', () {
        final repository = _MockStreakRepository();
        final fixedTime = DateTime(2025, 1, 15, 12, 0);

        expect(
          () => StreakServiceImpl(
            repository: repository,
            clock: () => fixedTime,
          ),
          returnsNormally,
        );
      });
    });

    group('getStreakStatus with time mocking', () {
      test('returns none when no play history', () async {
        final repository = _MockStreakRepository(
          streakData: StreakData.empty(),
        );
        final service = StreakServiceImpl(repository: repository);

        final status = await service.getStreakStatus();

        expect(status, StreakStatus.none);
      });

      test('returns active when played today', () async {
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: today,
            streakStartDate: DateTime(2025, 1, 10),
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final status = await service.getStreakStatus();

        expect(status, StreakStatus.active);
      });

      test('returns atRisk when played yesterday', () async {
        final yesterday = DateTime(2025, 1, 14, 12, 0);
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: yesterday,
            streakStartDate: DateTime(2025, 1, 10),
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final status = await service.getStreakStatus();

        expect(status, StreakStatus.atRisk);
      });

      test('returns broken when missed more than one day', () async {
        final twoDaysAgo = DateTime(2025, 1, 13, 12, 0);
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: twoDaysAgo,
            streakStartDate: DateTime(2025, 1, 8),
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final status = await service.getStreakStatus();

        expect(status, StreakStatus.broken);
      });
    });

    group('getCurrentStreak with time mocking', () {
      test('returns 0 when no play history', () async {
        final repository = _MockStreakRepository(
          streakData: StreakData.empty(),
        );
        final service = StreakServiceImpl(repository: repository);

        final streak = await service.getCurrentStreak();

        expect(streak, 0);
      });

      test('returns stored streak when played today', () async {
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 7,
            longestStreak: 10,
            lastPlayDate: today,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final streak = await service.getCurrentStreak();

        expect(streak, 7);
      });

      test('returns stored streak when played yesterday (at risk)', () async {
        final yesterday = DateTime(2025, 1, 14, 12, 0);
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 7,
            longestStreak: 10,
            lastPlayDate: yesterday,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final streak = await service.getCurrentStreak();

        expect(streak, 7);
      });

      test('returns 0 when streak is broken', () async {
        final twoDaysAgo = DateTime(2025, 1, 13, 12, 0);
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 7,
            longestStreak: 10,
            lastPlayDate: twoDaysAgo,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final streak = await service.getCurrentStreak();

        expect(streak, 0);
      });
    });

    group('getDaysUntilStreakLost', () {
      test('returns null when no streak', () async {
        final repository = _MockStreakRepository(
          streakData: StreakData.empty(),
        );
        final service = StreakServiceImpl(repository: repository);

        final days = await service.getDaysUntilStreakLost();

        expect(days, null);
      });

      test('returns 1 when played today', () async {
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: today,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final days = await service.getDaysUntilStreakLost();

        expect(days, 1);
      });

      test('returns 0 when at risk (played yesterday)', () async {
        final yesterday = DateTime(2025, 1, 14, 12, 0);
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: yesterday,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final days = await service.getDaysUntilStreakLost();

        expect(days, 0);
      });

      test('returns null when streak is broken', () async {
        final twoDaysAgo = DateTime(2025, 1, 13, 12, 0);
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: twoDaysAgo,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          clock: () => today,
        );

        final days = await service.getDaysUntilStreakLost();

        expect(days, null);
      });
    });

    group('grace period', () {
      test('treats early morning as previous day with grace period', () async {
        // Last played at 11 PM yesterday
        final lastNight = DateTime(2025, 1, 14, 23, 0);
        // Current time is 3 AM (within 4-hour grace period)
        final earlyMorning = DateTime(2025, 1, 15, 3, 0);

        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: lastNight,
            totalDaysPlayed: 20,
          ),
        );

        final service = StreakServiceImpl(
          repository: repository,
          config: const StreakConfig(gracePeriodHours: 4),
          clock: () => earlyMorning,
        );

        // With 4-hour grace period, 3 AM is treated as still "yesterday"
        // so playing at 11 PM yesterday is same effective day
        final status = await service.getStreakStatus();

        expect(status, StreakStatus.active);
      });

      test('after grace period, treats as new day', () async {
        final lastNight = DateTime(2025, 1, 14, 23, 0);
        // Current time is 5 AM (after 4-hour grace period)
        final afterGrace = DateTime(2025, 1, 15, 5, 0);

        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: lastNight,
            totalDaysPlayed: 20,
          ),
        );

        final service = StreakServiceImpl(
          repository: repository,
          config: const StreakConfig(gracePeriodHours: 4),
          clock: () => afterGrace,
        );

        // After grace period, it's a new day, so status is atRisk
        final status = await service.getStreakStatus();

        expect(status, StreakStatus.atRisk);
      });
    });

    group('milestones', () {
      test('getNextMilestone returns correct value', () async {
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastPlayDate: today,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          config: const StreakConfig(streakMilestones: [7, 30, 100]),
          clock: () => today,
        );

        final next = await service.getNextMilestone();

        expect(next, 7);
      });

      test('getMilestoneProgress returns correct value', () async {
        final today = DateTime(2025, 1, 15, 12, 0);
        final repository = _MockStreakRepository(
          streakData: StreakData(
            currentStreak: 3,
            longestStreak: 10,
            lastPlayDate: today,
            totalDaysPlayed: 20,
          ),
        );
        final service = StreakServiceImpl(
          repository: repository,
          config: const StreakConfig(streakMilestones: [7, 30, 100]),
          clock: () => today,
        );

        final progress = await service.getMilestoneProgress();

        // 3 out of 7 = ~0.43
        expect(progress, closeTo(3 / 7, 0.01));
      });
    });

    group('StreakActivityResult', () {
      test('hasChange returns true when streak changed', () {
        const result = StreakActivityResult(
          previousStreak: 5,
          newStreak: 6,
          isNewDay: true,
          milestoneReached: null,
          isNewRecord: false,
        );

        expect(result.hasChange, true);
        expect(result.streakChange, 1);
      });

      test('hasChange returns false when streak unchanged', () {
        const result = StreakActivityResult(
          previousStreak: 5,
          newStreak: 5,
          isNewDay: false,
          milestoneReached: null,
          isNewRecord: false,
        );

        expect(result.hasChange, false);
        expect(result.streakChange, 0);
      });

      test('can represent milestone reached', () {
        const result = StreakActivityResult(
          previousStreak: 6,
          newStreak: 7,
          isNewDay: true,
          milestoneReached: 7,
          isNewRecord: false,
        );

        expect(result.milestoneReached, 7);
      });

      test('can represent new record', () {
        const result = StreakActivityResult(
          previousStreak: 9,
          newStreak: 10,
          isNewDay: true,
          milestoneReached: null,
          isNewRecord: true,
        );

        expect(result.isNewRecord, true);
      });
    });

    group('service lifecycle', () {
      test('dispose can be called', () {
        final repository = _MockStreakRepository();
        final service = StreakServiceImpl(repository: repository);

        expect(() => service.dispose(), returnsNormally);
      });

      test('watchStreakData returns stream', () {
        final repository = _MockStreakRepository();
        final service = StreakServiceImpl(repository: repository);

        expect(service.watchStreakData(), isA<Stream<StreakData>>());

        service.dispose();
      });
    });
  });
}

/// Mock implementation of StreakRepository for testing.
class _MockStreakRepository implements StreakRepository {
  _MockStreakRepository({
    StreakData? streakData,
  }) : _streakData = streakData ?? StreakData.empty();

  StreakData _streakData;
  final _controller = StreamController<StreakData>.broadcast();

  @override
  Future<StreakData> getStreakData() async => _streakData;

  @override
  Future<int> getCurrentStreak() async => _streakData.currentStreak;

  @override
  Future<int> getLongestStreak() async => _streakData.longestStreak;

  @override
  Future<DateTime?> getLastPlayDate() async => _streakData.lastPlayDate;

  @override
  Future<int> getTotalDaysPlayed() async => _streakData.totalDaysPlayed;

  @override
  Future<void> updateStreak(DateTime playDate) async {
    // Simplified mock implementation
    final previousData = _streakData;
    final today = DateTime(playDate.year, playDate.month, playDate.day);

    if (previousData.lastPlayDate == null) {
      _streakData = StreakData(
        currentStreak: 1,
        longestStreak: 1,
        lastPlayDate: today,
        streakStartDate: today,
        totalDaysPlayed: 1,
      );
    } else {
      final lastNormalized = DateTime(
        previousData.lastPlayDate!.year,
        previousData.lastPlayDate!.month,
        previousData.lastPlayDate!.day,
      );
      final diff = today.difference(lastNormalized).inDays;

      if (diff == 0) {
        // Same day, no change
        return;
      } else if (diff == 1) {
        // Consecutive day
        final newStreak = previousData.currentStreak + 1;
        _streakData = previousData.copyWith(
          currentStreak: newStreak,
          longestStreak:
              newStreak > previousData.longestStreak ? newStreak : null,
          lastPlayDate: today,
          totalDaysPlayed: previousData.totalDaysPlayed + 1,
        );
      } else {
        // Streak broken, start new
        _streakData = previousData.copyWith(
          currentStreak: 1,
          lastPlayDate: today,
          streakStartDate: today,
          totalDaysPlayed: previousData.totalDaysPlayed + 1,
        );
      }
    }

    _controller.add(_streakData);
  }

  @override
  Future<void> resetStreak() async {
    _streakData = _streakData.copyWith(
      currentStreak: 0,
      clearLastPlayDate: true,
      clearStreakStartDate: true,
    );
    _controller.add(_streakData);
  }

  @override
  Stream<StreakData> watchStreakData() => _controller.stream;

  @override
  void clearCache() {}

  @override
  void dispose() {
    _controller.close();
  }
}
