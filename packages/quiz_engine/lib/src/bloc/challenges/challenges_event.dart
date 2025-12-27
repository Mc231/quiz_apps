/// Event classes for the Challenges BLoC.
library;

/// Sealed class representing all possible events for challenges.
sealed class ChallengesEvent {
  /// Creates a [ChallengesEvent].
  const ChallengesEvent();

  /// Creates a load event to load challenges and categories.
  factory ChallengesEvent.load() = LoadChallenges;

  /// Creates a refresh event.
  factory ChallengesEvent.refresh() = RefreshChallenges;
}

/// Event to load challenges and categories.
class LoadChallenges extends ChallengesEvent {
  /// Creates a [LoadChallenges].
  const LoadChallenges();
}

/// Event to refresh challenges and categories.
class RefreshChallenges extends ChallengesEvent {
  /// Creates a [RefreshChallenges].
  const RefreshChallenges();
}
