import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

/// Mock implementation of [StatisticsDataProvider] for testing.
class MockStatisticsDataProvider implements StatisticsDataProvider {
  MockStatisticsDataProvider({
    StatisticsDashboardData? mockData,
    bool shouldFail = false,
    Duration loadDelay = Duration.zero,
    Map<ProgressTimeRange, List<ProgressDataPoint>>? progressDataByRange,
  })  : _mockData = mockData ?? _createDefaultData(),
        _shouldFail = shouldFail,
        _loadDelay = loadDelay,
        _progressDataByRange = progressDataByRange ?? {};

  final StatisticsDashboardData _mockData;
  final bool _shouldFail;
  final Duration _loadDelay;
  final Map<ProgressTimeRange, List<ProgressDataPoint>> _progressDataByRange;

  int loadDashboardDataCallCount = 0;
  int loadProgressDataCallCount = 0;
  ProgressTimeRange? lastRequestedTimeRange;

  @override
  Future<StatisticsDashboardData> loadDashboardData() async {
    loadDashboardDataCallCount++;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFail) {
      throw Exception('Failed to load data');
    }
    return _mockData;
  }

  @override
  Future<List<ProgressDataPoint>> loadProgressData(
      ProgressTimeRange timeRange) async {
    loadProgressDataCallCount++;
    lastRequestedTimeRange = timeRange;
    if (_shouldFail) {
      throw Exception('Failed to load progress data');
    }
    return _progressDataByRange[timeRange] ??
        _mockData.progressDataPoints;
  }

  static StatisticsDashboardData _createDefaultData() {
    return StatisticsDashboardData(
      globalStatistics: const GlobalStatisticsData(
        totalSessions: 10,
        totalQuestions: 100,
        totalCorrect: 80,
        totalIncorrect: 20,
        averageScore: 80.0,
        bestScore: 95.0,
        totalTimePlayed: 3600,
        perfectScores: 2,
        currentStreak: 3,
        bestStreak: 5,
      ),
      categoryStatistics: [
        CategoryStatisticsData(
          categoryId: 'europe',
          categoryName: 'Europe',
          totalSessions: 5,
          averageScore: 85.0,
          bestScore: 95.0,
          accuracy: 84.0,
          totalQuestions: 50,
        ),
      ],
      progressDataPoints: [
        ProgressDataPoint(
          date: DateTime(2024, 1, 1),
          value: 75.0,
          sessions: 2,
        ),
        ProgressDataPoint(
          date: DateTime(2024, 1, 2),
          value: 80.0,
          sessions: 3,
        ),
      ],
      leaderboardEntries: [
        LeaderboardEntry(
          rank: 1,
          sessionId: 'session-1',
          quizName: 'European Flags',
          score: 95.0,
          date: DateTime.now(),
          categoryName: 'Europe',
        ),
      ],
      recentSessions: [
        SessionCardData(
          id: 'session-1',
          quizName: 'European Flags',
          totalQuestions: 10,
          totalCorrect: 9,
          scorePercentage: 90.0,
          completionStatus: 'completed',
          startTime: DateTime.now(),
        ),
      ],
    );
  }
}

