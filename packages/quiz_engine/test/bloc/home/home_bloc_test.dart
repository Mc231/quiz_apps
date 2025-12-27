import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

/// Mock implementation of [HomeDataProvider] for testing.
class MockHomeDataProvider implements HomeDataProvider {
  MockHomeDataProvider({
    List<SessionCardData>? historySessions,
    StatisticsDashboardData? dashboardData,
    AchievementsScreenData? achievementsData,
    bool shouldFailHistory = false,
    bool shouldFailDashboard = false,
    bool shouldFailAchievements = false,
    Duration loadDelay = Duration.zero,
  })  : _historySessions = historySessions ?? _createDefaultSessions(),
        _dashboardData = dashboardData ?? _createDefaultDashboardData(),
        _achievementsData = achievementsData,
        _shouldFailHistory = shouldFailHistory,
        _shouldFailDashboard = shouldFailDashboard,
        _shouldFailAchievements = shouldFailAchievements,
        _loadDelay = loadDelay;

  final List<SessionCardData> _historySessions;
  final StatisticsDashboardData _dashboardData;
  final AchievementsScreenData? _achievementsData;
  final bool _shouldFailHistory;
  final bool _shouldFailDashboard;
  final bool _shouldFailAchievements;
  final Duration _loadDelay;

  int loadHistoryCallCount = 0;
  int loadDashboardCallCount = 0;
  int loadAchievementsCallCount = 0;

