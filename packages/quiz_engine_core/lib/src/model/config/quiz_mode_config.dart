import 'answer_feedback_config.dart';
import 'base_config.dart';

/// Base sealed class for quiz mode configurations
/// Each mode has its own subclass with type-safe fields
sealed class QuizModeConfig extends BaseConfig {
  const QuizModeConfig();

  /// Returns the number of lives for this mode, or null if lives are not tracked
  int? get lives => switch (this) {
    LivesMode(:final lives) => lives,
    SurvivalMode(:final lives) => lives,
    EndlessMode() => 1, // One mistake ends the game
    _ => null, // No lives tracking
  };

  /// Configuration for answer feedback display behavior.
  ///
  /// Determines when to show feedback after answering a question:
  /// - [AlwaysFeedbackConfig] - Show for both correct and incorrect
  /// - [OnlyOnFailureFeedbackConfig] - Show only on wrong answers
  /// - [NoFeedbackConfig] - Never show feedback
  AnswerFeedbackConfig get answerFeedbackConfig => switch (this) {
    StandardMode(:final answerFeedbackConfig) => answerFeedbackConfig,
    TimedMode(:final answerFeedbackConfig) => answerFeedbackConfig,
    LivesMode(:final answerFeedbackConfig) => answerFeedbackConfig,
    EndlessMode(:final answerFeedbackConfig) => answerFeedbackConfig,
    SurvivalMode(:final answerFeedbackConfig) => answerFeedbackConfig,
  };

  /// Factory method for standard mode: no time limits, no lives
  factory QuizModeConfig.standard({
    AnswerFeedbackConfig answerFeedbackConfig = const AlwaysFeedbackConfig(),
    bool allowSkip = false,
  }) {
    return StandardMode(
      answerFeedbackConfig: answerFeedbackConfig,
      allowSkip: allowSkip,
    );
  }

  /// Factory method for timed mode: answer within time limit
  factory QuizModeConfig.timed({
    AnswerFeedbackConfig answerFeedbackConfig = const NoFeedbackConfig(),
    int timePerQuestion = 30,
    int? totalTimeLimit,
    bool allowSkip = false,
  }) {
    return TimedMode(
      answerFeedbackConfig: answerFeedbackConfig,
      timePerQuestion: timePerQuestion,
      totalTimeLimit: totalTimeLimit,
      allowSkip: allowSkip,
    );
  }

  /// Factory method for lives mode: lose lives on mistakes
  factory QuizModeConfig.lives({
    AnswerFeedbackConfig answerFeedbackConfig = const NoFeedbackConfig(),
    int lives = 3,
    bool allowSkip = false,
  }) {
    return LivesMode(
      answerFeedbackConfig: answerFeedbackConfig,
      lives: lives,
      allowSkip: allowSkip,
    );
  }

  /// Factory method for endless mode: keep going until first mistake
  factory QuizModeConfig.endless({
    AnswerFeedbackConfig answerFeedbackConfig = const NoFeedbackConfig(),
  }) {
    return EndlessMode(answerFeedbackConfig: answerFeedbackConfig);
  }

  /// Factory method for survival mode: timed + lives combined
  factory QuizModeConfig.survival({
    AnswerFeedbackConfig answerFeedbackConfig = const NoFeedbackConfig(),
    int lives = 3,
    int timePerQuestion = 30,
    int? totalTimeLimit,
  }) {
    return SurvivalMode(
      answerFeedbackConfig: answerFeedbackConfig,
      lives: lives,
      timePerQuestion: timePerQuestion,
      totalTimeLimit: totalTimeLimit,
    );
  }

  /// Deserialize from map
  factory QuizModeConfig.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;
    final _ = map['version'] as int? ?? 1;

    return switch (type) {
      'standard' => StandardMode.fromMap(map),
      'timed' => TimedMode.fromMap(map),
      'lives' => LivesMode.fromMap(map),
      'endless' => EndlessMode.fromMap(map),
      'survival' => SurvivalMode.fromMap(map),
      _ => throw ArgumentError('Unknown mode type: $type'),
    };
  }

  @override
  int get version => 1;
}

