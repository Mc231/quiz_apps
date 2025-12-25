import 'package:flutter/material.dart';

/// Difficulty level for a challenge mode.
enum ChallengeDifficulty {
  /// Easy difficulty - relaxed, no pressure.
  easy,

  /// Medium difficulty - moderate challenge.
  medium,

  /// Hard difficulty - intense, high pressure.
  hard,
}

/// Extension for [ChallengeDifficulty] with display properties.
extension ChallengeDifficultyExtension on ChallengeDifficulty {
  /// Returns the color associated with this difficulty.
  Color get color {
    switch (this) {
      case ChallengeDifficulty.easy:
        return const Color(0xFF4CAF50); // Green
      case ChallengeDifficulty.medium:
        return const Color(0xFFFF9800); // Orange
      case ChallengeDifficulty.hard:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Returns the label for this difficulty.
  String get label {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
    }
  }

  /// Returns the icon for this difficulty.
  IconData get icon {
    switch (this) {
      case ChallengeDifficulty.easy:
        return Icons.sentiment_satisfied;
      case ChallengeDifficulty.medium:
        return Icons.sentiment_neutral;
      case ChallengeDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}

/// Configuration for a challenge mode.
///
/// Defines the rules and settings for a specific challenge type.
/// Each app can define its own challenge modes with different configurations.
///
/// Example:
/// ```dart
/// final survivalChallenge = ChallengeMode(
///   id: 'survival',
///   name: 'Survival',
///   description: '1 livee, no hints. Can you survive?',
///   icon: Icons.favorite,
///   difficulty: ChallengeDifficulty.hard,
///   lives: 3,
///   showHints: false,
///   allowSkip: false,
/// );
/// ```
class ChallengeMode {
  /// Creates a [ChallengeMode].
  const ChallengeMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    this.lives,
    this.totalTimeSeconds,
    this.questionTimeSeconds,
    this.questionCount,
    this.showHints = false,
    this.allowSkip = false,
    this.trackTime = false,
    this.trackStreak = false,
    this.isEndless = false,
    this.showAnswerFeedback,
  });

  /// Unique identifier for this challenge.
  final String id;

  /// Display name for the challenge.
  final String name;

  /// Short description of the challenge rules.
  final String description;

  /// Icon representing this challenge.
  final IconData icon;

  /// Difficulty level of this challenge.
  final ChallengeDifficulty difficulty;

  /// Number of lives (null = unlimited).
  final int? lives;

  /// Total time limit in seconds (null = no limit).
  final int? totalTimeSeconds;

  /// Time limit per question in seconds (null = no limit).
  final int? questionTimeSeconds;

  /// Number of questions (null = unlimited/endless).
  final int? questionCount;

  /// Whether hints are available.
  final bool showHints;

  /// Whether skipping questions is allowed.
  final bool allowSkip;

  /// Whether to track completion time.
  final bool trackTime;

  /// Whether to track answer streak.
  final bool trackStreak;

  /// Whether this is an endless mode.
  final bool isEndless;

  /// Whether to show answer feedback for this challenge mode.
  ///
  /// If null, uses the category default or global default.
  /// This allows mode-specific override of feedback behavior.
  final bool? showAnswerFeedback;

  /// Creates a copy with the given fields replaced.
  ChallengeMode copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    ChallengeDifficulty? difficulty,
    int? lives,
    int? totalTimeSeconds,
    int? questionTimeSeconds,
    int? questionCount,
    bool? showHints,
    bool? allowSkip,
    bool? trackTime,
    bool? trackStreak,
    bool? isEndless,
    bool? showAnswerFeedback,
  }) {
    return ChallengeMode(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      difficulty: difficulty ?? this.difficulty,
      lives: lives ?? this.lives,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      questionTimeSeconds: questionTimeSeconds ?? this.questionTimeSeconds,
      questionCount: questionCount ?? this.questionCount,
      showHints: showHints ?? this.showHints,
      allowSkip: allowSkip ?? this.allowSkip,
      trackTime: trackTime ?? this.trackTime,
      trackStreak: trackStreak ?? this.trackStreak,
      isEndless: isEndless ?? this.isEndless,
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeMode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
