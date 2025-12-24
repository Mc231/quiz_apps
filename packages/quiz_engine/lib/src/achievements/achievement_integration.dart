import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'achievement_notification_controller.dart';

/// Helper class for integrating achievements with the quiz flow.
///
/// Provides utilities for:
/// - Creating quiz completion callbacks that check achievements
/// - Showing notifications for newly unlocked achievements
///
/// Example usage:
/// ```dart
/// final integration = AchievementIntegration(
///   achievementService: achievementService,
///   storageService: storageService,
///   notificationController: controller,
/// );
///
/// // Use with QuizBloc
/// QuizBloc(
///   dataProvider: loadQuestions,
///   randomItemPicker: picker,
///   configManager: configManager,
///   storageService: storage.quizStorage,
///   onQuizCompleted: integration.createCompletionCallback(),
/// );
/// ```
class AchievementIntegration {
  /// Creates an [AchievementIntegration].
  AchievementIntegration({
    required this.achievementService,
    required this.storageService,
    this.notificationController,
    this.onAchievementsUnlocked,
  });

  /// The achievement service for checking and managing achievements.
  final AchievementService achievementService;

  /// Storage service for retrieving session data.
  final StorageService storageService;

  /// Optional notification controller for showing unlock notifications.
  final AchievementNotificationController? notificationController;

  /// Callback invoked when achievements are unlocked.
  ///
  /// Use this for custom handling like analytics or sound effects.
  final void Function(List<Achievement> achievements)? onAchievementsUnlocked;

  /// Creates a quiz completion callback for use with QuizBloc.
  ///
  /// This callback will:
  /// 1. Retrieve the completed session from storage
  /// 2. Check for newly unlocked achievements
  /// 3. Show notifications for any unlocked achievements
  void Function(QuizResults results) createCompletionCallback() {
    return (QuizResults results) async {
      await checkAchievementsAfterQuiz(results);
    };
  }

  /// Checks for achievements after a quiz completes.
  ///
  /// Returns the list of newly unlocked achievements.
  Future<List<Achievement>> checkAchievementsAfterQuiz(
    QuizResults results,
  ) async {
    // Get the session from storage if we have a session ID
    if (results.sessionId == null) {
      return [];
    }

    final sessionResult =
        await storageService.getSessionWithAnswers(results.sessionId!);

    if (!sessionResult.isSuccess || sessionResult.valueOrNull == null) {
      return [];
    }

    final session = sessionResult.value!.session;

    // Check achievements using the service
    final unlocked = await achievementService.checkAfterSession(session);

    if (unlocked.isNotEmpty) {
      // Notify callback
      onAchievementsUnlocked?.call(unlocked);

      // Show notifications
      _showNotifications(unlocked);
    }

    return unlocked;
  }

  /// Shows notifications for unlocked achievements.
  void _showNotifications(List<Achievement> achievements) {
    final controller = notificationController;
    if (controller == null) return;

    for (final achievement in achievements) {
      controller.show(achievement);
    }
  }

  /// Checks for progress-based achievements (not tied to a specific session).
  ///
  /// Call this when you want to check achievements based on cumulative progress,
  /// such as total correct answers or sessions completed.
  Future<List<Achievement>> checkProgressAchievements() async {
    final unlocked = await achievementService.checkAll();

    if (unlocked.isNotEmpty) {
      onAchievementsUnlocked?.call(unlocked);
      _showNotifications(unlocked);
    }

    return unlocked;
  }

  /// Listens to the achievement service's unlock stream.
  ///
  /// This allows you to show notifications for achievements unlocked
  /// by any mechanism (not just quiz completion).
  void listenToUnlocks() {
    achievementService.onAchievementsUnlocked.listen((achievements) {
      _showNotifications(achievements);
    });
  }
}

/// Extension to add achievement integration to QuizBloc creation.
extension AchievementQuizBlocExtension on QuizBloc {
  /// Creates a callback that integrates with the achievement system.
  ///
  /// This is a convenience method for simple integration cases.
  /// For more control, use [AchievementIntegration] directly.
  static void Function(QuizResults) createAchievementCallback({
    required AchievementService achievementService,
    required StorageService storageService,
    AchievementNotificationController? notificationController,
  }) {
    final integration = AchievementIntegration(
      achievementService: achievementService,
      storageService: storageService,
      notificationController: notificationController,
    );
    return integration.createCompletionCallback();
  }
}
