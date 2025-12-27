/// State classes for the Statistics BLoC.
library;

import '../../screens/statistics_dashboard_screen.dart';
import '../../widgets/leaderboard_widget.dart';
import '../../widgets/progress_chart_widget.dart';

/// Base sealed class for statistics state.
sealed class StatisticsState {
  const StatisticsState();

  /// Factory constructor for initial loading state.
  factory StatisticsState.loading() = StatisticsLoading;

  /// Factory constructor for loaded state with data.
  factory StatisticsState.loaded({
    required StatisticsDashboardData data,
    StatisticsDashboardTab selectedTab,
    ProgressTimeRange progressTimeRange,
    LeaderboardType leaderboardType,
  }) = StatisticsLoaded;

  /// Factory constructor for error state.
  factory StatisticsState.error({
    required String message,
    Object? error,
  }) = StatisticsError;
}

/// Initial loading state.
class StatisticsLoading extends StatisticsState {
  /// Creates a [StatisticsLoading] state.
  const StatisticsLoading();
}

/// Loaded state with statistics data and UI state.
class StatisticsLoaded extends StatisticsState {
  /// Creates a [StatisticsLoaded] state.
  const StatisticsLoaded({
    required this.data,
    this.selectedTab = StatisticsDashboardTab.overview,
    this.progressTimeRange = ProgressTimeRange.week,
    this.leaderboardType = LeaderboardType.bestScores,
    this.isRefreshing = false,
  });

  /// The dashboard data.
  final StatisticsDashboardData data;

  /// Currently selected tab.
  final StatisticsDashboardTab selectedTab;

  /// Selected time range for progress chart.
  final ProgressTimeRange progressTimeRange;

  /// Selected leaderboard type.
  final LeaderboardType leaderboardType;

  /// Whether a refresh is in progress.
  final bool isRefreshing;

  /// Creates a copy of this state with optional new values.
  StatisticsLoaded copyWith({
    StatisticsDashboardData? data,
    StatisticsDashboardTab? selectedTab,
    ProgressTimeRange? progressTimeRange,
    LeaderboardType? leaderboardType,
    bool? isRefreshing,
  }) {
    return StatisticsLoaded(
      data: data ?? this.data,
      selectedTab: selectedTab ?? this.selectedTab,
      progressTimeRange: progressTimeRange ?? this.progressTimeRange,
      leaderboardType: leaderboardType ?? this.leaderboardType,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatisticsLoaded &&
        other.data == data &&
        other.selectedTab == selectedTab &&
        other.progressTimeRange == progressTimeRange &&
        other.leaderboardType == leaderboardType &&
        other.isRefreshing == isRefreshing;
  }

  @override
  int get hashCode => Object.hash(
        data,
        selectedTab,
        progressTimeRange,
        leaderboardType,
        isRefreshing,
      );
}

/// Error state when loading statistics fails.
class StatisticsError extends StatisticsState {
  /// Creates a [StatisticsError] state.
  const StatisticsError({
    required this.message,
    this.error,
  });

  /// User-friendly error message.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatisticsError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
