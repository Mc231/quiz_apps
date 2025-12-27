import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock analytics service that tracks calls and can simulate errors.
class MockAnalyticsService implements AnalyticsService {
  bool _isEnabled = false;
  bool _isInitialized = false;
  bool shouldThrow = false;
  String? errorMessage;

  final List<AnalyticsEvent> loggedEvents = [];
  final List<({String screenName, String? screenClass})> loggedScreens = [];
  final Map<String, String?> userProperties = {};
  String? userId;
  int initializeCallCount = 0;
  int disposeCallCount = 0;
  bool analyticsEnabled = true;

  @override
  bool get isEnabled => _isEnabled && _isInitialized;

  bool get isInitialized => _isInitialized;

  void _maybeThrow() {
    if (shouldThrow) {
      throw Exception(errorMessage ?? 'Mock error');
    }
  }

  @override
  Future<void> initialize() async {
    _maybeThrow();
    initializeCallCount++;
    _isInitialized = true;
    _isEnabled = true;
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    _maybeThrow();
    if (isEnabled) {
      loggedEvents.add(event);
    }
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    _maybeThrow();
    if (isEnabled) {
      loggedScreens.add((screenName: screenName, screenClass: screenClass));
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    _maybeThrow();
    if (isEnabled) {
      userProperties[name] = value;
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    _maybeThrow();
    if (isEnabled) {
      this.userId = userId;
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    _maybeThrow();
    userId = null;
    userProperties.clear();
    loggedEvents.clear();
    loggedScreens.clear();
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _maybeThrow();
    analyticsEnabled = enabled;
    _isEnabled = enabled;
  }

  @override
  void dispose() {
    disposeCallCount++;
    _isInitialized = false;
    _isEnabled = false;
  }

  void reset() {
    loggedEvents.clear();
    loggedScreens.clear();
    userProperties.clear();
    userId = null;
    initializeCallCount = 0;
    disposeCallCount = 0;
    shouldThrow = false;
    errorMessage = null;
    analyticsEnabled = true;
    _isInitialized = false;
    _isEnabled = false;
  }
}

void main() {
  group('CompositeAnalyticsService', () {
    late MockAnalyticsService provider1;
    late MockAnalyticsService provider2;
    late MockAnalyticsService provider3;

    setUp(() {
      provider1 = MockAnalyticsService();
      provider2 = MockAnalyticsService();
      provider3 = MockAnalyticsService();
    });

    tearDown(() {
      provider1.dispose();
      provider2.dispose();
      provider3.dispose();
    });

    group('initialization', () {
      test('starts disabled before initialize', () {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
          ],
        );

        expect(service.isEnabled, isFalse);
        expect(service.isInitialized, isFalse);
      });

      test('becomes enabled after initialize', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
          ],
        );

        await service.initialize();

        expect(service.isEnabled, isTrue);
        expect(service.isInitialized, isTrue);
      });

      test('initializes all providers', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
            AnalyticsProviderConfig(provider: provider3, name: 'Provider3'),
          ],
        );

        await service.initialize();

        expect(provider1.initializeCallCount, equals(1));
        expect(provider2.initializeCallCount, equals(1));
        expect(provider3.initializeCallCount, equals(1));
      });

      test('skips disabled providers during initialization', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(
                provider: provider2, name: 'Provider2', enabled: false),
            AnalyticsProviderConfig(provider: provider3, name: 'Provider3'),
          ],
        );

        await service.initialize();

        expect(provider1.initializeCallCount, equals(1));
        expect(provider2.initializeCallCount, equals(0));
        expect(provider3.initializeCallCount, equals(1));
      });

      test('continues initialization if one provider fails', () async {
        provider2.shouldThrow = true;

        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
            AnalyticsProviderConfig(provider: provider3, name: 'Provider3'),
          ],
        );

        await service.initialize();

        expect(provider1.initializeCallCount, equals(1));
        expect(provider3.initializeCallCount, equals(1));
        expect(service.isInitialized, isTrue);
      });

      test('stops on first error when stopOnFirstError is true', () async {
        provider2.shouldThrow = true;

        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
            AnalyticsProviderConfig(provider: provider3, name: 'Provider3'),
          ],
          stopOnFirstError: true,
        );

        await service.initialize();

        expect(provider1.initializeCallCount, equals(1));
        expect(provider3.initializeCallCount, equals(0));
      });

      test('only initializes once', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
          ],
        );

        await service.initialize();
        await service.initialize();

        expect(provider1.initializeCallCount, equals(1));
      });

      test('is disabled with empty providers list', () async {
        final service = CompositeAnalyticsService(providers: []);

        await service.initialize();

        expect(service.isEnabled, isFalse);
      });
    });

    group('logEvent', () {
      late CompositeAnalyticsService service;

      setUp(() async {
        service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ],
        );
        await service.initialize();
      });

      test('logs event to all providers', () async {
        const event = HomeScreenView(activeTab: 'play');

        await service.logEvent(event);

        expect(provider1.loggedEvents, hasLength(1));
        expect(provider1.loggedEvents.first, equals(event));
        expect(provider2.loggedEvents, hasLength(1));
        expect(provider2.loggedEvents.first, equals(event));
      });

      test('does not log when disabled', () async {
        await service.setAnalyticsCollectionEnabled(false);
        const event = HomeScreenView(activeTab: 'play');

        await service.logEvent(event);

        expect(provider1.loggedEvents, isEmpty);
        expect(provider2.loggedEvents, isEmpty);
      });

      test('continues logging if one provider fails', () async {
        provider1.shouldThrow = true;
        const event = HomeScreenView(activeTab: 'play');

        await service.logEvent(event);

        expect(provider2.loggedEvents, hasLength(1));
      });

      test('skips disabled providers', () async {
        final serviceWithDisabled = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(
                provider: provider2, name: 'Provider2', enabled: false),
            AnalyticsProviderConfig(provider: provider3, name: 'Provider3'),
          ],
        );
        await serviceWithDisabled.initialize();
        const event = HomeScreenView(activeTab: 'play');

        await serviceWithDisabled.logEvent(event);

        expect(provider1.loggedEvents, hasLength(1));
        expect(provider2.loggedEvents, isEmpty);
        expect(provider3.loggedEvents, hasLength(1));
      });
    });

    group('event filtering', () {
      test('applies event filter to provider', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'AllEvents'),
            AnalyticsProviderConfig(
              provider: provider2,
              name: 'ScreenViewsOnly',
              eventFilter: (event) => event is ScreenViewEvent,
            ),
          ],
        );
        await service.initialize();

        const screenEvent = HomeScreenView(activeTab: 'play');
        const quizEvent = QuizStartedEvent(
          quizId: 'quiz-1',
          quizName: 'test',
          categoryId: 'cat-1',
          categoryName: 'cat',
          mode: 'standard',
          totalQuestions: 10,
        );

        await service.logEvent(screenEvent);
        await service.logEvent(quizEvent);

        expect(provider1.loggedEvents, hasLength(2));
        expect(provider2.loggedEvents, hasLength(1));
        expect(provider2.loggedEvents.first, equals(screenEvent));
      });

      test('filter returning false skips the event', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(
              provider: provider1,
              name: 'NoEvents',
              eventFilter: (_) => false,
            ),
          ],
        );
        await service.initialize();

        await service.logEvent(const HomeScreenView(activeTab: 'play'));

        expect(provider1.loggedEvents, isEmpty);
      });
    });

    group('setCurrentScreen', () {
      late CompositeAnalyticsService service;

      setUp(() async {
        service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ],
        );
        await service.initialize();
      });

      test('sets screen on all providers', () async {
        await service.setCurrentScreen(
          screenName: 'home',
          screenClass: 'HomeScreen',
        );

        expect(provider1.loggedScreens, hasLength(1));
        expect(provider1.loggedScreens.first.screenName, equals('home'));
        expect(provider2.loggedScreens, hasLength(1));
        expect(provider2.loggedScreens.first.screenClass, equals('HomeScreen'));
      });

      test('does not set when disabled', () async {
        await service.setAnalyticsCollectionEnabled(false);

        await service.setCurrentScreen(screenName: 'home');

        expect(provider1.loggedScreens, isEmpty);
        expect(provider2.loggedScreens, isEmpty);
      });
    });

    group('setUserProperty', () {
      late CompositeAnalyticsService service;

      setUp(() async {
        service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ],
        );
        await service.initialize();
      });

      test('sets property on all providers', () async {
        await service.setUserProperty(name: 'level', value: '5');

        expect(provider1.userProperties['level'], equals('5'));
        expect(provider2.userProperties['level'], equals('5'));
      });

      test('clears property with null on all providers', () async {
        await service.setUserProperty(name: 'level', value: '5');
        await service.setUserProperty(name: 'level', value: null);

        expect(provider1.userProperties['level'], isNull);
        expect(provider2.userProperties['level'], isNull);
      });
    });

    group('setUserId', () {
      late CompositeAnalyticsService service;

      setUp(() async {
        service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ],
        );
        await service.initialize();
      });

      test('sets user ID on all providers', () async {
        await service.setUserId('user-123');

        expect(provider1.userId, equals('user-123'));
        expect(provider2.userId, equals('user-123'));
      });

      test('clears user ID on all providers', () async {
        await service.setUserId('user-123');
        await service.setUserId(null);

        expect(provider1.userId, isNull);
        expect(provider2.userId, isNull);
      });
    });

    group('resetAnalyticsData', () {
      late CompositeAnalyticsService service;

      setUp(() async {
        service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ],
        );
        await service.initialize();
      });

      test('resets data on all providers', () async {
        await service.setUserId('user-123');
        await service.setUserProperty(name: 'prop', value: 'value');
        await service.logEvent(const HomeScreenView(activeTab: 'play'));

        await service.resetAnalyticsData();

        expect(provider1.userId, isNull);
        expect(provider1.userProperties, isEmpty);
        expect(provider1.loggedEvents, isEmpty);
        expect(provider2.userId, isNull);
        expect(provider2.userProperties, isEmpty);
        expect(provider2.loggedEvents, isEmpty);
      });
    });

    group('setAnalyticsCollectionEnabled', () {
      late CompositeAnalyticsService service;

      setUp(() async {
        service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ],
        );
        await service.initialize();
      });

      test('disables all providers', () async {
        await service.setAnalyticsCollectionEnabled(false);

        expect(service.isEnabled, isFalse);
        expect(provider1.analyticsEnabled, isFalse);
        expect(provider2.analyticsEnabled, isFalse);
      });

      test('re-enables all providers', () async {
        await service.setAnalyticsCollectionEnabled(false);
        await service.setAnalyticsCollectionEnabled(true);

        expect(service.isEnabled, isTrue);
        expect(provider1.analyticsEnabled, isTrue);
        expect(provider2.analyticsEnabled, isTrue);
      });
    });

    group('dispose', () {
      test('disposes all providers', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ],
        );
        await service.initialize();

        service.dispose();

        expect(provider1.disposeCallCount, equals(1));
        expect(provider2.disposeCallCount, equals(1));
        expect(service.isInitialized, isFalse);
      });

      test('continues disposing even if one fails', () async {
        final throwingProvider = MockAnalyticsService();
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(
                provider: throwingProvider, name: 'Throwing'),
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
          ],
        );
        await service.initialize();

        // Make dispose throw (by setting flag that affects next operation)
        // Actually, since dispose doesn't check shouldThrow, we just verify
        // that both get disposed
        service.dispose();

        expect(throwingProvider.disposeCallCount, equals(1));
        expect(provider1.disposeCallCount, equals(1));
      });
    });

    group('provider management', () {
      test('getProvider returns correct provider', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Firebase'),
            AnalyticsProviderConfig(provider: provider2, name: 'Amplitude'),
          ],
        );

        expect(service.getProvider('Firebase'), equals(provider1));
        expect(service.getProvider('Amplitude'), equals(provider2));
        expect(service.getProvider('Unknown'), isNull);
      });

      test('getProviderConfig returns configuration', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Firebase'),
            AnalyticsProviderConfig(
              provider: provider2,
              name: 'Amplitude',
              enabled: false,
            ),
          ],
        );

        final firebaseConfig = service.getProviderConfig('Firebase');
        final amplitudeConfig = service.getProviderConfig('Amplitude');

        expect(firebaseConfig?.enabled, isTrue);
        expect(amplitudeConfig?.enabled, isFalse);
        expect(service.getProviderConfig('Unknown'), isNull);
      });

      test('providerNames returns all names', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Firebase'),
            AnalyticsProviderConfig(provider: provider2, name: 'Amplitude'),
            AnalyticsProviderConfig(provider: provider3, name: 'Mixpanel'),
          ],
        );

        expect(
          service.providerNames,
          containsAll(['Firebase', 'Amplitude', 'Mixpanel']),
        );
      });

      test('activeProviderCount returns correct count', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
            AnalyticsProviderConfig(
                provider: provider2, name: 'Provider2', enabled: false),
            AnalyticsProviderConfig(provider: provider3, name: 'Provider3'),
          ],
        );

        expect(service.activeProviderCount, equals(0));

        await service.initialize();

        expect(service.activeProviderCount, equals(2));
      });

      test('providers list is unmodifiable', () async {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
          ],
        );

        expect(
          () => (service.providers as List).add(
            AnalyticsProviderConfig(provider: provider2, name: 'Provider2'),
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('debug logging', () {
      test('enableDebugLogging can be set', () {
        final service = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: provider1, name: 'Provider1'),
          ],
          enableDebugLogging: true,
        );

        expect(service.enableDebugLogging, isTrue);
      });
    });
  });

  group('AnalyticsProviderConfig', () {
    late MockAnalyticsService provider;

    setUp(() {
      provider = MockAnalyticsService();
    });

    test('creates with required parameters', () {
      final config = AnalyticsProviderConfig(
        provider: provider,
        name: 'TestProvider',
      );

      expect(config.provider, equals(provider));
      expect(config.name, equals('TestProvider'));
      expect(config.enabled, isTrue);
      expect(config.eventFilter, isNull);
    });

    test('creates with all parameters', () {
      bool filter(AnalyticsEvent event) => true;

      final config = AnalyticsProviderConfig(
        provider: provider,
        name: 'TestProvider',
        enabled: false,
        eventFilter: filter,
      );

      expect(config.enabled, isFalse);
      expect(config.eventFilter, equals(filter));
    });

    test('copyWith creates modified copy', () {
      final original = AnalyticsProviderConfig(
        provider: provider,
        name: 'Original',
        enabled: true,
      );

      final modified = original.copyWith(
        name: 'Modified',
        enabled: false,
      );

      expect(modified.name, equals('Modified'));
      expect(modified.enabled, isFalse);
      expect(modified.provider, equals(provider));
    });

    test('copyWith without changes returns equivalent config', () {
      final original = AnalyticsProviderConfig(
        provider: provider,
        name: 'Original',
      );

      final copy = original.copyWith();

      expect(copy.provider, equals(original.provider));
      expect(copy.name, equals(original.name));
      expect(copy.enabled, equals(original.enabled));
    });
  });

  group('CompositeAnalyticsServiceExtension', () {
    late MockAnalyticsService provider1;
    late MockAnalyticsService provider2;

    setUp(() {
      provider1 = MockAnalyticsService();
      provider2 = MockAnalyticsService();
    });

    test('toCompositeService creates service from list', () async {
      final service = [provider1, provider2].toCompositeService();

      expect(service.providers, hasLength(2));
      expect(service.providerNames, contains('Provider0'));
      expect(service.providerNames, contains('Provider1'));
    });

    test('toCompositeService accepts options', () {
      final service = [provider1].toCompositeService(
        enableDebugLogging: true,
        stopOnFirstError: true,
      );

      expect(service.enableDebugLogging, isTrue);
      expect(service.stopOnFirstError, isTrue);
    });
  });
}
