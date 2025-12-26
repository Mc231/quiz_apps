import 'base_config.dart';

/// Represents the breakdown of a score calculation.
///
/// Contains base points, bonus points, and the total score.
class ScoreBreakdownData {
  /// Creates a [ScoreBreakdownData].
  const ScoreBreakdownData({
    required this.basePoints,
    required this.bonusPoints,
    required this.totalScore,
    this.bonusDescription,
  });

  /// Base points earned (e.g., for correct answers).
  final int basePoints;

  /// Bonus points earned (e.g., for speed or streaks).
  final int bonusPoints;

  /// Total score (basePoints + bonusPoints).
  final int totalScore;

  /// Optional description of how the bonus was calculated.
  final String? bonusDescription;

  @override
  String toString() {
    return 'ScoreBreakdownData(base: $basePoints, bonus: $bonusPoints, total: $totalScore)';
  }
}

/// Strategy pattern for different scoring algorithms
/// Apps can implement custom strategies
sealed class ScoringStrategy extends BaseConfig {
  const ScoringStrategy();

  /// Calculate the total score based on quiz performance.
  ///
  /// Parameters:
  /// - [correctAnswers]: Number of correct answers
  /// - [totalQuestions]: Total number of questions
  /// - [durationSeconds]: Total duration of the quiz in seconds
  /// - [streaks]: Optional list of consecutive correct answer counts
  ///
  /// Returns a [ScoreBreakdownData] containing the score breakdown.
  ScoreBreakdownData calculateScore({
    required int correctAnswers,
    required int totalQuestions,
    required int durationSeconds,
    List<int>? streaks,
  });

  factory ScoringStrategy.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;

    return switch (type) {
      'simple' => SimpleScoring.fromMap(map),
      'timed' => TimedScoring.fromMap(map),
      'streak' => StreakScoring.fromMap(map),
      _ => const SimpleScoring(),
    };
  }
}

/// Simple scoring: 1 point per correct answer
class SimpleScoring extends ScoringStrategy {
  /// Points awarded per correct answer.
  final int pointsPerCorrect;

  @override
  final int version;

  const SimpleScoring({
    this.pointsPerCorrect = 1,
    this.version = 1,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'simple',
      'version': version,
      'pointsPerCorrect': pointsPerCorrect,
    };
  }

  factory SimpleScoring.fromMap(Map<String, dynamic> map) {
    return SimpleScoring(
      pointsPerCorrect: map['pointsPerCorrect'] as int? ?? 1,
      version: map['version'] as int? ?? 1,
    );
  }

  @override
  ScoreBreakdownData calculateScore({
    required int correctAnswers,
    required int totalQuestions,
    required int durationSeconds,
    List<int>? streaks,
  }) {
    final basePoints = correctAnswers * pointsPerCorrect;
    return ScoreBreakdownData(
      basePoints: basePoints,
      bonusPoints: 0,
      totalScore: basePoints,
    );
  }
}

/// Time-based scoring: bonus for speed
///
/// Formula:
/// - basePoints = correctAnswers * basePointsPerQuestion
/// - timeBonus = max(0, (timeThresholdSeconds - avgSecondsPerQuestion)) * bonusPerSecondSaved * correctAnswers
/// - totalScore = basePoints + timeBonus
class TimedScoring extends ScoringStrategy {
  final int basePointsPerQuestion;
  final int bonusPerSecondSaved;
  final int timeThresholdSeconds;

  @override
  final int version;

  const TimedScoring({
    this.basePointsPerQuestion = 100,
    this.bonusPerSecondSaved = 5,
    this.timeThresholdSeconds = 30,
    this.version = 1,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'timed',
      'version': version,
      'basePointsPerQuestion': basePointsPerQuestion,
      'bonusPerSecondSaved': bonusPerSecondSaved,
      'timeThresholdSeconds': timeThresholdSeconds,
    };
  }

  factory TimedScoring.fromMap(Map<String, dynamic> map) {
    return TimedScoring(
      basePointsPerQuestion: map['basePointsPerQuestion'] as int? ?? 100,
      bonusPerSecondSaved: map['bonusPerSecondSaved'] as int? ?? 5,
      timeThresholdSeconds: map['timeThresholdSeconds'] as int? ?? 30,
      version: map['version'] as int? ?? 1,
    );
  }