/// Helper to parse answer feedback config from map with backward compatibility.
AnswerFeedbackConfig _parseAnswerFeedbackConfig(
  Map<String, dynamic> map,
  AnswerFeedbackConfig defaultConfig,
) {
  // Check for new format first
  if (map.containsKey('answerFeedbackConfig')) {
    final configMap = map['answerFeedbackConfig'];
    if (configMap is Map<String, dynamic>) {
      return AnswerFeedbackConfig.fromMap(configMap);
    }
  }

  // Backward compatibility: check for legacy boolean field
  if (map.containsKey('showAnswerFeedback')) {
    final showFeedback = map['showAnswerFeedback'] as bool? ?? true;
    return AnswerFeedbackConfig.fromBool(showFeedback);
  }

  // Return mode-specific default
  return defaultConfig;
}

/// Standard mode - answer all questions, no time limit, no lives
class StandardMode extends QuizModeConfig {
  final bool allowSkip;

  @override
  final AnswerFeedbackConfig answerFeedbackConfig;

  const StandardMode({
    this.answerFeedbackConfig = const AlwaysFeedbackConfig(),
    this.allowSkip = false,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'standard',
      'version': version,
      'allowSkip': allowSkip,
      'answerFeedbackConfig': answerFeedbackConfig.toMap(),
    };
  }

  factory StandardMode.fromMap(Map<String, dynamic> map) {
    return StandardMode(
      answerFeedbackConfig: _parseAnswerFeedbackConfig(
        map,
        const AlwaysFeedbackConfig(),
      ),
      allowSkip: map['allowSkip'] as bool? ?? false,
    );
  }

  StandardMode copyWith({
    bool? allowSkip,
    AnswerFeedbackConfig? answerFeedbackConfig,
  }) {
    return StandardMode(
      answerFeedbackConfig: answerFeedbackConfig ?? this.answerFeedbackConfig,
      allowSkip: allowSkip ?? this.allowSkip,
    );
  }
}

/// Timed mode - answer questions within time limit
class TimedMode extends QuizModeConfig {
  /// Time limit per question in seconds
  final int timePerQuestion;

  /// Total time limit for entire quiz in seconds (optional)
  final int? totalTimeLimit;

  final bool allowSkip;

  @override
  final AnswerFeedbackConfig answerFeedbackConfig;

  const TimedMode({
    this.answerFeedbackConfig = const NoFeedbackConfig(),
    this.timePerQuestion = 30,
    this.totalTimeLimit,
    this.allowSkip = false,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'timed',
      'version': version,
      'timePerQuestion': timePerQuestion,
      'totalTimeLimit': totalTimeLimit,
      'allowSkip': allowSkip,
      'answerFeedbackConfig': answerFeedbackConfig.toMap(),
    };
  }

  factory TimedMode.fromMap(Map<String, dynamic> map) {
    return TimedMode(
      answerFeedbackConfig: _parseAnswerFeedbackConfig(
        map,
        const NoFeedbackConfig(),
      ),
      timePerQuestion: map['timePerQuestion'] as int? ?? 30,
      totalTimeLimit: map['totalTimeLimit'] as int?,
      allowSkip: map['allowSkip'] as bool? ?? false,
    );
  }

  TimedMode copyWith({
    int? timePerQuestion,
    int? totalTimeLimit,
    bool? allowSkip,
    AnswerFeedbackConfig? answerFeedbackConfig,
  }) {
    return TimedMode(
      answerFeedbackConfig: answerFeedbackConfig ?? this.answerFeedbackConfig,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      totalTimeLimit: totalTimeLimit ?? this.totalTimeLimit,
      allowSkip: allowSkip ?? this.allowSkip,
    );
  }
}

