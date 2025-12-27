import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/bloc/base/base_bloc_state.dart';
import 'package:quiz_engine/src/bloc/base/screen_bloc.dart';

/// Test state hierarchy for ScreenBloc tests.
sealed class TestState {
  const TestState();
}

class TestLoading extends TestState implements LoadableState {
  const TestLoading();

  @override
  bool get isLoading => true;
}

class TestLoaded extends TestState {
  const TestLoaded({required this.data});

  final String data;
}

class TestError extends TestState implements ErrorState {
  const TestError({required this.message, this.error});

  @override
  final String message;

  @override
  final Object? error;
}

/// Concrete implementation of ScreenBloc for testing.
class TestScreenBloc extends ScreenBloc<TestState> {
  TestScreenBloc({super.analytics, super.screenName});

  @override
  TestState get initialState => const TestLoading();

  void load() {
    dispatchState(const TestLoading());
  }

  void setLoaded(String data) {
    dispatchState(TestLoaded(data: data));
  }

  void setError(String message) {
    dispatchState(TestError(message: message));
  }
}

/// Concrete implementation of TrackedScreenBloc for testing.
class TestTrackedBloc extends TrackedScreenBloc<TestState, TestLoaded> {
  TestTrackedBloc({super.analytics, super.screenName});

  @override
  TestState get initialState => const TestLoading();

  @override
  bool isLoadedState(TestState state) => state is TestLoaded;

  @override
  TestLoaded? extractLoaded(TestState state) {
    return state is TestLoaded ? state : null;
  }

  void load() {
    dispatchState(const TestLoading());
  }

  void setLoaded(String data) {
    dispatchState(TestLoaded(data: data));
  }

  void setError(String message) {
    dispatchState(TestError(message: message));
  }
}

void main() {
  group('ScreenBloc', () {
    late TestScreenBloc bloc;

    setUp(() {
      bloc = TestScreenBloc(screenName: 'test_screen');
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('initial state is correct', () {
        expect(bloc.initialState, isA<TestLoading>());
      });

      test('currentState is null before dispatch', () {
        expect(bloc.currentState, isNull);
      });

      test('hasAnalytics returns false when no analytics', () {
        expect(bloc.hasAnalytics, isFalse);
      });

      test('screenName is set correctly', () {
        expect(bloc.screenName, equals('test_screen'));
      });
    });

    group('state tracking', () {
      test('currentState is updated after dispatch', () {
        bloc.load();

        expect(bloc.currentState, isA<TestLoading>());
      });

      test('isLoading returns true for loading state', () {
        bloc.load();

        expect(bloc.isLoading, isTrue);
      });

      test('isLoading returns false for non-loading state', () {
        bloc.setLoaded('test data');

        expect(bloc.isLoading, isFalse);
      });

      test('hasError returns true for error state', () {
        bloc.setError('test error');

        expect(bloc.hasError, isTrue);
      });

      test('hasError returns false for non-error state', () {
        bloc.setLoaded('test data');

        expect(bloc.hasError, isFalse);
      });

      test('errorMessage returns message for error state', () {
        bloc.setError('test error message');

        expect(bloc.errorMessage, equals('test error message'));
      });

      test('errorMessage returns null for non-error state', () {
        bloc.setLoaded('test data');

        expect(bloc.errorMessage, isNull);
      });
    });

    group('stream', () {
      test('emits states correctly', () async {
        final states = <TestState>[];
        bloc.stream.listen(states.add);

        bloc.load();
        bloc.setLoaded('data');
        bloc.setError('error');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, hasLength(3));
        expect(states[0], isA<TestLoading>());
        expect(states[1], isA<TestLoaded>());
        expect(states[2], isA<TestError>());
      });
    });
  });

  group('TrackedScreenBloc', () {
    late TestTrackedBloc bloc;

    setUp(() {
      bloc = TestTrackedBloc(screenName: 'tracked_test');
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('lastLoadedState is null before any loaded state', () {
        expect(bloc.lastLoadedState, isNull);
      });
    });

    group('state tracking', () {
      test('lastLoadedState is updated when loaded state dispatched', () {
        bloc.setLoaded('test data');

        expect(bloc.lastLoadedState, isNotNull);
        expect(bloc.lastLoadedState?.data, equals('test data'));
      });

      test('lastLoadedState persists through loading state', () {
        bloc.setLoaded('initial data');
        bloc.load();

        expect(bloc.lastLoadedState?.data, equals('initial data'));
      });

      test('lastLoadedState updates to new loaded state', () {
        bloc.setLoaded('first');
        bloc.setLoaded('second');

        expect(bloc.lastLoadedState?.data, equals('second'));
      });

      test('isLoadedState returns true for loaded state', () {
        const loaded = TestLoaded(data: 'test');
        const loading = TestLoading();

        expect(bloc.isLoadedState(loaded), isTrue);
        expect(bloc.isLoadedState(loading), isFalse);
      });

      test('extractLoaded returns state for loaded state', () {
        const loaded = TestLoaded(data: 'test');
        const loading = TestLoading();

        expect(bloc.extractLoaded(loaded), isNotNull);
        expect(bloc.extractLoaded(loading), isNull);
      });
    });

    group('clearLoadedState', () {
      test('clears the tracked loaded state', () {
        bloc.setLoaded('data');
        expect(bloc.lastLoadedState, isNotNull);

        bloc.clearLoadedState();
        expect(bloc.lastLoadedState, isNull);
      });
    });

    group('stream', () {
      test('emits states while tracking loaded state', () async {
        final states = <TestState>[];
        bloc.stream.listen(states.add);

        bloc.setLoaded('first');
        bloc.load();
        bloc.setLoaded('second');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, hasLength(3));
        expect(bloc.lastLoadedState?.data, equals('second'));
      });
    });
  });
}
