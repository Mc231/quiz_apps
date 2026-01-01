import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('DeepLinkEvent', () {
    group('deepLinkReceived', () {
      test('creates event with required parameters', () {
        final event = DeepLinkEvent.received(
          scheme: 'flagsquiz',
          host: 'quiz',
          path: '/europe',
        );

        expect(event.eventName, 'deep_link_received');
        expect(event.parameters['scheme'], 'flagsquiz');
        expect(event.parameters['host'], 'quiz');
        expect(event.parameters['path'], '/europe');
        expect(event.parameters.containsKey('source'), false);
      });

      test('creates event with source parameter', () {
        final event = DeepLinkEvent.received(
          scheme: 'flagsquiz',
          host: 'quiz',
          path: '/europe',
          source: 'cold_start',
        );

        expect(event.parameters['source'], 'cold_start');
      });
    });

    group('deepLinkHandled', () {
      test('creates event with required parameters', () {
        final event = DeepLinkEvent.handled(
          scheme: 'flagsquiz',
          host: 'quiz',
          path: '/europe',
          routeType: 'quiz',
        );

        expect(event.eventName, 'deep_link_handled');
        expect(event.parameters['scheme'], 'flagsquiz');
        expect(event.parameters['host'], 'quiz');
        expect(event.parameters['path'], '/europe');
        expect(event.parameters['route_type'], 'quiz');
        expect(event.parameters.containsKey('route_id'), false);
      });

      test('creates event with routeId parameter', () {
        final event = DeepLinkEvent.handled(
          scheme: 'flagsquiz',
          host: 'quiz',
          path: '/europe',
          routeType: 'quiz',
          routeId: 'europe',
        );

        expect(event.parameters['route_id'], 'europe');
      });
    });

    group('deepLinkFailed', () {
      test('creates event with all parameters', () {
        final event = DeepLinkEvent.failed(
          scheme: 'flagsquiz',
          host: 'unknown',
          path: '/something',
          reason: 'unknown_route',
        );

        expect(event.eventName, 'deep_link_failed');
        expect(event.parameters['scheme'], 'flagsquiz');
        expect(event.parameters['host'], 'unknown');
        expect(event.parameters['path'], '/something');
        expect(event.parameters['reason'], 'unknown_route');
      });
    });
  });
}
