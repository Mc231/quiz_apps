import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('UnlockedAchievement', () {
    late DateTime testTime;
    late UnlockedAchievement testAchievement;

    setUp(() {
      testTime = DateTime(2024, 1, 15, 10, 30, 0);
      testAchievement = UnlockedAchievement(
        id: 'uuid-123',
        achievementId: 'first_quiz',
        unlockedAt: testTime,
        progress: 1,
        notified: false,
        createdAt: testTime,
      );
    });

    test('creates with required fields', () {
      expect(testAchievement.id, 'uuid-123');
      expect(testAchievement.achievementId, 'first_quiz');
      expect(testAchievement.unlockedAt, testTime);
      expect(testAchievement.progress, 1);
      expect(testAchievement.notified, false);
      expect(testAchievement.createdAt, testTime);
    });

    group('factory create', () {
      test('creates new unlocked achievement', () {
        final achievement = UnlockedAchievement.create(
          id: 'new-uuid',
          achievementId: 'quizzes_10',
          progress: 10,
        );

        expect(achievement.id, 'new-uuid');
        expect(achievement.achievementId, 'quizzes_10');
        expect(achievement.progress, 10);
        expect(achievement.notified, false);
        // unlockedAt and createdAt should be close to now
        expect(
          achievement.unlockedAt.difference(DateTime.now()).inSeconds.abs(),
          lessThan(2),
        );
      });
    });

    group('toMap / fromMap', () {
      test('serializes to map correctly', () {
        final map = testAchievement.toMap();

        expect(map['id'], 'uuid-123');
        expect(map['achievement_id'], 'first_quiz');
        expect(map['unlocked_at'], testTime.millisecondsSinceEpoch ~/ 1000);
        expect(map['progress'], 1);
        expect(map['notified'], 0);
        expect(map['created_at'], testTime.millisecondsSinceEpoch ~/ 1000);
      });

      test('deserializes from map correctly', () {
        final map = {
          'id': 'uuid-456',
          'achievement_id': 'streak_10',
          'unlocked_at': 1705312200,
          'progress': 10,
          'notified': 1,
          'created_at': 1705312200,
        };

        final achievement = UnlockedAchievement.fromMap(map);

        expect(achievement.id, 'uuid-456');
        expect(achievement.achievementId, 'streak_10');
        expect(achievement.progress, 10);
        expect(achievement.notified, true);
      });

      test('handles null progress in map', () {
        final map = {
          'id': 'uuid-789',
          'achievement_id': 'test',
          'unlocked_at': 1705312200,
          'progress': null,
          'notified': 0,
          'created_at': 1705312200,
        };

        final achievement = UnlockedAchievement.fromMap(map);
        expect(achievement.progress, 0);
      });

      test('handles null notified in map', () {
        final map = {
          'id': 'uuid-789',
          'achievement_id': 'test',
          'unlocked_at': 1705312200,
          'progress': 5,
          'notified': null,
          'created_at': 1705312200,
        };

        final achievement = UnlockedAchievement.fromMap(map);
        expect(achievement.notified, false);
      });

      test('round trips correctly', () {
        final map = testAchievement.toMap();
        final restored = UnlockedAchievement.fromMap(map);

        expect(restored.id, testAchievement.id);
        expect(restored.achievementId, testAchievement.achievementId);
        expect(restored.progress, testAchievement.progress);
        expect(restored.notified, testAchievement.notified);
        // Times might differ by up to 999ms due to second truncation
        expect(
          restored.unlockedAt.difference(testAchievement.unlockedAt).inSeconds.abs(),
          lessThanOrEqualTo(1),
        );
      });
    });

    test('copyWith creates modified copy', () {
      final modified = testAchievement.copyWith(
        progress: 5,
        notified: true,
      );

      expect(modified.id, testAchievement.id);
      expect(modified.achievementId, testAchievement.achievementId);
      expect(modified.progress, 5);
      expect(modified.notified, true);
    });

    test('markAsNotified returns copy with notified true', () {
      expect(testAchievement.notified, false);

      final notified = testAchievement.markAsNotified();

      expect(notified.notified, true);
      expect(notified.id, testAchievement.id);
      expect(notified.achievementId, testAchievement.achievementId);
    });

    test('equality based on id', () {
      final achievement1 = UnlockedAchievement(
        id: 'same-id',
        achievementId: 'first',
        unlockedAt: DateTime(2024, 1, 1),
        progress: 1,
        notified: false,
        createdAt: DateTime(2024, 1, 1),
      );
      final achievement2 = UnlockedAchievement(
        id: 'same-id',
        achievementId: 'second',
        unlockedAt: DateTime(2024, 12, 31),
        progress: 100,
        notified: true,
        createdAt: DateTime(2024, 12, 31),
      );
      final achievement3 = UnlockedAchievement(
        id: 'different-id',
        achievementId: 'first',
        unlockedAt: DateTime(2024, 1, 1),
        progress: 1,
        notified: false,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(achievement1, equals(achievement2));
      expect(achievement1, isNot(equals(achievement3)));
    });

    test('hashCode based on id', () {
      final achievement1 = testAchievement;
      final achievement2 = testAchievement.copyWith(progress: 999);

      expect(achievement1.hashCode, equals(achievement2.hashCode));
    });

    test('toString contains relevant info', () {
      final str = testAchievement.toString();

      expect(str, contains('uuid-123'));
      expect(str, contains('first_quiz'));
    });
  });
}
