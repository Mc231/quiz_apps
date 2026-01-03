import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/src/game/cloud_save_conflict_resolver.dart';
import 'package:shared_services/src/game/cloud_save_data.dart';

void main() {
  group('CloudSaveConflictResolver', () {
    late CloudSaveConflictResolver resolver;

    setUp(() {
      resolver = const CloudSaveConflictResolver();
    });

    group('resolve', () {
      test('merges achievements using union', () {
        final local = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: {'ach_1', 'ach_2'},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final remote = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: {'ach_2', 'ach_3'},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final merged = resolver.resolve(local, remote);

        expect(merged.unlockedAchievementIds, {'ach_1', 'ach_2', 'ach_3'});
      });

      test('takes maximum high scores per category', () {
        final local = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: {'cat_1': 100, 'cat_2': 80},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final remote = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: {'cat_1': 90, 'cat_2': 95, 'cat_3': 75},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final merged = resolver.resolve(local, remote);

        expect(merged.highScores['cat_1'], 100); // local is higher
        expect(merged.highScores['cat_2'], 95); // remote is higher
        expect(merged.highScores['cat_3'], 75); // only in remote
      });

      test('takes maximum perfect counts per category', () {
        final local = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: {'cat_1': 5, 'cat_2': 3},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final remote = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: {'cat_1': 3, 'cat_2': 7, 'cat_3': 2},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final merged = resolver.resolve(local, remote);

        expect(merged.perfectCounts['cat_1'], 5); // local is higher
        expect(merged.perfectCounts['cat_2'], 7); // remote is higher
        expect(merged.perfectCounts['cat_3'], 2); // only in remote
      });

      test('takes maximum total quizzes completed', () {
        final local = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 100,
          longestStreak: 0,
        );

        final remote = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 150,
          longestStreak: 0,
        );

        final merged = resolver.resolve(local, remote);

        expect(merged.totalQuizzesCompleted, 150);
      });

      test('takes maximum longest streak', () {
        final local = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 25,
        );

        final remote = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 20,
        );

        final merged = resolver.resolve(local, remote);

        expect(merged.longestStreak, 25);
      });

      test('takes higher version', () {
        final local = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final remote = CloudSaveData(
          version: 2,
          lastModified: DateTime.now(),
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final merged = resolver.resolve(local, remote);

        expect(merged.version, 2);
      });

      test('sets lastModified to now', () {
        final past = DateTime.now().subtract(const Duration(days: 1));
        final local = CloudSaveData(
          version: 1,
          lastModified: past,
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final remote = CloudSaveData(
          version: 1,
          lastModified: past,
          unlockedAchievementIds: const {},
          highScores: const {},
          perfectCounts: const {},
          totalQuizzesCompleted: 0,
          longestStreak: 0,
        );

        final merged = resolver.resolve(local, remote);

        // Merged lastModified should be close to now
        final diff = DateTime.now().difference(merged.lastModified);
        expect(diff.inSeconds, lessThan(5));
      });

      test('comprehensive merge preserves best of both', () {
        final local = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: {'ach_1', 'ach_2'},
          highScores: {'cat_1': 100, 'cat_2': 80},
          perfectCounts: {'cat_1': 5},
          totalQuizzesCompleted: 100,
          longestStreak: 25,
        );

        final remote = CloudSaveData(
          version: 2,
          lastModified: DateTime.now(),
          unlockedAchievementIds: {'ach_2', 'ach_3'},
          highScores: {'cat_2': 95, 'cat_3': 70},
          perfectCounts: {'cat_2': 3},
          totalQuizzesCompleted: 80,
          longestStreak: 30,
        );

        final merged = resolver.resolve(local, remote);

        expect(merged.version, 2); // higher version
        expect(merged.unlockedAchievementIds, {'ach_1', 'ach_2', 'ach_3'}); // union
        expect(merged.highScores, {'cat_1': 100, 'cat_2': 95, 'cat_3': 70}); // max
        expect(merged.perfectCounts, {'cat_1': 5, 'cat_2': 3}); // max
        expect(merged.totalQuizzesCompleted, 100); // max
        expect(merged.longestStreak, 30); // max
      });
    });

    group('hasConflicts', () {
      test('returns false for identical data', () {
        final now = DateTime.now();
        final data1 = CloudSaveData(
          version: 1,
          lastModified: now,
          unlockedAchievementIds: {'ach_1'},
          highScores: {'cat_1': 100},
          perfectCounts: {'cat_1': 5},
          totalQuizzesCompleted: 50,
          longestStreak: 10,
        );

        final data2 = CloudSaveData(
          version: 1,
          lastModified: now.add(const Duration(minutes: 1)), // different time is OK
          unlockedAchievementIds: {'ach_1'},
          highScores: {'cat_1': 100},
          perfectCounts: {'cat_1': 5},
          totalQuizzesCompleted: 50,
          longestStreak: 10,
        );

        expect(resolver.hasConflicts(data1, data2), isFalse);
      });

      test('returns true for different achievements', () {
        final data1 = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1'},
        );
        final data2 = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_2'},
        );

        expect(resolver.hasConflicts(data1, data2), isTrue);
      });

      test('returns true for different high scores', () {
        final data1 = CloudSaveData.empty().copyWith(
          highScores: {'cat_1': 100},
        );
        final data2 = CloudSaveData.empty().copyWith(
          highScores: {'cat_1': 95},
        );

        expect(resolver.hasConflicts(data1, data2), isTrue);
      });

      test('returns true for different perfect counts', () {
        final data1 = CloudSaveData.empty().copyWith(
          perfectCounts: {'cat_1': 5},
        );
        final data2 = CloudSaveData.empty().copyWith(
          perfectCounts: {'cat_1': 3},
        );

        expect(resolver.hasConflicts(data1, data2), isTrue);
      });

      test('returns true for different total quizzes', () {
        final data1 = CloudSaveData.empty().copyWith(
          totalQuizzesCompleted: 100,
        );
        final data2 = CloudSaveData.empty().copyWith(
          totalQuizzesCompleted: 80,
        );

        expect(resolver.hasConflicts(data1, data2), isTrue);
      });

      test('returns true for different longest streak', () {
        final data1 = CloudSaveData.empty().copyWith(
          longestStreak: 25,
        );
        final data2 = CloudSaveData.empty().copyWith(
          longestStreak: 20,
        );

        expect(resolver.hasConflicts(data1, data2), isTrue);
      });
    });

    group('diff', () {
      test('returns empty diff for identical data', () {
        final data1 = CloudSaveData.empty();
        final data2 = CloudSaveData.empty();

        final diff = resolver.diff(data1, data2);

        expect(diff.isEmpty, isTrue);
      });

      test('identifies new local achievements', () {
        final local = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1', 'ach_2'},
        );
        final remote = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_2'},
        );

        final diff = resolver.diff(local, remote);

        expect(diff.newLocalAchievements, {'ach_1'});
        expect(diff.newRemoteAchievements, isEmpty);
      });

      test('identifies new remote achievements', () {
        final local = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1'},
        );
        final remote = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1', 'ach_2'},
        );

        final diff = resolver.diff(local, remote);

        expect(diff.newLocalAchievements, isEmpty);
        expect(diff.newRemoteAchievements, {'ach_2'});
      });

      test('identifies categories where local has better scores', () {
        final local = CloudSaveData.empty().copyWith(
          highScores: {'cat_1': 100, 'cat_2': 80},
        );
        final remote = CloudSaveData.empty().copyWith(
          highScores: {'cat_1': 90, 'cat_2': 95},
        );

        final diff = resolver.diff(local, remote);

        expect(diff.localBetterScoreCategories, ['cat_1']);
        expect(diff.remoteBetterScoreCategories, ['cat_2']);
      });

      test('reports different total quizzes', () {
        final local = CloudSaveData.empty().copyWith(
          totalQuizzesCompleted: 100,
        );
        final remote = CloudSaveData.empty().copyWith(
          totalQuizzesCompleted: 80,
        );

        final diff = resolver.diff(local, remote);

        expect(diff.localQuizzesCompleted, 100);
        expect(diff.remoteQuizzesCompleted, 80);
      });

      test('reports different longest streaks', () {
        final local = CloudSaveData.empty().copyWith(
          longestStreak: 25,
        );
        final remote = CloudSaveData.empty().copyWith(
          longestStreak: 30,
        );

        final diff = resolver.diff(local, remote);

        expect(diff.localLongestStreak, 25);
        expect(diff.remoteLongestStreak, 30);
      });

      test('toString provides readable output', () {
        final local = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1'},
          highScores: {'cat_1': 100},
          totalQuizzesCompleted: 100,
          longestStreak: 25,
        );
        final remote = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_2'},
          highScores: {'cat_1': 90},
          totalQuizzesCompleted: 80,
          longestStreak: 30,
        );

        final diff = resolver.diff(local, remote);
        final str = diff.toString();

        expect(str, contains('CloudSaveDiff'));
        expect(str, contains('New local achievements'));
        expect(str, contains('New remote achievements'));
      });
    });
  });
}
