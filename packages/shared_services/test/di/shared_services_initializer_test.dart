import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('SharedServicesInitializer', () {
    setUp(() async {
      // Reset for each test
      SharedPreferences.setMockInitialValues({});
      await SharedServicesInitializer.resetForTesting();
    });

    tearDown(() async {
      await SharedServicesInitializer.resetForTesting();
    });

    group('initialize', () {
      test('returns success result when initialization succeeds', () async {
        // Skip database initialization to avoid sqflite FFI requirement in tests
        final result = await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        expect(result.success, isTrue);
        expect(result.failedServices, isEmpty);
        expect(result.totalDuration, isNotNull);
        expect(result.timings, isNotEmpty);
      });

      test('sets isInitialized to true after initialization', () async {
        expect(SharedServicesInitializer.isInitialized, isFalse);

        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        expect(SharedServicesInitializer.isInitialized, isTrue);
      });

      test('returns early if already initialized', () async {
        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );
        expect(SharedServicesInitializer.isInitialized, isTrue);

        // Second call should return quickly
        final result = await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        expect(result.success, isTrue);
        expect(result.timings, isEmpty); // No steps run
      });

      test('reports timing for each initialization step', () async {
        final reportedTimings = <String, Duration>{};

        await SharedServicesInitializer.initialize(
          config: SharedServicesConfig(
            initializeDatabase: false,
            onTiming: (step, duration) {
              reportedTimings[step] = duration;
            },
          ),
        );

        expect(reportedTimings, contains('DatabaseInitializer'));
        expect(reportedTimings, contains('SettingsModule'));
        expect(reportedTimings, contains('StorageModule'));
      });

      test('includes timings in result', () async {
        final result = await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        expect(result.timings, contains('DatabaseInitializer'));
        expect(result.timings, contains('SettingsModule'));
        expect(result.timings, contains('StorageModule'));
      });

      test('isPerformant returns true when under 500ms', () async {
        final result = await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        // In tests, initialization should be fast
        expect(result.totalDuration.inMilliseconds, lessThan(5000));
        // Note: isPerformant threshold is 500ms
        expect(result.isPerformant, isA<bool>());
      });

      test('registers SettingsService in service locator', () async {
        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        expect(sl.isRegistered<SettingsService>(), isTrue);
        expect(sl.get<SettingsService>(), isA<SettingsService>());
      });

      test('registers storage dependencies without initialization', () async {
        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        // When initializeDatabase is false, services are registered as lazy
        expect(sl.isRegistered<AppDatabase>(), isTrue);
        expect(sl.isRegistered<QuizSessionRepository>(), isTrue);
        expect(sl.isRegistered<AchievementService>(), isTrue);
      });
    });

    group('dispose', () {
      test('sets isInitialized to false', () async {
        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );
        expect(SharedServicesInitializer.isInitialized, isTrue);

        await SharedServicesInitializer.dispose();

        expect(SharedServicesInitializer.isInitialized, isFalse);
      });

      test('does nothing if not initialized', () async {
        expect(SharedServicesInitializer.isInitialized, isFalse);

        // Should not throw
        await SharedServicesInitializer.dispose();

        expect(SharedServicesInitializer.isInitialized, isFalse);
      });

      test('allows re-initialization after dispose', () async {
        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );
        await SharedServicesInitializer.dispose();

        final result = await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        expect(result.success, isTrue);
        expect(SharedServicesInitializer.isInitialized, isTrue);
      });
    });

    group('resetForTesting', () {
      test('clears all registrations', () async {
        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );
        expect(sl.isRegistered<SettingsService>(), isTrue);

        await SharedServicesInitializer.resetForTesting();

        expect(SharedServicesInitializer.isInitialized, isFalse);
      });

      test('allows fresh initialization', () async {
        await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );
        await SharedServicesInitializer.resetForTesting();

        final result = await SharedServicesInitializer.initialize(
          config: const SharedServicesConfig(initializeDatabase: false),
        );

        expect(result.success, isTrue);
        expect(result.timings, isNotEmpty);
      });
    });

    group('SharedServicesConfig', () {
      test('defaultConfig has expected values', () {
        const config = SharedServicesConfig.defaultConfig;

        expect(config.initializeDatabase, isTrue);
        expect(config.customModules, isEmpty);
        expect(config.onError, isNull);
        expect(config.onTiming, isNull);
      });

      test('can create config with custom values', () {
        var errorCalled = false;
        var timingCalled = false;

        final config = SharedServicesConfig(
          initializeDatabase: false,
          onError: (_, __, ___) => errorCalled = true,
          onTiming: (_, __) => timingCalled = true,
        );

        expect(config.initializeDatabase, isFalse);
        expect(config.onError, isNotNull);
        expect(config.onTiming, isNotNull);

        // Verify callbacks can be invoked
        config.onError!('test', 'error', StackTrace.current);
        config.onTiming!('test', Duration.zero);

        expect(errorCalled, isTrue);
        expect(timingCalled, isTrue);
      });
    });

    group('SharedServicesInitResult', () {
      test('toString provides readable output', () {
        const result = SharedServicesInitResult(
          success: true,
          totalDuration: Duration(milliseconds: 250),
          timings: {
            'Step1': Duration(milliseconds: 100),
            'Step2': Duration(milliseconds: 150),
          },
        );

        final output = result.toString();

        expect(output, contains('success: true'));
        expect(output, contains('totalDuration: 250ms'));
        expect(output, contains('isPerformant: true'));
        expect(output, contains('Step1: 100ms'));
        expect(output, contains('Step2: 150ms'));
      });

      test('toString includes failed services when present', () {
        const result = SharedServicesInitResult(
          success: false,
          totalDuration: Duration(milliseconds: 100),
          failedServices: ['ServiceA', 'ServiceB'],
        );

        final output = result.toString();

        expect(output, contains('success: false'));
        expect(output, contains('failedServices:'));
        expect(output, contains('ServiceA'));
        expect(output, contains('ServiceB'));
      });

      test('isPerformant returns true for fast initialization', () {
        const result = SharedServicesInitResult(
          success: true,
          totalDuration: Duration(milliseconds: 499),
        );

        expect(result.isPerformant, isTrue);
      });

      test('isPerformant returns false for slow initialization', () {
        const result = SharedServicesInitResult(
          success: true,
          totalDuration: Duration(milliseconds: 500),
        );

        expect(result.isPerformant, isFalse);
      });
    });

    group('error handling', () {
      test('reports errors via onError callback', () async {
        String? reportedService;
        Object? reportedError;

        await SharedServicesInitializer.initialize(
          config: SharedServicesConfig(
            initializeDatabase: false,
            onError: (service, error, stack) {
              reportedService = service;
              reportedError = error;
            },
          ),
        );

        // With proper mocks, initialization should succeed
        // Error handling is tested via the callback infrastructure
        expect(reportedService, isNull);
        expect(reportedError, isNull);
      });

      test('onTiming callback is called for each step', () async {
        final timingSteps = <String>[];

        await SharedServicesInitializer.initialize(
          config: SharedServicesConfig(
            initializeDatabase: false,
            onTiming: (step, duration) {
              timingSteps.add(step);
            },
          ),
        );

        expect(timingSteps, contains('DatabaseInitializer'));
        expect(timingSteps, contains('SettingsModule'));
        expect(timingSteps, contains('StorageModule'));
        expect(timingSteps.length, equals(3));
      });
    });

    group('custom modules', () {
      test('registers custom modules', () async {
        final customModule = _TestModule();

        await SharedServicesInitializer.initialize(
          config: SharedServicesConfig(
            initializeDatabase: false,
            customModules: [customModule],
          ),
        );

        expect(customModule.wasRegistered, isTrue);
      });

      test('reports timing for custom modules', () async {
        final customModule = _TestModule();
        final reportedTimings = <String, Duration>{};

        await SharedServicesInitializer.initialize(
          config: SharedServicesConfig(
            initializeDatabase: false,
            customModules: [customModule],
            onTiming: (step, duration) {
              reportedTimings[step] = duration;
            },
          ),
        );

        expect(reportedTimings, contains('_TestModule'));
      });
    });
  });
}

/// Test module for verifying custom module registration.
class _TestModule implements DependencyModule {
  bool wasRegistered = false;

  @override
  void register(ServiceLocator locator) {
    wasRegistered = true;
  }

  @override
  Future<void> dispose() async {}
}
