/// Base abstract class for all analytics events.
///
/// Each event category has its own sealed subtype:
/// - [ScreenViewEvent] - Screen navigation tracking
/// - QuizEvent - Quiz lifecycle (Sprint 9.1.1)
/// - QuestionEvent - Question/answer events (Sprint 9.1.1)
/// - HintEvent - Hint usage (Sprint 9.1.1)
/// - ResourceEvent - Lives, timers (Sprint 9.1.1)
/// - InteractionEvent - User interactions (Sprint 9.1.2)
/// - SettingsEvent - Settings changes (Sprint 9.1.2)
/// - AchievementEvent - Achievement tracking (Sprint 9.1.2)
/// - MonetizationEvent - IAP, ads (Sprint 9.1.3)
/// - ErrorEvent - Error tracking (Sprint 9.1.3)
/// - PerformanceEvent - Performance metrics (Sprint 9.1.3)
///
/// Note: Each category is sealed within its own file for exhaustive
/// pattern matching while allowing the base class to be extended
/// across multiple files.
abstract class AnalyticsEvent {
  const AnalyticsEvent();

  /// Event name for analytics providers (snake_case).
  String get eventName;

  /// Event parameters as a map.
  Map<String, dynamic> get parameters;
}
