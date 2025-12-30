import '../analytics_event.dart';

/// Sealed class for error-related events.
///
/// Tracks application errors, failures, and recovery attempts.
/// Total: 6 events.
sealed class ErrorEvent extends AnalyticsEvent {
  const ErrorEvent();

  // ============ Data Error Events ============

  /// Data load failed event.
  factory ErrorEvent.dataLoadFailed({
    required String dataType,
    required String errorCode,
    required String errorMessage,
    String? source,
    int? retryCount,
  }) = DataLoadFailedEvent;

  /// Save failed event.
  factory ErrorEvent.saveFailed({
    required String dataType,
    required String errorCode,
    required String errorMessage,
    String? operation,
    int? dataSize,
  }) = SaveFailedEvent;

  // ============ User Action Events ============

  /// Retry tapped event.
  factory ErrorEvent.retryTapped({
    required String errorType,
    required String context,
    required int attemptNumber,
    Duration? timeSinceError,
  }) = RetryTappedEvent;

  // ============ App Error Events ============

  /// App crash event.
  factory ErrorEvent.appCrash({
    required String crashType,
    required String errorMessage,
    String? stackTrace,
    String? screenName,
    Map<String, dynamic>? additionalData,
  }) = AppCrashEvent;

  /// Feature failure event.
  factory ErrorEvent.featureFailure({
    required String featureName,
    required String errorCode,
    required String errorMessage,
    String? userAction,
    bool? wasRecoverable,
  }) = FeatureFailureEvent;

  // ============ Network Error Events ============

  /// Network error event.
  factory ErrorEvent.network({
    required String endpoint,
    required int statusCode,
    required String errorMessage,
    required Duration requestDuration,
    String? requestMethod,
    int? retryCount,
  }) = NetworkErrorEvent;
}

// ============ Data Error Event Implementations ============

/// Data load failed event.
final class DataLoadFailedEvent extends ErrorEvent {
  const DataLoadFailedEvent({
    required this.dataType,
    required this.errorCode,
    required this.errorMessage,
    this.source,
    this.retryCount,
  });

  final String dataType;
  final String errorCode;
  final String errorMessage;
  final String? source;
  final int? retryCount;

  @override
  String get eventName => 'data_load_failed';

  @override
  Map<String, dynamic> get parameters => {
        'data_type': dataType,
        'error_code': errorCode,
        'error_message': errorMessage,
        if (source != null) 'source': source,
        if (retryCount != null) 'retry_count': retryCount,
      };
}

/// Save failed event.
final class SaveFailedEvent extends ErrorEvent {
  const SaveFailedEvent({
    required this.dataType,
    required this.errorCode,
    required this.errorMessage,
    this.operation,
    this.dataSize,
  });

  final String dataType;
  final String errorCode;
  final String errorMessage;
  final String? operation;
  final int? dataSize;

  @override
  String get eventName => 'save_failed';

  @override
  Map<String, dynamic> get parameters => {
        'data_type': dataType,
        'error_code': errorCode,
        'error_message': errorMessage,
        if (operation != null) 'operation': operation,
        if (dataSize != null) 'data_size': dataSize,
      };
}

// ============ User Action Event Implementations ============

/// Retry tapped event.
final class RetryTappedEvent extends ErrorEvent {
  const RetryTappedEvent({
    required this.errorType,
    required this.context,
    required this.attemptNumber,
    this.timeSinceError,
  });

  final String errorType;
  final String context;
  final int attemptNumber;
  final Duration? timeSinceError;

  @override
  String get eventName => 'retry_tapped';

  @override
  Map<String, dynamic> get parameters => {
        'error_type': errorType,
        'context': context,
        'attempt_number': attemptNumber,
        if (timeSinceError != null)
          'time_since_error_ms': timeSinceError!.inMilliseconds,
      };
}

// ============ App Error Event Implementations ============

/// App crash event.
final class AppCrashEvent extends ErrorEvent {
  const AppCrashEvent({
    required this.crashType,
    required this.errorMessage,
    this.stackTrace,
    this.screenName,
    this.additionalData,
  });

  final String crashType;
  final String errorMessage;
  final String? stackTrace;
  final String? screenName;
  final Map<String, dynamic>? additionalData;

  @override
  String get eventName => 'app_crash';

  @override
  Map<String, dynamic> get parameters => {
        'crash_type': crashType,
        'error_message': errorMessage,
        if (stackTrace != null) 'stack_trace': stackTrace,
        if (screenName != null) 'screen_name': screenName,
        if (additionalData != null) ...additionalData!,
      };
}

/// Feature failure event.
final class FeatureFailureEvent extends ErrorEvent {
  const FeatureFailureEvent({
    required this.featureName,
    required this.errorCode,
    required this.errorMessage,
    this.userAction,
    this.wasRecoverable,
  });

  final String featureName;
  final String errorCode;
  final String errorMessage;
  final String? userAction;
  final bool? wasRecoverable;

  @override
  String get eventName => 'feature_failure';

  @override
  Map<String, dynamic> get parameters => {
        'feature_name': featureName,
        'error_code': errorCode,
        'error_message': errorMessage,
        if (userAction != null) 'user_action': userAction,
        if (wasRecoverable != null) 'was_recoverable': wasRecoverable! ? 1 : 0,
      };
}

// ============ Network Error Event Implementations ============

/// Network error event.
final class NetworkErrorEvent extends ErrorEvent {
  const NetworkErrorEvent({
    required this.endpoint,
    required this.statusCode,
    required this.errorMessage,
    required this.requestDuration,
    this.requestMethod,
    this.retryCount,
  });

  final String endpoint;
  final int statusCode;
  final String errorMessage;
  final Duration requestDuration;
  final String? requestMethod;
  final int? retryCount;

  @override
  String get eventName => 'network_error';

  @override
  Map<String, dynamic> get parameters => {
        'endpoint': endpoint,
        'status_code': statusCode,
        'error_message': errorMessage,
        'request_duration_ms': requestDuration.inMilliseconds,
        if (requestMethod != null) 'request_method': requestMethod,
        if (retryCount != null) 'retry_count': retryCount,
      };
}
