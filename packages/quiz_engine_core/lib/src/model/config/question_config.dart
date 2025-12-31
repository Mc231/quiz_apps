import 'base_config.dart';
import 'quiz_layout_config.dart';

/// Configuration for question behavior and presentation
class QuestionConfig extends BaseConfig {
  /// Number of options per question (2, 4, 6, etc.)
  final int optionCount;

  /// Shuffle questions order
  final bool shuffleQuestions;

  /// Shuffle answer options order
  final bool shuffleOptions;

  /// Layout configuration for questions and answers.
  ///
  /// Defines how questions and answers are displayed.
  /// If null, defaults to [ImageQuestionTextAnswersLayout].
  final QuizLayoutConfig? layoutConfig;

  @override
  final int version;

  const QuestionConfig({
    this.optionCount = 4,
    this.shuffleQuestions = true,
    this.shuffleOptions = true,
    this.layoutConfig,
    this.version = 1,
  });

  /// Fixed order configuration (no shuffling)
  const QuestionConfig.fixedOrder({
    this.optionCount = 4,
    this.layoutConfig,
  }) : shuffleQuestions = false,
       shuffleOptions = false,
       version = 1;

  /// True/False questions (2 options)
  const QuestionConfig.trueFalse({
    this.shuffleQuestions = true,
    this.layoutConfig,
  }) : optionCount = 2,
       shuffleOptions = true,
       version = 1;

  /// Multiple choice with custom option count
  const QuestionConfig.multipleChoice({
    this.optionCount = 4,
    this.shuffleQuestions = true,
    this.shuffleOptions = true,
    this.layoutConfig,
  }) : version = 1;

  @override
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'optionCount': optionCount,
      'shuffleQuestions': shuffleQuestions,
      'shuffleOptions': shuffleOptions,
      if (layoutConfig != null) 'layoutConfig': layoutConfig!.toMap(),
    };
  }

  factory QuestionConfig.fromMap(Map<String, dynamic> map) {
    return QuestionConfig(
      version: map['version'] as int? ?? 1,
      optionCount: map['optionCount'] as int? ?? 4,
      shuffleQuestions: map['shuffleQuestions'] as bool? ?? true,
      shuffleOptions: map['shuffleOptions'] as bool? ?? true,
      layoutConfig: map['layoutConfig'] != null
          ? QuizLayoutConfig.fromMap(map['layoutConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  QuestionConfig copyWith({
    int? optionCount,
    bool? shuffleQuestions,
    bool? shuffleOptions,
    QuizLayoutConfig? layoutConfig,
  }) {
    return QuestionConfig(
      optionCount: optionCount ?? this.optionCount,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      version: version,
    );
  }
}