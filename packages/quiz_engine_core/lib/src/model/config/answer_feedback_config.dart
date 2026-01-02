/// Configuration for answer feedback display behavior.
///
/// Controls when and whether to show feedback after answering a question.
/// This is used by [QuizModeConfig] to determine feedback display rules.
sealed class AnswerFeedbackConfig {
  const AnswerFeedbackConfig();

  /// Show feedback for both correct and incorrect answers.
  ///
  /// This is the default behavior for standard quiz modes.
  factory AnswerFeedbackConfig.always() = AlwaysFeedbackConfig;

  /// Show feedback only when the answer is incorrect.
  ///
  /// Useful for modes where you want to highlight mistakes without
  /// interrupting flow on correct answers.
  factory AnswerFeedbackConfig.onlyOnFailure() = OnlyOnFailureFeedbackConfig;

  /// Don't show any feedback after answering.
  ///
  /// Used in challenge modes or speed-focused quizzes where
  /// immediate progression is desired.
  factory AnswerFeedbackConfig.none() = NoFeedbackConfig;

  /// Whether to show feedback for the given answer result.
  ///
  /// [isCorrect] - Whether the user's answer was correct.
  /// Returns true if feedback should be displayed.
  bool shouldShowFeedback(bool isCorrect);

  /// Whether feedback can be shown at all.
  bool get canBeShown => this is! NoFeedbackConfig;

  /// Convert to map for serialization.
  Map<String, dynamic> toMap();

  /// Deserialize from map.
  factory AnswerFeedbackConfig.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String? ?? 'always';
    return switch (type) {
      'always' => const AlwaysFeedbackConfig(),
      'onlyOnFailure' => const OnlyOnFailureFeedbackConfig(),
      'none' => const NoFeedbackConfig(),
      _ => const AlwaysFeedbackConfig(), // Default fallback
    };
  }

  /// Deserialize from legacy boolean value.
  ///
  /// For backward compatibility with old configs that used boolean.
  /// - true -> AlwaysFeedbackConfig
  /// - false -> NoFeedbackConfig
  factory AnswerFeedbackConfig.fromBool(bool showFeedback) {
    return showFeedback
        ? const AlwaysFeedbackConfig()
        : const NoFeedbackConfig();
  }
}

/// Show feedback for both correct and incorrect answers.
class AlwaysFeedbackConfig extends AnswerFeedbackConfig {
  const AlwaysFeedbackConfig();

  @override
  bool shouldShowFeedback(bool isCorrect) => true;

  @override
  Map<String, dynamic> toMap() => {'type': 'always'};

  @override
  bool operator ==(Object other) => other is AlwaysFeedbackConfig;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AnswerFeedbackConfig.always()';
}

/// Show feedback only when the answer is incorrect.
class OnlyOnFailureFeedbackConfig extends AnswerFeedbackConfig {
  const OnlyOnFailureFeedbackConfig();

  @override
  bool shouldShowFeedback(bool isCorrect) => !isCorrect;

  @override
  Map<String, dynamic> toMap() => {'type': 'onlyOnFailure'};

  @override
  bool operator ==(Object other) => other is OnlyOnFailureFeedbackConfig;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AnswerFeedbackConfig.onlyOnFailure()';
}

/// Don't show any feedback after answering.
class NoFeedbackConfig extends AnswerFeedbackConfig {
  const NoFeedbackConfig();

  @override
  bool shouldShowFeedback(bool isCorrect) => false;

  @override
  Map<String, dynamic> toMap() => {'type': 'none'};

  @override
  bool operator ==(Object other) => other is NoFeedbackConfig;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AnswerFeedbackConfig.none()';
}