/// Lives mode - lose lives on wrong answers, game over at 0
class LivesMode extends QuizModeConfig {
  /// Number of lives available
  @override
  final int lives;

  final bool allowSkip;

  @override
  final AnswerFeedbackConfig answerFeedbackConfig;

  const LivesMode({
    this.answerFeedbackConfig = const NoFeedbackConfig(),
    this.lives = 3,
    this.allowSkip = false,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'lives',
      'version': version,
      'lives': lives,
      'allowSkip': allowSkip,
      'answerFeedbackConfig': answerFeedbackConfig.toMap(),
    };
  }

  factory LivesMode.fromMap(Map<String, dynamic> map) {
    return LivesMode(
      answerFeedbackConfig: _parseAnswerFeedbackConfig(
        map,
        const NoFeedbackConfig(),
      ),
      lives: map['lives'] as int? ?? 3,
      allowSkip: map['allowSkip'] as bool? ?? false,
    );
  }

  LivesMode copyWith({
    int? lives,
    bool? allowSkip,
    AnswerFeedbackConfig? answerFeedbackConfig,
  }) {
    return LivesMode(
      answerFeedbackConfig: answerFeedbackConfig ?? this.answerFeedbackConfig,
      lives: lives ?? this.lives,
      allowSkip: allowSkip ?? this.allowSkip,
    );
  }
}

/// Endless mode - keep answering until wrong answer
class EndlessMode extends QuizModeConfig {
  @override
  final AnswerFeedbackConfig answerFeedbackConfig;

  const EndlessMode({
    this.answerFeedbackConfig = const NoFeedbackConfig(),
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'endless',
      'version': version,
      'answerFeedbackConfig': answerFeedbackConfig.toMap(),
    };
  }

  factory EndlessMode.fromMap(Map<String, dynamic> map) {
    return EndlessMode(
      answerFeedbackConfig: _parseAnswerFeedbackConfig(
        map,
        const NoFeedbackConfig(),
      ),
    );
  }

  EndlessMode copyWith({AnswerFeedbackConfig? answerFeedbackConfig}) {
    return EndlessMode(
      answerFeedbackConfig: answerFeedbackConfig ?? this.answerFeedbackConfig,
    );
  }
}

/// Survival mode - timed + lives combined
class SurvivalMode extends QuizModeConfig {
  /// Number of lives available
  @override
  final int lives;

  /// Time limit per question in seconds
  final int timePerQuestion;

  /// Total time limit for entire quiz in seconds (optional)
  final int? totalTimeLimit;

  @override
  final AnswerFeedbackConfig answerFeedbackConfig;

  const SurvivalMode({
    this.answerFeedbackConfig = const NoFeedbackConfig(),
    this.lives = 3,
    this.timePerQuestion = 30,
    this.totalTimeLimit,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'survival',
      'version': version,
      'lives': lives,
      'timePerQuestion': timePerQuestion,
      'totalTimeLimit': totalTimeLimit,
      'answerFeedbackConfig': answerFeedbackConfig.toMap(),
    };
  }

  factory SurvivalMode.fromMap(Map<String, dynamic> map) {
    return SurvivalMode(
      answerFeedbackConfig: _parseAnswerFeedbackConfig(
        map,
        const NoFeedbackConfig(),
      ),
      lives: map['lives'] as int? ?? 3,
      timePerQuestion: map['timePerQuestion'] as int? ?? 30,
      totalTimeLimit: map['totalTimeLimit'] as int?,
    );
  }

  SurvivalMode copyWith({
    int? lives,
    int? timePerQuestion,
    int? totalTimeLimit,
    AnswerFeedbackConfig? answerFeedbackConfig,
  }) {
    return SurvivalMode(
      answerFeedbackConfig: answerFeedbackConfig ?? this.answerFeedbackConfig,
      lives: lives ?? this.lives,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      totalTimeLimit: totalTimeLimit ?? this.totalTimeLimit,
    );
  }
}