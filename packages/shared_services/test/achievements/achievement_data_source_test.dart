import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('AchievementDataSource Interface', () {
    test('AchievementDataSourceImpl can be instantiated', () {
      expect(
        () => AchievementDataSourceImpl(),
        returnsNormally,
      );
    });
  });

  group('UnlockedAchievement integration', () {
    test('UnlockedAchievement.create creates valid record', () {
      final achievement = UnlockedAchievement.create(
        id: 'ach_123',
        achievementId: 'first_quiz',
        progress: 1,
      );

      expect(achievement.id, 'ach_123');
      expect(achievement.achievementId, 'first_quiz');
      expect(achievement.progress, 1);
      expect(achievement.notified, false);
      expect(achievement.unlockedAt, isNotNull);
      expect(achievement.createdAt, isNotNull);
    });

    test('UnlockedAchievement toMap and fromMap are symmetric', () {
      final now = DateTime.now();
      final achievement = UnlockedAchievement(
        id: 'ach_456',
        achievementId: 'quizzes_10',
        unlockedAt: now,
        progress: 10,
        notified: true,
        createdAt: now,
      );

      final map = achievement.toMap();
      final restored = UnlockedAchievement.fromMap(map);

      expect(restored.id, achievement.id);
      expect(restored.achievementId, achievement.achievementId);
      expect(restored.progress, achievement.progress);
      expect(restored.notified, achievement.notified);
    });

    test('UnlockedAchievement copyWith updates specified fields', () {
      final achievement = UnlockedAchievement.create(
        id: 'ach_789',
        achievementId: 'perfect_5',
        progress: 5,
      );

      final updated = achievement.copyWith(notified: true);

      expect(updated.notified, true);
      expect(updated.id, achievement.id);
      expect(updated.achievementId, achievement.achievementId);
      expect(updated.progress, achievement.progress);
    });

    test('UnlockedAchievement markAsNotified returns updated copy', () {
      final achievement = UnlockedAchievement.create(
        id: 'ach_abc',
        achievementId: 'streak_10',
        progress: 10,
      );

      expect(achievement.notified, false);

      final notified = achievement.markAsNotified();

      expect(notified.notified, true);
      expect(notified.id, achievement.id);
      expect(achievement.notified, false); // Original unchanged
    });

    test('UnlockedAchievement equality is based on id', () {
      final now = DateTime.now();
      final achievement1 = UnlockedAchievement(
        id: 'same_id',
        achievementId: 'first_quiz',
        unlockedAt: now,
        progress: 1,
        notified: false,
        createdAt: now,
      );

      final achievement2 = UnlockedAchievement(
        id: 'same_id',
        achievementId: 'different_achievement',
        unlockedAt: now.add(const Duration(hours: 1)),
        progress: 5,
        notified: true,
        createdAt: now,
      );

      expect(achievement1, equals(achievement2));
      expect(achievement1.hashCode, equals(achievement2.hashCode));
    });

    test('UnlockedAchievement toMap stores timestamps correctly', () {
      final now = DateTime.now();
      final achievement = UnlockedAchievement(
        id: 'ach_time',
        achievementId: 'time_test',
        unlockedAt: now,
        progress: 1,
        notified: false,
        createdAt: now,
      );

      final map = achievement.toMap();

      // Timestamps should be in seconds (Unix timestamp)
      expect(map['unlocked_at'], isA<int>());
      expect(map['created_at'], isA<int>());
      expect(map['unlocked_at'], equals(now.millisecondsSinceEpoch ~/ 1000));
    });

    test('UnlockedAchievement fromMap reads timestamps correctly', () {
      final timestamp = 1703433600; // 2023-12-24 12:00:00 UTC
      final map = {
        'id': 'ach_time',
        'achievement_id': 'time_test',
        'unlocked_at': timestamp,
        'progress': 1,
        'notified': 0,
        'created_at': timestamp,
      };

      final achievement = UnlockedAchievement.fromMap(map);

      expect(
        achievement.unlockedAt.millisecondsSinceEpoch,
        equals(timestamp * 1000),
      );
    });

    test('UnlockedAchievement fromMap handles notified as int', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final mapNotified = {
        'id': 'ach_1',
        'achievement_id': 'test',
        'unlocked_at': now,
        'progress': 1,
        'notified': 1,
        'created_at': now,
      };

      final mapNotNotified = {
        'id': 'ach_2',
        'achievement_id': 'test2',
        'unlocked_at': now,
        'progress': 1,
        'notified': 0,
        'created_at': now,
      };

      expect(UnlockedAchievement.fromMap(mapNotified).notified, true);
      expect(UnlockedAchievement.fromMap(mapNotNotified).notified, false);
    });

    test('UnlockedAchievement toString returns meaningful string', () {
      final achievement = UnlockedAchievement.create(
        id: 'ach_str',
        achievementId: 'first_quiz',
        progress: 1,
      );

      final str = achievement.toString();

      expect(str, contains('UnlockedAchievement'));
      expect(str, contains('ach_str'));
      expect(str, contains('first_quiz'));
    });
  });
}
