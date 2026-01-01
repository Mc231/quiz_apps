import 'flags_quiz_deep_link_route.dart';

/// Parses URIs into [FlagsQuizDeepLinkRoute] instances.
///
/// Supports the `flagsquiz://` URL scheme with the following paths:
/// - `/quiz/{categoryId}` - Opens a quiz for the specified category
/// - `/achievement/{id}` - Shows achievement details
/// - `/challenge/{id}` - Opens a specific challenge
///
/// Example:
/// ```dart
/// final router = DeepLinkRouter();
///
/// // Parse quiz deep link
/// final route = router.parse(Uri.parse('flagsquiz://quiz/europe'));
/// // Returns QuizRoute(categoryId: 'europe')
///
/// // Parse unknown link
/// final unknown = router.parse(Uri.parse('flagsquiz://unknown'));
/// // Returns UnknownRoute(uri: ...)
/// ```
class DeepLinkRouter {
  /// Creates a [DeepLinkRouter].
  const DeepLinkRouter();

  /// The expected URL scheme for Flags Quiz deep links.
  static const String scheme = 'flagsquiz';

  /// Parse a URI into a [FlagsQuizDeepLinkRoute].
  ///
  /// Returns [UnknownRoute] if the URI:
  /// - Has a different scheme than `flagsquiz`
  /// - Has an unrecognized path pattern
  /// - Is missing required path segments
  FlagsQuizDeepLinkRoute parse(Uri uri) {
    // Validate scheme
    if (uri.scheme != scheme) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    // Get path segments, handling both host-based and path-based URLs
    // flagsquiz://quiz/europe -> host: 'quiz', pathSegments: ['europe']
    // flagsquiz:///quiz/europe -> host: '', pathSegments: ['quiz', 'europe']
    final segments = _getPathSegments(uri);

    if (segments.isEmpty) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    final routeType = segments[0].toLowerCase();

    return switch (routeType) {
      'quiz' => _parseQuizRoute(segments, uri),
      'achievement' => _parseAchievementRoute(segments, uri),
      'challenge' => _parseChallengeRoute(segments, uri),
      _ => FlagsQuizDeepLinkRoute.unknown(uri: uri),
    };
  }

  /// Extract path segments from a URI, handling both formats:
  /// - `flagsquiz://quiz/europe` (host-based)
  /// - `flagsquiz:///quiz/europe` (path-based)
  List<String> _getPathSegments(Uri uri) {
    // If host is not empty, treat it as the first segment
    if (uri.host.isNotEmpty) {
      return [uri.host, ...uri.pathSegments];
    }

    // Otherwise use path segments directly
    return uri.pathSegments.where((s) => s.isNotEmpty).toList();
  }

  /// Parse quiz route: flagsquiz://quiz/{categoryId}
  FlagsQuizDeepLinkRoute _parseQuizRoute(List<String> segments, Uri uri) {
    if (segments.length < 2) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    final categoryId = segments[1];
    if (categoryId.isEmpty) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    return FlagsQuizDeepLinkRoute.quiz(categoryId: categoryId);
  }

  /// Parse achievement route: flagsquiz://achievement/{achievementId}
  FlagsQuizDeepLinkRoute _parseAchievementRoute(
    List<String> segments,
    Uri uri,
  ) {
    if (segments.length < 2) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    final achievementId = segments[1];
    if (achievementId.isEmpty) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    return FlagsQuizDeepLinkRoute.achievement(achievementId: achievementId);
  }

  /// Parse challenge route: flagsquiz://challenge/{challengeId}
  FlagsQuizDeepLinkRoute _parseChallengeRoute(List<String> segments, Uri uri) {
    if (segments.length < 2) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    final challengeId = segments[1];
    if (challengeId.isEmpty) {
      return FlagsQuizDeepLinkRoute.unknown(uri: uri);
    }

    return FlagsQuizDeepLinkRoute.challenge(challengeId: challengeId);
  }
}
