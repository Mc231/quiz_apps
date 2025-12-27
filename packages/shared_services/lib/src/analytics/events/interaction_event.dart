import '../analytics_event.dart';

/// Sealed class for user interaction events.
///
/// Tracks user interactions with UI elements, navigation, and data operations.
/// Total: 12 events.
sealed class InteractionEvent extends AnalyticsEvent {
  const InteractionEvent();

  // ============ Navigation Events ============

  /// Category selected event.
  factory InteractionEvent.categorySelected({
    required String categoryId,
    required String categoryName,
    required int categoryIndex,
    String? parentCategoryId,
  }) = CategorySelectedEvent;

  /// Tab selected event.
  factory InteractionEvent.tabSelected({
    required String tabId,
    required String tabName,
    required int tabIndex,
    String? previousTabId,
  }) = TabSelectedEvent;

  // ============ Session Events ============

  /// Session viewed event (user opened session details).
  factory InteractionEvent.sessionViewed({
    required String sessionId,
    required String quizName,
    required double scorePercentage,
    required int daysAgo,
  }) = SessionViewedEvent;

  /// Session deleted event.
  factory InteractionEvent.sessionDeleted({
    required String sessionId,
    required String quizName,
    required int daysAgo,
  }) = SessionDeletedEvent;

  /// View all sessions event.
  factory InteractionEvent.viewAllSessions({
    required int totalSessions,
    required String source,
  }) = ViewAllSessionsEvent;

  // ============ Dialog Events ============

  /// Exit dialog shown event.
  factory InteractionEvent.exitDialogShown({
    required String quizId,
    required int questionsAnswered,
    required int totalQuestions,
  }) = ExitDialogShownEvent;

  /// Exit dialog confirmed event (user chose to exit).
  factory InteractionEvent.exitDialogConfirmed({
    required String quizId,
    required int questionsAnswered,
    required int totalQuestions,
    required Duration timeSpent,
  }) = ExitDialogConfirmedEvent;

  /// Exit dialog cancelled event (user chose to continue).
  factory InteractionEvent.exitDialogCancelled({
    required String quizId,
    required int questionsAnswered,
    required int totalQuestions,
  }) = ExitDialogCancelledEvent;

  // ============ Data Events ============

  /// Data export initiated event.
  factory InteractionEvent.dataExportInitiated({
    required String exportFormat,
    required int sessionCount,
    String? dateRange,
  }) = DataExportInitiatedEvent;

  /// Data export completed event.
  factory InteractionEvent.dataExportCompleted({
    required String exportFormat,
    required int sessionCount,
    required int fileSizeBytes,
    required Duration exportDuration,
    required bool success,
    String? errorMessage,
  }) = DataExportCompletedEvent;

  // ============ Refresh Events ============

  /// Pull to refresh event.
  factory InteractionEvent.pullToRefresh({
    required String screenName,
    required Duration refreshDuration,
    required bool success,
  }) = PullToRefreshEvent;

  // ============ Leaderboard Events ============

  /// Leaderboard viewed event.
  factory InteractionEvent.leaderboardViewed({
    required String leaderboardType,
    required int userRank,
    required int totalEntries,
    String? categoryId,
  }) = LeaderboardViewedEvent;
}

// ============ Navigation Event Implementations ============

/// Category selected event.
final class CategorySelectedEvent extends InteractionEvent {
  const CategorySelectedEvent({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIndex,
    this.parentCategoryId,
  });

  final String categoryId;
  final String categoryName;
  final int categoryIndex;
  final String? parentCategoryId;

  @override
  String get eventName => 'category_selected';

  @override
  Map<String, dynamic> get parameters => {
        'category_id': categoryId,
        'category_name': categoryName,
        'category_index': categoryIndex,
        if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      };
}

/// Tab selected event.
final class TabSelectedEvent extends InteractionEvent {
  const TabSelectedEvent({
    required this.tabId,
    required this.tabName,
    required this.tabIndex,
    this.previousTabId,
  });

  final String tabId;
  final String tabName;
  final int tabIndex;
  final String? previousTabId;

  @override
  String get eventName => 'tab_selected';

  @override
  Map<String, dynamic> get parameters => {
        'tab_id': tabId,
        'tab_name': tabName,
        'tab_index': tabIndex,
        if (previousTabId != null) 'previous_tab_id': previousTabId,
      };
}

// ============ Session Event Implementations ============

