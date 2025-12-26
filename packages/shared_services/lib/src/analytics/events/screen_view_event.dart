import '../analytics_event.dart';

/// Sealed class for all screen view events.
///
/// Provides exhaustive tracking of all app screens.
/// Total: 17 standard screens + 1 custom screen type.
sealed class ScreenViewEvent extends AnalyticsEvent {
  const ScreenViewEvent();

  @override
  String get eventName => 'screen_view';

  /// The screen name (required by all screen events).
  String get screenName;

  /// Optional screen class for more detailed tracking.
  String get screenClass;

  // ============ Home & Navigation Screens ============

  /// Home screen with tabs.
  factory ScreenViewEvent.home({required String activeTab}) = HomeScreenView;

  /// Play/Categories tab.
  factory ScreenViewEvent.play({required int categoryCount}) = PlayScreenView;

  /// Tabbed play screen variant.
  factory ScreenViewEvent.playTabbed({
    required String tabId,
    required String tabName,
  }) = PlayTabbedScreenView;

  /// Session history tab.
  factory ScreenViewEvent.history({required int sessionCount}) =
      HistoryScreenView;

  /// Statistics dashboard tab.
  factory ScreenViewEvent.statistics({
    required int totalSessions,
    required double averageScore,
  }) = StatisticsScreenView;

  /// Achievements tab.
  factory ScreenViewEvent.achievements({
    required int unlockedCount,
    required int totalCount,
    required int totalPoints,
  }) = AchievementsScreenView;

  /// Settings screen.
  factory ScreenViewEvent.settings() = SettingsScreenView;

  // ============ Quiz Screens ============

  /// Quiz gameplay screen.
  factory ScreenViewEvent.quiz({
    required String quizId,
    required String quizName,
    required String mode,
    required int totalQuestions,
  }) = QuizScreenView;

  /// Quiz results screen.
  factory ScreenViewEvent.results({
    required String quizId,
    required String quizName,
    required double scorePercentage,
    required bool isPerfectScore,
    required int starRating,
  }) = ResultsScreenView;

  /// Session detail/review screen.
  factory ScreenViewEvent.sessionDetail({
    required String sessionId,
    required String quizName,
    required double scorePercentage,
    required int daysAgo,
  }) = SessionDetailScreenView;

  // ============ Category & Challenge Screens ============

  /// Category statistics screen.
  factory ScreenViewEvent.categoryStatistics({
    required String categoryId,
    required String categoryName,
    required int totalSessions,
    required double averageScore,
  }) = CategoryStatisticsScreenView;

  /// Challenges list screen.
  factory ScreenViewEvent.challenges({
    required int challengeCount,
    required int completedCount,
  }) = ChallengesScreenView;

  /// Practice mode screen.
  factory ScreenViewEvent.practice({
    required String categoryId,
    required String categoryName,
  }) = PracticeScreenView;

  // ============ Leaderboard & Social ============

  /// Leaderboard screen.
  factory ScreenViewEvent.leaderboard({
    required String leaderboardType,
    required int entryCount,
  }) = LeaderboardScreenView;

  // ============ Info Screens ============

  /// About dialog/screen.
  factory ScreenViewEvent.about({
    required String appVersion,
    required String buildNumber,
  }) = AboutScreenView;

  /// Open source licenses screen.
  factory ScreenViewEvent.licenses() = LicensesScreenView;

  /// Tutorial/onboarding screen.
  factory ScreenViewEvent.tutorial({
    required int stepIndex,
    required int totalSteps,
  }) = TutorialScreenView;

  // ============ Custom Screen ============

  /// Custom screen for app-specific screens not covered by standard events.
  ///
  /// Use this for app-specific screens like:
  /// - FlagsQuiz: continent selection, flag detail
  /// - MathQuiz: difficulty selection, formula reference
  factory ScreenViewEvent.custom({
    required String name,
    required String className,
    Map<String, dynamic>? additionalParams,
  }) = CustomScreenView;
}

// ============ Home & Navigation Implementations ============

/// Home screen view event.
final class HomeScreenView extends ScreenViewEvent {
  const HomeScreenView({required this.activeTab});

  final String activeTab;

  @override
  String get screenName => 'home';

  @override
  String get screenClass => 'HomeScreen';

  @override
  Map<String, dynamic> get parameters => {
        'active_tab': activeTab,
      };
}

