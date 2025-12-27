/// Mixin for adding analytics capabilities to BLoCs.
library;

import 'package:shared_services/shared_services.dart';

/// Mixin that adds analytics capabilities to any class.
///
/// This mixin provides a convenient way to add analytics tracking
/// to BLoCs or other classes without requiring inheritance.
///
/// Example:
/// ```dart
/// class MyBloc extends SingleSubscriptionBloc<MyState>
///     with BlocAnalyticsMixin {
///   MyBloc({AnalyticsService? analytics}) {
///     initAnalytics(analytics, screenName: 'my_screen');
///   }
///
///   void handleEvent() {
///     logEvent(InteractionEvent.buttonTapped(
///       buttonName: 'start',
///       screenName: 'my_screen',
///     ));
///   }
/// }
/// ```
mixin BlocAnalyticsMixin {
  AnalyticsService? _analytics;
  String? _screenName;

  /// Initializes the analytics mixin.
  ///
  /// [analytics] is the analytics service to use.
  /// [screenName] is the name used for screen tracking.
  void initAnalytics(AnalyticsService? analytics, {String? screenName}) {
    _analytics = analytics;
    _screenName = screenName;
  }

  /// The analytics service, if configured.
  AnalyticsService? get analytics => _analytics;

  /// The screen name for analytics tracking.
  String? get analyticsScreenName => _screenName;

  /// Whether analytics is available.
  bool get hasAnalytics => _analytics != null;

  /// Logs an analytics event if analytics is available.
  ///
  /// Returns immediately if analytics is not configured.
  Future<void> logEvent(AnalyticsEvent event) async {
    await _analytics?.logEvent(event);
  }

  /// Tracks a screen view in analytics.
  ///
  /// Uses the configured screen name if [screenName] is not provided.
  Future<void> trackScreenView([String? screenName]) async {
    final name = screenName ?? _screenName;
    if (name != null && _analytics != null) {
      await _analytics!.setCurrentScreen(
        screenName: name,
        screenClass: runtimeType.toString(),
      );
    }
  }

  /// Logs a data load failure event.
  ///
  /// Convenience method for logging data loading errors.
  Future<void> logDataLoadError({
    required String dataType,
    required String errorCode,
    required String errorMessage,
  }) async {
    await logEvent(ErrorEvent.dataLoadFailed(
      dataType: dataType,
      errorCode: errorCode,
      errorMessage: errorMessage,
    ));
  }

  /// Logs a screen render performance event.
  ///
  /// [renderDuration] is the time taken to render the screen.
  /// [isInitialRender] indicates if this is the first render.
  Future<void> logScreenRender({
    required Duration renderDuration,
    bool isInitialRender = true,
  }) async {
    final name = _screenName;
    if (name != null) {
      await logEvent(PerformanceEvent.screenRender(
        screenName: name,
        renderDuration: renderDuration,
        isInitialRender: isInitialRender,
      ));
    }
  }
}

/// Extension to track timing for analytics.
///
/// Provides a convenient way to measure and log operation durations.
extension AnalyticsTimingExtension on Stopwatch {
  /// Logs the elapsed time as a screen render event.
  ///
  /// [analytics] is the analytics mixin to use for logging.
  /// [isInitialRender] indicates if this is the first render.
  Future<void> logScreenRender(
    BlocAnalyticsMixin analytics, {
    bool isInitialRender = true,
  }) async {
    stop();
    await analytics.logScreenRender(
      renderDuration: elapsed,
      isInitialRender: isInitialRender,
    );
  }
}
