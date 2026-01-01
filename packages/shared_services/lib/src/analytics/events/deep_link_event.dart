import '../analytics_event.dart';

/// Sealed class for deep link analytics events.
///
/// Tracks deep link handling including:
/// - Link received
/// - Link successfully handled
/// - Link handling failed
///
/// Total: 3 events.
sealed class DeepLinkEvent extends AnalyticsEvent {
  const DeepLinkEvent();

  /// Deep link was received by the app.
  factory DeepLinkEvent.received({
    required String scheme,
    required String host,
    required String path,
    String? source,
  }) = DeepLinkReceivedEvent;

  /// Deep link was successfully handled and navigated.
  factory DeepLinkEvent.handled({
    required String scheme,
    required String host,
    required String path,
    required String routeType,
    String? routeId,
  }) = DeepLinkHandledEvent;

  /// Deep link handling failed.
  factory DeepLinkEvent.failed({
    required String scheme,
    required String host,
    required String path,
    required String reason,
  }) = DeepLinkFailedEvent;
}

/// Deep link was received by the app.
final class DeepLinkReceivedEvent extends DeepLinkEvent {
  const DeepLinkReceivedEvent({
    required this.scheme,
    required this.host,
    required this.path,
    this.source,
  });

  /// URL scheme (e.g., 'flagsquiz').
  final String scheme;

  /// Host/authority part of the URL.
  final String host;

  /// Path component of the URL.
  final String path;

  /// Optional source indicator (e.g., 'cold_start', 'background').
  final String? source;

  @override
  String get eventName => 'deep_link_received';

  @override
  Map<String, dynamic> get parameters => {
        'scheme': scheme,
        'host': host,
        'path': path,
        if (source != null) 'source': source,
      };
}

/// Deep link was successfully handled and navigated.
final class DeepLinkHandledEvent extends DeepLinkEvent {
  const DeepLinkHandledEvent({
    required this.scheme,
    required this.host,
    required this.path,
    required this.routeType,
    this.routeId,
  });

  /// URL scheme.
  final String scheme;

  /// Host/authority part of the URL.
  final String host;

  /// Path component of the URL.
  final String path;

  /// Type of route navigated to (e.g., 'quiz', 'achievement', 'challenge').
  final String routeType;

  /// Optional route-specific identifier.
  final String? routeId;

  @override
  String get eventName => 'deep_link_handled';

  @override
  Map<String, dynamic> get parameters => {
        'scheme': scheme,
        'host': host,
        'path': path,
        'route_type': routeType,
        if (routeId != null) 'route_id': routeId,
      };
}

/// Deep link handling failed.
final class DeepLinkFailedEvent extends DeepLinkEvent {
  const DeepLinkFailedEvent({
    required this.scheme,
    required this.host,
    required this.path,
    required this.reason,
  });

  /// URL scheme.
  final String scheme;

  /// Host/authority part of the URL.
  final String host;

  /// Path component of the URL.
  final String path;

  /// Reason for failure (e.g., 'unknown_route', 'invalid_id', 'not_found').
  final String reason;

  @override
  String get eventName => 'deep_link_failed';

  @override
  Map<String, dynamic> get parameters => {
        'scheme': scheme,
        'host': host,
        'path': path,
        'reason': reason,
      };
}
