import 'package:shared_services/shared_services.dart';

import '../home/quiz_home_screen.dart';

/// Interface for providing achievements data and handling session completion.
///
/// Apps implement this interface to integrate their achievement system
/// with [QuizApp]. The provider handles both loading achievements for display
/// and processing completed quiz sessions for achievement checks.
///
/// Example:
/// ```dart
/// class MyAchievementsDataProvider implements AchievementsDataProvider {
///   final AchievementService _achievementService;
///   final QuizSessionRepository _sessionRepository;
///
///   @override
///   Future<AchievementsTabData> loadAchievementsData() async {
///     // Load and return achievements data for display
///   }
///
///   @override
///   Future<void> onSessionCompleted(QuizSession session) async {
///     // Check achievements after quiz completion
///     await _achievementService.checkAfterSession(session);
///   }
/// }
/// ```
abstract class AchievementsDataProvider {
  /// Creates an [AchievementsDataProvider].
  const AchievementsDataProvider();

  /// Loads achievements data for the Achievements tab.
  ///
  /// Called when the Achievements tab is displayed or needs to be refreshed.
  /// Returns all achievements with their current progress and unlock status.
  Future<AchievementsTabData> loadAchievementsData();

  /// Called when a quiz session is completed.
  ///
  /// This method is invoked by [QuizApp] after a quiz finishes.
  /// Implementations should:
  /// 1. Refresh any cached data (category stats, challenge stats, etc.)
  /// 2. Check for newly unlocked achievements
  /// 3. Trigger any necessary notifications
  ///
  /// [session] - The completed quiz session from storage.
  Future<void> onSessionCompleted(QuizSession session);
}
