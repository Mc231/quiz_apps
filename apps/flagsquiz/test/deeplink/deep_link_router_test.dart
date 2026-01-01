import 'package:flags_quiz/deeplink/deeplink_exports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeepLinkRouter', () {
    late DeepLinkRouter router;

    setUp(() {
      router = const DeepLinkRouter();
    });

    group('quiz routes', () {
      test('parses flagsquiz://quiz/europe', () {
        final uri = Uri.parse('flagsquiz://quiz/europe');
        final route = router.parse(uri);

        expect(route, isA<QuizRoute>());
        expect((route as QuizRoute).categoryId, 'europe');
        expect(route.routeType, 'quiz');
        expect(route.routeId, 'europe');
      });

      test('parses flagsquiz://quiz/asia-pacific', () {
        final uri = Uri.parse('flagsquiz://quiz/asia-pacific');
        final route = router.parse(uri);

        expect(route, isA<QuizRoute>());
        expect((route as QuizRoute).categoryId, 'asia-pacific');
      });

      test('returns unknown for quiz without category', () {
        final uri = Uri.parse('flagsquiz://quiz');
        final route = router.parse(uri);

        expect(route, isA<UnknownRoute>());
      });
    });

    group('achievement routes', () {
      test('parses flagsquiz://achievement/perfectionist', () {
        final uri = Uri.parse('flagsquiz://achievement/perfectionist');
        final route = router.parse(uri);

        expect(route, isA<AchievementRoute>());
        expect((route as AchievementRoute).achievementId, 'perfectionist');
        expect(route.routeType, 'achievement');
        expect(route.routeId, 'perfectionist');
      });

      test('returns unknown for achievement without id', () {
        final uri = Uri.parse('flagsquiz://achievement');
        final route = router.parse(uri);

        expect(route, isA<UnknownRoute>());
      });
    });

    group('challenge routes', () {
      test('parses flagsquiz://challenge/daily', () {
        final uri = Uri.parse('flagsquiz://challenge/daily');
        final route = router.parse(uri);

        expect(route, isA<ChallengeRoute>());
        expect((route as ChallengeRoute).challengeId, 'daily');
        expect(route.routeType, 'challenge');
        expect(route.routeId, 'daily');
      });

      test('parses flagsquiz://challenge/weekly', () {
        final uri = Uri.parse('flagsquiz://challenge/weekly');
        final route = router.parse(uri);

        expect(route, isA<ChallengeRoute>());
        expect((route as ChallengeRoute).challengeId, 'weekly');
      });

      test('returns unknown for challenge without id', () {
        final uri = Uri.parse('flagsquiz://challenge');
        final route = router.parse(uri);

        expect(route, isA<UnknownRoute>());
      });
    });

    group('unknown routes', () {
      test('returns unknown for different scheme', () {
        final uri = Uri.parse('otherscheme://quiz/europe');
        final route = router.parse(uri);

        expect(route, isA<UnknownRoute>());
        expect((route as UnknownRoute).uri, uri);
        expect(route.routeType, 'unknown');
        expect(route.routeId, isNull);
      });

      test('returns unknown for unrecognized path', () {
        final uri = Uri.parse('flagsquiz://settings');
        final route = router.parse(uri);

        expect(route, isA<UnknownRoute>());
      });

      test('returns unknown for empty path', () {
        final uri = Uri.parse('flagsquiz://');
        final route = router.parse(uri);

        expect(route, isA<UnknownRoute>());
      });
    });

    group('case sensitivity', () {
      test('handles uppercase route type', () {
        final uri = Uri.parse('flagsquiz://QUIZ/europe');
        final route = router.parse(uri);

        expect(route, isA<QuizRoute>());
        expect((route as QuizRoute).categoryId, 'europe');
      });

      test('handles mixed case route type', () {
        final uri = Uri.parse('flagsquiz://Challenge/daily');
        final route = router.parse(uri);

        expect(route, isA<ChallengeRoute>());
      });
    });

    group('path-based URLs', () {
      test('parses flagsquiz:///quiz/europe', () {
        final uri = Uri.parse('flagsquiz:///quiz/europe');
        final route = router.parse(uri);

        expect(route, isA<QuizRoute>());
        expect((route as QuizRoute).categoryId, 'europe');
      });
    });
  });

  group('FlagsQuizDeepLinkRoute', () {
    group('QuizRoute', () {
      test('equality', () {
        final route1 = FlagsQuizDeepLinkRoute.quiz(categoryId: 'europe');
        final route2 = FlagsQuizDeepLinkRoute.quiz(categoryId: 'europe');
        final route3 = FlagsQuizDeepLinkRoute.quiz(categoryId: 'asia');

        expect(route1, equals(route2));
        expect(route1, isNot(equals(route3)));
      });

      test('hashCode', () {
        final route1 = FlagsQuizDeepLinkRoute.quiz(categoryId: 'europe');
        final route2 = FlagsQuizDeepLinkRoute.quiz(categoryId: 'europe');

        expect(route1.hashCode, equals(route2.hashCode));
      });

      test('toString', () {
        final route = FlagsQuizDeepLinkRoute.quiz(categoryId: 'europe');
        expect(route.toString(), 'QuizRoute(categoryId: europe)');
      });
    });

    group('AchievementRoute', () {
      test('equality', () {
        final route1 =
            FlagsQuizDeepLinkRoute.achievement(achievementId: 'first_quiz');
        final route2 =
            FlagsQuizDeepLinkRoute.achievement(achievementId: 'first_quiz');
        final route3 =
            FlagsQuizDeepLinkRoute.achievement(achievementId: 'perfectionist');

        expect(route1, equals(route2));
        expect(route1, isNot(equals(route3)));
      });

      test('toString', () {
        final route =
            FlagsQuizDeepLinkRoute.achievement(achievementId: 'perfectionist');
        expect(
          route.toString(),
          'AchievementRoute(achievementId: perfectionist)',
        );
      });
    });

    group('ChallengeRoute', () {
      test('equality', () {
        final route1 = FlagsQuizDeepLinkRoute.challenge(challengeId: 'daily');
        final route2 = FlagsQuizDeepLinkRoute.challenge(challengeId: 'daily');
        final route3 = FlagsQuizDeepLinkRoute.challenge(challengeId: 'weekly');

        expect(route1, equals(route2));
        expect(route1, isNot(equals(route3)));
      });

      test('toString', () {
        final route = FlagsQuizDeepLinkRoute.challenge(challengeId: 'daily');
        expect(route.toString(), 'ChallengeRoute(challengeId: daily)');
      });
    });

    group('UnknownRoute', () {
      test('equality', () {
        final uri = Uri.parse('flagsquiz://unknown');
        final route1 = FlagsQuizDeepLinkRoute.unknown(uri: uri);
        final route2 = FlagsQuizDeepLinkRoute.unknown(uri: uri);
        final route3 = FlagsQuizDeepLinkRoute.unknown(
          uri: Uri.parse('flagsquiz://other'),
        );

        expect(route1, equals(route2));
        expect(route1, isNot(equals(route3)));
      });

      test('toString', () {
        final uri = Uri.parse('flagsquiz://unknown');
        final route = FlagsQuizDeepLinkRoute.unknown(uri: uri);
        expect(route.toString(), 'UnknownRoute(uri: $uri)');
      });
    });
  });
}
