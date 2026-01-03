import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('UnlockAchievementResult', () {
    test('success factory creates UnlockAchievementSuccess', () {
      final result = UnlockAchievementResult.success(
        wasAlreadyUnlocked: false,
      );

      expect(result, isA<UnlockAchievementSuccess>());
      expect((result as UnlockAchievementSuccess).wasAlreadyUnlocked, isFalse);
    });

    test('success factory works without optional field', () {
      final result = UnlockAchievementResult.success();

      expect(result, isA<UnlockAchievementSuccess>());
      expect((result as UnlockAchievementSuccess).wasAlreadyUnlocked, isNull);
    });

    test('failed factory creates UnlockAchievementFailed', () {
      final result = UnlockAchievementResult.failed(
        error: 'Network error',
        errorCode: 'NET_001',
      );

      expect(result, isA<UnlockAchievementFailed>());
      expect((result as UnlockAchievementFailed).error, equals('Network error'));
      expect(result.errorCode, equals('NET_001'));
    });

    test('notFound factory creates UnlockAchievementNotFound', () {
      final result = UnlockAchievementResult.notFound();

      expect(result, isA<UnlockAchievementNotFound>());
    });

    test('notSignedIn factory creates UnlockAchievementNotSignedIn', () {
      final result = UnlockAchievementResult.notSignedIn();

      expect(result, isA<UnlockAchievementNotSignedIn>());
    });

    test('sealed class pattern matching works', () {
      final results = [
        UnlockAchievementResult.success(),
        UnlockAchievementResult.failed(error: 'error'),
        UnlockAchievementResult.notFound(),
        UnlockAchievementResult.notSignedIn(),
      ];

      final types = results.map((result) {
        return switch (result) {
          UnlockAchievementSuccess() => 'success',
          UnlockAchievementFailed() => 'failed',
          UnlockAchievementNotFound() => 'notFound',
          UnlockAchievementNotSignedIn() => 'notSignedIn',
        };
      }).toList();

      expect(types, equals(['success', 'failed', 'notFound', 'notSignedIn']));
    });
  });

  group('IncrementAchievementResult', () {
    test('success factory creates IncrementAchievementSuccess', () {
      final result = IncrementAchievementResult.success(
        currentSteps: 5,
        totalSteps: 10,
        isUnlocked: false,
      );

      expect(result, isA<IncrementAchievementSuccess>());
      final success = result as IncrementAchievementSuccess;
      expect(success.currentSteps, equals(5));
      expect(success.totalSteps, equals(10));
      expect(success.isUnlocked, isFalse);
      expect(success.progress, equals(0.5));
    });

    test('success calculates progress correctly', () {
      final result = IncrementAchievementResult.success(
        currentSteps: 7,
        totalSteps: 10,
        isUnlocked: false,
      );

      expect((result as IncrementAchievementSuccess).progress, equals(0.7));
    });

    test('success handles zero totalSteps', () {
      final result = IncrementAchievementResult.success(
        currentSteps: 0,
        totalSteps: 0,
        isUnlocked: true,
      );

      expect((result as IncrementAchievementSuccess).progress, equals(0.0));
    });

    test('failed factory creates IncrementAchievementFailed', () {
      final result = IncrementAchievementResult.failed(
        error: 'Network error',
        errorCode: 'NET_001',
      );

      expect(result, isA<IncrementAchievementFailed>());
      expect(
        (result as IncrementAchievementFailed).error,
        equals('Network error'),
      );
    });

    test('notFound factory creates IncrementAchievementNotFound', () {
      final result = IncrementAchievementResult.notFound();

      expect(result, isA<IncrementAchievementNotFound>());
    });

    test('notSignedIn factory creates IncrementAchievementNotSignedIn', () {
      final result = IncrementAchievementResult.notSignedIn();

      expect(result, isA<IncrementAchievementNotSignedIn>());
    });
  });

  group('CloudAchievementInfo', () {
    test('creates with required fields', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
      );

      expect(info.achievementId, equals('ach_001'));
      expect(info.name, equals('First Steps'));
      expect(info.description, isNull);
      expect(info.isUnlocked, isFalse);
      expect(info.currentSteps, isNull);
      expect(info.totalSteps, isNull);
      expect(info.unlockedAt, isNull);
      expect(info.iconUrl, isNull);
      expect(info.isIncremental, isFalse);
      expect(info.progress, equals(0.0));
    });

    test('creates with all fields', () {
      final unlockTime = DateTime(2024, 1, 15);
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
        description: 'Complete your first quiz',
        isUnlocked: true,
        currentSteps: 1,
        totalSteps: 1,
        unlockedAt: unlockTime,
        iconUrl: 'https://example.com/icon.png',
      );

      expect(info.description, equals('Complete your first quiz'));
      expect(info.isUnlocked, isTrue);
      expect(info.unlockedAt, equals(unlockTime));
      expect(info.iconUrl, equals('https://example.com/icon.png'));
    });

    test('isIncremental returns true for multi-step achievements', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_002',
        name: 'Quiz Master',
        totalSteps: 100,
        currentSteps: 50,
      );

      expect(info.isIncremental, isTrue);
    });

    test('isIncremental returns false for single-step achievements', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
        totalSteps: 1,
        currentSteps: 0,
      );

      expect(info.isIncremental, isFalse);
    });

    test('isIncremental returns false when totalSteps is null', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
      );

      expect(info.isIncremental, isFalse);
    });

    test('progress returns 1.0 when unlocked', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
        isUnlocked: true,
        currentSteps: 5,
        totalSteps: 10,
      );

      expect(info.progress, equals(1.0));
    });

    test('progress calculates correctly for incremental', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_002',
        name: 'Quiz Master',
        currentSteps: 75,
        totalSteps: 100,
      );

      expect(info.progress, equals(0.75));
    });

    test('progress returns 0.0 when steps are null', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
      );

      expect(info.progress, equals(0.0));
    });

    test('progress handles zero totalSteps', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
        currentSteps: 5,
        totalSteps: 0,
      );

      expect(info.progress, equals(0.0));
    });

    test('toString returns readable format', () {
      final info = CloudAchievementInfo(
        achievementId: 'ach_001',
        name: 'First Steps',
        isUnlocked: true,
      );

      expect(
        info.toString(),
        equals('CloudAchievementInfo(id: ach_001, name: First Steps, unlocked: true)'),
      );
    });
  });

  group('NoOpCloudAchievementService', () {
    late NoOpCloudAchievementService service;

    setUp(() {
      service = const NoOpCloudAchievementService();
    });

    test('unlockAchievement returns notSignedIn', () async {
      final result = await service.unlockAchievement('ach_001');

      expect(result, isA<UnlockAchievementNotSignedIn>());
    });

    test('incrementAchievement returns notSignedIn', () async {
      final result = await service.incrementAchievement('ach_001');

      expect(result, isA<IncrementAchievementNotSignedIn>());
    });

    test('incrementAchievement with steps returns notSignedIn', () async {
      final result = await service.incrementAchievement('ach_001', steps: 5);

      expect(result, isA<IncrementAchievementNotSignedIn>());
    });

    test('setAchievementProgress returns notSignedIn', () async {
      final result = await service.setAchievementProgress('ach_001', steps: 50);

      expect(result, isA<IncrementAchievementNotSignedIn>());
    });

    test('getAchievements returns empty list', () async {
      final result = await service.getAchievements();

      expect(result, isEmpty);
    });

    test('getAchievement returns null', () async {
      final result = await service.getAchievement('ach_001');

      expect(result, isNull);
    });

    test('showAchievements returns false', () async {
      final result = await service.showAchievements();

      expect(result, isFalse);
    });

    test('revealAchievement returns false', () async {
      final result = await service.revealAchievement('ach_001');

      expect(result, isFalse);
    });
  });
}