/// Play screen view event.
final class PlayScreenView extends ScreenViewEvent {
  const PlayScreenView({required this.categoryCount});

  final int categoryCount;

  @override
  String get screenName => 'play';

  @override
  String get screenClass => 'PlayScreen';

  @override
  Map<String, dynamic> get parameters => {
        'category_count': categoryCount,
      };
}

/// Tabbed play screen view event.
final class PlayTabbedScreenView extends ScreenViewEvent {
  const PlayTabbedScreenView({
    required this.tabId,
    required this.tabName,
  });

  final String tabId;
  final String tabName;

  @override
  String get screenName => 'play_tabbed';

  @override
  String get screenClass => 'PlayTabbedScreen';

  @override
  Map<String, dynamic> get parameters => {
        'tab_id': tabId,
        'tab_name': tabName,
      };
}

/// History screen view event.
final class HistoryScreenView extends ScreenViewEvent {
  const HistoryScreenView({required this.sessionCount});

  final int sessionCount;

  @override
  String get screenName => 'history';

  @override
  String get screenClass => 'SessionHistoryScreen';

  @override
  Map<String, dynamic> get parameters => {
        'session_count': sessionCount,
      };
}

/// Statistics screen view event.
final class StatisticsScreenView extends ScreenViewEvent {
  const StatisticsScreenView({
    required this.totalSessions,
    required this.averageScore,
  });

  final int totalSessions;
  final double averageScore;

  @override
  String get screenName => 'statistics';

  @override
  String get screenClass => 'StatisticsDashboard';

  @override
  Map<String, dynamic> get parameters => {
        'total_sessions': totalSessions,
        'average_score': averageScore,
      };
}

/// Achievements screen view event.
final class AchievementsScreenView extends ScreenViewEvent {
  const AchievementsScreenView({
    required this.unlockedCount,
    required this.totalCount,
    required this.totalPoints,
  });

  final int unlockedCount;
  final int totalCount;
  final int totalPoints;

  @override
  String get screenName => 'achievements';

  @override
  String get screenClass => 'AchievementsScreen';

  @override
  Map<String, dynamic> get parameters => {
        'unlocked_count': unlockedCount,
        'total_count': totalCount,
        'total_points': totalPoints,
        'unlock_percentage': totalCount > 0
            ? (unlockedCount / totalCount * 100).toStringAsFixed(1)
            : '0.0',
      };
}

/// Settings screen view event.
final class SettingsScreenView extends ScreenViewEvent {
  const SettingsScreenView();

  @override
  String get screenName => 'settings';

  @override
  String get screenClass => 'QuizSettingsScreen';

  @override
  Map<String, dynamic> get parameters => {};
}

// ============ Quiz Screen Implementations ============

/// Quiz screen view event.
final class QuizScreenView extends ScreenViewEvent {
  const QuizScreenView({
    required this.quizId,
    required this.quizName,
    required this.mode,
    required this.totalQuestions,
  });

  final String quizId;
  final String quizName;
  final String mode;
  final int totalQuestions;

  @override
  String get screenName => 'quiz';

  @override
  String get screenClass => 'QuizScreen';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'mode': mode,
        'total_questions': totalQuestions,
      };
}

/// Results screen view event.
final class ResultsScreenView extends ScreenViewEvent {
  const ResultsScreenView({
    required this.quizId,
    required this.quizName,
    required this.scorePercentage,
    required this.isPerfectScore,
    required this.starRating,
  });

  final String quizId;
  final String quizName;
  final double scorePercentage;
  final bool isPerfectScore;
  final int starRating;

  @override
  String get screenName => 'results';

  @override
  String get screenClass => 'QuizResultsScreen';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'score_percentage': scorePercentage,
        'is_perfect_score': isPerfectScore,
        'star_rating': starRating,
      };
}

/// Session detail screen view event.
final class SessionDetailScreenView extends ScreenViewEvent {
  const SessionDetailScreenView({
    required this.sessionId,
    required this.quizName,
    required this.scorePercentage,
    required this.daysAgo,
  });

  final String sessionId;
  final String quizName;
  final double scorePercentage;
  final int daysAgo;

  @override
  String get screenName => 'session_detail';

  @override
  String get screenClass => 'SessionDetailScreen';

