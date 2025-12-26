import '../analytics_event.dart';
import '../analytics_service.dart';

/// No-operation analytics service for testing.
///
/// Does nothing when analytics methods are called.
/// Use this for unit tests and CI/CD environments.
class NoOpAnalyticsService implements AnalyticsService {
  bool _isEnabled = false;

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<void> initialize() async {
    _isEnabled = true;
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    // No-op
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    // No-op
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    // No-op
  }

  @override
  Future<void> setUserId(String? userId) async {
    // No-op
  }

  @override
  Future<void> resetAnalyticsData() async {
    // No-op
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;
  }

  @override
  void dispose() {
    _isEnabled = false;
  }
}
