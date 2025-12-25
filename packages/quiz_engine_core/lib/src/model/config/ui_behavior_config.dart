import 'base_config.dart';

/// Configuration for UI feedback behavior during quiz
///
/// Note: `showAnswerFeedback` has been moved to per-category/per-mode
/// configuration in QuizCategory and QuizModeConfig.
class UIBehaviorConfig extends BaseConfig {
  /// Duration to show feedback before moving to next question (milliseconds)
  final int answerFeedbackDuration;

  /// Play sound effects on answer
  final bool playSounds;

  /// Enable haptic feedback on answer
  final bool hapticFeedback;

  /// Show exit confirmation dialog when user tries to leave quiz
  final bool showExitConfirmation;

  @override
  final int version;

  const UIBehaviorConfig({
    this.answerFeedbackDuration = 1500,
    this.playSounds = true,
    this.hapticFeedback = true,
    this.showExitConfirmation = true,
    this.version = 1,
  });

  /// No feedback configuration (instant progression)
  const UIBehaviorConfig.noFeedback()
    : answerFeedbackDuration = 0,
      playSounds = false,
      hapticFeedback = false,
      showExitConfirmation = true,
      version = 1;

  /// Silent configuration (no sound/haptics)
  const UIBehaviorConfig.silent({
    this.answerFeedbackDuration = 1500,
  }) : playSounds = false,
       hapticFeedback = false,
       showExitConfirmation = true,
       version = 1;

  @override
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'answerFeedbackDuration': answerFeedbackDuration,
      'playSounds': playSounds,
      'hapticFeedback': hapticFeedback,
      'showExitConfirmation': showExitConfirmation,
    };
  }

  factory UIBehaviorConfig.fromMap(Map<String, dynamic> map) {
    return UIBehaviorConfig(
      version: map['version'] as int? ?? 1,
      answerFeedbackDuration: map['answerFeedbackDuration'] as int? ?? 1500,
      playSounds: map['playSounds'] as bool? ?? true,
      hapticFeedback: map['hapticFeedback'] as bool? ?? true,
      showExitConfirmation: map['showExitConfirmation'] as bool? ?? true,
    );
  }

  UIBehaviorConfig copyWith({
    int? answerFeedbackDuration,
    bool? playSounds,
    bool? hapticFeedback,
    bool? showExitConfirmation,
  }) {
    return UIBehaviorConfig(
      answerFeedbackDuration:
          answerFeedbackDuration ?? this.answerFeedbackDuration,
      playSounds: playSounds ?? this.playSounds,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showExitConfirmation: showExitConfirmation ?? this.showExitConfirmation,
      version: version,
    );
  }
}
