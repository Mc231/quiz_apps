import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/analytics/analytics_navigator_observer.dart';
import 'package:shared_services/shared_services.dart';

// Mock Analytics Service
class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> loggedEvents = [];
  final List<({String screenName, String? screenClass})> screenViews = [];
  final List<({String name, String? value})> userProperties = [];
  String? userId;
  bool _enabled = true;

  @override
  bool get isEnabled => _enabled;

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
    screenViews.add((screenName: screenName, screenClass: screenClass));
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    userProperties.add((name: name, value: value));
  }

  @override
  Future<void> setUserId(String? id) async {
    userId = id;
  }

  @override
  Future<void> resetAnalyticsData() async {
    loggedEvents.clear();
    screenViews.clear();
    userProperties.clear();
    userId = null;
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _enabled = enabled;
  }

  @override
  void dispose() {}
}

void main() {
  group('AnalyticsNavigatorObserver', () {
    late MockAnalyticsService mockAnalyticsService;
    late AnalyticsNavigatorObserver observer;

    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
      observer = AnalyticsNavigatorObserver(
        analyticsService: mockAnalyticsService,
      );
    });

    testWidgets('tracks screen view on push', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/details': (context) => const Scaffold(body: Text('Details')),
          },
        ),
      );

      // Navigate to details screen
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Trigger navigation programmatically
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pushNamed('/details');
      await tester.pumpAndSettle();

      // Verify screen view was tracked
      expect(mockAnalyticsService.screenViews, isNotEmpty);
      expect(
        mockAnalyticsService.screenViews.last.screenName,
        'details',
      );
    });

    testWidgets('tracks screen view on pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/details': (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ),
          },
        ),
      );

      // Navigate to details
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pushNamed('/details');
      await tester.pumpAndSettle();

      // Clear previous screen views
      mockAnalyticsService.screenViews.clear();

      // Pop back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Verify home screen view was tracked on pop
      expect(mockAnalyticsService.screenViews, isNotEmpty);
    });

    test('excludes routes in excludedRoutes set', () {
      final observerWithExclusions = AnalyticsNavigatorObserver(
        analyticsService: mockAnalyticsService,
        excludedRoutes: {'excluded_route'},
      );

      // Create a mock route with excluded name
      final excludedRoute = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/excluded_route'),
      );

      // This should not track
      observerWithExclusions.didPush(excludedRoute, null);

      expect(
        mockAnalyticsService.screenViews
            .where((v) => v.screenName == 'excluded_route'),
        isEmpty,
      );
    });

    test('formats route names correctly', () {
      final testRoute = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/my-test-screen'),
      );

      observer.didPush(testRoute, null);

      expect(mockAnalyticsService.screenViews, isNotEmpty);
      expect(
        mockAnalyticsService.screenViews.last.screenName,
        'my_test_screen',
      );
    });

    test('handles nested routes', () {
      final nestedRoute = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/parent/child/screen'),
      );

      observer.didPush(nestedRoute, null);

      expect(mockAnalyticsService.screenViews, isNotEmpty);
      expect(
        mockAnalyticsService.screenViews.last.screenName,
        'parent_child_screen',
      );
    });

    test('tracks screen class when enabled', () {
      final route = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/test'),
      );

      observer.didPush(route, null);

      expect(mockAnalyticsService.screenViews, isNotEmpty);
      expect(
        mockAnalyticsService.screenViews.last.screenClass,
        isNotNull,
      );
    });

    test('does not track screen class when disabled', () {
      final observerNoClass = AnalyticsNavigatorObserver(
        analyticsService: mockAnalyticsService,
        trackScreenClass: false,
      );

      final route = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/test'),
      );

      observerNoClass.didPush(route, null);

      expect(mockAnalyticsService.screenViews, isNotEmpty);
      expect(
        mockAnalyticsService.screenViews.last.screenClass,
        isNull,
      );
    });

    test('uses custom screen name extractor when provided', () {
      final observerWithExtractor = AnalyticsNavigatorObserver(
        analyticsService: mockAnalyticsService,
        screenNameExtractor: (route) => 'custom_screen_name',
      );

      final route = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/ignored'),
      );

      observerWithExtractor.didPush(route, null);

      expect(mockAnalyticsService.screenViews, isNotEmpty);
      expect(
        mockAnalyticsService.screenViews.last.screenName,
        'custom_screen_name',
      );
    });

    test('falls back to default extraction when custom extractor returns null',
        () {
      final observerWithExtractor = AnalyticsNavigatorObserver(
        analyticsService: mockAnalyticsService,
        screenNameExtractor: (route) => null,
      );

      final route = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/default_name'),
      );

      observerWithExtractor.didPush(route, null);

      expect(mockAnalyticsService.screenViews, isNotEmpty);
      expect(
        mockAnalyticsService.screenViews.last.screenName,
        'default_name',
      );
    });
  });

  group('AnalyticsServiceScreenTracking extension', () {
    late MockAnalyticsService mockAnalyticsService;

    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
    });

    test('logScreenView logs event and sets current screen', () async {
      final screenEvent = ScreenViewEvent.home(activeTab: 'play');

      await mockAnalyticsService.logScreenView(screenEvent);

      // Verify event was logged
      expect(mockAnalyticsService.loggedEvents, hasLength(1));
      expect(mockAnalyticsService.loggedEvents.first, isA<ScreenViewEvent>());

      // Verify screen was set
      expect(mockAnalyticsService.screenViews, hasLength(1));
      expect(mockAnalyticsService.screenViews.first.screenName, 'home');
      expect(
          mockAnalyticsService.screenViews.first.screenClass, 'HomeScreen');
    });

    test('logScreenView works with different screen types', () async {
      final events = [
        ScreenViewEvent.home(activeTab: 'play'),
        ScreenViewEvent.settings(),
        ScreenViewEvent.history(sessionCount: 10),
        ScreenViewEvent.statistics(totalSessions: 5, averageScore: 85.0),
      ];

      for (final event in events) {
        await mockAnalyticsService.logScreenView(event);
      }

      expect(mockAnalyticsService.loggedEvents, hasLength(4));
      expect(mockAnalyticsService.screenViews, hasLength(4));
    });
  });
}
