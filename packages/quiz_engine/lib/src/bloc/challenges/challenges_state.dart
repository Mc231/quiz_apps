/// State classes for the Challenges BLoC.
library;

import '../../models/challenge_mode.dart';
import '../../models/quiz_category.dart';

/// Sealed class representing all possible states for challenges.
sealed class ChallengesState {
  /// Creates a [ChallengesState].
  const ChallengesState();

  /// Creates a loading state.
  factory ChallengesState.loading() = ChallengesLoading;

  /// Creates a loaded state with challenges and categories.
  factory ChallengesState.loaded({
    required List<ChallengeMode> challenges,
    required List<QuizCategory> categories,
    bool isRefreshing,
  }) = ChallengesLoaded;

  /// Creates an error state.
  factory ChallengesState.error({
    required String message,
    Object? error,
  }) = ChallengesError;
}

/// State when challenges are loading.
class ChallengesLoading extends ChallengesState {
  /// Creates a [ChallengesLoading].
  const ChallengesLoading();
}

/// State when challenges are loaded.
class ChallengesLoaded extends ChallengesState {
  /// Creates a [ChallengesLoaded].
  const ChallengesLoaded({
    required this.challenges,
    required this.categories,
    this.isRefreshing = false,
  });

  /// The list of available challenges.
  final List<ChallengeMode> challenges;

  /// The list of available categories.
  final List<QuizCategory> categories;

  /// Whether challenges are being refreshed.
  final bool isRefreshing;

  /// Creates a copy with updated values.
  ChallengesLoaded copyWith({
    List<ChallengeMode>? challenges,
    List<QuizCategory>? categories,
    bool? isRefreshing,
  }) {
    return ChallengesLoaded(
      challenges: challenges ?? this.challenges,
      categories: categories ?? this.categories,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengesLoaded &&
        _listEquals(other.challenges, challenges) &&
        _listEquals(other.categories, categories) &&
        other.isRefreshing == isRefreshing;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(challenges),
        Object.hashAll(categories),
        isRefreshing,
      );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// State when there's an error loading challenges.
class ChallengesError extends ChallengesState {
  /// Creates a [ChallengesError].
  const ChallengesError({
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
    return other is ChallengesError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
