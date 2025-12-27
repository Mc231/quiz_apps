/// Event classes for the Home BLoC.
library;

/// Enum representing the type of tab to load.
enum HomeTabType {
  /// Play tab.
  play,

  /// History tab.
  history,

  /// Statistics tab.
  statistics,

  /// Achievements tab.
  achievements,

  /// Settings tab.
  settings,
}

/// Sealed class representing all possible events for home screen.
sealed class HomeEvent {
  /// Creates a [HomeEvent].
  const HomeEvent();

  /// Creates a load event to initialize home screen.
  factory HomeEvent.load({int initialTabIndex}) = LoadHome;

  /// Creates an event to change the current tab.
  factory HomeEvent.changeTab(int tabIndex) = HomeChangeTab;

  /// Creates an event to load data for a specific tab.
  factory HomeEvent.loadTabData(HomeTabType tabType) = HomeLoadTabData;

  /// Creates an event to refresh history data.
  factory HomeEvent.refreshHistory() = HomeRefreshHistory;

  /// Creates an event to refresh statistics data.
  factory HomeEvent.refreshStatistics() = HomeRefreshStatistics;

  /// Creates an event to refresh achievements data.
  factory HomeEvent.refreshAchievements() = HomeRefreshAchievements;
}

/// Event to load home screen.
class LoadHome extends HomeEvent {
  /// Creates a [LoadHome].
  const LoadHome({this.initialTabIndex = 0});

  /// The initial tab index.
  final int initialTabIndex;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadHome && other.initialTabIndex == initialTabIndex;
  }

  @override
  int get hashCode => initialTabIndex.hashCode;
}

/// Event to change the current tab.
class HomeChangeTab extends HomeEvent {
  /// Creates a [HomeChangeTab].
  const HomeChangeTab(this.tabIndex);

  /// The new tab index.
  final int tabIndex;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeChangeTab && other.tabIndex == tabIndex;
  }

  @override
  int get hashCode => tabIndex.hashCode;
}

/// Event to load data for a specific tab.
class HomeLoadTabData extends HomeEvent {
  /// Creates a [HomeLoadTabData].
  const HomeLoadTabData(this.tabType);

  /// The type of tab to load data for.
  final HomeTabType tabType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeLoadTabData && other.tabType == tabType;
  }

  @override
  int get hashCode => tabType.hashCode;
}

/// Event to refresh history data.
class HomeRefreshHistory extends HomeEvent {
  /// Creates a [HomeRefreshHistory].
  const HomeRefreshHistory();
}

/// Event to refresh statistics data.
class HomeRefreshStatistics extends HomeEvent {
  /// Creates a [HomeRefreshStatistics].
  const HomeRefreshStatistics();
}

/// Event to refresh achievements data.
class HomeRefreshAchievements extends HomeEvent {
  /// Creates a [HomeRefreshAchievements].
  const HomeRefreshAchievements();
}
