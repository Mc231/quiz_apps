/// Base classes and interfaces for BLoC state management.
library;

/// Base interface for BLoC states that support loading operations.
///
/// States implementing this interface can indicate when they're in a
/// loading state, which is useful for showing loading indicators in the UI.
abstract interface class LoadableState {
  /// Whether the state is currently loading.
  bool get isLoading;
}

/// Base interface for BLoC states that support refresh operations.
///
/// States implementing this interface can indicate when they're refreshing
/// existing data, which allows the UI to show existing content while
/// a refresh is in progress.
abstract interface class RefreshableState {
  /// Whether a refresh operation is in progress.
  bool get isRefreshing;
}

/// Base interface for BLoC states that support pagination.
///
/// States implementing this interface can track whether more data is
/// available and whether a load-more operation is in progress.
abstract interface class PaginableState {
  /// Whether there are more items to load.
  bool get hasMore;

  /// Whether a load-more operation is in progress.
  bool get isLoadingMore;
}

/// Base interface for error states.
///
/// States implementing this interface contain error information that
/// can be displayed to the user.
abstract interface class ErrorState {
  /// User-friendly error message.
  String get message;

  /// The underlying error, if any.
  Object? get error;
}

/// Mixin providing common error state properties and equality.
///
/// Apply this mixin to error state classes to get consistent
/// error handling behavior.
mixin ErrorStateMixin implements ErrorState {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorState &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}

/// Mixin providing common refreshable state properties.
///
/// Apply this mixin to loaded state classes to get consistent
/// refresh handling behavior.
mixin RefreshableStateMixin implements RefreshableState {
  /// Whether this state represents refreshing of existing data.
  @override
  bool get isRefreshing;
}

/// Abstract base class for BLoC states using the sealed class pattern.
///
/// This provides a common structure for BLoC states. Subclass this in your
/// sealed state class to inherit common functionality.
///
/// Example:
/// ```dart
/// sealed class MyState extends BaseBlocState {
///   const MyState();
///
///   factory MyState.loading() = MyLoading;
///   factory MyState.loaded({required MyData data}) = MyLoaded;
///   factory MyState.error({required String message}) = MyError;
/// }
/// ```
abstract class BaseBlocState {
  /// Creates a [BaseBlocState].
  const BaseBlocState();
}

/// Utility class for working with BLoC states.
///
/// Provides helper methods for common state operations.
abstract final class BlocStateUtils {
  /// Returns `true` if the state is a loading state.
  ///
  /// A state is considered loading if it implements [LoadableState]
  /// and its [LoadableState.isLoading] property is `true`.
  static bool isLoading(Object state) {
    if (state is LoadableState) {
      return state.isLoading;
    }
    return false;
  }

  /// Returns `true` if the state is refreshing.
  ///
  /// A state is considered refreshing if it implements [RefreshableState]
  /// and its [RefreshableState.isRefreshing] property is `true`.
  static bool isRefreshing(Object state) {
    if (state is RefreshableState) {
      return state.isRefreshing;
    }
    return false;
  }

  /// Returns `true` if the state has an error.
  ///
  /// A state has an error if it implements [ErrorState].
  static bool hasError(Object state) {
    return state is ErrorState;
  }

  /// Returns the error message if the state is an error state.
  static String? getErrorMessage(Object state) {
    if (state is ErrorState) {
      return state.message;
    }
    return null;
  }

  /// Returns `true` if pagination can load more items.
  ///
  /// Returns `true` if the state implements [PaginableState],
  /// has more items available, and is not currently loading more.
  static bool canLoadMore(Object state) {
    if (state is PaginableState) {
      return state.hasMore && !state.isLoadingMore;
    }
    return false;
  }
}
