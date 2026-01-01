/// Sealed class representing parsed deep link routes for Flags Quiz.
///
/// Supports the following URL patterns:
/// - `flagsquiz://quiz/{categoryId}` - Open a specific quiz category
/// - `flagsquiz://achievement/{achievementId}` - Show achievement details
/// - `flagsquiz://challenge/{challengeId}` - Open a specific challenge
///
/// Unknown or invalid URLs are represented by [UnknownRoute].
sealed class FlagsQuizDeepLinkRoute {
  const FlagsQuizDeepLinkRoute();

  /// Open a specific quiz category.
  factory FlagsQuizDeepLinkRoute.quiz({required String categoryId}) = QuizRoute;

  /// Show achievement details.
  factory FlagsQuizDeepLinkRoute.achievement({
    required String achievementId,
  }) = AchievementRoute;

  /// Open a specific challenge.
  factory FlagsQuizDeepLinkRoute.challenge({
    required String challengeId,
  }) = ChallengeRoute;

  /// Unknown or invalid deep link.
  factory FlagsQuizDeepLinkRoute.unknown({required Uri uri}) = UnknownRoute;

  /// The route type name for analytics.
  String get routeType;

  /// The route-specific identifier for analytics (if applicable).
  String? get routeId;
}

/// Route to open a specific quiz category.
final class QuizRoute extends FlagsQuizDeepLinkRoute {
  const QuizRoute({required this.categoryId});

  /// The category ID to open (e.g., 'europe', 'asia', 'africa').
  final String categoryId;

  @override
  String get routeType => 'quiz';

  @override
  String? get routeId => categoryId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizRoute && categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;

  @override
  String toString() => 'QuizRoute(categoryId: $categoryId)';
}

/// Route to show achievement details.
final class AchievementRoute extends FlagsQuizDeepLinkRoute {
  const AchievementRoute({required this.achievementId});

  /// The achievement ID to display.
  final String achievementId;

  @override
  String get routeType => 'achievement';

  @override
  String? get routeId => achievementId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementRoute && achievementId == other.achievementId;

  @override
  int get hashCode => achievementId.hashCode;

  @override
  String toString() => 'AchievementRoute(achievementId: $achievementId)';
}

/// Route to open a specific challenge.
final class ChallengeRoute extends FlagsQuizDeepLinkRoute {
  const ChallengeRoute({required this.challengeId});

  /// The challenge ID to open (e.g., 'daily', 'weekly').
  final String challengeId;

  @override
  String get routeType => 'challenge';

  @override
  String? get routeId => challengeId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeRoute && challengeId == other.challengeId;

  @override
  int get hashCode => challengeId.hashCode;

  @override
  String toString() => 'ChallengeRoute(challengeId: $challengeId)';
}

/// Unknown or invalid deep link route.
final class UnknownRoute extends FlagsQuizDeepLinkRoute {
  const UnknownRoute({required this.uri});

  /// The original URI that couldn't be parsed.
  final Uri uri;

  @override
  String get routeType => 'unknown';

  @override
  String? get routeId => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnknownRoute && uri == other.uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => 'UnknownRoute(uri: $uri)';
}
