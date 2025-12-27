/// State classes for the Home BLoC.
library;

import '../../achievements/screens/achievements_screen.dart';
import '../../screens/statistics_dashboard_screen.dart';
import '../../widgets/session_card.dart';

/// Sealed class representing all possible states for home screen.
sealed class HomeState {
  /// Creates a [HomeState].
  const HomeState();

  /// Creates a loading state.
  factory HomeState.loading() = HomeLoading;

  /// Creates a loaded state with all tab data.
  factory HomeState.loaded({
    required int currentTabIndex,
    required HomeTabData tabData,
  }) = HomeLoaded;

  /// Creates an error state.
  factory HomeState.error({
    required String message,
    Object? error,
  }) = HomeError;
}

/// State when home screen is loading.
class HomeLoading extends HomeState {
  /// Creates a [HomeLoading].
  const HomeLoading();
}

/// State when home screen is loaded.
class HomeLoaded extends HomeState {
  /// Creates a [HomeLoaded].
  const HomeLoaded({
    required this.currentTabIndex,
    required this.tabData,
  });

  /// The current tab index.
  final int currentTabIndex;

  /// Data for all tabs.
  final HomeTabData tabData;

  /// Creates a copy with updated values.
  HomeLoaded copyWith({
    int? currentTabIndex,
    HomeTabData? tabData,
  }) {
    return HomeLoaded(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      tabData: tabData ?? this.tabData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeLoaded &&
        other.currentTabIndex == currentTabIndex &&
        other.tabData == tabData;
  }

  @override
  int get hashCode => Object.hash(currentTabIndex, tabData);
}

/// State when there's an error loading home screen.
class HomeError extends HomeState {
  /// Creates a [HomeError].
  const HomeError({
    required this.message,
    this.error,
  });

  /// The error message to display.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}

/// Data container for all home screen tabs.
class HomeTabData {
  /// Creates a [HomeTabData].
  const HomeTabData({
    this.historySessions = const [],
    this.isHistoryLoading = false,
    this.dashboardData,
    this.isDashboardLoading = false,
    this.achievementsData,
    this.isAchievementsLoading = false,
  });

  /// Sessions for the history tab.
  final List<SessionCardData> historySessions;

  /// Whether history is loading.
  final bool isHistoryLoading;

  /// Dashboard data for statistics tab.
  final StatisticsDashboardData? dashboardData;

  /// Whether dashboard is loading.
  final bool isDashboardLoading;

  /// Achievements data for achievements tab.
  final AchievementsScreenData? achievementsData;

  /// Whether achievements are loading.
  final bool isAchievementsLoading;

  /// Creates empty tab data.
  static const empty = HomeTabData();

  /// Creates a copy with updated values.
  HomeTabData copyWith({
    List<SessionCardData>? historySessions,
    bool? isHistoryLoading,
    StatisticsDashboardData? dashboardData,
    bool? isDashboardLoading,
    AchievementsScreenData? achievementsData,
    bool? isAchievementsLoading,
  }) {
    return HomeTabData(
      historySessions: historySessions ?? this.historySessions,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      dashboardData: dashboardData ?? this.dashboardData,
      isDashboardLoading: isDashboardLoading ?? this.isDashboardLoading,
      achievementsData: achievementsData ?? this.achievementsData,
      isAchievementsLoading:
          isAchievementsLoading ?? this.isAchievementsLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeTabData &&
        _listEquals(other.historySessions, historySessions) &&
        other.isHistoryLoading == isHistoryLoading &&
        other.dashboardData == dashboardData &&
        other.isDashboardLoading == isDashboardLoading &&
        other.achievementsData == achievementsData &&
        other.isAchievementsLoading == isAchievementsLoading;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(historySessions),
        isHistoryLoading,
        dashboardData,
        isDashboardLoading,
        achievementsData,
        isAchievementsLoading,
      );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