void main() {
  group('StatisticsBloc', () {
    late MockStatisticsDataProvider mockProvider;
    late StatisticsBloc bloc;

    setUp(() {
      mockProvider = MockStatisticsDataProvider();
      bloc = StatisticsBloc(dataProvider: mockProvider);
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('initialState is StatisticsLoading', () {
        expect(bloc.initialState, isA<StatisticsLoading>());
      });

      test('selectedTab is null before loading', () {
        expect(bloc.selectedTab, isNull);
      });

      test('progressTimeRange is null before loading', () {
        expect(bloc.progressTimeRange, isNull);
      });

      test('leaderboardType is null before loading', () {
        expect(bloc.leaderboardType, isNull);
      });
    });

    group('LoadStatistics event', () {
      test('emits StatisticsLoading then StatisticsLoaded on success', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<StatisticsLoading>());
        expect(states[1], isA<StatisticsLoaded>());
      });

      test('calls loadDashboardData on data provider', () async {
        bloc.add(StatisticsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadDashboardDataCallCount, 1);
      });

      test('sets default values in loaded state', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as StatisticsLoaded;
        expect(loadedState.selectedTab, StatisticsDashboardTab.overview);
        expect(loadedState.progressTimeRange, ProgressTimeRange.week);
        expect(loadedState.leaderboardType, LeaderboardType.bestScores);
        expect(loadedState.isRefreshing, false);
      });

      test('uses initialTab when specified', () async {
        bloc.dispose();
        bloc = StatisticsBloc(
          dataProvider: mockProvider,
          initialTab: StatisticsDashboardTab.progress,
        );

        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as StatisticsLoaded;
        expect(loadedState.selectedTab, StatisticsDashboardTab.progress);
      });

      test('emits StatisticsError on failure', () async {
        mockProvider = MockStatisticsDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = StatisticsBloc(dataProvider: mockProvider);

        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<StatisticsLoading>());
        expect(states[1], isA<StatisticsError>());
      });

      test('error state contains error message', () async {
        mockProvider = MockStatisticsDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = StatisticsBloc(dataProvider: mockProvider);

        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final errorState = states[1] as StatisticsError;
        expect(errorState.message, 'Failed to load statistics');
        expect(errorState.error, isA<Exception>());
      });
    });

    group('RefreshStatistics event', () {
      test('refreshes data while keeping existing state', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        // First load
        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        // Change tab
        bloc.add(StatisticsEvent.changeTab(StatisticsDashboardTab.categories));
        await Future.delayed(const Duration(milliseconds: 50));

        // Refresh
        bloc.add(StatisticsEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        // Find the last loaded state after refresh
        final refreshedState =
            states.whereType<StatisticsLoaded>().last;

        // Tab should be preserved
        expect(refreshedState.selectedTab, StatisticsDashboardTab.categories);
        expect(mockProvider.loadDashboardDataCallCount, 2);
      });

      test('sets isRefreshing to true during refresh', () async {
        mockProvider = MockStatisticsDataProvider(
          loadDelay: const Duration(milliseconds: 50),
        );
        bloc.dispose();
        bloc = StatisticsBloc(dataProvider: mockProvider);

        // First load
        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        // Refresh
        bloc.add(StatisticsEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 10));

        // Should be refreshing
        final refreshingState = states.first as StatisticsLoaded;
        expect(refreshingState.isRefreshing, true);

        // Wait for refresh to complete to avoid "bad state" error
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('calls loadDashboardData when not in loaded state', () async {
        // Don't load first, just refresh
        bloc.add(StatisticsEvent.refresh());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadDashboardDataCallCount, 1);
      });
    });

    group('ChangeTab event', () {
      test('updates selected tab in loaded state', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(StatisticsEvent.changeTab(StatisticsDashboardTab.leaderboard));
        await Future.delayed(const Duration(milliseconds: 50));

        final lastState = states.last as StatisticsLoaded;
        expect(lastState.selectedTab, StatisticsDashboardTab.leaderboard);
      });

      test('does nothing when not in loaded state', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.changeTab(StatisticsDashboardTab.categories));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, isEmpty);
      });

      test('updates selectedTab getter', () async {
        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(StatisticsEvent.changeTab(StatisticsDashboardTab.progress));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.selectedTab, StatisticsDashboardTab.progress);
      });
    });

    group('ChangeTimeRange event', () {
      test('updates progress time range', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(StatisticsEvent.changeTimeRange(ProgressTimeRange.month));
        await Future.delayed(const Duration(milliseconds: 100));

        final lastState = states.last as StatisticsLoaded;
        expect(lastState.progressTimeRange, ProgressTimeRange.month);
      });

      test('calls loadProgressData with new time range', () async {
        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(StatisticsEvent.changeTimeRange(ProgressTimeRange.quarter));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadProgressDataCallCount, 1);
        expect(mockProvider.lastRequestedTimeRange, ProgressTimeRange.quarter);
      });

      test('updates progressTimeRange getter', () async {
        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(StatisticsEvent.changeTimeRange(ProgressTimeRange.year));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.progressTimeRange, ProgressTimeRange.year);
      });

      test('does nothing when not in loaded state', () async {
        bloc.add(StatisticsEvent.changeTimeRange(ProgressTimeRange.month));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockProvider.loadProgressDataCallCount, 0);
      });
    });

    group('ChangeLeaderboardType event', () {
      test('updates leaderboard type', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(StatisticsEvent.changeLeaderboardType(
            LeaderboardType.fastestPerfect));
        await Future.delayed(const Duration(milliseconds: 50));

        final lastState = states.last as StatisticsLoaded;
        expect(lastState.leaderboardType, LeaderboardType.fastestPerfect);
      });

      test('updates leaderboardType getter', () async {
        bloc.add(StatisticsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(
            StatisticsEvent.changeLeaderboardType(LeaderboardType.mostPlayed));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.leaderboardType, LeaderboardType.mostPlayed);
      });

      test('does nothing when not in loaded state', () async {
        final states = <StatisticsState>[];
        bloc.stream.listen(states.add);

        bloc.add(StatisticsEvent.changeLeaderboardType(
            LeaderboardType.bestStreaks));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, isEmpty);
      });
    });

    group('StatisticsLoaded copyWith', () {
      test('creates copy with updated data', () {
        final original = StatisticsLoaded(
          data: StatisticsDashboardData.empty,
          selectedTab: StatisticsDashboardTab.overview,
        );

        final newData = StatisticsDashboardData(
          globalStatistics: const GlobalStatisticsData(
            totalSessions: 1,
            totalQuestions: 10,
            totalCorrect: 8,
            totalIncorrect: 2,
            averageScore: 80.0,
            bestScore: 80.0,
            totalTimePlayed: 100,
            perfectScores: 0,
            currentStreak: 1,
            bestStreak: 1,
          ),
        );

        final copy = original.copyWith(data: newData);

        expect(copy.data, newData);
        expect(copy.selectedTab, original.selectedTab);
      });

      test('preserves all values when no arguments provided', () {
        final original = StatisticsLoaded(
          data: StatisticsDashboardData.empty,
          selectedTab: StatisticsDashboardTab.categories,
          progressTimeRange: ProgressTimeRange.month,
          leaderboardType: LeaderboardType.fastestPerfect,
          isRefreshing: true,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('StatisticsState equality', () {
      test('StatisticsLoading instances are equal', () {
        const state1 = StatisticsLoading();
        const state2 = StatisticsLoading();

        // They're const, so identity equals
        expect(identical(state1, state2), true);
      });

      test('StatisticsError instances with same values are equal', () {
        const state1 = StatisticsError(message: 'Error', error: null);
        const state2 = StatisticsError(message: 'Error', error: null);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('StatisticsLoaded instances with same values are equal', () {
        final state1 = StatisticsLoaded(
          data: StatisticsDashboardData.empty,
          selectedTab: StatisticsDashboardTab.overview,
        );
        final state2 = StatisticsLoaded(
          data: StatisticsDashboardData.empty,
          selectedTab: StatisticsDashboardTab.overview,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('StatisticsEvent equality', () {
      test('ChangeTab instances with same tab are equal', () {
        const event1 = ChangeTab(StatisticsDashboardTab.progress);
        const event2 = ChangeTab(StatisticsDashboardTab.progress);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('ChangeTimeRange instances with same range are equal', () {
        const event1 = ChangeTimeRange(ProgressTimeRange.month);
        const event2 = ChangeTimeRange(ProgressTimeRange.month);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('ChangeLeaderboardType instances with same type are equal', () {
        const event1 = ChangeLeaderboardType(LeaderboardType.bestScores);
        const event2 = ChangeLeaderboardType(LeaderboardType.bestScores);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });
    });

    group('dispose', () {
      test('closes stream', () async {
        bloc.dispose();

        expect(bloc.stream.isBroadcast, true);
        // After dispose, adding events should not cause errors
        // but also should not emit new states
      });
    });
  });
}
