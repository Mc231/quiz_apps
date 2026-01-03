import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/src/game/cloud_save_data.dart';

void main() {
  group('CloudSaveData', () {
    group('constructor', () {
      test('creates instance with all required fields', () {
        final now = DateTime.now();
        final data = CloudSaveData(
          version: 1,
          lastModified: now,
          unlockedAchievementIds: {'ach_1', 'ach_2'},
          highScores: {'category_1': 100, 'category_2': 85},
          perfectCounts: {'category_1': 5, 'category_2': 3},
          totalQuizzesCompleted: 50,
          longestStreak: 10,
        );

        expect(data.version, 1);
        expect(data.lastModified, now);
        expect(data.unlockedAchievementIds, {'ach_1', 'ach_2'});
        expect(data.highScores, {'category_1': 100, 'category_2': 85});
        expect(data.perfectCounts, {'category_1': 5, 'category_2': 3});
        expect(data.totalQuizzesCompleted, 50);
        expect(data.longestStreak, 10);
      });
    });

    group('empty factory', () {
      test('creates instance with default values', () {
        final data = CloudSaveData.empty();

        expect(data.version, cloudSaveSchemaVersion);
        expect(data.unlockedAchievementIds, isEmpty);
        expect(data.highScores, isEmpty);
        expect(data.perfectCounts, isEmpty);
        expect(data.totalQuizzesCompleted, 0);
        expect(data.longestStreak, 0);
      });
    });

    group('JSON serialization', () {
      test('toJson converts to correct format', () {
        final lastModified = DateTime.fromMillisecondsSinceEpoch(1704067200000);
        final data = CloudSaveData(
          version: 1,
          lastModified: lastModified,
          unlockedAchievementIds: {'ach_1', 'ach_2'},
          highScores: {'cat_1': 100},
          perfectCounts: {'cat_1': 5},
          totalQuizzesCompleted: 50,
          longestStreak: 10,
        );

        final json = data.toJson();

        expect(json['version'], 1);
        expect(json['lastModified'], 1704067200000);
        expect(json['unlockedAchievementIds'], containsAll(['ach_1', 'ach_2']));
        expect(json['highScores'], {'cat_1': 100});
        expect(json['perfectCounts'], {'cat_1': 5});
        expect(json['totalQuizzesCompleted'], 50);
        expect(json['longestStreak'], 10);
      });

      test('fromJson parses correctly', () {
        final json = {
          'version': 1,
          'lastModified': 1704067200000,
          'unlockedAchievementIds': ['ach_1', 'ach_2'],
          'highScores': {'cat_1': 100},
          'perfectCounts': {'cat_1': 5},
          'totalQuizzesCompleted': 50,
          'longestStreak': 10,
        };

        final data = CloudSaveData.fromJson(json);

        expect(data.version, 1);
        expect(data.lastModified,
            DateTime.fromMillisecondsSinceEpoch(1704067200000));
        expect(data.unlockedAchievementIds, {'ach_1', 'ach_2'});
        expect(data.highScores, {'cat_1': 100});
        expect(data.perfectCounts, {'cat_1': 5});
        expect(data.totalQuizzesCompleted, 50);
        expect(data.longestStreak, 10);
      });

      test('fromJson handles missing fields gracefully', () {
        final data = CloudSaveData.fromJson({});

        expect(data.version, cloudSaveSchemaVersion);
        expect(data.unlockedAchievementIds, isEmpty);
        expect(data.highScores, isEmpty);
        expect(data.perfectCounts, isEmpty);
        expect(data.totalQuizzesCompleted, 0);
        expect(data.longestStreak, 0);
      });

      test('roundtrip preserves data', () {
        final original = CloudSaveData(
          version: 1,
          lastModified: DateTime.fromMillisecondsSinceEpoch(1704067200000),
          unlockedAchievementIds: {'ach_1', 'ach_2', 'ach_3'},
          highScores: {'cat_1': 100, 'cat_2': 95},
          perfectCounts: {'cat_1': 5, 'cat_2': 3},
          totalQuizzesCompleted: 150,
          longestStreak: 25,
        );

        final json = original.toJson();
        final restored = CloudSaveData.fromJson(json);

        expect(restored.version, original.version);
        expect(restored.lastModified, original.lastModified);
        expect(restored.unlockedAchievementIds, original.unlockedAchievementIds);
        expect(restored.highScores, original.highScores);
        expect(restored.perfectCounts, original.perfectCounts);
        expect(restored.totalQuizzesCompleted, original.totalQuizzesCompleted);
        expect(restored.longestStreak, original.longestStreak);
      });
    });

    group('copyWith', () {
      test('copies with updated version', () {
        final original = CloudSaveData.empty();
        final copy = original.copyWith(version: 2);

        expect(copy.version, 2);
        expect(copy.unlockedAchievementIds, original.unlockedAchievementIds);
      });

      test('copies with updated achievements', () {
        final original = CloudSaveData.empty();
        final copy = original.copyWith(
          unlockedAchievementIds: {'new_ach'},
        );

        expect(copy.unlockedAchievementIds, {'new_ach'});
      });

      test('copies with updated high scores', () {
        final original = CloudSaveData.empty();
        final copy = original.copyWith(
          highScores: {'cat_1': 100},
        );

        expect(copy.highScores, {'cat_1': 100});
      });

      test('preserves unchanged fields', () {
        final original = CloudSaveData(
          version: 1,
          lastModified: DateTime.now(),
          unlockedAchievementIds: {'ach_1'},
          highScores: {'cat_1': 100},
          perfectCounts: {'cat_1': 5},
          totalQuizzesCompleted: 50,
          longestStreak: 10,
        );

        final copy = original.copyWith(longestStreak: 20);

        expect(copy.version, original.version);
        expect(copy.unlockedAchievementIds, original.unlockedAchievementIds);
        expect(copy.highScores, original.highScores);
        expect(copy.perfectCounts, original.perfectCounts);
        expect(copy.totalQuizzesCompleted, original.totalQuizzesCompleted);
        expect(copy.longestStreak, 20);
      });
    });

    group('computed properties', () {
      test('hasProgress returns false for empty data', () {
        final data = CloudSaveData.empty();
        expect(data.hasProgress, isFalse);
      });

      test('hasProgress returns true when achievements exist', () {
        final data = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1'},
        );
        expect(data.hasProgress, isTrue);
      });

      test('hasProgress returns true when high scores exist', () {
        final data = CloudSaveData.empty().copyWith(
          highScores: {'cat_1': 100},
        );
        expect(data.hasProgress, isTrue);
      });

      test('hasProgress returns true when quizzes completed', () {
        final data = CloudSaveData.empty().copyWith(
          totalQuizzesCompleted: 1,
        );
        expect(data.hasProgress, isTrue);
      });

      test('achievementCount returns correct count', () {
        final data = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1', 'ach_2', 'ach_3'},
        );
        expect(data.achievementCount, 3);
      });

      test('categoriesPlayed returns correct count', () {
        final data = CloudSaveData.empty().copyWith(
          highScores: {'cat_1': 100, 'cat_2': 95, 'cat_3': 80},
        );
        expect(data.categoriesPlayed, 3);
      });

      test('totalPerfectQuizzes sums all categories', () {
        final data = CloudSaveData.empty().copyWith(
          perfectCounts: {'cat_1': 5, 'cat_2': 3, 'cat_3': 2},
        );
        expect(data.totalPerfectQuizzes, 10);
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        final now = DateTime.fromMillisecondsSinceEpoch(1704067200000);
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
          lastModified: now,
          unlockedAchievementIds: {'ach_1'},
          highScores: {'cat_1': 100},
          perfectCounts: {'cat_1': 5},
          totalQuizzesCompleted: 50,
          longestStreak: 10,
        );

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('different instances are not equal', () {
        final data1 = CloudSaveData.empty();
        final data2 = data1.copyWith(longestStreak: 10);

        expect(data1, isNot(equals(data2)));
      });
    });

    group('toString', () {
      test('returns readable string', () {
        final data = CloudSaveData.empty().copyWith(
          unlockedAchievementIds: {'ach_1', 'ach_2'},
          highScores: {'cat_1': 100},
          totalQuizzesCompleted: 50,
          longestStreak: 10,
        );

        final str = data.toString();

        expect(str, contains('CloudSaveData'));
        expect(str, contains('achievements: 2'));
        expect(str, contains('categories: 1'));
        expect(str, contains('quizzes: 50'));
        expect(str, contains('longestStreak: 10'));
      });
    });
  });
}
