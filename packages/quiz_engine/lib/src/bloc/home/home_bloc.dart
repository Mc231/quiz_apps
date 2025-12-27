/// BLoC for managing home screen state.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../../achievements/screens/achievements_screen.dart';
import '../../screens/statistics_dashboard_screen.dart';
import '../../widgets/session_card.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Interface for providing home screen data.
///
/// Apps must implement this interface to provide data to [HomeBloc].
abstract interface class HomeDataProvider {
  /// Loads history sessions.
  ///
  /// Returns a list of [SessionCardData] for the history tab.
  Future<List<SessionCardData>> loadHistorySessions();

  /// Loads statistics dashboard data.
  ///
  /// Returns [StatisticsDashboardData] for the statistics tab.
  Future<StatisticsDashboardData> loadDashboardData();

  /// Loads achievements data.
  ///
  /// Returns [AchievementsScreenData] for the achievements tab.
  /// This method is optional - return null if achievements are not supported.
  Future<AchievementsScreenData?> loadAchievementsData();
}

/// BLoC for managing home screen state.
///
/// Handles tab switching and data loading for all tabs.
class HomeBloc extends SingleSubscriptionBloc<HomeState> {
  /// Creates a [HomeBloc].
  HomeBloc({
    required HomeDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final HomeDataProvider _dataProvider;

  /// Tracks the last loaded state for access to current data.
  HomeLoaded? _lastLoadedState;

  @override
  HomeState get initialState => const HomeLoading();

  /// Returns the current tab index, if loaded.
  int? get currentTabIndex => _lastLoadedState?.currentTabIndex;

  /// Returns the current tab data, if loaded.
  HomeTabData? get tabData => _lastLoadedState?.tabData;

  /// Adds an event to the BLoC.
  void add(HomeEvent event) {
    switch (event) {
      case LoadHome():
        _handleLoad(event);
      case HomeChangeTab():
        _handleChangeTab(event);
      case HomeLoadTabData():
        _handleLoadTabData(event);
      case HomeRefreshHistory():
        _handleRefreshHistory();
      case HomeRefreshStatistics():
        _handleRefreshStatistics();
      case HomeRefreshAchievements():
        _handleRefreshAchievements();
    }
  }

  @override
  void dispatchState(HomeState state) {
    if (state is HomeLoaded) {
      _lastLoadedState = state;
    } else if (state is HomeLoading) {
      // Keep last loaded state for reference
    } else if (state is HomeError) {
      _lastLoadedState = null;
    }
    super.dispatchState(state);
  }

  Future<void> _handleLoad(LoadHome event) async {
    dispatchState(const HomeLoading());

    try {
      // Initialize with empty tab data
      dispatchState(HomeState.loaded(
        currentTabIndex: event.initialTabIndex,
        tabData: HomeTabData.empty,
      ));
    } catch (e) {
      dispatchState(HomeState.error(
        message: 'Failed to load home screen',
        error: e,
      ));
    }
  }

  void _handleChangeTab(HomeChangeTab event) {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(
      currentTabIndex: event.tabIndex,
    ));
  }

  Future<void> _handleLoadTabData(HomeLoadTabData event) async {
    switch (event.tabType) {
      case HomeTabType.history:
        await _loadHistoryData();
      case HomeTabType.statistics:
        await _loadStatisticsData();
      case HomeTabType.achievements:
        await _loadAchievementsData();
      case HomeTabType.play:
      case HomeTabType.settings:
        // No async data to load for these tabs
        break;
    }
  }

  Future<void> _handleRefreshHistory() async {
    await _loadHistoryData();
  }

  Future<void> _handleRefreshStatistics() async {
    await _loadStatisticsData();
  }

  Future<void> _handleRefreshAchievements() async {
    await _loadAchievementsData();
  }

  Future<void> _loadHistoryData() async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    // Set loading state
    dispatchState(currentState.copyWith(
      tabData: currentState.tabData.copyWith(isHistoryLoading: true),
    ));

    try {
      final sessions = await _dataProvider.loadHistorySessions();
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          tabData: latestState.tabData.copyWith(
            historySessions: sessions,
            isHistoryLoading: false,
          ),
        ));
      }
    } catch (e) {
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          tabData: latestState.tabData.copyWith(isHistoryLoading: false),
        ));
      }
    }
  }

  Future<void> _loadStatisticsData() async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    // Set loading state
    dispatchState(currentState.copyWith(
      tabData: currentState.tabData.copyWith(isDashboardLoading: true),
    ));

    try {
      final dashboardData = await _dataProvider.loadDashboardData();
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          tabData: latestState.tabData.copyWith(
            dashboardData: dashboardData,
            isDashboardLoading: false,
          ),
        ));
      }
    } catch (e) {
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          tabData: latestState.tabData.copyWith(isDashboardLoading: false),
        ));
      }
    }
  }

  Future<void> _loadAchievementsData() async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    // Set loading state
    dispatchState(currentState.copyWith(
      tabData: currentState.tabData.copyWith(isAchievementsLoading: true),
    ));

    try {
      final achievementsData = await _dataProvider.loadAchievementsData();
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          tabData: latestState.tabData.copyWith(
            achievementsData: achievementsData,
            isAchievementsLoading: false,
          ),
        ));
      }
    } catch (e) {
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          tabData: latestState.tabData.copyWith(isAchievementsLoading: false),
        ));
      }
    }
  }
}
