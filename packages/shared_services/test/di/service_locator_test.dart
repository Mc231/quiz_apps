import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/src/di/service_locator.dart';

// Test interfaces and implementations
abstract class TestService {
  String getValue();
}

class TestServiceImpl implements TestService {
  TestServiceImpl(this.value);
  final String value;

  @override
  String getValue() => value;
}

class DisposableService implements Disposable {
  bool disposed = false;

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class CountingFactory {
  int callCount = 0;

  TestService create() {
    callCount++;
    return TestServiceImpl('instance_$callCount');
  }
}

void main() {
  late ServiceLocator locator;

  setUp(() {
    // Create a fresh instance for each test
    locator = ServiceLocator.instance;
    locator.resetSync();
  });

  tearDown(() {
    locator.resetSync();
  });

  group('ServiceLocator', () {
    group('registerSingleton', () {
      test('registers and retrieves singleton instance', () {
        final service = TestServiceImpl('singleton');
        locator.registerSingleton<TestService>(service);

        final retrieved = locator.get<TestService>();

        expect(retrieved, same(service));
        expect(retrieved.getValue(), 'singleton');
      });

      test('returns same instance on multiple gets', () {
        final service = TestServiceImpl('singleton');
        locator.registerSingleton<TestService>(service);

        final first = locator.get<TestService>();
        final second = locator.get<TestService>();

        expect(first, same(second));
      });

      test('throws when registering duplicate type', () {
        locator.registerSingleton<TestService>(TestServiceImpl('first'));

        expect(
          () => locator.registerSingleton<TestService>(TestServiceImpl('second')),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('registerLazySingleton', () {
      test('creates instance on first access', () {
        final factory = CountingFactory();
        locator.registerLazySingleton<TestService>(factory.create);

        expect(factory.callCount, 0);

        locator.get<TestService>();

        expect(factory.callCount, 1);
      });

      test('returns same instance on multiple gets', () {
        final factory = CountingFactory();
        locator.registerLazySingleton<TestService>(factory.create);

        final first = locator.get<TestService>();
        final second = locator.get<TestService>();

        expect(first, same(second));
        expect(factory.callCount, 1);
      });

      test('throws when registering duplicate type', () {
        locator.registerLazySingleton<TestService>(() => TestServiceImpl('first'));

        expect(
          () => locator.registerLazySingleton<TestService>(() => TestServiceImpl('second')),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('registerFactory', () {
      test('creates new instance on each access', () {
        final factory = CountingFactory();
        locator.registerFactory<TestService>(factory.create);

        final first = locator.get<TestService>();
        final second = locator.get<TestService>();

        expect(first, isNot(same(second)));
        expect(first.getValue(), 'instance_1');
        expect(second.getValue(), 'instance_2');
        expect(factory.callCount, 2);
      });

      test('throws when registering duplicate type', () {
        locator.registerFactory<TestService>(() => TestServiceImpl('first'));

        expect(
          () => locator.registerFactory<TestService>(() => TestServiceImpl('second')),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('get', () {
      test('throws when type not registered', () {
        expect(
          () => locator.get<TestService>(),
          throwsA(isA<StateError>()),
        );
      });

      test('error message includes type name', () {
        try {
          locator.get<TestService>();
          fail('Should have thrown');
        } catch (e) {
          expect(e.toString(), contains('TestService'));
        }
      });
    });

    group('getOrNull', () {
      test('returns null when type not registered', () {
        final result = locator.getOrNull<TestService>();
        expect(result, isNull);
      });

      test('returns instance when registered', () {
        locator.registerSingleton<TestService>(TestServiceImpl('test'));

        final result = locator.getOrNull<TestService>();

        expect(result, isNotNull);
        expect(result!.getValue(), 'test');
      });
    });

    group('isRegistered', () {
      test('returns false when not registered', () {
        expect(locator.isRegistered<TestService>(), isFalse);
      });

      test('returns true for singleton', () {
        locator.registerSingleton<TestService>(TestServiceImpl('test'));
        expect(locator.isRegistered<TestService>(), isTrue);
      });

      test('returns true for lazy singleton', () {
        locator.registerLazySingleton<TestService>(() => TestServiceImpl('test'));
        expect(locator.isRegistered<TestService>(), isTrue);
      });

      test('returns true for factory', () {
        locator.registerFactory<TestService>(() => TestServiceImpl('test'));
        expect(locator.isRegistered<TestService>(), isTrue);
      });
    });

    group('unregister', () {
      test('removes singleton registration', () {
        locator.registerSingleton<TestService>(TestServiceImpl('test'));

        final removed = locator.unregister<TestService>();

        expect(removed, isTrue);
        expect(locator.isRegistered<TestService>(), isFalse);
      });

      test('removes lazy singleton registration', () {
        locator.registerLazySingleton<TestService>(() => TestServiceImpl('test'));

        final removed = locator.unregister<TestService>();

        expect(removed, isTrue);
        expect(locator.isRegistered<TestService>(), isFalse);
      });

      test('removes factory registration', () {
        locator.registerFactory<TestService>(() => TestServiceImpl('test'));

        final removed = locator.unregister<TestService>();

        expect(removed, isTrue);
        expect(locator.isRegistered<TestService>(), isFalse);
      });

      test('returns false when not registered', () {
        final removed = locator.unregister<TestService>();
        expect(removed, isFalse);
      });

      test('allows re-registration after unregister', () {
        locator.registerSingleton<TestService>(TestServiceImpl('first'));
        locator.unregister<TestService>();
        locator.registerSingleton<TestService>(TestServiceImpl('second'));

        expect(locator.get<TestService>().getValue(), 'second');
      });
    });

    group('reset', () {
      test('clears all registrations', () async {
        locator.registerSingleton<TestService>(TestServiceImpl('test'));
        locator.registerLazySingleton<String>(() => 'lazy');
        locator.registerFactory<int>(() => 42);

        await locator.reset();

        expect(locator.isRegistered<TestService>(), isFalse);
        expect(locator.isRegistered<String>(), isFalse);
        expect(locator.isRegistered<int>(), isFalse);
      });

      test('disposes disposable singletons when dispose=true', () async {
        final service = DisposableService();
        locator.registerSingleton<DisposableService>(service);

        await locator.reset(dispose: true);

        expect(service.disposed, isTrue);
      });

      test('does not dispose when dispose=false', () async {
        final service = DisposableService();
        locator.registerSingleton<DisposableService>(service);

        await locator.reset(dispose: false);

        expect(service.disposed, isFalse);
      });
    });

    group('resetSync', () {
      test('clears all registrations', () {
        locator.registerSingleton<TestService>(TestServiceImpl('test'));
        locator.registerLazySingleton<String>(() => 'lazy');
        locator.registerFactory<int>(() => 42);

        locator.resetSync();

        expect(locator.isRegistered<TestService>(), isFalse);
        expect(locator.isRegistered<String>(), isFalse);
        expect(locator.isRegistered<int>(), isFalse);
      });
    });

    group('debugInfo', () {
      test('returns empty lists when nothing registered', () {
        final info = locator.debugInfo;

        expect(info['singletons'], isEmpty);
        expect(info['lazySingletons'], isEmpty);
        expect(info['factories'], isEmpty);
      });

      test('includes registered types', () {
        locator.registerSingleton<TestService>(TestServiceImpl('test'));
        locator.registerLazySingleton<String>(() => 'lazy');
        locator.registerFactory<int>(() => 42);

        final info = locator.debugInfo;

        expect(info['singletons'], contains('TestService'));
        expect(info['lazySingletons'], contains('String'));
        expect(info['factories'], contains('int'));
      });

      test('moves lazy singleton to singletons after access', () {
        locator.registerLazySingleton<TestService>(() => TestServiceImpl('test'));

        var info = locator.debugInfo;
        expect(info['lazySingletons'], contains('TestService'));
        expect(info['singletons'], isNot(contains('TestService')));

        locator.get<TestService>(); // Access to trigger creation

        info = locator.debugInfo;
        expect(info['singletons'], contains('TestService'));
        expect(info['lazySingletons'], isNot(contains('TestService')));
      });
    });
  });

  group('sl global shortcut', () {
    test('is same instance as ServiceLocator.instance', () {
      expect(sl, same(ServiceLocator.instance));
    });
  });
}
