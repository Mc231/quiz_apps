import '../analytics_event.dart';

/// Sealed class for rate app (in-app review) events.
///
/// Tracks the complete rate app funnel:
/// - Condition checking
/// - Love dialog interactions
/// - Native rating dialog
/// - Feedback dialog
///
/// Total: 11 events.
sealed class RateAppEvent extends AnalyticsEvent {
  const RateAppEvent();

  // ============ Condition Events ============

  /// Conditions were checked to determine if rate prompt should show.
  factory RateAppEvent.conditionsChecked({
    required bool shouldShow,
    String? blockingReason,
    required int completedQuizzes,
    required int quizScore,
    required int daysSinceInstall,
    required int promptCount,
    required int declineCount,
  }) = RateAppConditionsCheckedEvent;

  // ============ Love Dialog Events ============

  /// Love dialog was displayed to user.
  factory RateAppEvent.loveDialogShown({
    required int completedQuizzes,
    required int quizScore,
    required int promptCount,
  }) = RateAppLoveDialogShownEvent;

  /// User tapped "Yes!" in love dialog.
  factory RateAppEvent.loveDialogPositive({
    required int promptCount,
    required Duration timeToRespond,
  }) = RateAppLoveDialogPositiveEvent;

  /// User tapped "Not Really" in love dialog.
  factory RateAppEvent.loveDialogNegative({
    required int promptCount,
    required int declineCount,
    required Duration timeToRespond,
  }) = RateAppLoveDialogNegativeEvent;

  /// User dismissed love dialog without action.
  factory RateAppEvent.loveDialogDismissed({
    required int promptCount,
    required Duration timeToRespond,
  }) = RateAppLoveDialogDismissedEvent;

  // ============ Native Dialog Events ============

  /// Native rating dialog was displayed.
  factory RateAppEvent.nativeDialogShown({
    required int promptCount,
  }) = RateAppNativeDialogShownEvent;

  /// User completed native rating (or dialog closed normally).
  factory RateAppEvent.nativeDialogCompleted({
    required int promptCount,
  }) = RateAppNativeDialogCompletedEvent;

  /// Native dialog was not available on this platform.
  factory RateAppEvent.nativeDialogUnavailable({
    required String platform,
  }) = RateAppNativeDialogUnavailableEvent;

  // ============ Feedback Dialog Events ============

  /// Feedback dialog was displayed to user.
  factory RateAppEvent.feedbackDialogShown({
    required int declineCount,
    String? feedbackEmail,
  }) = RateAppFeedbackDialogShownEvent;

  /// User chose to submit feedback.
  factory RateAppEvent.feedbackSubmitted({
    required int declineCount,
    required Duration timeToRespond,
  }) = RateAppFeedbackSubmittedEvent;

  /// User dismissed feedback dialog.
  factory RateAppEvent.feedbackDismissed({
    required int declineCount,
    required Duration timeToRespond,
  }) = RateAppFeedbackDismissedEvent;
}

// ============ Condition Event Implementations ============

/// Conditions were checked to determine if rate prompt should show.
final class RateAppConditionsCheckedEvent extends RateAppEvent {
  const RateAppConditionsCheckedEvent({
    required this.shouldShow,
    this.blockingReason,
    required this.completedQuizzes,
    required this.quizScore,
    required this.daysSinceInstall,
    required this.promptCount,
    required this.declineCount,
  });

  final bool shouldShow;
  final String? blockingReason;
  final int completedQuizzes;
  final int quizScore;
  final int daysSinceInstall;
  final int promptCount;
  final int declineCount;

  @override
  String get eventName => 'rate_app_conditions_checked';

  @override
  Map<String, dynamic> get parameters => {
        'should_show': shouldShow,
        if (blockingReason != null) 'blocking_reason': blockingReason,
        'completed_quizzes': completedQuizzes,
        'quiz_score': quizScore,
        'days_since_install': daysSinceInstall,
        'prompt_count': promptCount,
        'decline_count': declineCount,
      };
}

// ============ Love Dialog Event Implementations ============

/// Love dialog was displayed to user.
final class RateAppLoveDialogShownEvent extends RateAppEvent {
  const RateAppLoveDialogShownEvent({
    required this.completedQuizzes,
    required this.quizScore,
    required this.promptCount,
  });

  final int completedQuizzes;
  final int quizScore;
  final int promptCount;

  @override
  String get eventName => 'rate_app_love_dialog_shown';

  @override
  Map<String, dynamic> get parameters => {
        'completed_quizzes': completedQuizzes,
        'quiz_score': quizScore,
        'prompt_count': promptCount,
      };
}

