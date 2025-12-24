/// Context data for achievement evaluation.
library;

import '../../storage/models/global_statistics.dart';
import '../../storage/models/quiz_session.dart';

/// Provides all context needed for evaluating achievement triggers.
///
/// This class bundles together:
/// - Global statistics (cumulative data)
/// - Current session (if evaluating after a quiz)
/// - App-provided data for categories and challenges
class AchievementContext {
  /// Creates an [AchievementContext].
  const AchievementContext({
    required this.globalStats,
    this.session,
    this.categoryData = const {},
    this.challengeData = const {},
  });

  /// Creates a context for checking after a quiz session completes.
  factory AchievementContext.afterSession({
    required GlobalStatistics globalStats,
    required QuizSession session,
    Map<String, CategoryCompletionData> categoryData = const {},
    Map<String, ChallengeCompletionData> challengeData = const {},
  }) {
    return AchievementContext(
      globalStats: globalStats,
      session: session,
      categoryData: categoryData,
      challengeData: challengeData,
    );
  }

  /// Creates a context for checking cumulative/progressive achievements.
  factory AchievementContext.forProgress({
    required GlobalStatistics globalStats,
    Map<String, CategoryCompletionData> categoryData = const {},
    Map<String, ChallengeCompletionData> challengeData = const {},
  }) {
    return AchievementContext(
      globalStats: globalStats,
      categoryData: categoryData,
      challengeData: challengeData,
    );
  }

  /// Global statistics across all sessions.
  final GlobalStatistics globalStats;

  /// The current quiz session (null if checking progress only).
  final QuizSession? session;

  /// App-provided category completion data.
  ///
  /// Key is category ID, value is completion data.
  /// Apps should provide this based on their domain model.
  final Map<String, CategoryCompletionData> categoryData;

  /// App-provided challenge completion data.
  ///
  /// Key is challenge ID, value is completion data.
  /// Apps should provide this based on their domain model.
  final Map<String, ChallengeCompletionData> challengeData;

  /// Whether this context has session data.
  bool get hasSession => session != null;

  /// Whether the current session (if any) was completed.
  bool get sessionCompleted =>
      session?.completionStatus == CompletionStatus.completed;

  /// Whether the current session (if any) had a perfect score.
  bool get sessionPerfect => session?.scorePercentage == 100.0;

  /// Whether the current session (if any) used no hints.
  bool get sessionNoHints =>
      session != null &&
      session!.hintsUsed5050 == 0 &&
      session!.hintsUsedSkip == 0;

  /// Gets category data for a specific category ID.
  CategoryCompletionData? getCategoryData(String categoryId) =>
      categoryData[categoryId];

  /// Gets challenge data for a specific challenge ID.
  ChallengeCompletionData? getChallengeData(String challengeId) =>
      challengeData[challengeId];

  @override
  String toString() => 'AchievementContext('
      'hasSession: $hasSession, '
      'categories: ${categoryData.length}, '
      'challenges: ${challengeData.length})';
}

/// Data about category completion provided by the app.
class CategoryCompletionData {
  /// Creates category completion data.
  const CategoryCompletionData({
    required this.categoryId,
    this.totalCompletions = 0,
    this.perfectCompletions = 0,
    this.isFullyCompleted = false,
  });

  /// The category identifier.
  final String categoryId;

  /// Total number of times this category was completed.
  final int totalCompletions;

  /// Number of times completed with perfect score.
  final int perfectCompletions;

  /// Whether all questions in this category have been answered correctly.
  final bool isFullyCompleted;

  @override
  String toString() => 'CategoryCompletionData('
      'categoryId: $categoryId, '
      'completions: $totalCompletions, '
      'perfect: $perfectCompletions)';
}

/// Data about challenge completion provided by the app.
class ChallengeCompletionData {
  /// Creates challenge completion data.
  const ChallengeCompletionData({
    required this.challengeId,
    this.totalCompletions = 0,
    this.perfectCompletions = 0,
    this.noLivesLostCompletions = 0,
    this.bestScore = 0.0,
  });

  /// The challenge identifier.
  final String challengeId;

  /// Total number of times this challenge was completed.
  final int totalCompletions;

  /// Number of times completed with perfect score.
  final int perfectCompletions;

  /// Number of times completed without losing any lives.
  final int noLivesLostCompletions;

  /// Best score achieved in this challenge.
  final double bestScore;

  /// Whether this challenge has ever been completed.
  bool get hasCompleted => totalCompletions > 0;

  /// Whether this challenge was completed with perfect score.
  bool get hasCompletedPerfect => perfectCompletions > 0;

  /// Whether this challenge was completed without losing lives.
  bool get hasCompletedNoLivesLost => noLivesLostCompletions > 0;

  @override
  String toString() => 'ChallengeCompletionData('
      'challengeId: $challengeId, '
      'completions: $totalCompletions, '
      'perfect: $perfectCompletions)';
}
