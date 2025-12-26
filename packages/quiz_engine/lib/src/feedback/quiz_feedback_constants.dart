/// Constants and recommendations for audio and haptic feedback in quiz apps.
///
/// These constants define balanced volume levels, timing recommendations,
/// and best practices for feedback patterns.
abstract final class QuizFeedbackConstants {
  // ============================================================
  // VOLUME LEVELS
  // ============================================================

  /// Default volume for all sounds (0.0 - 1.0).
  static const double defaultVolume = 0.8;

  /// Volume for UI interaction sounds (button clicks).
  ///
  /// Lower volume to avoid being intrusive.
  static const double uiInteractionVolume = 0.5;

  /// Volume for feedback sounds (correct/incorrect answers).
  ///
  /// Standard volume for clear feedback.
  static const double feedbackVolume = 0.8;

  /// Volume for alert sounds (timer warnings, life lost).
  ///
  /// Slightly higher to draw attention.
  static const double alertVolume = 0.9;

  /// Volume for celebration sounds (achievements, quiz complete).
  ///
  /// Full volume for positive reinforcement.
  static const double celebrationVolume = 1.0;

  // ============================================================
  // TIMING RECOMMENDATIONS
  // ============================================================

  /// Minimum delay between consecutive sounds to prevent overlap.
  static const Duration soundCooldown = Duration(milliseconds: 100);

  /// Delay before playing quiz start sound after navigation.
  static const Duration quizStartDelay = Duration(milliseconds: 300);

  /// Delay for timer warning sound before time expires.
  static const Duration timerWarningThreshold = Duration(seconds: 5);

  // ============================================================
  // HAPTIC INTENSITY GUIDELINES
  // ============================================================

  /// Use [HapticFeedbackType.selection] for:
  /// - Option/button taps
  /// - Navigation selections
  /// - Toggle changes
  static const String hapticSelectionUsage = 'UI selections and toggles';

  /// Use [HapticFeedbackType.light] for:
  /// - Correct answers (positive reinforcement)
  /// - Hint usage
  /// - Quiz start
  /// - Timer warnings
  static const String hapticLightUsage = 'Positive feedback and alerts';

  /// Use [HapticFeedbackType.medium] for:
  /// - Incorrect answers
  /// - Life lost
  /// - Time expired
  static const String hapticMediumUsage = 'Negative feedback';

  /// Use [HapticFeedbackType.heavy] for:
  /// - Resource depleted
  /// - Quiz complete
  /// - Achievement unlocked
  static const String hapticHeavyUsage = 'Significant events';

  /// Use [HapticFeedbackType.vibrate] for:
  /// - Error states
  /// - Invalid actions
  static const String hapticVibrateUsage = 'Error indication';

  // ============================================================
  // SOUND FILE RECOMMENDATIONS
  // ============================================================

  /// Maximum recommended file size per sound effect.
  static const int maxSoundFileSizeBytes = 50 * 1024; // 50KB

  /// Recommended bitrate for sound files.
  static const int recommendedBitrate = 128; // kbps

  /// Recommended duration ranges for sound types.
  static const Duration minSoundDuration = Duration(milliseconds: 100);
  static const Duration maxButtonClickDuration = Duration(milliseconds: 200);
  static const Duration maxFeedbackDuration = Duration(milliseconds: 500);
  static const Duration maxCelebrationDuration = Duration(seconds: 2);
}

/// Recommended volume levels for each sound effect type.
///
/// These values provide a balanced audio experience.
extension QuizSoundVolumeRecommendations on QuizFeedbackConstants {
  /// Gets recommended volume for a sound pattern.
  static double volumeForPattern(String patternName) {
    return switch (patternName) {
      'buttonTap' => QuizFeedbackConstants.uiInteractionVolume,
      'correctAnswer' => QuizFeedbackConstants.feedbackVolume,
      'incorrectAnswer' => QuizFeedbackConstants.feedbackVolume,
      'hintUsed' => QuizFeedbackConstants.uiInteractionVolume,
      'lifeLost' => QuizFeedbackConstants.alertVolume,
      'timerWarning' => QuizFeedbackConstants.alertVolume,
      'timeout' => QuizFeedbackConstants.alertVolume,
      'quizStart' => QuizFeedbackConstants.feedbackVolume,
      'quizComplete' => QuizFeedbackConstants.celebrationVolume,
      'achievementUnlocked' => QuizFeedbackConstants.celebrationVolume,
      _ => QuizFeedbackConstants.defaultVolume,
    };
  }
}
