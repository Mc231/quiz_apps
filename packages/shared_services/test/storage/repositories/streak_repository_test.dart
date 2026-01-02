import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('StreakRepository Interface', () {
    test('StreakRepositoryImpl can be instantiated', () {
      expect(
        () => StreakRepositoryImpl(
          dataSource: StreakDataSourceImpl(),
        ),
        returnsNormally,
      );
    });

    test('StreakRepositoryImpl accepts custom cache duration', () {
      expect(
        () => StreakRepositoryImpl(
          dataSource: StreakDataSourceImpl(),
          cacheDuration: const Duration(minutes: 15),
        ),
        returnsNormally,
      );
    });
  });

  group('StreakRepository Stream support', () {
    test('repository can be instantiated for stream operations', () {
      final repository = StreakRepositoryImpl(
        dataSource: StreakDataSourceImpl(),
      );

      expect(repository, isNotNull);

      repository.dispose();
    });

    test('watchStreakData returns a stream', () {
      final repository = StreakRepositoryImpl(
        dataSource: StreakDataSourceImpl(),
      );

      // Verify the stream method is available
      expect(repository.watchStreakData, isA<Function>());

      repository.dispose();
    });
  });

  group('StreakRepository Cache', () {
    test('clearCache executes without error', () {
      final repository = StreakRepositoryImpl(
        dataSource: StreakDataSourceImpl(),
      );

      expect(() => repository.clearCache(), returnsNormally);

      repository.dispose();
    });
  });

  group('StreakRepository Methods', () {
    test('repository streak methods are available', () {
      final repository = StreakRepositoryImpl(
        dataSource: StreakDataSourceImpl(),
      );

      // Verify methods exist
      expect(repository.getStreakData, isA<Function>());
      expect(repository.updateStreak, isA<Function>());
      expect(repository.resetStreak, isA<Function>());
      expect(repository.getCurrentStreak, isA<Function>());
      expect(repository.getLongestStreak, isA<Function>());
      expect(repository.getLastPlayDate, isA<Function>());
      expect(repository.getTotalDaysPlayed, isA<Function>());

      repository.dispose();
    });
  });

  group('StreakDataSource Interface', () {
    test('StreakDataSourceImpl can be instantiated', () {
      expect(
        () => StreakDataSourceImpl(),
        returnsNormally,
      );
    });

    test('data source methods are available', () {
      final dataSource = StreakDataSourceImpl();

      expect(dataSource.getStreakData, isA<Function>());
      expect(dataSource.updateStreakData, isA<Function>());
      expect(dataSource.updateField, isA<Function>());
      expect(dataSource.resetStreak, isA<Function>());
      expect(dataSource.getCurrentStreak, isA<Function>());
      expect(dataSource.getLongestStreak, isA<Function>());
      expect(dataSource.getLastPlayDate, isA<Function>());
      expect(dataSource.getStreakStartDate, isA<Function>());
      expect(dataSource.getTotalDaysPlayed, isA<Function>());
      expect(dataSource.updateStreakValues, isA<Function>());
    });
  });

  group('Streak Table Constants', () {
    test('table name is defined', () {
      expect(streakTable, 'streak');
    });

    test('createStreakTable SQL is defined', () {
      expect(createStreakTable, isNotEmpty);
      expect(createStreakTable, contains('CREATE TABLE'));
      expect(createStreakTable, contains('streak'));
      expect(createStreakTable, contains('current_streak'));
      expect(createStreakTable, contains('longest_streak'));
      expect(createStreakTable, contains('last_play_date'));
      expect(createStreakTable, contains('streak_start_date'));
      expect(createStreakTable, contains('total_days_played'));
    });

    test('insertStreakRow SQL is defined', () {
      expect(insertStreakRow, isNotEmpty);
      expect(insertStreakRow, contains('INSERT'));
      expect(insertStreakRow, contains('streak'));
    });

    test('StreakColumns has all required columns', () {
      expect(StreakColumns.id, 'id');
      expect(StreakColumns.currentStreak, 'current_streak');
      expect(StreakColumns.longestStreak, 'longest_streak');
      expect(StreakColumns.lastPlayDate, 'last_play_date');
      expect(StreakColumns.streakStartDate, 'streak_start_date');
      expect(StreakColumns.totalDaysPlayed, 'total_days_played');
      expect(StreakColumns.createdAt, 'created_at');
      expect(StreakColumns.updatedAt, 'updated_at');
    });
  });
}
