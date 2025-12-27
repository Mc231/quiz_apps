import '../analytics_event.dart';

/// Sealed class for performance-related events.
///
/// Tracks app performance metrics, timing, and resource usage.
/// Total: 5 events.
sealed class PerformanceEvent extends AnalyticsEvent {
  const PerformanceEvent();

  // ============ App Lifecycle Events ============

  /// App launch event.
  factory PerformanceEvent.appLaunch({
    required Duration coldStartDuration,
    required bool isFirstLaunch,
    String? launchType,
    String? previousVersion,
  }) = AppLaunchEvent;

  /// Session start event.
  factory PerformanceEvent.sessionStart({
    required String sessionId,
    required DateTime startTime,
    String? entryPoint,
    Map<String, dynamic>? deviceInfo,
  }) = SessionStartEvent;

  /// Session end event.
  factory PerformanceEvent.sessionEnd({
    required String sessionId,
    required Duration sessionDuration,
    required int screenViewCount,
    required int interactionCount,
    String? exitReason,
  }) = SessionEndEvent;

  // ============ Rendering Events ============

  /// Screen render event.
  factory PerformanceEvent.screenRender({
    required String screenName,
    required Duration renderDuration,
    required bool isInitialRender,
    int? widgetCount,
    Duration? dataLoadDuration,
  }) = ScreenRenderEvent;

  // ============ Database Events ============

  /// Database query event.
  factory PerformanceEvent.databaseQuery({
    required String queryType,
    required String tableName,
    required Duration queryDuration,
    required int resultCount,
    bool? usedIndex,
    int? querySize,
  }) = DatabaseQueryEvent;
}

// ============ App Lifecycle Event Implementations ============

/// App launch event.
final class AppLaunchEvent extends PerformanceEvent {
  const AppLaunchEvent({
    required this.coldStartDuration,
    required this.isFirstLaunch,
    this.launchType,
    this.previousVersion,
  });

  final Duration coldStartDuration;
  final bool isFirstLaunch;
  final String? launchType;
  final String? previousVersion;

  @override
  String get eventName => 'app_launch';

  @override
  Map<String, dynamic> get parameters => {
        'cold_start_duration_ms': coldStartDuration.inMilliseconds,
        'is_first_launch': isFirstLaunch,
        if (launchType != null) 'launch_type': launchType,
        if (previousVersion != null) 'previous_version': previousVersion,
      };
}

/// Session start event.
final class SessionStartEvent extends PerformanceEvent {
  const SessionStartEvent({
    required this.sessionId,
    required this.startTime,
    this.entryPoint,
    this.deviceInfo,
  });

  final String sessionId;
  final DateTime startTime;
  final String? entryPoint;
  final Map<String, dynamic>? deviceInfo;

  @override
  String get eventName => 'session_start';

  @override
  Map<String, dynamic> get parameters => {
        'session_id': sessionId,
        'start_time': startTime.toIso8601String(),
        if (entryPoint != null) 'entry_point': entryPoint,
        if (deviceInfo != null) 'device_info': deviceInfo,
      };
}

/// Session end event.
final class SessionEndEvent extends PerformanceEvent {
  const SessionEndEvent({
    required this.sessionId,
    required this.sessionDuration,
    required this.screenViewCount,
    required this.interactionCount,
    this.exitReason,
  });

  final String sessionId;
  final Duration sessionDuration;
  final int screenViewCount;
  final int interactionCount;
  final String? exitReason;

  @override
  String get eventName => 'session_end';

  @override
  Map<String, dynamic> get parameters => {
        'session_id': sessionId,
        'session_duration_ms': sessionDuration.inMilliseconds,
        'screen_view_count': screenViewCount,
        'interaction_count': interactionCount,
        if (exitReason != null) 'exit_reason': exitReason,
      };
}

// ============ Rendering Event Implementations ============

/// Screen render event.
final class ScreenRenderEvent extends PerformanceEvent {
  const ScreenRenderEvent({
    required this.screenName,
    required this.renderDuration,
    required this.isInitialRender,
    this.widgetCount,
    this.dataLoadDuration,
  });

  final String screenName;
  final Duration renderDuration;
  final bool isInitialRender;
  final int? widgetCount;
  final Duration? dataLoadDuration;

  @override
  String get eventName => 'screen_render';

  @override
  Map<String, dynamic> get parameters => {
        'screen_name': screenName,
        'render_duration_ms': renderDuration.inMilliseconds,
        'is_initial_render': isInitialRender,
        if (widgetCount != null) 'widget_count': widgetCount,
        if (dataLoadDuration != null)
          'data_load_duration_ms': dataLoadDuration!.inMilliseconds,
      };
}

// ============ Database Event Implementations ============

/// Database query event.
final class DatabaseQueryEvent extends PerformanceEvent {
  const DatabaseQueryEvent({
    required this.queryType,
    required this.tableName,
    required this.queryDuration,
    required this.resultCount,
    this.usedIndex,
    this.querySize,
  });

  final String queryType;
  final String tableName;
  final Duration queryDuration;
  final int resultCount;
  final bool? usedIndex;
  final int? querySize;

  @override
  String get eventName => 'database_query';

  @override
  Map<String, dynamic> get parameters => {
        'query_type': queryType,
        'table_name': tableName,
        'query_duration_ms': queryDuration.inMilliseconds,
        'result_count': resultCount,
        if (usedIndex != null) 'used_index': usedIndex,
        if (querySize != null) 'query_size': querySize,
      };
}
