import 'base_config.dart';
import 'quiz_mode_config.dart';
import 'hint_config.dart';
import 'quiz_layout_config.dart';
import 'scoring_strategy.dart';
import 'storage_config.dart';
import 'ui_behavior_config.dart';
import 'question_config.dart';

/// Main configuration for a quiz session
/// Contains all settings for quiz behavior, UI feedback, hints, and question handling
class QuizConfig extends BaseConfig {
  // Core settings
  /// Unique identifier for this quiz (e.g., "flags_europe", "capitals_asia")
  final String quizId;

  /// Configuration for quiz game mode (standard, timed, lives, etc.)
  final QuizModeConfig modeConfig;

  /// Strategy for calculating score
  final ScoringStrategy scoringStrategy;

  /// Configuration for UI feedback behavior
  final UIBehaviorConfig uiBehaviorConfig;

  /// Configuration for hint system
  final HintConfig hintConfig;

  /// Configuration for question behavior
  final QuestionConfig questionConfig;

  /// Configuration for storage and persistence
  final StorageConfig storageConfig;

  /// Configuration for quiz layout.
  ///
  /// Determines how questions and answers are displayed.
  /// Supports various layouts including [ImageQuestionTextAnswersLayout] (default),
  /// [TextQuestionImageAnswersLayout], [TextQuestionTextAnswersLayout],
  /// [AudioQuestionTextAnswersLayout], and [MixedLayout] for varying layouts.
  ///
  /// When [MixedLayout] is used, the layout is resolved per-question based on
  /// the configured strategy.
  final QuizLayoutConfig layoutConfig;

  @override
  final int version;

  const QuizConfig({
    required this.quizId,
    this.modeConfig = const StandardMode(showAnswerFeedback: true),
    this.scoringStrategy = const SimpleScoring(),
    this.uiBehaviorConfig = const UIBehaviorConfig(),
    this.hintConfig = const HintConfig(),
    this.questionConfig = const QuestionConfig(),
    this.storageConfig = const StorageConfig(),
    this.layoutConfig = const ImageQuestionTextAnswersLayout(),
    this.version = 1,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'quizId': quizId,
      'modeConfig': modeConfig.toMap(),
      'scoringStrategy': scoringStrategy.toMap(),
      'uiBehaviorConfig': uiBehaviorConfig.toMap(),
      'hintConfig': hintConfig.toMap(),
      'questionConfig': questionConfig.toMap(),
      'storageConfig': storageConfig.toMap(),
      'layoutConfig': layoutConfig.toMap(),
    };
  }

  factory QuizConfig.fromMap(Map<String, dynamic> map) {
    return QuizConfig(
      version: map['version'] as int? ?? 1,
      quizId: map['quizId'] as String,
      modeConfig: QuizModeConfig.fromMap(
        map['modeConfig'] as Map<String, dynamic>,
      ),
      scoringStrategy: ScoringStrategy.fromMap(
        map['scoringStrategy'] as Map<String, dynamic>,
      ),
      uiBehaviorConfig: UIBehaviorConfig.fromMap(
        map['uiBehaviorConfig'] as Map<String, dynamic>? ?? {},
      ),
      hintConfig: HintConfig.fromMap(
        map['hintConfig'] as Map<String, dynamic>? ?? {},
      ),
      questionConfig: QuestionConfig.fromMap(
        map['questionConfig'] as Map<String, dynamic>? ?? {},
      ),
      storageConfig: StorageConfig.fromMap(
        map['storageConfig'] as Map<String, dynamic>? ?? {},
      ),
      layoutConfig: map['layoutConfig'] != null
          ? QuizLayoutConfig.fromMap(map['layoutConfig'] as Map<String, dynamic>)
          : const ImageQuestionTextAnswersLayout(),
    );
  }

  QuizConfig copyWith({
    String? quizId,
    QuizModeConfig? modeConfig,
    ScoringStrategy? scoringStrategy,
    UIBehaviorConfig? uiBehaviorConfig,
    HintConfig? hintConfig,
    QuestionConfig? questionConfig,
    StorageConfig? storageConfig,
    QuizLayoutConfig? layoutConfig,
  }) {
    return QuizConfig(
      quizId: quizId ?? this.quizId,
      modeConfig: modeConfig ?? this.modeConfig,
      scoringStrategy: scoringStrategy ?? this.scoringStrategy,
      uiBehaviorConfig: uiBehaviorConfig ?? this.uiBehaviorConfig,
      hintConfig: hintConfig ?? this.hintConfig,
      questionConfig: questionConfig ?? this.questionConfig,
      storageConfig: storageConfig ?? this.storageConfig,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      version: version,
    );
  }
}
