import 'dart:developer' as developer;

import '../analytics_event.dart';
import '../analytics_service.dart';

/// Console-based analytics service for development.
///
/// Logs all analytics events to the console with formatted output.
/// Use this for debugging and development purposes.
class ConsoleAnalyticsService implements AnalyticsService {
  ConsoleAnalyticsService({
    this.enableLogging = true,
    this.logPrefix = '[Analytics]',
  });

  /// Whether logging is enabled.
  final bool enableLogging;

  /// Prefix for log messages.
  final String logPrefix;

  bool _isEnabled = true;
  bool _isInitialized = false;
  String? _userId;
  final Map<String, String?> _userProperties = {};

  @override
  bool get isEnabled => _isEnabled && _isInitialized;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// The current user ID.
  String? get userId => _userId;

  /// Current user properties.
  Map<String, String?> get userProperties => Map.unmodifiable(_userProperties);

  /// List of logged events (for testing).
  final List<AnalyticsEvent> loggedEvents = [];

  /// List of logged screen views (for testing).
  final List<({String screenName, String? screenClass})> loggedScreens = [];

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    _log('Initialized');
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!isEnabled) return;

    loggedEvents.add(event);

    final buffer = StringBuffer()
      ..writeln('Event: ${event.eventName}')
      ..writeln('  Type: ${event.runtimeType}');

    if (event.parameters.isNotEmpty) {
      buffer.writeln('  Parameters:');
      for (final entry in event.parameters.entries) {
        buffer.writeln('    ${entry.key}: ${entry.value}');
      }
    }

    _log(buffer.toString());
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (!isEnabled) return;

    loggedScreens.add((screenName: screenName, screenClass: screenClass));

    final classInfo = screenClass != null ? ' (class: $screenClass)' : '';
    _log('Screen: $screenName$classInfo');
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!isEnabled) return;

    _userProperties[name] = value;

    final valueInfo = value ?? '(cleared)';
    _log('User Property: $name = $valueInfo');
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!isEnabled) return;

    _userId = userId;

    final idInfo = userId ?? '(cleared)';
    _log('User ID: $idInfo');
  }

  @override
  Future<void> resetAnalyticsData() async {
    _userId = null;
    _userProperties.clear();
    loggedEvents.clear();
    loggedScreens.clear();
    _log('Analytics data reset');
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;
    _log('Analytics collection ${enabled ? 'enabled' : 'disabled'}');
  }

  @override
  void dispose() {
    _isInitialized = false;
    _log('Disposed');
  }

  void _log(String message) {
    if (!enableLogging) return;

    developer.log(
      message,
      name: logPrefix,
      time: DateTime.now(),
    );
  }

  /// Clears all logged data (for testing).
  void clearLogs() {
    loggedEvents.clear();
    loggedScreens.clear();
  }
}