/// Session viewed event.
final class SessionViewedEvent extends InteractionEvent {
  const SessionViewedEvent({
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
  String get eventName => 'session_viewed';

  @override
  Map<String, dynamic> get parameters => {
        'session_id': sessionId,
        'quiz_name': quizName,
        'score_percentage': scorePercentage,
        'days_ago': daysAgo,
      };
}

/// Session deleted event.
final class SessionDeletedEvent extends InteractionEvent {
  const SessionDeletedEvent({
    required this.sessionId,
    required this.quizName,
    required this.daysAgo,
  });

  final String sessionId;
  final String quizName;
  final int daysAgo;

  @override
  String get eventName => 'session_deleted';

  @override
  Map<String, dynamic> get parameters => {
        'session_id': sessionId,
        'quiz_name': quizName,
        'days_ago': daysAgo,
      };
}

/// View all sessions event.
final class ViewAllSessionsEvent extends InteractionEvent {
  const ViewAllSessionsEvent({
    required this.totalSessions,
    required this.source,
  });

  final int totalSessions;
  final String source;

  @override
  String get eventName => 'view_all_sessions';

  @override
  Map<String, dynamic> get parameters => {
        'total_sessions': totalSessions,
        'source': source,
      };
}

// ============ Dialog Event Implementations ============

/// Exit dialog shown event.
final class ExitDialogShownEvent extends InteractionEvent {
  const ExitDialogShownEvent({
    required this.quizId,
    required this.questionsAnswered,
    required this.totalQuestions,
  });

  final String quizId;
  final int questionsAnswered;
  final int totalQuestions;

  @override
  String get eventName => 'exit_dialog_shown';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'questions_answered': questionsAnswered,
        'total_questions': totalQuestions,
        'completion_percentage': totalQuestions > 0
            ? (questionsAnswered / totalQuestions * 100).toStringAsFixed(1)
            : '0.0',
      };
}

/// Exit dialog confirmed event.
final class ExitDialogConfirmedEvent extends InteractionEvent {
  const ExitDialogConfirmedEvent({
    required this.quizId,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.timeSpent,
  });

  final String quizId;
  final int questionsAnswered;
  final int totalQuestions;
  final Duration timeSpent;

  @override
  String get eventName => 'exit_dialog_confirmed';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'questions_answered': questionsAnswered,
        'total_questions': totalQuestions,
        'time_spent_seconds': timeSpent.inSeconds,
      };
}

/// Exit dialog cancelled event.
final class ExitDialogCancelledEvent extends InteractionEvent {
  const ExitDialogCancelledEvent({
    required this.quizId,
    required this.questionsAnswered,
    required this.totalQuestions,
  });

  final String quizId;
  final int questionsAnswered;
  final int totalQuestions;

  @override
  String get eventName => 'exit_dialog_cancelled';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'questions_answered': questionsAnswered,
        'total_questions': totalQuestions,
      };
}

// ============ Data Event Implementations ============

/// Data export initiated event.
final class DataExportInitiatedEvent extends InteractionEvent {
  const DataExportInitiatedEvent({
    required this.exportFormat,
    required this.sessionCount,
    this.dateRange,
  });

  final String exportFormat;
  final int sessionCount;
  final String? dateRange;

  @override
  String get eventName => 'data_export_initiated';

  @override
  Map<String, dynamic> get parameters => {
        'export_format': exportFormat,
        'session_count': sessionCount,
        if (dateRange != null) 'date_range': dateRange,
      };
}

/// Data export completed event.
final class DataExportCompletedEvent extends InteractionEvent {
  const DataExportCompletedEvent({
    required this.exportFormat,
    required this.sessionCount,
    required this.fileSizeBytes,
    required this.exportDuration,
    required this.success,
    this.errorMessage,
  });

  final String exportFormat;
  final int sessionCount;
  final int fileSizeBytes;
  final Duration exportDuration;
  final bool success;
  final String? errorMessage;

  @override
  String get eventName => 'data_export_completed';

  @override
  Map<String, dynamic> get parameters => {
        'export_format': exportFormat,
        'session_count': sessionCount,
        'file_size_bytes': fileSizeBytes,
        'export_duration_ms': exportDuration.inMilliseconds,
        'success': success,
        if (errorMessage != null) 'error_message': errorMessage,
      };
}

// ============ Refresh Event Implementations ============

/// Pull to refresh event.
final class PullToRefreshEvent extends InteractionEvent {
  const PullToRefreshEvent({
    required this.screenName,
    required this.refreshDuration,
    required this.success,
  });

  final String screenName;
  final Duration refreshDuration;
  final bool success;

  @override
  String get eventName => 'pull_to_refresh';

  @override
  Map<String, dynamic> get parameters => {
        'screen_name': screenName,
        'refresh_duration_ms': refreshDuration.inMilliseconds,
        'success': success,
      };
}

// ============ Leaderboard Event Implementations ============

/// Leaderboard viewed event.
final class LeaderboardViewedEvent extends InteractionEvent {
  const LeaderboardViewedEvent({
    required this.leaderboardType,
    required this.userRank,
    required this.totalEntries,
    this.categoryId,
  });

  final String leaderboardType;
  final int userRank;
  final int totalEntries;
  final String? categoryId;

  @override
  String get eventName => 'leaderboard_viewed';

  @override
  Map<String, dynamic> get parameters => {
        'leaderboard_type': leaderboardType,
        'user_rank': userRank,
        'total_entries': totalEntries,
        if (categoryId != null) 'category_id': categoryId,
      };
}
