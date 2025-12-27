import '../analytics_event.dart';

/// Sealed class for settings-related events.
///
/// Tracks user settings changes and preferences interactions.
/// Total: 8 events.
sealed class SettingsEvent extends AnalyticsEvent {
  const SettingsEvent();

  // ============ Settings Change Events ============

  /// Generic settings changed event.
  factory SettingsEvent.changed({
    required String settingName,
    required String oldValue,
    required String newValue,
    String? settingCategory,
  }) = SettingsChangedEvent;

  /// Sound effects toggled event.
  factory SettingsEvent.soundEffectsToggled({
    required bool enabled,
    required String source,
  }) = SoundEffectsToggledEvent;

  /// Haptic feedback toggled event.
  factory SettingsEvent.hapticFeedbackToggled({
    required bool enabled,
    required String source,
  }) = HapticFeedbackToggledEvent;

  /// Theme changed event.
  factory SettingsEvent.themeChanged({
    required String newTheme,
    required String previousTheme,
    required String source,
  }) = ThemeChangedEvent;

  /// Answer feedback toggled event.
  factory SettingsEvent.answerFeedbackToggled({
    required bool enabled,
    required String source,
  }) = AnswerFeedbackToggledEvent;

  /// Reset confirmed event (user reset app data).
  factory SettingsEvent.resetConfirmed({
    required String resetType,
    required int sessionsDeleted,
    required int achievementsReset,
  }) = ResetConfirmedEvent;

  // ============ Info Link Events ============

  /// Privacy policy viewed event.
  factory SettingsEvent.privacyPolicyViewed({
    required String source,
  }) = PrivacyPolicyViewedEvent;

  /// Terms of service viewed event.
  factory SettingsEvent.termsOfServiceViewed({
    required String source,
  }) = TermsOfServiceViewedEvent;
}

// ============ Settings Change Event Implementations ============

/// Generic settings changed event.
final class SettingsChangedEvent extends SettingsEvent {
  const SettingsChangedEvent({
    required this.settingName,
    required this.oldValue,
    required this.newValue,
    this.settingCategory,
  });

  final String settingName;
  final String oldValue;
  final String newValue;
  final String? settingCategory;

  @override
  String get eventName => 'settings_changed';

  @override
  Map<String, dynamic> get parameters => {
        'setting_name': settingName,
        'old_value': oldValue,
        'new_value': newValue,
        if (settingCategory != null) 'setting_category': settingCategory,
      };
}

/// Sound effects toggled event.
final class SoundEffectsToggledEvent extends SettingsEvent {
  const SoundEffectsToggledEvent({
    required this.enabled,
    required this.source,
  });

  final bool enabled;
  final String source;

  @override
  String get eventName => 'sound_effects_toggled';

  @override
  Map<String, dynamic> get parameters => {
        'enabled': enabled,
        'source': source,
      };
}

/// Haptic feedback toggled event.
final class HapticFeedbackToggledEvent extends SettingsEvent {
  const HapticFeedbackToggledEvent({
    required this.enabled,
    required this.source,
  });

  final bool enabled;
  final String source;

  @override
  String get eventName => 'haptic_feedback_toggled';

  @override
  Map<String, dynamic> get parameters => {
        'enabled': enabled,
        'source': source,
      };
}

/// Theme changed event.
final class ThemeChangedEvent extends SettingsEvent {
  const ThemeChangedEvent({
    required this.newTheme,
    required this.previousTheme,
    required this.source,
  });

  final String newTheme;
  final String previousTheme;
  final String source;

  @override
  String get eventName => 'theme_changed';

  @override
  Map<String, dynamic> get parameters => {
        'new_theme': newTheme,
        'previous_theme': previousTheme,
        'source': source,
      };
}

/// Answer feedback toggled event.
final class AnswerFeedbackToggledEvent extends SettingsEvent {
  const AnswerFeedbackToggledEvent({
    required this.enabled,
    required this.source,
  });

  final bool enabled;
  final String source;

  @override
  String get eventName => 'answer_feedback_toggled';

  @override
  Map<String, dynamic> get parameters => {
        'enabled': enabled,
        'source': source,
      };
}

/// Reset confirmed event.
final class ResetConfirmedEvent extends SettingsEvent {
  const ResetConfirmedEvent({
    required this.resetType,
    required this.sessionsDeleted,
    required this.achievementsReset,
  });

  final String resetType;
  final int sessionsDeleted;
  final int achievementsReset;

  @override
  String get eventName => 'reset_confirmed';

  @override
  Map<String, dynamic> get parameters => {
        'reset_type': resetType,
        'sessions_deleted': sessionsDeleted,
        'achievements_reset': achievementsReset,
      };
}

// ============ Info Link Event Implementations ============

/// Privacy policy viewed event.
final class PrivacyPolicyViewedEvent extends SettingsEvent {
  const PrivacyPolicyViewedEvent({
    required this.source,
  });

  final String source;

  @override
  String get eventName => 'privacy_policy_viewed';

  @override
  Map<String, dynamic> get parameters => {
        'source': source,
      };
}

/// Terms of service viewed event.
final class TermsOfServiceViewedEvent extends SettingsEvent {
  const TermsOfServiceViewedEvent({
    required this.source,
  });

  final String source;

  @override
  String get eventName => 'terms_of_service_viewed';

  @override
  Map<String, dynamic> get parameters => {
        'source': source,
      };
}
