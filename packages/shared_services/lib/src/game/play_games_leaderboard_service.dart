import 'dart:io';

import 'package:games_services/games_services.dart' as gs;

import 'leaderboard_service.dart';

/// Android Google Play Games implementation of [LeaderboardService].
///
/// Provides leaderboard functionality through Google Play Games.
///
/// **Setup Required:**
/// 1. Enable Play Games Services in Google Play Console
/// 2. Create leaderboards in Play Games Services:
///    - Go to Play Console → Play Games Services → Setup & Management
///    - Add Leaderboards with unique IDs
/// 3. Use the leaderboard IDs configured in Play Console
///
/// On non-Android platforms, this service will return appropriate fallback values.
class PlayGamesLeaderboardService implements LeaderboardService {
  /// Creates a new Play Games leaderboard service instance.
  PlayGamesLeaderboardService();

  /// Whether the current platform supports Play Games.
  bool get isSupported => Platform.isAndroid;

  @override
  Future<SubmitScoreResult> submitScore({
    required String leaderboardId,
    required int score,
  }) async {
    if (!isSupported) {
      return SubmitScoreResult.notSignedIn();
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return SubmitScoreResult.notSignedIn();
      }

      final gsScore = gs.Score(
        iOSLeaderboardID: '', // Not used for Play Games
        androidLeaderboardID: leaderboardId,
        value: score,
      );

      final result = await gs.Leaderboards.submitScore(score: gsScore);

      // games_services returns a string result
      if (result == null || result.contains('error')) {
        return SubmitScoreResult.failed(
          error: result ?? 'Unknown error submitting score',
          errorCode: 'SUBMIT_SCORE_ERROR',
        );
      }

      return SubmitScoreResult.success();
    } on Exception catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('not authenticated') ||
          errorMessage.contains('not signed in') ||
          errorMessage.contains('SIGN_IN_REQUIRED')) {
        return SubmitScoreResult.notSignedIn();
      }

      return SubmitScoreResult.failed(
        error: 'Failed to submit score: $errorMessage',
        errorCode: 'PLAY_GAMES_ERROR',
      );
    }
  }

  @override
  Future<List<LeaderboardEntry>> getTopScores({
    required String leaderboardId,
    required int count,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  }) async {
    if (!isSupported) {
      return const [];
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return const [];
      }

      final scores = await gs.Leaderboards.loadLeaderboardScores(
        iOSLeaderboardID: '', // Not used for Play Games
        androidLeaderboardID: leaderboardId,
        scope: gs.PlayerScope.global,
        timeScope: _mapTimeSpan(timeSpan),
        maxResults: count,
      );

      if (scores == null) {
        return const [];
      }

      return scores.map((score) {
        return LeaderboardEntry(
          playerId: score.scoreHolder.playerID ?? 'unknown',
          displayName: score.scoreHolder.displayName,
          score: score.rawScore,
          rank: score.rank,
          avatarUrl: score.scoreHolder.iconImage,
          formattedScore: score.displayScore,
          timestamp: DateTime.fromMillisecondsSinceEpoch(score.timestampMillis),
        );
      }).toList();
    } on Exception {
      return const [];
    }
  }

  @override
  Future<PlayerScore?> getPlayerScore({
    required String leaderboardId,
    LeaderboardTimeSpan timeSpan = LeaderboardTimeSpan.allTime,
  }) async {
    if (!isSupported) {
      return null;
    }

    try {
      // Check if signed in first
      final isSignedIn = await gs.GameAuth.isSignedIn;
      if (!isSignedIn) {
        return null;
      }

      final score = await gs.Leaderboards.getPlayerScoreObject(
        iOSLeaderboardID: '', // Not used for Play Games
        androidLeaderboardID: leaderboardId,
        scope: gs.PlayerScope.global,
        timeScope: _mapTimeSpan(timeSpan),
      );

      if (score == null) {
        return null;
      }

      return PlayerScore(
        score: score.rawScore,
        rank: score.rank,
        formattedScore: score.displayScore,
        timestamp: DateTime.fromMillisecondsSinceEpoch(score.timestampMillis),
      );
    } on Exception {
      return null;
    }
  }

  @override
  Future<bool> showLeaderboard({String? leaderboardId}) async {
    if (!isSupported) {
      return false;
    }

    try {
      final result = await gs.Leaderboards.showLeaderboards(
        iOSLeaderboardID: '', // Not used for Play Games
        androidLeaderboardID: leaderboardId ?? '',
      );

      return result == null || !result.contains('error');
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> showAllLeaderboards() async {
    if (!isSupported) {
      return false;
    }

    try {
      // Pass empty string to show all leaderboards
      final result = await gs.Leaderboards.showLeaderboards(
        iOSLeaderboardID: '', // Not used for Play Games
        androidLeaderboardID: '',
      );

      return result == null || !result.contains('error');
    } on Exception {
      return false;
    }
  }

  /// Maps our [LeaderboardTimeSpan] to games_services [TimeScope].
  gs.TimeScope _mapTimeSpan(LeaderboardTimeSpan timeSpan) {
    switch (timeSpan) {
      case LeaderboardTimeSpan.allTime:
        return gs.TimeScope.allTime;
      case LeaderboardTimeSpan.weekly:
        return gs.TimeScope.week;
      case LeaderboardTimeSpan.daily:
        return gs.TimeScope.today;
    }
  }
}