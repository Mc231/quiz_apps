/// Model representing a user's result for a daily challenge.
library;

import 'package:uuid/uuid.dart';

/// Represents the user's performance on a daily challenge.
class DailyChallengeResult {
  /// Creates a new [DailyChallengeResult].
  const DailyChallengeResult({
    required this.id,
    required this.challengeId,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.completionTimeSeconds,
    required this.completedAt,
    this.streakBonus = 0,
    this.timeBonus = 0,
  });

  /// Creates a new result for a completed challenge.
  factory DailyChallengeResult.create({
    required String challengeId,
    required int score,
    required int correctCount,
    required int totalQuestions,
    required int completionTimeSeconds,
    int streakBonus = 0,
    int timeBonus = 0,
  }) {
    return DailyChallengeResult(
      id: const Uuid().v4(),
      challengeId: challengeId,
      score: score,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      completionTimeSeconds: completionTimeSeconds,
      completedAt: DateTime.now(),
      streakBonus: streakBonus,
      timeBonus: timeBonus,
    );
  }

  /// Creates a [DailyChallengeResult] from a database map.
  factory DailyChallengeResult.fromMap(Map<String, dynamic> map) {
    return DailyChallengeResult(
      id: map['id'] as String,
      challengeId: map['challenge_id'] as String,
      score: map['score'] as int,
      correctCount: map['correct_count'] as int,
      totalQuestions: map['total_questions'] as int,
      completionTimeSeconds: map['completion_time_seconds'] as int,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['completed_at'] as int) * 1000,
      ),
      streakBonus: (map['streak_bonus'] as int?) ?? 0,
      timeBonus: (map['time_bonus'] as int?) ?? 0,
    );
  }

  /// Unique identifier for this result.
  final String id;

  /// Reference to the daily challenge.
  final String challengeId;

  /// Total score earned (base + bonuses).
  final int score;

  /// Number of questions answered correctly.
  final int correctCount;

  /// Total number of questions in the challenge.
  final int totalQuestions;

  /// Time taken to complete in seconds.
  final int completionTimeSeconds;

  /// When the challenge was completed.
  final DateTime completedAt;

  /// Bonus points from daily streak.
  final int streakBonus;

  /// Bonus points for fast completion.
  final int timeBonus;

  /// Base score without bonuses.
  int get baseScore => score - streakBonus - timeBonus;

  /// Score as a percentage (0.0 to 100.0).
  double get scorePercentage {
    if (totalQuestions == 0) return 0.0;
    return (correctCount / totalQuestions) * 100;
  }

  /// Whether this is a perfect score.
  bool get isPerfectScore => correctCount == totalQuestions;

  /// Number of incorrect answers.
  int get incorrectCount => totalQuestions - correctCount;

  /// Formatted completion time as MM:SS.
  String get formattedTime {
    final minutes = completionTimeSeconds ~/ 60;
    final seconds = completionTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Converts this [DailyChallengeResult] to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'score': score,
      'correct_count': correctCount,
      'total_questions': totalQuestions,
      'completion_time_seconds': completionTimeSeconds,
      'completed_at': completedAt.millisecondsSinceEpoch ~/ 1000,
      'streak_bonus': streakBonus,
      'time_bonus': timeBonus,
    };
  }

  /// Creates a copy with the given fields replaced.
  DailyChallengeResult copyWith({
    String? id,
    String? challengeId,
    int? score,
    int? correctCount,
    int? totalQuestions,
    int? completionTimeSeconds,
    DateTime? completedAt,
    int? streakBonus,
    int? timeBonus,
  }) {
    return DailyChallengeResult(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completionTimeSeconds:
          completionTimeSeconds ?? this.completionTimeSeconds,
      completedAt: completedAt ?? this.completedAt,
      streakBonus: streakBonus ?? this.streakBonus,
      timeBonus: timeBonus ?? this.timeBonus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyChallengeResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DailyChallengeResult(id: $id, challengeId: $challengeId, '
        'score: $score, correct: $correctCount/$totalQuestions, '
        'time: ${formattedTime}s)';
  }
}