  TimedScoring copyWith({
    int? basePointsPerQuestion,
    int? bonusPerSecondSaved,
    int? timeThresholdSeconds,
  }) {
    return TimedScoring(
      basePointsPerQuestion:
          basePointsPerQuestion ?? this.basePointsPerQuestion,
      bonusPerSecondSaved: bonusPerSecondSaved ?? this.bonusPerSecondSaved,
      timeThresholdSeconds: timeThresholdSeconds ?? this.timeThresholdSeconds,
      version: version,
    );
  }

  @override
  ScoreBreakdownData calculateScore({
    required int correctAnswers,
    required int totalQuestions,
    required int durationSeconds,
    List<int>? streaks,
  }) {
    final basePoints = correctAnswers * basePointsPerQuestion;

    // Calculate time bonus based on average time per question
    int timeBonus = 0;
    if (totalQuestions > 0 && correctAnswers > 0) {
      final avgSecondsPerQuestion = durationSeconds / totalQuestions;
      if (avgSecondsPerQuestion < timeThresholdSeconds) {
        final secondsSaved =
            (timeThresholdSeconds - avgSecondsPerQuestion).floor();
        timeBonus = secondsSaved * bonusPerSecondSaved * correctAnswers;
      }
    }

    return ScoreBreakdownData(
      basePoints: basePoints,
      bonusPoints: timeBonus,
      totalScore: basePoints + timeBonus,
      bonusDescription: timeBonus > 0 ? 'Time bonus' : null,
    );
  }
}

/// Streak-based scoring: bonus for consecutive correct answers
///
/// Formula:
/// - For each correct answer in a streak: basePoints * (1 + streak * multiplierBonus)
/// - Where multiplierBonus = (streakMultiplier - 1) = 0.5 for default 1.5x multiplier
///
/// Example with 3-answer streak: 100 + 150 + 200 = 450 points
class StreakScoring extends ScoringStrategy {
  final int basePointsPerQuestion;
  final double streakMultiplier;

  @override
  final int version;

  const StreakScoring({
    this.basePointsPerQuestion = 100,
    this.streakMultiplier = 1.5,
    this.version = 1,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'streak',
      'version': version,
      'basePointsPerQuestion': basePointsPerQuestion,
      'streakMultiplier': streakMultiplier,
    };
  }

  factory StreakScoring.fromMap(Map<String, dynamic> map) {
    return StreakScoring(
      basePointsPerQuestion: map['basePointsPerQuestion'] as int? ?? 100,
      streakMultiplier: (map['streakMultiplier'] as num?)?.toDouble() ?? 1.5,
      version: map['version'] as int? ?? 1,
    );
  }

  StreakScoring copyWith({
    int? basePointsPerQuestion,
    double? streakMultiplier,
  }) {
    return StreakScoring(
      basePointsPerQuestion:
          basePointsPerQuestion ?? this.basePointsPerQuestion,
      streakMultiplier: streakMultiplier ?? this.streakMultiplier,
      version: version,
    );
  }

  @override
  ScoreBreakdownData calculateScore({
    required int correctAnswers,
    required int totalQuestions,
    required int durationSeconds,
    List<int>? streaks,
  }) {
    final basePoints = correctAnswers * basePointsPerQuestion;

    // Calculate streak bonus
    int streakBonus = 0;
    if (streaks != null && streaks.isNotEmpty) {
      // For each streak, calculate bonus based on position in streak
      // A streak of 3 gives: base + (base * 0.5) + (base * 1.0) bonus
      final multiplierBonus = streakMultiplier - 1.0;
      for (final streakLength in streaks) {
        for (int i = 1; i < streakLength; i++) {
          streakBonus += (basePointsPerQuestion * multiplierBonus * i).round();
        }
      }
    }

    return ScoreBreakdownData(
      basePoints: basePoints,
      bonusPoints: streakBonus,
      totalScore: basePoints + streakBonus,
      bonusDescription: streakBonus > 0 ? 'Streak bonus' : null,
    );
  }
}