  @override
  Map<String, dynamic> get parameters => {
        'session_id': sessionId,
        'quiz_name': quizName,
        'score_percentage': scorePercentage,
        'days_ago': daysAgo,
      };
}

// ============ Category & Challenge Implementations ============

/// Category statistics screen view event.
final class CategoryStatisticsScreenView extends ScreenViewEvent {
  const CategoryStatisticsScreenView({
    required this.categoryId,
    required this.categoryName,
    required this.totalSessions,
    required this.averageScore,
  });

  final String categoryId;
  final String categoryName;
  final int totalSessions;
  final double averageScore;

  @override
  String get screenName => 'category_statistics';

  @override
  String get screenClass => 'CategoryStatisticsScreen';

  @override
  Map<String, dynamic> get parameters => {
        'category_id': categoryId,
        'category_name': categoryName,
        'total_sessions': totalSessions,
        'average_score': averageScore,
      };
}

/// Challenges screen view event.
final class ChallengesScreenView extends ScreenViewEvent {
  const ChallengesScreenView({
    required this.challengeCount,
    required this.completedCount,
  });

  final int challengeCount;
  final int completedCount;

  @override
  String get screenName => 'challenges';

  @override
  String get screenClass => 'ChallengesScreen';

  @override
  Map<String, dynamic> get parameters => {
        'challenge_count': challengeCount,
        'completed_count': completedCount,
        'completion_percentage': challengeCount > 0
            ? (completedCount / challengeCount * 100).toStringAsFixed(1)
            : '0.0',
      };
}

/// Practice screen view event.
final class PracticeScreenView extends ScreenViewEvent {
  const PracticeScreenView({
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  String get screenName => 'practice';

  @override
  String get screenClass => 'PracticeScreen';

  @override
  Map<String, dynamic> get parameters => {
        'category_id': categoryId,
        'category_name': categoryName,
      };
}

// ============ Leaderboard Implementation ============

/// Leaderboard screen view event.
final class LeaderboardScreenView extends ScreenViewEvent {
  const LeaderboardScreenView({
    required this.leaderboardType,
    required this.entryCount,
  });

  final String leaderboardType;
  final int entryCount;

  @override
  String get screenName => 'leaderboard';

  @override
  String get screenClass => 'LeaderboardScreen';

  @override
  Map<String, dynamic> get parameters => {
        'leaderboard_type': leaderboardType,
        'entry_count': entryCount,
      };
}

// ============ Info Screen Implementations ============

/// About screen view event.
final class AboutScreenView extends ScreenViewEvent {
  const AboutScreenView({
    required this.appVersion,
    required this.buildNumber,
  });

  final String appVersion;
  final String buildNumber;

  @override
  String get screenName => 'about';

  @override
  String get screenClass => 'AboutScreen';

  @override
  Map<String, dynamic> get parameters => {
        'app_version': appVersion,
        'build_number': buildNumber,
      };
}

/// Licenses screen view event.
final class LicensesScreenView extends ScreenViewEvent {
  const LicensesScreenView();

  @override
  String get screenName => 'licenses';

  @override
  String get screenClass => 'LicensesScreen';

  @override
  Map<String, dynamic> get parameters => {};
}

/// Tutorial screen view event.
final class TutorialScreenView extends ScreenViewEvent {
  const TutorialScreenView({
    required this.stepIndex,
    required this.totalSteps,
  });

  final int stepIndex;
  final int totalSteps;

  @override
  String get screenName => 'tutorial';

  @override
  String get screenClass => 'TutorialScreen';

  @override
  Map<String, dynamic> get parameters => {
        'step_index': stepIndex,
        'total_steps': totalSteps,
        'progress_percentage': totalSteps > 0
            ? ((stepIndex + 1) / totalSteps * 100).toStringAsFixed(1)
            : '0.0',
      };
}

// ============ Custom Screen Implementation ============

/// Custom screen view event for app-specific screens.
///
/// Use this for screens not covered by standard events.
final class CustomScreenView extends ScreenViewEvent {
  const CustomScreenView({
    required this.name,
    required this.className,
    this.additionalParams,
  });

  final String name;
  final String className;
  final Map<String, dynamic>? additionalParams;

  @override
  String get screenName => name;

  @override
  String get screenClass => className;

  @override
  Map<String, dynamic> get parameters => {
        ...?additionalParams,
      };
}
