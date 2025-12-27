import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/bloc/base/bloc_analytics_mixin.dart';
import 'package:shared_services/shared_services.dart';

/// Mock implementation of AnalyticsService for testing.
class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> loggedEvents = [];
  final List<String> loggedScreens = [];

  @override
  bool get isEnabled => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    loggedEvents.add(event);
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    loggedScreens.add(screenName);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> resetAnalyticsData() async {}

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {}

  @override
  void dispose() {}
}

/// Test class that uses the BlocAnalyticsMixin.
class TestAnalyticsUser with BlocAnalyticsMixin {}

void main() {
  group('BlocAnalyticsMixin', () {
    late TestAnalyticsUser user;
    late MockAnalyticsService mockAnalytics;

    setUp(() {
      user = TestAnalyticsUser();
      mockAnalytics = MockAnalyticsService();
    });

    group('initialization', () {
      test('analytics is null before init', () {
        expect(user.analytics, isNull);
        expect(user.hasAnalytics, isFalse);
      });

      test('analytics is set after initAnalytics', () {
        user.initAnalytics(mockAnalytics, screenName: 'test_screen');

        expect(user.analytics, isNotNull);
        expect(user.hasAnalytics, isTrue);
      });

      test('screenName is set after initAnalytics', () {
        user.initAnalytics(mockAnalytics, screenName: 'test_screen');

        expect(user.analyticsScreenName, equals('test_screen'));
      });

      test('works with null analytics', () {
        user.initAnalytics(null, screenName: 'test_screen');

        expect(user.analytics, isNull);
        expect(user.hasAnalytics, isFalse);
      });
    });

    group('logEvent', () {
      test('logs event when analytics is available', () async {
        user.initAnalytics(mockAnalytics, screenName: 'test_screen');

        await user.logEvent(InteractionEvent.categorySelected(
          categoryId: 'test_category',
          categoryName: 'Test Category',
          categoryIndex: 0,
        ));

        expect(mockAnalytics.loggedEvents, hasLength(1));
        expect(mockAnalytics.loggedEvents.first, isA<InteractionEvent>());
      });

      test('does nothing when analytics is null', () async {
        user.initAnalytics(null, screenName: 'test_screen');

        // This should not throw
        await user.logEvent(InteractionEvent.categorySelected(
          categoryId: 'test_category',
          categoryName: 'Test Category',
          categoryIndex: 0,
        ));

        // No way to verify, but it shouldn't throw
      });
    });

    group('trackScreenView', () {
      test('tracks screen with configured name', () async {
        user.initAnalytics(mockAnalytics, screenName: 'configured_screen');

        await user.trackScreenView();

        expect(mockAnalytics.loggedScreens, contains('configured_screen'));
      });

      test('tracks screen with provided name', () async {
        user.initAnalytics(mockAnalytics, screenName: 'configured_screen');

        await user.trackScreenView('override_screen');

        expect(mockAnalytics.loggedScreens, contains('override_screen'));
      });

      test('does nothing when analytics is null', () async {
        user.initAnalytics(null, screenName: 'test_screen');

        // This should not throw
        await user.trackScreenView();
      });

      test('does nothing when no screen name', () async {
        user.initAnalytics(mockAnalytics);

        await user.trackScreenView();

        expect(mockAnalytics.loggedScreens, isEmpty);
      });
    });

    group('logDataLoadError', () {
      test('logs error event with correct parameters', () async {
        user.initAnalytics(mockAnalytics, screenName: 'test_screen');

        await user.logDataLoadError(
          dataType: 'user_data',
          errorCode: 'NETWORK_ERROR',
          errorMessage: 'Connection failed',
        );

        expect(mockAnalytics.loggedEvents, hasLength(1));
        expect(mockAnalytics.loggedEvents.first, isA<ErrorEvent>());
      });
    });

    group('logScreenRender', () {
      test('logs render event with duration', () async {
        user.initAnalytics(mockAnalytics, screenName: 'test_screen');

        await user.logScreenRender(
          renderDuration: const Duration(milliseconds: 150),
          isInitialRender: true,
        );

        expect(mockAnalytics.loggedEvents, hasLength(1));
        expect(mockAnalytics.loggedEvents.first, isA<PerformanceEvent>());
      });

      test('does nothing when no screen name', () async {
        user.initAnalytics(mockAnalytics);

        await user.logScreenRender(
          renderDuration: const Duration(milliseconds: 150),
        );

        expect(mockAnalytics.loggedEvents, isEmpty);
      });
    });
  });

  group('AnalyticsTimingExtension', () {
    test('logScreenRender stops stopwatch and logs event', () async {
      final user = TestAnalyticsUser();
      final mockAnalytics = MockAnalyticsService();
      user.initAnalytics(mockAnalytics, screenName: 'test_screen');

      final stopwatch = Stopwatch()..start();
      // Simulate some time passing
      await Future.delayed(const Duration(milliseconds: 10));

      await stopwatch.logScreenRender(user);

      expect(stopwatch.isRunning, isFalse);
      expect(mockAnalytics.loggedEvents, hasLength(1));
    });
  });
}
