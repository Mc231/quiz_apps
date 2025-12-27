/// Event classes for the Practice BLoC.
library;

/// Sealed class representing all possible events for practice screen.
sealed class PracticeEvent {
  /// Creates a [PracticeEvent].
  const PracticeEvent();

  /// Creates a load event to initialize practice data.
  factory PracticeEvent.load() = LoadPractice;

  /// Creates a refresh event to reload practice data.
  factory PracticeEvent.refresh() = RefreshPractice;

  /// Creates an event when practice session completes.
  factory PracticeEvent.complete({
    required int correctCount,
    required int needMorePracticeCount,
    required List<String> correctQuestionIds,
  }) = PracticeSessionComplete;

  /// Creates an event to reset back to ready state.
  factory PracticeEvent.reset() = ResetPractice;
}

/// Event to load practice data.
class LoadPractice extends PracticeEvent {
  /// Creates a [LoadPractice].
  const LoadPractice();
}

/// Event to refresh practice data.
class RefreshPractice extends PracticeEvent {
  /// Creates a [RefreshPractice].
  const RefreshPractice();
}

/// Event when a practice session completes.
class PracticeSessionComplete extends PracticeEvent {
  /// Creates a [PracticeSessionComplete].
  const PracticeSessionComplete({
    required this.correctCount,
    required this.needMorePracticeCount,
    required this.correctQuestionIds,
  });

  /// The number of questions answered correctly.
  final int correctCount;

  /// The number of questions that still need more practice.
  final int needMorePracticeCount;

  /// The IDs of questions that were answered correctly.
  final List<String> correctQuestionIds;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PracticeSessionComplete) return false;
    if (correctCount != other.correctCount) return false;
    if (needMorePracticeCount != other.needMorePracticeCount) return false;
    if (correctQuestionIds.length != other.correctQuestionIds.length) {
      return false;
    }
    for (var i = 0; i < correctQuestionIds.length; i++) {
      if (correctQuestionIds[i] != other.correctQuestionIds[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        correctCount,
        needMorePracticeCount,
        Object.hashAll(correctQuestionIds),
      );
}

/// Event to reset practice state back to ready.
class ResetPractice extends PracticeEvent {
  /// Creates a [ResetPractice].
  const ResetPractice();
}
