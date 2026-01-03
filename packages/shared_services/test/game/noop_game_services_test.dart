import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('NoOpGameServices', () {
    test('provides singleton instance', () {
      final instance1 = NoOpGameServices.instance;
      final instance2 = NoOpGameServices.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('provides NoOpGameService', () {
      expect(NoOpGameServices.gameService, isA<NoOpGameService>());
      expect(NoOpGameServices.gameService, isA<GameService>());
    });

    test('provides NoOpLeaderboardService', () {
      expect(NoOpGameServices.leaderboardService, isA<NoOpLeaderboardService>());
      expect(NoOpGameServices.leaderboardService, isA<LeaderboardService>());
    });

    test('provides NoOpCloudAchievementService', () {
      expect(
        NoOpGameServices.cloudAchievementService,
        isA<NoOpCloudAchievementService>(),
      );
      expect(
        NoOpGameServices.cloudAchievementService,
        isA<CloudAchievementService>(),
      );
    });

    test('all services are const instances', () {
      // Verify they can be used as const
      const gameService = NoOpGameServices.gameService;
      const leaderboardService = NoOpGameServices.leaderboardService;
      const cloudAchievementService = NoOpGameServices.cloudAchievementService;

      expect(gameService, isNotNull);
      expect(leaderboardService, isNotNull);
      expect(cloudAchievementService, isNotNull);
    });
  });

  group('NoOpGameServices integration', () {
    test('can be used together in a typical flow', () async {
      final gameService = NoOpGameServices.gameService;
      final leaderboardService = NoOpGameServices.leaderboardService;
      final achievementService = NoOpGameServices.cloudAchievementService;

      // Attempt sign in
      final signInResult = await gameService.signIn();
      expect(signInResult, isA<SignInNotAuthenticated>());

      // Check signed in status
      final isSignedIn = await gameService.isSignedIn();
      expect(isSignedIn, isFalse);

      // Try to submit score
      final scoreResult = await leaderboardService.submitScore(
        leaderboardId: 'main_leaderboard',
        score: 1000,
      );
      expect(scoreResult, isA<SubmitScoreNotSignedIn>());

      // Try to get leaderboard
      final scores = await leaderboardService.getTopScores(
        leaderboardId: 'main_leaderboard',
        count: 10,
      );
      expect(scores, isEmpty);

      // Try to unlock achievement
      final unlockResult = await achievementService.unlockAchievement(
        'first_quiz',
      );
      expect(unlockResult, isA<UnlockAchievementNotSignedIn>());

      // Try to get achievements
      final achievements = await achievementService.getAchievements();
      expect(achievements, isEmpty);
    });

    test('services work independently', () async {
      // Each service should work regardless of others
      final gameService = NoOpGameServices.gameService;
      final leaderboardService = NoOpGameServices.leaderboardService;
      final achievementService = NoOpGameServices.cloudAchievementService;

      // All operations should complete without throwing
      await expectLater(gameService.isSignedIn(), completion(isFalse));
      await expectLater(
        leaderboardService.showAllLeaderboards(),
        completion(isFalse),
      );
      await expectLater(
        achievementService.showAchievements(),
        completion(isFalse),
      );
    });
  });
}