import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('SubmitScoreResult', () {
    test('success factory creates SubmitScoreSuccess', () {
      final result = SubmitScoreResult.success(
        newRank: 5,
        isNewHighScore: true,
      );

      expect(result, isA<SubmitScoreSuccess>());
      expect((result as SubmitScoreSuccess).newRank, equals(5));
      expect(result.isNewHighScore, isTrue);
    });

    test('success factory works without optional fields', () {
      final result = SubmitScoreResult.success();

      expect(result, isA<SubmitScoreSuccess>());
      expect((result as SubmitScoreSuccess).newRank, isNull);
      expect(result.isNewHighScore, isNull);
    });

    test('failed factory creates SubmitScoreFailed', () {
      final result = SubmitScoreResult.failed(
        error: 'Network error',
        errorCode: 'NET_001',
      );

      expect(result, isA<SubmitScoreFailed>());
      expect((result as SubmitScoreFailed).error, equals('Network error'));
      expect(result.errorCode, equals('NET_001'));
    });

    test('notSignedIn factory creates SubmitScoreNotSignedIn', () {
      final result = SubmitScoreResult.notSignedIn();

      expect(result, isA<SubmitScoreNotSignedIn>());
    });

    test('sealed class pattern matching works', () {
      final results = [
        SubmitScoreResult.success(newRank: 1),
        SubmitScoreResult.failed(error: 'error'),
        SubmitScoreResult.notSignedIn(),
      ];

      final types = results.map((result) {
        return switch (result) {
          SubmitScoreSuccess() => 'success',
          SubmitScoreFailed() => 'failed',
          SubmitScoreNotSignedIn() => 'notSignedIn',
        };
      }).toList();

      expect(types, equals(['success', 'failed', 'notSignedIn']));
    });
  });

  group('LeaderboardEntry', () {
    test('creates with required fields', () {
      final entry = LeaderboardEntry(
        playerId: 'player123',
        displayName: 'John Doe',
        score: 1000,
        rank: 5,
      );

      expect(entry.playerId, equals('player123'));
      expect(entry.displayName, equals('John Doe'));
      expect(entry.score, equals(1000));
      expect(entry.rank, equals(5));
      expect(entry.avatarUrl, isNull);
      expect(entry.formattedScore, isNull);
      expect(entry.timestamp, isNull);
    });

    test('creates with all fields', () {
      final timestamp = DateTime(2024, 1, 15);
      final entry = LeaderboardEntry(
        playerId: 'player123',
        displayName: 'John Doe',
        score: 1000,
        rank: 5,
        avatarUrl: 'https://example.com/avatar.png',
        formattedScore: '1,000 pts',
        timestamp: timestamp,
      );

      expect(entry.avatarUrl, equals('https://example.com/avatar.png'));
      expect(entry.formattedScore, equals('1,000 pts'));
      expect(entry.timestamp, equals(timestamp));
    });

    test('toString returns readable format', () {
      final entry = LeaderboardEntry(
        playerId: 'player123',
        displayName: 'John Doe',
        score: 1000,
        rank: 5,
      );

      expect(
        entry.toString(),
        equals('LeaderboardEntry(rank: 5, displayName: John Doe, score: 1000)'),
      );
    });
  });

  group('PlayerScore', () {
    test('creates with required fields', () {
      final score = PlayerScore(
        score: 1000,
        rank: 5,
      );

      expect(score.score, equals(1000));
      expect(score.rank, equals(5));
      expect(score.formattedScore, isNull);
      expect(score.timestamp, isNull);
    });

    test('creates with all fields', () {
      final timestamp = DateTime(2024, 1, 15);
      final score = PlayerScore(
        score: 1000,
        rank: 5,
        formattedScore: '1,000 pts',
        timestamp: timestamp,
      );

      expect(score.formattedScore, equals('1,000 pts'));
      expect(score.timestamp, equals(timestamp));
    });

    test('toString returns readable format', () {
      final score = PlayerScore(
        score: 1000,
        rank: 5,
      );

      expect(
        score.toString(),
        equals('PlayerScore(rank: 5, score: 1000)'),
      );
    });
  });

  group('LeaderboardTimeSpan', () {
    test('has all expected values', () {
      expect(LeaderboardTimeSpan.values, hasLength(3));
      expect(
        LeaderboardTimeSpan.values,
        containsAll([
          LeaderboardTimeSpan.allTime,
          LeaderboardTimeSpan.weekly,
          LeaderboardTimeSpan.daily,
        ]),
      );
    });
  });

  group('NoOpLeaderboardService', () {
    late NoOpLeaderboardService service;

    setUp(() {
      service = const NoOpLeaderboardService();
    });

    test('submitScore returns notSignedIn', () async {
      final result = await service.submitScore(
        leaderboardId: 'test_leaderboard',
        score: 1000,
      );

      expect(result, isA<SubmitScoreNotSignedIn>());
    });

    test('getTopScores returns empty list', () async {
      final result = await service.getTopScores(
        leaderboardId: 'test_leaderboard',
        count: 10,
      );

      expect(result, isEmpty);
    });

    test('getTopScores with timeSpan returns empty list', () async {
      final result = await service.getTopScores(
        leaderboardId: 'test_leaderboard',
        count: 10,
        timeSpan: LeaderboardTimeSpan.weekly,
      );

      expect(result, isEmpty);
    });

    test('getPlayerScore returns null', () async {
      final result = await service.getPlayerScore(
        leaderboardId: 'test_leaderboard',
      );

      expect(result, isNull);
    });

    test('showLeaderboard returns false', () async {
      final result = await service.showLeaderboard(
        leaderboardId: 'test_leaderboard',
      );

      expect(result, isFalse);
    });

    test('showLeaderboard without ID returns false', () async {
      final result = await service.showLeaderboard();

      expect(result, isFalse);
    });

    test('showAllLeaderboards returns false', () async {
      final result = await service.showAllLeaderboards();

      expect(result, isFalse);
    });
  });
}