import 'package:flutter/services.dart';

/// Types of haptic feedback available
enum HapticFeedbackType {
  /// Light impact feedback (suitable for UI interactions)
  light,

  /// Medium impact feedback (suitable for important actions)
  medium,

  /// Heavy impact feedback (suitable for critical actions or errors)
  heavy,

  /// Selection changed feedback (suitable for picker/selector changes)
  selection,

  /// Vibration feedback (long press or error indication)
  vibrate,
}

/// Service for providing haptic feedback in quiz applications
///
/// Wraps Flutter's HapticFeedback API with a convenient interface
/// and additional controls for enabling/disabling feedback.
///
/// Example:
/// ```dart
/// final hapticService = HapticService();
/// await hapticService.impact(HapticFeedbackType.light);
/// ```
class HapticService {
  bool _isEnabled = true;

  /// Whether haptic feedback is currently enabled
  bool get isEnabled => _isEnabled;

  /// Enables or disables haptic feedback
  ///
  /// [enabled] - true to enable, false to disable
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Toggles haptic feedback on/off
  ///
  /// Returns the new enabled state
  bool toggle() {
    _isEnabled = !_isEnabled;
    return _isEnabled;
  }

  /// Triggers haptic feedback with the specified type
  ///
  /// [type] - The type of haptic feedback to trigger
  ///
  /// Does nothing if haptic feedback is disabled.
  Future<void> impact(HapticFeedbackType type) async {
    if (!_isEnabled) return;

    try {
      switch (type) {
        case HapticFeedbackType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticFeedbackType.vibrate:
          await HapticFeedback.vibrate();
          break;
      }
    } catch (e) {
      // Silently fail if haptic feedback is not supported
      // This prevents crashes on platforms without haptic support
      // ignore: avoid_print
      print('Haptic feedback error: $e');
    }
  }

  /// Provides feedback for a correct answer
  ///
  /// Uses light impact for positive reinforcement
  Future<void> correctAnswer() async {
    await impact(HapticFeedbackType.light);
  }

  /// Provides feedback for an incorrect answer
  ///
  /// Uses medium impact to indicate error without being too harsh
  Future<void> incorrectAnswer() async {
    await impact(HapticFeedbackType.medium);
  }

  /// Provides feedback for button clicks and UI interactions
  ///
  /// Uses selection feedback for subtle interaction confirmation
  Future<void> buttonClick() async {
    await impact(HapticFeedbackType.selection);
  }

  /// Provides feedback for important actions
  ///
  /// Uses heavy impact for quiz completion or achievements
  Future<void> importantAction() async {
    await impact(HapticFeedbackType.heavy);
  }

  /// Provides feedback for errors or critical situations
  ///
  /// Uses vibrate for strong indication of problems
  Future<void> error() async {
    await impact(HapticFeedbackType.vibrate);
  }
}
