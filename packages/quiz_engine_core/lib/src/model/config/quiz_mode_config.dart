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

  /// Whether to show answer feedback for this mode.
  ///
  /// If null, uses the category default or global default.
  /// This allows mode-specific override of feedback behavior.
  bool? get showAnswerFeedback => switch (this) {
    StandardMode(:final showAnswerFeedback) => showAnswerFeedback,
    TimedMode(:final showAnswerFeedback) => showAnswerFeedback,
    LivesMode(:final showAnswerFeedback) => showAnswerFeedback,
    EndlessMode(:final showAnswerFeedback) => showAnswerFeedback,
    SurvivalMode(:final showAnswerFeedback) => showAnswerFeedback,
  };

  /// Factory method for standard mode: no time limits, no lives
  factory QuizModeConfig.standard({
    bool allowSkip = false,
    bool? showAnswerFeedback,
  }) {
    return StandardMode(
      allowSkip: allowSkip,
      showAnswerFeedback: showAnswerFeedback,
    );
  }

  /// Factory method for timed mode: answer within time limit
  factory QuizModeConfig.timed({
    int timePerQuestion = 30,
    int? totalTimeLimit,
    bool allowSkip = false,
    bool? showAnswerFeedback,
  }) {
    return TimedMode(
      timePerQuestion: timePerQuestion,
      totalTimeLimit: totalTimeLimit,
      allowSkip: allowSkip,
      showAnswerFeedback: showAnswerFeedback,
    );
  }

  /// Factory method for lives mode: lose lives on mistakes
  factory QuizModeConfig.lives({
    int lives = 3,
    bool allowSkip = false,
    bool? showAnswerFeedback,
  }) {
    return LivesMode(
      lives: lives,
      allowSkip: allowSkip,
      showAnswerFeedback: showAnswerFeedback,
    );
  }

  /// Factory method for endless mode: keep going until first mistake
  factory QuizModeConfig.endless({bool? showAnswerFeedback}) {
    return EndlessMode(showAnswerFeedback: showAnswerFeedback);
  }

  /// Factory method for survival mode: timed + lives combined
  factory QuizModeConfig.survival({
    int lives = 3,
    int timePerQuestion = 30,
    int? totalTimeLimit,
    bool? showAnswerFeedback,
  }) {
    return SurvivalMode(
      lives: lives,
      timePerQuestion: timePerQuestion,
      totalTimeLimit: totalTimeLimit,
      showAnswerFeedback: showAnswerFeedback,
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

/// Standard mode - answer all questions, no time limit, no lives
class StandardMode extends QuizModeConfig {
  final bool allowSkip;

  @override
  final bool? showAnswerFeedback;

  const StandardMode({this.allowSkip = false, this.showAnswerFeedback});

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'standard',
      'version': version,
      'allowSkip': allowSkip,
      'showAnswerFeedback': showAnswerFeedback,
    };
  }

  factory StandardMode.fromMap(Map<String, dynamic> map) {
    return StandardMode(
      allowSkip: map['allowSkip'] as bool? ?? false,
      showAnswerFeedback: map['showAnswerFeedback'] as bool?,
    );
  }

  StandardMode copyWith({bool? allowSkip, bool? showAnswerFeedback}) {
    return StandardMode(
      allowSkip: allowSkip ?? this.allowSkip,
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
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
  final bool? showAnswerFeedback;

  const TimedMode({
    this.timePerQuestion = 30,
    this.totalTimeLimit,
    this.allowSkip = false,
    this.showAnswerFeedback,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'timed',
      'version': version,
      'timePerQuestion': timePerQuestion,
      'totalTimeLimit': totalTimeLimit,
      'allowSkip': allowSkip,
      'showAnswerFeedback': showAnswerFeedback,
    };
  }

  factory TimedMode.fromMap(Map<String, dynamic> map) {
    return TimedMode(
      timePerQuestion: map['timePerQuestion'] as int? ?? 30,
      totalTimeLimit: map['totalTimeLimit'] as int?,
      allowSkip: map['allowSkip'] as bool? ?? false,
      showAnswerFeedback: map['showAnswerFeedback'] as bool?,
    );
  }

  TimedMode copyWith({
    int? timePerQuestion,
    int? totalTimeLimit,
    bool? allowSkip,
    bool? showAnswerFeedback,
  }) {
    return TimedMode(
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      totalTimeLimit: totalTimeLimit ?? this.totalTimeLimit,
      allowSkip: allowSkip ?? this.allowSkip,
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
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
  final bool? showAnswerFeedback;

  const LivesMode({
    this.lives = 3,
    this.allowSkip = false,
    this.showAnswerFeedback,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'lives',
      'version': version,
      'lives': lives,
      'allowSkip': allowSkip,
      'showAnswerFeedback': showAnswerFeedback,
    };
  }

  factory LivesMode.fromMap(Map<String, dynamic> map) {
    return LivesMode(
      lives: map['lives'] as int? ?? 3,
      allowSkip: map['allowSkip'] as bool? ?? false,
      showAnswerFeedback: map['showAnswerFeedback'] as bool?,
    );
  }

  LivesMode copyWith({int? lives, bool? allowSkip, bool? showAnswerFeedback}) {
    return LivesMode(
      lives: lives ?? this.lives,
      allowSkip: allowSkip ?? this.allowSkip,
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
    );
  }
}

/// Endless mode - keep answering until wrong answer
class EndlessMode extends QuizModeConfig {
  @override
  final bool? showAnswerFeedback;

  const EndlessMode({this.showAnswerFeedback});

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'endless',
      'version': version,
      'showAnswerFeedback': showAnswerFeedback,
    };
  }

  factory EndlessMode.fromMap(Map<String, dynamic> map) {
    return EndlessMode(showAnswerFeedback: map['showAnswerFeedback'] as bool?);
  }

  EndlessMode copyWith({bool? showAnswerFeedback}) {
    return EndlessMode(
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
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
  final bool? showAnswerFeedback;

  const SurvivalMode({
    this.lives = 3,
    this.timePerQuestion = 30,
    this.totalTimeLimit,
    this.showAnswerFeedback,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'survival',
      'version': version,
      'lives': lives,
      'timePerQuestion': timePerQuestion,
      'totalTimeLimit': totalTimeLimit,
      'showAnswerFeedback': showAnswerFeedback,
    };
  }

  factory SurvivalMode.fromMap(Map<String, dynamic> map) {
    return SurvivalMode(
      lives: map['lives'] as int? ?? 3,
      timePerQuestion: map['timePerQuestion'] as int? ?? 30,
      totalTimeLimit: map['totalTimeLimit'] as int?,
      showAnswerFeedback: map['showAnswerFeedback'] as bool?,
    );
  }

  SurvivalMode copyWith({
    int? lives,
    int? timePerQuestion,
    int? totalTimeLimit,
    bool? showAnswerFeedback,
  }) {
    return SurvivalMode(
      lives: lives ?? this.lives,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      totalTimeLimit: totalTimeLimit ?? this.totalTimeLimit,
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
    );
  }
}
