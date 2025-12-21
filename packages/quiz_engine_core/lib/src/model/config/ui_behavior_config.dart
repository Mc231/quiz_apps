import 'base_config.dart';

/// Configuration for UI feedback behavior during quiz
class UIBehaviorConfig extends BaseConfig {
  /// Show visual feedback after answering (correct/incorrect indication)
  final bool showAnswerFeedback;

  /// Duration to show feedback before moving to next question (milliseconds)
  final int answerFeedbackDuration;

  /// Play sound effects on answer
  final bool playSounds;

  /// Enable haptic feedback on answer
  final bool hapticFeedback;

  @override
  final int version;

  const UIBehaviorConfig({
    this.showAnswerFeedback = true,
    this.answerFeedbackDuration = 1500,
    this.playSounds = true,
    this.hapticFeedback = true,
    this.version = 1,
  });

  /// No feedback configuration (instant progression)
  const UIBehaviorConfig.noFeedback()
      : showAnswerFeedback = false,
        answerFeedbackDuration = 0,
        playSounds = false,
        hapticFeedback = false,
        version = 1;

  /// Silent configuration (feedback but no sound/haptics)
  const UIBehaviorConfig.silent({
    this.showAnswerFeedback = true,
    this.answerFeedbackDuration = 1500,
  })  : playSounds = false,
        hapticFeedback = false,
        version = 1;

  @override
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'showAnswerFeedback': showAnswerFeedback,
      'answerFeedbackDuration': answerFeedbackDuration,
      'playSounds': playSounds,
      'hapticFeedback': hapticFeedback,
    };
  }

  factory UIBehaviorConfig.fromMap(Map<String, dynamic> map) {
    return UIBehaviorConfig(
      version: map['version'] as int? ?? 1,
      showAnswerFeedback: map['showAnswerFeedback'] as bool? ?? true,
      answerFeedbackDuration: map['answerFeedbackDuration'] as int? ?? 1500,
      playSounds: map['playSounds'] as bool? ?? true,
      hapticFeedback: map['hapticFeedback'] as bool? ?? true,
    );
  }

  UIBehaviorConfig copyWith({
    bool? showAnswerFeedback,
    int? answerFeedbackDuration,
    bool? playSounds,
    bool? hapticFeedback,
  }) {
    return UIBehaviorConfig(
      showAnswerFeedback: showAnswerFeedback ?? this.showAnswerFeedback,
      answerFeedbackDuration:
          answerFeedbackDuration ?? this.answerFeedbackDuration,
      playSounds: playSounds ?? this.playSounds,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      version: version,
    );
  }
}