import 'base_config.dart';

/// Strategy pattern for different scoring algorithms
/// Apps can implement custom strategies
sealed class ScoringStrategy extends BaseConfig {
  const ScoringStrategy();

  /// Calculate score based on quiz performance
  /// This method will be implemented when QuizResults is available
  // int calculateScore(QuizResults results);

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
  @override
  final int version;

  const SimpleScoring({this.version = 1});

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'simple',
      'version': version,
    };
  }

  factory SimpleScoring.fromMap(Map<String, dynamic> map) {
    return SimpleScoring(
      version: map['version'] as int? ?? 1,
    );
  }

  // int calculateScore(QuizResults results) {
  //   return results.correctAnswers;
  // }
}

/// Time-based scoring: bonus for speed
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
      basePointsPerQuestion: basePointsPerQuestion ?? this.basePointsPerQuestion,
      bonusPerSecondSaved: bonusPerSecondSaved ?? this.bonusPerSecondSaved,
      timeThresholdSeconds: timeThresholdSeconds ?? this.timeThresholdSeconds,
      version: version,
    );
  }

  // int calculateScore(QuizResults results) {
  //   int totalScore = 0;
  //   final avgTimePerQuestion =
  //       results.timeTaken.inSeconds / results.totalQuestions;
  //
  //   for (int i = 0; i < results.correctAnswers; i++) {
  //     int questionScore = basePointsPerQuestion;
  //
  //     if (avgTimePerQuestion < timeThresholdSeconds) {
  //       final secondsSaved =
  //           (timeThresholdSeconds - avgTimePerQuestion).floor();
  //       questionScore += secondsSaved * bonusPerSecondSaved;
  //     }
  //
  //     totalScore += questionScore;
  //   }
  //
  //   return totalScore;
  // }
}

/// Streak-based scoring: bonus for consecutive correct answers
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
      basePointsPerQuestion: basePointsPerQuestion ?? this.basePointsPerQuestion,
      streakMultiplier: streakMultiplier ?? this.streakMultiplier,
      version: version,
    );
  }

  // int calculateScore(QuizResults results) {
  //   // Would need Answer objects with order to calculate streaks
  //   return results.correctAnswers * basePointsPerQuestion;
  // }
}