import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock repository for testing.
class MockDailyChallengeRepository implements DailyChallengeRepository {
  DailyChallenge? _todaysChallenge;
  DailyChallengeResult? _todaysResult;
  final List<DailyChallengeResult> _results = [];
  int _currentStreak = 0;

  @override
  Future<DailyChallenge> getTodaysChallenge({
    required Future<String> Function() categoryProvider,
    int questionCount = 10,
    int? timeLimitSeconds,
  }) async {
    if (_todaysChallenge == null) {
      final categoryId = await categoryProvider();
      _todaysChallenge = DailyChallenge.forToday(
        categoryId: categoryId,
        questionCount: questionCount,
        timeLimitSeconds: timeLimitSeconds,
      );
    }
    return _todaysChallenge!;
  }

  @override
  Future<DailyChallenge?> getChallengeById(String id) async {
    if (_todaysChallenge?.id == id) return _todaysChallenge;
    return null;
  }

  @override
  Future<DailyChallenge?> getChallengeByDate(DateTime date) async {
    return _todaysChallenge;
  }

  @override
  Future<bool> hasCompletedToday() async => _todaysResult != null;

  @override
  Future<DailyChallengeResult?> getTodaysResult() async => _todaysResult;

  @override
  Future<DailyChallengeResult?> getResultByChallengeId(
    String challengeId,
  ) async {
    return _results.cast<DailyChallengeResult?>().firstWhere(
          (r) => r?.challengeId == challengeId,
          orElse: () => null,
        );
  }

  @override
  Future<void> submitResult(DailyChallengeResult result) async {
    _results.add(result);
    _todaysResult = result;
    _currentStreak++;
  }

  @override
  Future<List<DailyChallengeResult>> getHistory({int days = 30}) async {
    return _results;
  }

  @override
  Future<List<DailyChallengeResult>> getAllResults({
    int? limit,
    int? offset,
  }) async {
    return _results;
  }

  @override
  Future<int> getCompletedCount() async => _results.length;

  @override
  Future<int> getTotalScore() async =>
      _results.fold<int>(0, (sum, r) => sum + r.score);

  @override
  Future<int> getBestScore() async {
    if (_results.isEmpty) return 0;
    return _results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<double> getAverageScorePercentage() async {
    if (_results.isEmpty) return 0.0;
    return _results.map((r) => r.scorePercentage).reduce((a, b) => a + b) /
        _results.length;
  }

  @override
  Future<int> getCurrentStreak() async => _currentStreak;

  void setStreak(int streak) => _currentStreak = streak;

  @override
  Stream<DailyChallengeStatus> watchTodayStatus() {
    return Stream.empty();
  }

  @override
  void clearCache() {}

  @override
  void dispose() {}
}

void main() {
  group('DailyChallengeService', () {
    late MockDailyChallengeRepository repository;
    late DailyChallengeServiceImpl service;

    setUp(() {
      repository = MockDailyChallengeRepository();
      service = DailyChallengeServiceImpl(
        repository: repository,
        availableCategories: ['europe', 'asia', 'americas'],
        config: const DailyChallengeConfig(
          basePointsPerQuestion: 100,
          streakBonusPerDay: 10,
          maxStreakBonus: 100,
          timeBonusThresholdSeconds: 60,
          timeBonusPerSecond: 2,
          maxTimeBonus: 50,
          perfectScoreMultiplier: 1.5,
        ),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('getTodaysChallenge returns challenge for today', () async {
      final challenge = await service.getTodaysChallenge();

      expect(challenge.isToday, isTrue);
      expect(challenge.questionCount, equals(10));
      expect(['europe', 'asia', 'americas'], contains(challenge.categoryId));
    });

    test('hasCompletedToday returns false initially', () async {
      final completed = await service.hasCompletedToday();
      expect(completed, isFalse);
    });

    test('submitResult calculates base score correctly', () async {
      final challenge = await service.getTodaysChallenge();

      final result = await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 120,
      );

      expect(result.correctCount, equals(8));
      expect(result.totalQuestions, equals(10));
      // Base score: 8 * 100 = 800
      expect(result.score, greaterThanOrEqualTo(800));
    });

    test('submitResult applies perfect score multiplier', () async {
      final challenge = await service.getTodaysChallenge();

      final result = await service.submitResult(
        challengeId: challenge.id,
        correctCount: 10,
        totalQuestions: 10,
        completionTimeSeconds: 120,
      );

      // Base: 10 * 100 = 1000
      // Perfect multiplier: 1000 * 1.5 = 1500
      expect(result.score, greaterThanOrEqualTo(1500));
    });

    test('submitResult applies streak bonus', () async {
      repository.setStreak(5);
      final challenge = await service.getTodaysChallenge();

      final result = await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 120,
      );

      // Streak bonus: 5 * 10 = 50
      expect(result.streakBonus, equals(50));
    });

    test('streak bonus is capped at max', () async {
      repository.setStreak(20); // Would be 200, but max is 100
      final challenge = await service.getTodaysChallenge();

      final result = await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 120,
      );

      expect(result.streakBonus, equals(100));
    });

    test('submitResult applies time bonus for fast completion', () async {
      final challenge = await service.getTodaysChallenge();

      final result = await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 30, // 30 seconds under 60 threshold
      );

      // Time bonus: (60 - 30) * 2 = 60, capped at 50
      expect(result.timeBonus, equals(50));
    });

    test('no time bonus when over threshold', () async {
      final challenge = await service.getTodaysChallenge();

      final result = await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 90, // Over 60 threshold
      );

      expect(result.timeBonus, equals(0));
    });

    test('hasCompletedToday returns true after submission', () async {
      final challenge = await service.getTodaysChallenge();

      await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 100,
      );

      final completed = await service.hasCompletedToday();
      expect(completed, isTrue);
    });

