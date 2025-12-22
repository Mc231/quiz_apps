import 'base_config.dart';

/// Defines different quiz game modes
enum QuizMode {
  /// Standard mode - answer all questions, no time limit, no lives
  standard,

  /// Timed mode - answer questions within time limit
  timed,

  /// Lives mode - lose lives on wrong answers, game over at 0
  lives,

  /// Endless mode - keep answering until wrong answer
  endless,

  /// Survival mode - timed + lives combined
  survival,
}

/// Configuration for quiz mode behavior
class QuizModeConfig extends BaseConfig {
  final QuizMode mode;

  /// Time limit per question in seconds (for timed/survival modes)
  final int? timePerQuestion;

  /// Total time limit for entire quiz in seconds (for timed/survival modes)
  final int? totalTimeLimit;

  /// Number of lives (for lives/survival modes)
  final int? lives;

  /// Allow skipping questions
  final bool allowSkip;

  /// Infinite questions (for endless mode)
  final bool infinite;

  @override
  final int version;

  const QuizModeConfig._({
    required this.mode,
    this.timePerQuestion,
    this.totalTimeLimit,
    this.lives,
    required this.allowSkip,
    required this.infinite,
    this.version = 1,
  });

  /// Standard mode: no time limits, no lives
  const QuizModeConfig.standard()
    : mode = QuizMode.standard,
      timePerQuestion = null,
      totalTimeLimit = null,
      lives = null,
      allowSkip = false,
      infinite = false,
      version = 1;

  /// Timed mode: answer within time limit
  const QuizModeConfig.timed({
    this.timePerQuestion = 30,
    this.totalTimeLimit,
    this.allowSkip = false,
  }) : mode = QuizMode.timed,
       lives = null,
       infinite = false,
       version = 1;

  /// Lives mode: lose lives on mistakes
  const QuizModeConfig.lives({this.lives = 3, this.allowSkip = false})
    : mode = QuizMode.lives,
      timePerQuestion = null,
      totalTimeLimit = null,
      infinite = false,
      version = 1;

  /// Endless mode: keep going until first mistake
  const QuizModeConfig.endless()
    : mode = QuizMode.endless,
      timePerQuestion = null,
      totalTimeLimit = null,
      lives = 1, // One mistake ends the game
      allowSkip = false,
      infinite = true,
      version = 1;

  /// Survival mode: timed + lives combined
  const QuizModeConfig.survival({
    this.lives = 3,
    this.timePerQuestion = 30,
    this.totalTimeLimit,
  }) : mode = QuizMode.survival,
       allowSkip = false,
       infinite = false,
       version = 1;

  @override
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'mode': mode.name,
      'timePerQuestion': timePerQuestion,
      'totalTimeLimit': totalTimeLimit,
      'lives': lives,
      'allowSkip': allowSkip,
      'infinite': infinite,
    };
  }

  factory QuizModeConfig.fromMap(Map<String, dynamic> map) {
    final version = map['version'] as int? ?? 1;
    final modeName = map['mode'] as String;
    final mode = QuizMode.values.firstWhere((e) => e.name == modeName);

    return QuizModeConfig._(
      mode: mode,
      timePerQuestion: map['timePerQuestion'] as int?,
      totalTimeLimit: map['totalTimeLimit'] as int?,
      lives: map['lives'] as int?,
      allowSkip: map['allowSkip'] as bool? ?? false,
      infinite: map['infinite'] as bool? ?? false,
      version: version,
    );
  }

  QuizModeConfig copyWith({
    QuizMode? mode,
    int? timePerQuestion,
    int? totalTimeLimit,
    int? lives,
    bool? allowSkip,
    bool? infinite,
  }) {
    return QuizModeConfig._(
      mode: mode ?? this.mode,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      totalTimeLimit: totalTimeLimit ?? this.totalTimeLimit,
      lives: lives ?? this.lives,
      allowSkip: allowSkip ?? this.allowSkip,
      infinite: infinite ?? this.infinite,
      version: version,
    );
  }
}
