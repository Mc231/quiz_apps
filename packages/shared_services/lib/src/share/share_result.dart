import 'package:flutter/foundation.dart';

/// Represents quiz result data to be shared.
///
/// Contains all the information needed to generate shareable
/// text or images from a completed quiz session.
///
/// Example:
/// ```dart
/// final result = ShareResult(
///   score: 85.0,
///   categoryName: 'European Flags',
///   correctCount: 17,
///   totalCount: 20,
///   mode: 'standard',
///   timestamp: DateTime.now(),
/// );
///
/// // Or use factory constructors
/// final perfectResult = ShareResult.perfect(
///   categoryName: 'World Capitals',
///   totalCount: 25,
/// );
/// ```
@immutable
class ShareResult {
  /// Creates a [ShareResult].
  const ShareResult({
    required this.score,
    required this.categoryName,
    required this.correctCount,
    required this.totalCount,
    required this.mode,
    required this.timestamp,
    this.categoryId,
    this.achievementUnlocked,
    this.streakCount,
    this.bestScore,
    this.timeTaken,
  });

  /// Creates a perfect score result.
  factory ShareResult.perfect({
    required String categoryName,
    required int totalCount,
    required String mode,
    String? categoryId,
    String? achievementUnlocked,
    Duration? timeTaken,
  }) {
    return ShareResult(
      score: 100.0,
      categoryName: categoryName,
      correctCount: totalCount,
      totalCount: totalCount,
      mode: mode,
      timestamp: DateTime.now(),
      categoryId: categoryId,
      achievementUnlocked: achievementUnlocked,
      timeTaken: timeTaken,
    );
  }

  /// Creates a result from quiz completion data.
  factory ShareResult.fromQuizCompletion({
    required int correctCount,
    required int totalCount,
    required String categoryName,
    required String mode,
    String? categoryId,
    String? achievementUnlocked,
    int? streakCount,
    double? bestScore,
    Duration? timeTaken,
  }) {
    final score = totalCount > 0 ? (correctCount / totalCount) * 100 : 0.0;
    return ShareResult(
      score: score,
      categoryName: categoryName,
      correctCount: correctCount,
      totalCount: totalCount,
      mode: mode,
      timestamp: DateTime.now(),
      categoryId: categoryId,
      achievementUnlocked: achievementUnlocked,
      streakCount: streakCount,
      bestScore: bestScore,
      timeTaken: timeTaken,
    );
  }

  /// Score as percentage (0.0 - 100.0).
  final double score;

  /// Name of the quiz category played.
  final String categoryName;

  /// Optional category identifier for deep linking.
  final String? categoryId;

  /// Number of questions answered correctly.
  final int correctCount;

  /// Total number of questions in the quiz.
  final int totalCount;

  /// Game mode played (e.g., 'standard', 'timed', 'survival').
  final String mode;

  /// When the quiz was completed.
  final DateTime timestamp;

  /// Optional achievement unlocked during this quiz.
  ///
  /// When set, the share message/image can highlight
  /// this achievement for extra engagement.
  final String? achievementUnlocked;

  /// Optional streak count for consecutive correct answers.
  final int? streakCount;

  /// Optional personal best score for this category.
  ///
  /// Useful for "New personal best!" messages.
  final double? bestScore;

  /// Optional time taken to complete the quiz.
  final Duration? timeTaken;

  /// Whether this is a perfect score (100%).
  bool get isPerfect => score >= 100.0;

  /// Whether this is a new personal best.
  bool get isNewBest => bestScore != null && score > bestScore!;

  /// Whether an achievement was unlocked.
  bool get hasAchievement => achievementUnlocked != null;

  /// Score rounded to integer percentage.
  int get scorePercent => score.round();

  /// Formatted time taken string (e.g., "2:30").
  String? get formattedTime {
    if (timeTaken == null) return null;
    final minutes = timeTaken!.inMinutes;
    final seconds = timeTaken!.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Creates a copy with the given fields replaced.
  ShareResult copyWith({
    double? score,
    String? categoryName,
    String? categoryId,
    int? correctCount,
    int? totalCount,
    String? mode,
    DateTime? timestamp,
    String? achievementUnlocked,
    int? streakCount,
    double? bestScore,
    Duration? timeTaken,
  }) {
    return ShareResult(
      score: score ?? this.score,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
      mode: mode ?? this.mode,
      timestamp: timestamp ?? this.timestamp,
      achievementUnlocked: achievementUnlocked ?? this.achievementUnlocked,
      streakCount: streakCount ?? this.streakCount,
      bestScore: bestScore ?? this.bestScore,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareResult &&
        other.score == score &&
        other.categoryName == categoryName &&
        other.categoryId == categoryId &&
        other.correctCount == correctCount &&
        other.totalCount == totalCount &&
        other.mode == mode &&
        other.timestamp == timestamp &&
        other.achievementUnlocked == achievementUnlocked &&
        other.streakCount == streakCount &&
        other.bestScore == bestScore &&
        other.timeTaken == timeTaken;
  }

  @override
  int get hashCode => Object.hash(
        score,
        categoryName,
        categoryId,
        correctCount,
        totalCount,
        mode,
        timestamp,
        achievementUnlocked,
        streakCount,
        bestScore,
        timeTaken,
      );

  @override
  String toString() {
    return 'ShareResult('
        'score: $scorePercent%, '
        'category: $categoryName, '
        'correct: $correctCount/$totalCount, '
        'mode: $mode'
        '${hasAchievement ? ', achievement: $achievementUnlocked' : ''}'
        ')';
  }
}