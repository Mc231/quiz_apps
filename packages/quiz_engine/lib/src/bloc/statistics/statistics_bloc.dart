/// Business Logic Component for the Statistics Dashboard.
library;

import 'dart:async';

import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../../screens/statistics_dashboard_screen.dart';
import '../../widgets/leaderboard_widget.dart';
import '../../widgets/progress_chart_widget.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

/// Abstract interface for providing statistics data to the BLoC.
///
/// This interface allows apps to implement their own data fetching logic
/// while the BLoC handles state management and UI coordination.
abstract class StatisticsDataProvider {
  /// Creates a [StatisticsDataProvider].
  const StatisticsDataProvider();

  /// Loads the complete statistics dashboard data.
  ///
  /// This includes global statistics, category statistics, progress data,
  /// leaderboard entries, and recent sessions.
  Future<StatisticsDashboardData> loadDashboardData();

  /// Loads progress data points for a specific time range.
  ///
  /// Used when the user changes the progress chart time range.
  Future<List<ProgressDataPoint>> loadProgressData(ProgressTimeRange timeRange);
}

/// BLoC for managing the Statistics Dashboard state.
///
/// Handles:
/// - Loading and refreshing statistics data
/// - Tab switching
/// - Progress time range changes
/// - Leaderboard type changes
class StatisticsBloc extends SingleSubscriptionBloc<StatisticsState> {
  /// Creates a [StatisticsBloc].
  ///
  /// [dataProvider] is required to fetch statistics data.
  /// [initialTab] optionally sets the initial tab (defaults to overview).
  StatisticsBloc({
    required StatisticsDataProvider dataProvider,
    StatisticsDashboardTab initialTab = StatisticsDashboardTab.overview,
  })  : _dataProvider = dataProvider,
        _initialTab = initialTab;

  final StatisticsDataProvider _dataProvider;
  final StatisticsDashboardTab _initialTab;

  /// Dispatches an event to the BLoC.
  void add(StatisticsEvent event) {
    switch (event) {
      case LoadStatistics():
        _handleLoad();
      case RefreshStatistics():
        _handleRefresh();
      case ChangeTab(:final tab):
        _handleTabChange(tab);
      case ChangeTimeRange(:final timeRange):
        _handleTimeRangeChange(timeRange);
      case ChangeLeaderboardType(:final type):
        _handleLeaderboardTypeChange(type);
    }
  }

  @override
  StatisticsState get initialState => const StatisticsLoading();

  Future<void> _handleLoad() async {
    dispatchState(const StatisticsLoading());

    try {
      final data = await _dataProvider.loadDashboardData();
      dispatchState(StatisticsLoaded(
        data: data,
        selectedTab: _initialTab,
      ));
    } catch (e) {
      dispatchState(StatisticsError(
        message: 'Failed to load statistics',
        error: e,
      ));
    }
  }

  Future<void> _handleRefresh() async {
    final currentState = _currentLoadedState;
    if (currentState == null) {
      // If not in loaded state, just do a full load
      await _handleLoad();
      return;
    }

    // Mark as refreshing
    dispatchState(currentState.copyWith(isRefreshing: true));

    try {
      final data = await _dataProvider.loadDashboardData();
      dispatchState(currentState.copyWith(
        data: data,
        isRefreshing: false,
      ));
    } catch (e) {
      // On refresh failure, keep existing data but stop refreshing
      dispatchState(currentState.copyWith(isRefreshing: false));
    }
  }

  void _handleTabChange(StatisticsDashboardTab tab) {
    final currentState = _currentLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(selectedTab: tab));
  }

  Future<void> _handleTimeRangeChange(ProgressTimeRange timeRange) async {
    final currentState = _currentLoadedState;
    if (currentState == null) return;

    // Update time range immediately for UI responsiveness
    dispatchState(currentState.copyWith(progressTimeRange: timeRange));

    // Optionally load new progress data for the time range
    try {
      final progressData = await _dataProvider.loadProgressData(timeRange);
      final updatedData = StatisticsDashboardData(
        globalStatistics: currentState.data.globalStatistics,
        categoryStatistics: currentState.data.categoryStatistics,
        progressDataPoints: progressData,
        leaderboardEntries: currentState.data.leaderboardEntries,
        recentSessions: currentState.data.recentSessions,
        weeklyTrend: currentState.data.weeklyTrend,
        trendDirection: currentState.data.trendDirection,
        progressImprovement: currentState.data.progressImprovement,
      );

      // Get the latest state (it might have changed)
      final latestState = _currentLoadedState;
      if (latestState != null &&
          latestState.progressTimeRange == timeRange) {
        dispatchState(latestState.copyWith(data: updatedData));
      }
    } catch (_) {
      // Silently fail - we already have the time range updated
    }
  }

  void _handleLeaderboardTypeChange(LeaderboardType type) {
    final currentState = _currentLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(leaderboardType: type));
  }

  /// Gets the current state if it's a loaded state, null otherwise.
  StatisticsLoaded? get _currentLoadedState {
    // We need to track the current state
    // Since SingleSubscriptionBloc doesn't expose current state,
    // we'll track it ourselves
    return _lastLoadedState;
  }

  StatisticsLoaded? _lastLoadedState;

  @override
  void dispatchState(StatisticsState state) {
    if (state is StatisticsLoaded) {
      _lastLoadedState = state;
    } else if (state is StatisticsLoading) {
      // Keep last loaded state for refresh purposes
    } else if (state is StatisticsError) {
      _lastLoadedState = null;
    }
    super.dispatchState(state);
  }

  /// The currently selected tab, if in loaded state.
  StatisticsDashboardTab? get selectedTab => _lastLoadedState?.selectedTab;

  /// The currently selected time range, if in loaded state.
  ProgressTimeRange? get progressTimeRange =>
      _lastLoadedState?.progressTimeRange;

  /// The currently selected leaderboard type, if in loaded state.
  LeaderboardType? get leaderboardType => _lastLoadedState?.leaderboardType;
}
