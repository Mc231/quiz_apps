import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/bloc/base/base_bloc_state.dart';

/// Test implementation of LoadableState.
class TestLoadingState implements LoadableState {
  const TestLoadingState({required this.isLoading});

  @override
  final bool isLoading;
}

/// Test implementation of RefreshableState.
class TestRefreshableState implements RefreshableState {
  const TestRefreshableState({required this.isRefreshing});

  @override
  final bool isRefreshing;
}

/// Test implementation of PaginableState.
class TestPaginableState implements PaginableState {
  const TestPaginableState({
    required this.hasMore,
    required this.isLoadingMore,
  });

  @override
  final bool hasMore;

  @override
  final bool isLoadingMore;
}

/// Test implementation of ErrorState.
class TestErrorState with ErrorStateMixin implements ErrorState {
  const TestErrorState({
    required this.message,
    this.error,
  });

  @override
  final String message;

  @override
  final Object? error;
}

/// Test sealed state hierarchy.
sealed class TestState extends BaseBlocState {
  const TestState();
}

class TestStateLoading extends TestState implements LoadableState {
  const TestStateLoading();

  @override
  bool get isLoading => true;
}

class TestStateLoaded extends TestState
    implements RefreshableState, PaginableState {
  const TestStateLoaded({
    this.isRefreshing = false,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  final bool isRefreshing;

  @override
  final bool hasMore;

  @override
  final bool isLoadingMore;
}

class TestStateError extends TestState with ErrorStateMixin {
  const TestStateError({
    required this.message,
    this.error,
  });

  @override
  final String message;

  @override
  final Object? error;
}

void main() {
  group('LoadableState', () {
    test('isLoading returns correct value', () {
      const loading = TestLoadingState(isLoading: true);
      const notLoading = TestLoadingState(isLoading: false);

      expect(loading.isLoading, isTrue);
      expect(notLoading.isLoading, isFalse);
    });
  });

  group('RefreshableState', () {
    test('isRefreshing returns correct value', () {
      const refreshing = TestRefreshableState(isRefreshing: true);
      const notRefreshing = TestRefreshableState(isRefreshing: false);

      expect(refreshing.isRefreshing, isTrue);
      expect(notRefreshing.isRefreshing, isFalse);
    });
  });

  group('PaginableState', () {
    test('hasMore returns correct value', () {
      const hasMore = TestPaginableState(hasMore: true, isLoadingMore: false);
      const noMore = TestPaginableState(hasMore: false, isLoadingMore: false);

      expect(hasMore.hasMore, isTrue);
      expect(noMore.hasMore, isFalse);
    });

    test('isLoadingMore returns correct value', () {
      const loading = TestPaginableState(hasMore: true, isLoadingMore: true);
      const notLoading =
          TestPaginableState(hasMore: true, isLoadingMore: false);

      expect(loading.isLoadingMore, isTrue);
      expect(notLoading.isLoadingMore, isFalse);
    });
  });

  group('ErrorStateMixin', () {
    test('provides message and error', () {
      final error = Exception('Test exception');
      const errorState = TestErrorState(
        message: 'Test error',
        error: null,
      );
      final errorStateWithException = TestErrorState(
        message: 'Test error',
        error: error,
      );

      expect(errorState.message, equals('Test error'));
      expect(errorState.error, isNull);
      expect(errorStateWithException.error, equals(error));
    });

    test('equality works correctly', () {
      const error1 = TestErrorState(message: 'Error 1');
      const error2 = TestErrorState(message: 'Error 1');
      const error3 = TestErrorState(message: 'Error 2');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('hashCode works correctly', () {
      const error1 = TestErrorState(message: 'Error 1');
      const error2 = TestErrorState(message: 'Error 1');

      expect(error1.hashCode, equals(error2.hashCode));
    });
  });

  group('BlocStateUtils', () {
    group('isLoading', () {
      test('returns true for loading state', () {
        const state = TestStateLoading();
        expect(BlocStateUtils.isLoading(state), isTrue);
      });

      test('returns false for non-loading state', () {
        const state = TestStateLoaded();
        expect(BlocStateUtils.isLoading(state), isFalse);
      });

      test('returns false for non-LoadableState', () {
        const state = 'not a state';
        expect(BlocStateUtils.isLoading(state), isFalse);
      });
    });

    group('isRefreshing', () {
      test('returns true for refreshing state', () {
        const state = TestStateLoaded(isRefreshing: true);
        expect(BlocStateUtils.isRefreshing(state), isTrue);
      });

      test('returns false for non-refreshing state', () {
        const state = TestStateLoaded(isRefreshing: false);
        expect(BlocStateUtils.isRefreshing(state), isFalse);
      });

      test('returns false for non-RefreshableState', () {
        const state = TestStateLoading();
        expect(BlocStateUtils.isRefreshing(state), isFalse);
      });
    });

    group('hasError', () {
      test('returns true for error state', () {
        const state = TestStateError(message: 'Error');
        expect(BlocStateUtils.hasError(state), isTrue);
      });

      test('returns false for non-error state', () {
        const state = TestStateLoaded();
        expect(BlocStateUtils.hasError(state), isFalse);
      });
    });

    group('getErrorMessage', () {
      test('returns message for error state', () {
        const state = TestStateError(message: 'Test error message');
        expect(BlocStateUtils.getErrorMessage(state), equals('Test error message'));
      });

      test('returns null for non-error state', () {
        const state = TestStateLoaded();
        expect(BlocStateUtils.getErrorMessage(state), isNull);
      });
    });

    group('canLoadMore', () {
      test('returns true when hasMore and not loading', () {
        const state = TestStateLoaded(hasMore: true, isLoadingMore: false);
        expect(BlocStateUtils.canLoadMore(state), isTrue);
      });

      test('returns false when hasMore but already loading', () {
        const state = TestStateLoaded(hasMore: true, isLoadingMore: true);
        expect(BlocStateUtils.canLoadMore(state), isFalse);
      });

      test('returns false when no more items', () {
        const state = TestStateLoaded(hasMore: false, isLoadingMore: false);
        expect(BlocStateUtils.canLoadMore(state), isFalse);
      });

      test('returns false for non-PaginableState', () {
        const state = TestStateLoading();
        expect(BlocStateUtils.canLoadMore(state), isFalse);
      });
    });
  });

  group('BaseBlocState', () {
    test('can be extended by sealed classes', () {
      const loading = TestStateLoading();
      const loaded = TestStateLoaded();
      const error = TestStateError(message: 'Error');

      expect(loading, isA<BaseBlocState>());
      expect(loaded, isA<BaseBlocState>());
      expect(error, isA<BaseBlocState>());
    });
  });
}