/// User tapped "Yes!" in love dialog.
final class RateAppLoveDialogPositiveEvent extends RateAppEvent {
  const RateAppLoveDialogPositiveEvent({
    required this.promptCount,
    required this.timeToRespond,
  });

  final int promptCount;
  final Duration timeToRespond;

  @override
  String get eventName => 'rate_app_love_dialog_positive';

  @override
  Map<String, dynamic> get parameters => {
        'prompt_count': promptCount,
        'time_to_respond_ms': timeToRespond.inMilliseconds,
      };
}

/// User tapped "Not Really" in love dialog.
final class RateAppLoveDialogNegativeEvent extends RateAppEvent {
  const RateAppLoveDialogNegativeEvent({
    required this.promptCount,
    required this.declineCount,
    required this.timeToRespond,
  });

  final int promptCount;
  final int declineCount;
  final Duration timeToRespond;

  @override
  String get eventName => 'rate_app_love_dialog_negative';

  @override
  Map<String, dynamic> get parameters => {
        'prompt_count': promptCount,
        'decline_count': declineCount,
        'time_to_respond_ms': timeToRespond.inMilliseconds,
      };
}

/// User dismissed love dialog without action.
final class RateAppLoveDialogDismissedEvent extends RateAppEvent {
  const RateAppLoveDialogDismissedEvent({
    required this.promptCount,
    required this.timeToRespond,
  });

  final int promptCount;
  final Duration timeToRespond;

  @override
  String get eventName => 'rate_app_love_dialog_dismissed';

  @override
  Map<String, dynamic> get parameters => {
        'prompt_count': promptCount,
        'time_to_respond_ms': timeToRespond.inMilliseconds,
      };
}

// ============ Native Dialog Event Implementations ============

/// Native rating dialog was displayed.
final class RateAppNativeDialogShownEvent extends RateAppEvent {
  const RateAppNativeDialogShownEvent({
    required this.promptCount,
  });

  final int promptCount;

  @override
  String get eventName => 'rate_app_native_dialog_shown';

  @override
  Map<String, dynamic> get parameters => {
        'prompt_count': promptCount,
      };
}

/// User completed native rating (or dialog closed normally).
final class RateAppNativeDialogCompletedEvent extends RateAppEvent {
  const RateAppNativeDialogCompletedEvent({
    required this.promptCount,
  });

  final int promptCount;

  @override
  String get eventName => 'rate_app_native_dialog_completed';

  @override
  Map<String, dynamic> get parameters => {
        'prompt_count': promptCount,
      };
}

/// Native dialog was not available on this platform.
final class RateAppNativeDialogUnavailableEvent extends RateAppEvent {
  const RateAppNativeDialogUnavailableEvent({
    required this.platform,
  });

  final String platform;

  @override
  String get eventName => 'rate_app_native_dialog_unavailable';

  @override
  Map<String, dynamic> get parameters => {
        'platform': platform,
      };
}

// ============ Feedback Dialog Event Implementations ============

/// Feedback dialog was displayed to user.
final class RateAppFeedbackDialogShownEvent extends RateAppEvent {
  const RateAppFeedbackDialogShownEvent({
    required this.declineCount,
    this.feedbackEmail,
  });

  final int declineCount;
  final String? feedbackEmail;

  @override
  String get eventName => 'rate_app_feedback_dialog_shown';

  @override
  Map<String, dynamic> get parameters => {
        'decline_count': declineCount,
        'has_feedback_email': feedbackEmail != null,
      };
}

/// User chose to submit feedback.
final class RateAppFeedbackSubmittedEvent extends RateAppEvent {
  const RateAppFeedbackSubmittedEvent({
    required this.declineCount,
    required this.timeToRespond,
  });

  final int declineCount;
  final Duration timeToRespond;

  @override
  String get eventName => 'rate_app_feedback_submitted';

  @override
  Map<String, dynamic> get parameters => {
        'decline_count': declineCount,
        'time_to_respond_ms': timeToRespond.inMilliseconds,
      };
}

/// User dismissed feedback dialog.
final class RateAppFeedbackDismissedEvent extends RateAppEvent {
  const RateAppFeedbackDismissedEvent({
    required this.declineCount,
    required this.timeToRespond,
  });

  final int declineCount;
  final Duration timeToRespond;

  @override
  String get eventName => 'rate_app_feedback_dismissed';

  @override
  Map<String, dynamic> get parameters => {
        'decline_count': declineCount,
        'time_to_respond_ms': timeToRespond.inMilliseconds,
      };
}