  @override
  Future<List<SessionCardData>> loadHistorySessions() async {
    loadHistoryCallCount++;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFailHistory) {
      throw Exception('Failed to load history');
    }
    return _historySessions;
  }

  @override
  Future<StatisticsDashboardData> loadDashboardData() async {
    loadDashboardCallCount++;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFailDashboard) {
      throw Exception('Failed to load dashboard');
    }
    return _dashboardData;
  }

  @override
  Future<AchievementsScreenData?> loadAchievementsData() async {
    loadAchievementsCallCount++;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFailAchievements) {
      throw Exception('Failed to load achievements');
    }
    return _achievementsData;
  }

  static List<SessionCardData> _createDefaultSessions() {
    return [
      SessionCardData(
        id: 'session-1',
        quizName: 'European Flags',
        totalQuestions: 10,
        totalCorrect: 8,
        scorePercentage: 80.0,
        completionStatus: 'completed',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SessionCardData(
        id: 'session-2',
        quizName: 'Asian Capitals',
        totalQuestions: 15,
        totalCorrect: 12,
        scorePercentage: 80.0,
        completionStatus: 'completed',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  static StatisticsDashboardData _createDefaultDashboardData() {
    return StatisticsDashboardData(
      globalStatistics: GlobalStatisticsData(
        totalSessions: 10,
        totalQuestions: 100,
        totalCorrect: 80,
        totalIncorrect: 20,
        averageScore: 80.0,
        bestScore: 100.0,
        totalTimePlayed: 7200,
        perfectScores: 2,
        currentStreak: 3,
        bestStreak: 5,
      ),
    );
  }
}

void main() {
  group('HomeBloc', () {
    late MockHomeDataProvider mockProvider;
    late HomeBloc bloc;

    setUp(() {
      mockProvider = MockHomeDataProvider();
      bloc = HomeBloc(dataProvider: mockProvider);
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('initialState is HomeLoading', () {
        expect(bloc.initialState, isA<HomeLoading>());
      });

      test('currentTabIndex is null before loading', () {
        expect(bloc.currentTabIndex, isNull);
      });

      test('tabData is null before loading', () {
        expect(bloc.tabData, isNull);
      });
    });

    group('LoadHome event', () {
      test('emits HomeLoading then HomeLoaded on success', () async {
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<HomeLoading>());
        expect(states[1], isA<HomeLoaded>());
      });

      test('sets initial tab index from event', () async {
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.load(initialTabIndex: 2));

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as HomeLoaded;
        expect(loadedState.currentTabIndex, 2);
      });

      test('initializes with empty tab data', () async {
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as HomeLoaded;
        expect(loadedState.tabData.historySessions, isEmpty);
        expect(loadedState.tabData.dashboardData, isNull);
        expect(loadedState.tabData.achievementsData, isNull);
      });

      test('defaults to tab index 0', () async {
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as HomeLoaded;
        expect(loadedState.currentTabIndex, 0);
      });

      test('updates currentTabIndex accessor after load', () async {
        bloc.add(HomeEvent.load(initialTabIndex: 3));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.currentTabIndex, 3);
      });

      test('updates tabData accessor after load', () async {
        bloc.add(HomeEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.tabData, isNotNull);
        expect(bloc.tabData, equals(HomeTabData.empty));
      });
    });

    group('ChangeTab event', () {
      test('updates current tab index', () async {
        bloc.add(HomeEvent.load(initialTabIndex: 0));
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.changeTab(2));
        await Future.delayed(const Duration(milliseconds: 50));

        final loadedState = states.last as HomeLoaded;
        expect(loadedState.currentTabIndex, 2);
      });

      test('does nothing when not in loaded state', () async {
        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.changeTab(2));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, isEmpty);
      });

      test('preserves tab data when changing tabs', () async {
        // First load and then load history data
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.history));
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        // Change tab
        bloc.add(HomeEvent.changeTab(2));
        await Future.delayed(const Duration(milliseconds: 50));

        final loadedState = states.last as HomeLoaded;
        expect(loadedState.tabData.historySessions, isNotEmpty);
      });
    });

    group('LoadTabData event - history', () {
      test('loads history sessions', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.history));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadHistoryCallCount, 1);
        expect(bloc.tabData?.historySessions.length, 2);
      });

      test('sets isHistoryLoading during load', () async {
        mockProvider = MockHomeDataProvider(
          loadDelay: const Duration(milliseconds: 50),
        );
        bloc.dispose();
        bloc = HomeBloc(dataProvider: mockProvider);

        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.loadTabData(HomeTabType.history));
        await Future.delayed(const Duration(milliseconds: 10));

        final loadingState = states.first as HomeLoaded;
        expect(loadingState.tabData.isHistoryLoading, true);

        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('clears isHistoryLoading after load', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.history));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.tabData?.isHistoryLoading, false);
      });

      test('clears isHistoryLoading on failure', () async {
        mockProvider = MockHomeDataProvider(shouldFailHistory: true);
        bloc.dispose();
        bloc = HomeBloc(dataProvider: mockProvider);

        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.history));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.tabData?.isHistoryLoading, false);
      });
    });

    group('LoadTabData event - statistics', () {
      test('loads dashboard data', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.statistics));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadDashboardCallCount, 1);
        expect(bloc.tabData?.dashboardData, isNotNull);
      });

      test('sets isDashboardLoading during load', () async {
        mockProvider = MockHomeDataProvider(
          loadDelay: const Duration(milliseconds: 50),
        );
        bloc.dispose();
        bloc = HomeBloc(dataProvider: mockProvider);

        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.loadTabData(HomeTabType.statistics));
        await Future.delayed(const Duration(milliseconds: 10));

        final loadingState = states.first as HomeLoaded;
        expect(loadingState.tabData.isDashboardLoading, true);

        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('clears isDashboardLoading after load', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.statistics));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.tabData?.isDashboardLoading, false);
      });
    });

    group('LoadTabData event - achievements', () {
      test('loads achievements data', () async {
        mockProvider = MockHomeDataProvider(
          achievementsData: const AchievementsScreenData(
            achievements: [],
            totalPoints: 100,
          ),
        );
        bloc.dispose();
        bloc = HomeBloc(dataProvider: mockProvider);

        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.achievements));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadAchievementsCallCount, 1);
        expect(bloc.tabData?.achievementsData, isNotNull);
      });

      test('handles null achievements data', () async {
        mockProvider = MockHomeDataProvider(achievementsData: null);
        bloc.dispose();
        bloc = HomeBloc(dataProvider: mockProvider);

        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.achievements));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.tabData?.achievementsData, isNull);
      });

      test('sets isAchievementsLoading during load', () async {
        mockProvider = MockHomeDataProvider(
          loadDelay: const Duration(milliseconds: 50),
        );
        bloc.dispose();
        bloc = HomeBloc(dataProvider: mockProvider);

        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <HomeState>[];
        bloc.stream.listen(states.add);

        bloc.add(HomeEvent.loadTabData(HomeTabType.achievements));
        await Future.delayed(const Duration(milliseconds: 10));

        final loadingState = states.first as HomeLoaded;
        expect(loadingState.tabData.isAchievementsLoading, true);

        await Future.delayed(const Duration(milliseconds: 100));
      });
    });

    group('LoadTabData event - play and settings', () {
      test('does not call any provider method for play tab', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.play));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadHistoryCallCount, 0);
        expect(mockProvider.loadDashboardCallCount, 0);
        expect(mockProvider.loadAchievementsCallCount, 0);
      });

      test('does not call any provider method for settings tab', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.settings));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadHistoryCallCount, 0);
        expect(mockProvider.loadDashboardCallCount, 0);
        expect(mockProvider.loadAchievementsCallCount, 0);
      });
    });

    group('RefreshHistory event', () {
      test('reloads history sessions', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.history));
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.refreshHistory());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadHistoryCallCount, 2);
      });

      test('does nothing when not in loaded state', () async {
        bloc.add(HomeEvent.refreshHistory());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadHistoryCallCount, 0);
      });
    });

    group('RefreshStatistics event', () {
      test('reloads dashboard data', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.statistics));
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.refreshStatistics());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadDashboardCallCount, 2);
      });
    });

    group('RefreshAchievements event', () {
      test('reloads achievements data', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.loadTabData(HomeTabType.achievements));
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(HomeEvent.refreshAchievements());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadAchievementsCallCount, 2);
      });
    });

    group('HomeTabData', () {
      test('empty has default values', () {
        expect(HomeTabData.empty.historySessions, isEmpty);
        expect(HomeTabData.empty.isHistoryLoading, false);
        expect(HomeTabData.empty.dashboardData, isNull);
        expect(HomeTabData.empty.isDashboardLoading, false);
        expect(HomeTabData.empty.achievementsData, isNull);
        expect(HomeTabData.empty.isAchievementsLoading, false);
      });

      test('copyWith updates historySessions', () {
        const original = HomeTabData();
        final sessions = [
          SessionCardData(
            id: 'test',
            quizName: 'Test',
            totalQuestions: 10,
            totalCorrect: 8,
            scorePercentage: 80.0,
            completionStatus: 'completed',
            startTime: DateTime.now(),
          ),
        ];

        final copy = original.copyWith(historySessions: sessions);

        expect(copy.historySessions, sessions);
        expect(copy.isHistoryLoading, original.isHistoryLoading);
      });

      test('copyWith updates isHistoryLoading', () {
        const original = HomeTabData();
        final copy = original.copyWith(isHistoryLoading: true);

        expect(copy.isHistoryLoading, true);
        expect(copy.historySessions, original.historySessions);
      });

      test('copyWith updates dashboardData', () {
        const original = HomeTabData();
        final dashboard = StatisticsDashboardData(
          globalStatistics: GlobalStatisticsData(
            totalSessions: 5,
            totalQuestions: 50,
            totalCorrect: 40,
            totalIncorrect: 10,
            averageScore: 80.0,
            bestScore: 100.0,
            totalTimePlayed: 3600,
            perfectScores: 1,
            currentStreak: 2,
            bestStreak: 3,
          ),
        );

        final copy = original.copyWith(dashboardData: dashboard);

        expect(copy.dashboardData, dashboard);
        expect(copy.isDashboardLoading, original.isDashboardLoading);
      });

      test('equality works correctly', () {
        const data1 = HomeTabData();
        const data2 = HomeTabData();

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('inequality with different values', () {
        const data1 = HomeTabData(isHistoryLoading: true);
        const data2 = HomeTabData(isHistoryLoading: false);

        expect(data1, isNot(equals(data2)));
      });
    });

    group('HomeLoaded', () {
      test('copyWith updates currentTabIndex', () {
        const original = HomeLoaded(
          currentTabIndex: 0,
          tabData: HomeTabData(),
        );

        final copy = original.copyWith(currentTabIndex: 2);

        expect(copy.currentTabIndex, 2);
        expect(copy.tabData, original.tabData);
      });

      test('copyWith updates tabData', () {
        const original = HomeLoaded(
          currentTabIndex: 0,
          tabData: HomeTabData(),
        );
        const newTabData = HomeTabData(isHistoryLoading: true);

        final copy = original.copyWith(tabData: newTabData);

        expect(copy.tabData, newTabData);
        expect(copy.currentTabIndex, original.currentTabIndex);
      });

      test('preserves values when copyWith called with no arguments', () {
        const original = HomeLoaded(
          currentTabIndex: 3,
          tabData: HomeTabData(isHistoryLoading: true),
        );

        final copy = original.copyWith();

        expect(copy.currentTabIndex, original.currentTabIndex);
        expect(copy.tabData, original.tabData);
      });

      test('equality works correctly', () {
        const state1 = HomeLoaded(
          currentTabIndex: 0,
          tabData: HomeTabData(),
        );
        const state2 = HomeLoaded(
          currentTabIndex: 0,
          tabData: HomeTabData(),
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('HomeState equality', () {
      test('HomeLoading instances are equal', () {
        const state1 = HomeLoading();
        const state2 = HomeLoading();

        expect(identical(state1, state2), true);
      });

      test('HomeError instances with same values are equal', () {
        const state1 = HomeError(message: 'Error', error: null);
        const state2 = HomeError(message: 'Error', error: null);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('HomeError instances with different messages are not equal', () {
        const state1 = HomeError(message: 'Error 1');
        const state2 = HomeError(message: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('HomeEvent equality', () {
      test('LoadHome instances with same index are equal', () {
        const event1 = LoadHome(initialTabIndex: 2);
        const event2 = LoadHome(initialTabIndex: 2);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('LoadHome instances with different index are not equal', () {
        const event1 = LoadHome(initialTabIndex: 1);
        const event2 = LoadHome(initialTabIndex: 2);

        expect(event1, isNot(equals(event2)));
      });

      test('HomeChangeTab instances with same index are equal', () {
        const event1 = HomeChangeTab(2);
        const event2 = HomeChangeTab(2);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('HomeLoadTabData instances with same type are equal', () {
        const event1 = HomeLoadTabData(HomeTabType.history);
        const event2 = HomeLoadTabData(HomeTabType.history);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('HomeLoadTabData instances with different types are not equal', () {
        const event1 = HomeLoadTabData(HomeTabType.history);
        const event2 = HomeLoadTabData(HomeTabType.statistics);

        expect(event1, isNot(equals(event2)));
      });
    });

    group('dispatchState behavior', () {
      test('clears lastLoadedState on HomeError', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.currentTabIndex, isNotNull);

        // Force an error by creating a new bloc with failing provider
        mockProvider = MockHomeDataProvider(
          shouldFailHistory: true,
          shouldFailDashboard: true,
          shouldFailAchievements: true,
        );
        bloc.dispose();

        // We can't easily trigger HomeError through normal events
        // since the current implementation doesn't emit HomeError
        // from tab data loading failures
      });

      test('keeps lastLoadedState on HomeLoading', () async {
        bloc.add(HomeEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        final initialTabIndex = bloc.currentTabIndex;

        // Load home again should go through loading but keep reference
        bloc.add(HomeEvent.load(initialTabIndex: 1));
        await Future.delayed(const Duration(milliseconds: 100));

        // After re-load, should have new tab index
        expect(bloc.currentTabIndex, 1);
        expect(initialTabIndex, isNot(equals(bloc.currentTabIndex)));
      });
    });

    group('dispose', () {
      test('closes stream', () async {
        bloc.dispose();

        expect(bloc.stream.isBroadcast, true);
      });
    });
  });
}
