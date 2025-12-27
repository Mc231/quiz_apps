import 'package:shared_services/shared_services.dart';

/// Mock analytics service that captures logged events for testing.
class MockAnalyticsService implements AnalyticsService {
  bool _isEnabled = false;
  bool _isInitialized = false;

  /// All events that have been logged.
  final List<AnalyticsEvent> loggedEvents = [];

  /// All screens that have been logged.
  final List<({String screenName, String? screenClass})> loggedScreens = [];

  /// User properties that have been set.
  final Map<String, String?> userProperties = {};

  /// Current user ID.
  String? userId;

  @override
  bool get isEnabled => _isEnabled && _isInitialized;

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    _isEnabled = true;
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (isEnabled) {
      loggedEvents.add(event);
    }
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (isEnabled) {
      loggedScreens.add((screenName: screenName, screenClass: screenClass));
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (isEnabled) {
      userProperties[name] = value;
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (isEnabled) {
      this.userId = userId;
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    userId = null;
    userProperties.clear();
    loggedEvents.clear();
    loggedScreens.clear();
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;
  }

  @override
  void dispose() {
    _isInitialized = false;
    _isEnabled = false;
  }

  /// Resets the mock to initial state.
  void reset() {
    loggedEvents.clear();
    loggedScreens.clear();
    userProperties.clear();
    userId = null;
  }

  /// Gets events of a specific type.
  List<T> getEventsOfType<T extends AnalyticsEvent>() {
    return loggedEvents.whereType<T>().toList();
  }

  /// Gets the first event of a specific type, or null if none found.
  T? getFirstEventOfType<T extends AnalyticsEvent>() {
    return loggedEvents.whereType<T>().firstOrNull;
  }

  /// Gets the last event of a specific type, or null if none found.
  T? getLastEventOfType<T extends AnalyticsEvent>() {
    return loggedEvents.whereType<T>().lastOrNull;
  }
}