    test('getHistory returns past results', () async {
      final challenge = await service.getTodaysChallenge();

      await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 100,
      );

      final history = await service.getHistory();
      expect(history.length, equals(1));
      expect(history.first.correctCount, equals(8));
    });

    test('getStats returns statistics', () async {
      final challenge = await service.getTodaysChallenge();

      await service.submitResult(
        challengeId: challenge.id,
        correctCount: 8,
        totalQuestions: 10,
        completionTimeSeconds: 100,
      );

      final stats = await service.getStats();
      expect(stats.completedCount, equals(1));
      expect(stats.currentStreak, greaterThan(0));
      expect(stats.totalScore, greaterThan(0));
    });

    test('getTimeUntilNextChallenge returns valid duration', () {
      final duration = service.getTimeUntilNextChallenge();

      expect(duration.inSeconds, greaterThan(0));
      expect(duration.inHours, lessThanOrEqualTo(24));
    });
  });

  group('CategoryRotationStrategy', () {
    test('RandomCategoryRotation returns consistent category for same date',
        () {
      final strategy = RandomCategoryRotation();
      final categories = ['a', 'b', 'c', 'd', 'e'];
      final date = DateTime(2024, 6, 15);

      final cat1 = strategy.getCategoryForDate(date, categories);
      final cat2 = strategy.getCategoryForDate(date, categories);

      expect(cat1, equals(cat2));
    });

    test('RandomCategoryRotation throws for empty categories', () {
      final strategy = RandomCategoryRotation();
      final date = DateTime(2024, 6, 15);

      expect(
        () => strategy.getCategoryForDate(date, []),
        throwsArgumentError,
      );
    });

    test('SequentialCategoryRotation cycles through categories', () {
      final strategy = SequentialCategoryRotation();
      final categories = ['mon', 'tue', 'wed'];

      // Different days should cycle through categories
      final results = <String>{};
      for (int i = 0; i < 7; i++) {
        final date = DateTime(2024, 1, 1 + i);
        results.add(strategy.getCategoryForDate(date, categories));
      }

      // Should have used all categories at least once
      expect(results.length, equals(3));
    });

    test('SequentialCategoryRotation throws for empty categories', () {
      final strategy = SequentialCategoryRotation();
      final date = DateTime(2024, 6, 15);

      expect(
        () => strategy.getCategoryForDate(date, []),
        throwsArgumentError,
      );
    });
  });

  group('DailyChallengeConfig', () {
    test('default values are sensible', () {
      const config = DailyChallengeConfig();

      expect(config.basePointsPerQuestion, equals(100));
      expect(config.streakBonusPerDay, equals(10));
      expect(config.maxStreakBonus, equals(100));
      expect(config.perfectScoreMultiplier, equals(1.5));
    });
  });
}
