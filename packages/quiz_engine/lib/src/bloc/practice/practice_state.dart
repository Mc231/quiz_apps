/// State classes for the Practice BLoC.
library;

import '../../models/practice_data_provider.dart';

/// Sealed class representing all possible states for practice screen.
sealed class PracticeState {
  /// Creates a [PracticeState].
  const PracticeState();

  /// Creates a loading state.
  factory PracticeState.loading() = PracticeLoading;

  /// Creates a ready state with practice data.
  factory PracticeState.ready({
    required PracticeTabData data,
    bool isRefreshing,
  }) = PracticeReady;

  /// Creates a complete state with results.
  factory PracticeState.complete({
    required int correctCount,
    required int needMorePracticeCount,
  }) = PracticeComplete;

  /// Creates an error state.
  factory PracticeState.error({
    required String message,
    Object? error,
  }) = PracticeError;
}

/// State when practice data is loading.
class PracticeLoading extends PracticeState {
  /// Creates a [PracticeLoading].
  const PracticeLoading();
}

/// State when practice data is ready.
class PracticeReady extends PracticeState {
  /// Creates a [PracticeReady].
  const PracticeReady({
    required this.data,
    this.isRefreshing = false,
  });

  /// The practice data.
  final PracticeTabData data;

  /// Whether a refresh is in progress.
  final bool isRefreshing;

  /// The number of questions to practice.
  int get questionCount => data.questionCount;

  /// Whether there are questions to practice.
  bool get hasQuestions => data.hasQuestions;

  /// Creates a copy with updated values.
  PracticeReady copyWith({
    PracticeTabData? data,
    bool? isRefreshing,
  }) {
    return PracticeReady(
      data: data ?? this.data,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeReady &&
        other.data == data &&
        other.isRefreshing == isRefreshing;
  }

  @override
  int get hashCode => Object.hash(data, isRefreshing);
}

/// State when practice session is complete.
class PracticeComplete extends PracticeState {
  /// Creates a [PracticeComplete].
  const PracticeComplete({
    required this.correctCount,
    required this.needMorePracticeCount,
  });

  /// The number of questions answered correctly.
  final int correctCount;

  /// The number of questions that still need more practice.
  final int needMorePracticeCount;

  /// Total number of questions in the practice session.
  int get totalCount => correctCount + needMorePracticeCount;

  /// Whether all questions were answered correctly.
  bool get isAllCorrect => needMorePracticeCount == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeComplete &&
        other.correctCount == correctCount &&
        other.needMorePracticeCount == needMorePracticeCount;
  }

  @override
  int get hashCode => Object.hash(correctCount, needMorePracticeCount);
}

/// State when there's an error loading practice data.
class PracticeError extends PracticeState {
  /// Creates a [PracticeError].
  const PracticeError({
    required this.message,
    this.error,
  });

  /// The error message to display.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
