/// Event classes for the Statistics BLoC.
library;

import '../../screens/statistics_dashboard_screen.dart';
import '../../widgets/leaderboard_widget.dart';
import '../../widgets/progress_chart_widget.dart';

/// Base sealed class for statistics events.
sealed class StatisticsEvent {
  const StatisticsEvent();

  /// Factory constructor for load event.
  factory StatisticsEvent.load() = LoadStatistics;

  /// Factory constructor for refresh event.
  factory StatisticsEvent.refresh() = RefreshStatistics;

  /// Factory constructor for tab change event.
  factory StatisticsEvent.changeTab(StatisticsDashboardTab tab) = ChangeTab;

  /// Factory constructor for time range change event.
  factory StatisticsEvent.changeTimeRange(ProgressTimeRange timeRange) =
      ChangeTimeRange;

  /// Factory constructor for leaderboard type change event.
  factory StatisticsEvent.changeLeaderboardType(LeaderboardType type) =
      ChangeLeaderboardType;
}

/// Event to load initial statistics data.
class LoadStatistics extends StatisticsEvent {
  /// Creates a [LoadStatistics] event.
  const LoadStatistics();
}

/// Event to refresh statistics data.
class RefreshStatistics extends StatisticsEvent {
  /// Creates a [RefreshStatistics] event.
  const RefreshStatistics();
}

/// Event to change the selected tab.
class ChangeTab extends StatisticsEvent {
  /// Creates a [ChangeTab] event.
  const ChangeTab(this.tab);

  /// The new tab to select.
  final StatisticsDashboardTab tab;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeTab && other.tab == tab;
  }

  @override
  int get hashCode => tab.hashCode;
}

/// Event to change the progress time range.
class ChangeTimeRange extends StatisticsEvent {
  /// Creates a [ChangeTimeRange] event.
  const ChangeTimeRange(this.timeRange);

  /// The new time range to select.
  final ProgressTimeRange timeRange;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeTimeRange && other.timeRange == timeRange;
  }

  @override
  int get hashCode => timeRange.hashCode;
}

/// Event to change the leaderboard type.
class ChangeLeaderboardType extends StatisticsEvent {
  /// Creates a [ChangeLeaderboardType] event.
  const ChangeLeaderboardType(this.type);

  /// The new leaderboard type to select.
  final LeaderboardType type;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeLeaderboardType && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}
