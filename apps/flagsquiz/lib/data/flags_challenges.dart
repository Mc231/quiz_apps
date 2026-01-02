import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';

/// Challenge modes available in Flags Quiz.
///
/// Each challenge has different rules and difficulty levels.
/// After selecting a challenge, user picks a category to play.
class FlagsChallenges {
  FlagsChallenges._();

  /// Survival mode: 1 live, no hints, game over on 1 mistake.
  /// No answer feedback for faster gameplay.
  static const survival = ChallengeMode(
    id: 'survival',
    name: 'Survival',
    description: '1 live, no hints. Can you survive?',
    icon: Icons.favorite,
    difficulty: ChallengeDifficulty.hard,
    lives: 1,
    questionCount: null,
    showHints: false,
    allowSkip: false,
    showAnswerFeedback: false,
  );

  /// Time Attack: 60 seconds to answer as many as possible.
  /// No answer feedback for maximum speed.
  static const timeAttack = ChallengeMode(
    id: 'time_attack',
    name: 'Time Attack',
    description: '60 seconds. How many can you get?',
    icon: Icons.timer,
    difficulty: ChallengeDifficulty.medium,
    totalTimeSeconds: 60,
    questionCount: null,
    showHints: false,
    allowSkip: true,
    isEndless: true,
    showAnswerFeedback: false,
  );

  /// Speed Run: 20 questions, fastest time wins.
  /// No answer feedback for fastest completion.
  static const speedRun = ChallengeMode(
    id: 'speed_run',
    name: 'Speed Run',
    description: '20 questions. Race against time!',
    icon: Icons.speed,
    difficulty: ChallengeDifficulty.medium,
    questionCount: null,
    showHints: false,
    allowSkip: false,
    trackTime: true,
    showAnswerFeedback: false,
  );

  /// Marathon: Endless mode, track your streak.
  /// Shows answer feedback for learning during long sessions.
  static const marathon = ChallengeMode(
    id: 'marathon',
    name: 'Marathon',
    description: 'Endless mode. How far can you go?',
    icon: Icons.directions_run,
    difficulty: ChallengeDifficulty.easy,
    showHints: false,
    allowSkip: false,
    isEndless: true,
    trackStreak: true,
    showAnswerFeedback: true,
  );

  /// Blitz: 5 seconds per question, 1 life, 20 questions.
  /// No answer feedback for lightning-fast gameplay.
  static const blitz = ChallengeMode(
    id: 'blitz',
    name: 'Blitz',
    description: '5 seconds per question. Lightning fast!',
    icon: Icons.flash_on,
    difficulty: ChallengeDifficulty.hard,
    lives: 1,
    questionTimeSeconds: 5,
    questionCount: null,
    showHints: false,
    allowSkip: false,
    showAnswerFeedback: false,
  );

  /// All available challenges in display order.
  static const List<ChallengeMode> all = [
    survival,
    timeAttack,
    speedRun,
    marathon,
    blitz,
  ];

  /// Challenges sorted by difficulty (easy first).
  static List<ChallengeMode> get sortedByDifficulty {
    final sorted = List<ChallengeMode>.from(all);
    sorted.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
    return sorted;
  }
}
