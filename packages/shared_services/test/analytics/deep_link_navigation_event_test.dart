import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('DeepLinkNavigatedEvent', () {
    test('creates with required parameters', () {
      final event = DeepLinkEvent.navigated(
        routeType: 'quiz',
        routeId: 'europe',
      );

      expect(event, isA<DeepLinkNavigatedEvent>());
      expect(event.eventName, 'deep_link_navigated');

      final navigated = event as DeepLinkNavigatedEvent;
      expect(navigated.routeType, 'quiz');
      expect(navigated.routeId, 'europe');
      expect(navigated.navigationTimeMs, isNull);
    });

    test('creates with navigation time', () {
      final event = DeepLinkEvent.navigated(
        routeType: 'achievement',
        routeId: 'first_quiz',
        navigationTimeMs: 150,
      );

      final navigated = event as DeepLinkNavigatedEvent;
      expect(navigated.navigationTimeMs, 150);
    });

    test('parameters without navigation time', () {
      final event = DeepLinkEvent.navigated(
        routeType: 'quiz',
        routeId: 'europe',
      );

      expect(event.parameters, {
        'route_type': 'quiz',
        'route_id': 'europe',
      });
    });

    test('parameters with navigation time', () {
      final event = DeepLinkEvent.navigated(
        routeType: 'challenge',
        routeId: 'survival',
        navigationTimeMs: 250,
      );

      expect(event.parameters, {
        'route_type': 'challenge',
        'route_id': 'survival',
        'navigation_time_ms': 250,
      });
    });
  });

  group('DeepLinkNavigationFailedEvent', () {
    test('creates with required parameters', () {
      final event = DeepLinkEvent.navigationFailed(
        routeType: 'quiz',
        routeId: 'invalid_category',
        reason: 'not_found',
      );

      expect(event, isA<DeepLinkNavigationFailedEvent>());
      expect(event.eventName, 'deep_link_navigation_failed');

      final failed = event as DeepLinkNavigationFailedEvent;
      expect(failed.routeType, 'quiz');
      expect(failed.routeId, 'invalid_category');
      expect(failed.reason, 'not_found');
    });

    test('parameters', () {
      final event = DeepLinkEvent.navigationFailed(
        routeType: 'achievement',
        routeId: 'unknown_achievement',
        reason: 'invalid_id',
      );

      expect(event.parameters, {
        'route_type': 'achievement',
        'route_id': 'unknown_achievement',
        'reason': 'invalid_id',
      });
    });

    test('different failure reasons', () {
      final notReady = DeepLinkEvent.navigationFailed(
        routeType: 'quiz',
        routeId: 'europe',
        reason: 'not_ready',
      );

      final notFound = DeepLinkEvent.navigationFailed(
        routeType: 'quiz',
        routeId: 'invalid',
        reason: 'not_found',
      );

      expect(notReady.parameters['reason'], 'not_ready');
      expect(notFound.parameters['reason'], 'not_found');
    });
  });
}
