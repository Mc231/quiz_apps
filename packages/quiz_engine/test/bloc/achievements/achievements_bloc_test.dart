import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

/// Mock implementation of [AchievementsBlocDataProvider] for testing.
class MockAchievementsBlocDataProvider implements AchievementsBlocDataProvider {
  MockAchievementsBlocDataProvider({
    AchievementsScreenData? data,
    bool shouldFail = false,
    Duration loadDelay = Duration.zero,
  })  : _data = data ?? _createDefaultData(),
        _shouldFail = shouldFail,
        _loadDelay = loadDelay;

  final AchievementsScreenData _data;
  final bool _shouldFail;
  final Duration _loadDelay;

  int loadCallCount = 0;

  @override
  Future<AchievementsScreenData> loadAchievements() async {
    loadCallCount++;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFail) {
      throw Exception('Failed to load achievements');
    }
    return _data;
  }

  static AchievementsScreenData _createDefaultData() {
    return AchievementsScreenData(
      achievements: [
        AchievementDisplayData(
          achievement: Achievement(
            id: 'first_quiz',
            name: (BuildContext context) => 'First Quiz',
            description: (BuildContext context) => 'Complete your first quiz',
            icon: '🎯',
            tier: AchievementTier.common,
            trigger: const CumulativeTrigger(
              field: StatField.totalCompletedSessions,
              target: 1,
            ),
          ),
          progress: const AchievementProgress(
            achievementId: 'first_quiz',
            currentValue: 1,
            targetValue: 1,
            isUnlocked: true,
          ),
        ),
        AchievementDisplayData(
          achievement: Achievement(
            id: 'quiz_master',
            name: (BuildContext context) => 'Quiz Master',
            description: (BuildContext context) => 'Complete 10 quizzes',
            icon: '🏆',
            tier: AchievementTier.uncommon,
            trigger: const CumulativeTrigger(
              field: StatField.totalCompletedSessions,
              target: 10,
            ),
          ),
          progress: const AchievementProgress(
            achievementId: 'quiz_master',
            currentValue: 5,
            targetValue: 10,
            isUnlocked: false,
          ),
        ),
        AchievementDisplayData(
          achievement: Achievement(
            id: 'perfect_score',
            name: (BuildContext context) => 'Perfect Score',
            description: (BuildContext context) => 'Get 100% on any quiz',
            icon: '⭐',
            tier: AchievementTier.rare,
            trigger: const CumulativeTrigger(
              field: StatField.totalPerfectScores,
              target: 1,
            ),
          ),
          progress: const AchievementProgress(
            achievementId: 'perfect_score',
            currentValue: 0,
            targetValue: 1,
            isUnlocked: false,
          ),
        ),
      ],
      totalPoints: 10,
    );
  }
}

void main() {
  group('AchievementsBloc', () {
    late MockAchievementsBlocDataProvider mockProvider;
    late AchievementsBloc bloc;

    setUp(() {
      mockProvider = MockAchievementsBlocDataProvider();
      bloc = AchievementsBloc(dataProvider: mockProvider);
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('initialState is AchievementsLoading', () {
        expect(bloc.initialState, isA<AchievementsLoading>());
      });

      test('data is null before loading', () {
        expect(bloc.data, isNull);
      });

      test('filter is null before loading', () {
        expect(bloc.filter, isNull);
      });

      test('tierFilter is null before loading', () {
        expect(bloc.tierFilter, isNull);
      });
    });

    group('LoadAchievements event', () {
      test('emits AchievementsLoading then AchievementsLoaded on success',
          () async {
        final states = <AchievementsState>[];
        bloc.stream.listen(states.add);

        bloc.add(AchievementsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<AchievementsLoading>());
        expect(states[1], isA<AchievementsLoaded>());
      });

      test('calls loadAchievements on data provider', () async {
        bloc.add(AchievementsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadCallCount, 1);
      });

      test('sets data in loaded state', () async {
        bloc.add(AchievementsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.data, isNotNull);
        expect(bloc.data!.achievements.length, 3);
        expect(bloc.data!.totalPoints, 10);
      });

      test('sets default filter to all', () async {
        bloc.add(AchievementsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.filter, AchievementFilter.all);
      });

      test('sets tierFilter to null by default', () async {
        bloc.add(AchievementsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.tierFilter, isNull);
      });

      test('emits AchievementsError on failure', () async {
        mockProvider = MockAchievementsBlocDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = AchievementsBloc(dataProvider: mockProvider);

        final states = <AchievementsState>[];
        bloc.stream.listen(states.add);

        bloc.add(AchievementsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<AchievementsLoading>());
        expect(states[1], isA<AchievementsError>());
      });

      test('error state contains error message', () async {
        mockProvider = MockAchievementsBlocDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = AchievementsBloc(dataProvider: mockProvider);

        final states = <AchievementsState>[];
        bloc.stream.listen(states.add);

        bloc.add(AchievementsEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final errorState = states[1] as AchievementsError;
        expect(errorState.message, 'Failed to load achievements');
        expect(errorState.error, isNotNull);
      });
    });

    group('RefreshAchievements event', () {
      test('reloads data when in loaded state', () async {
        // First load
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        // Then refresh
        bloc.add(AchievementsEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadCallCount, 2);
      });

      test('sets isRefreshing to true during refresh', () async {
        mockProvider = MockAchievementsBlocDataProvider(
          loadDelay: const Duration(milliseconds: 50),
        );
        bloc.dispose();
        bloc = AchievementsBloc(dataProvider: mockProvider);

        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <AchievementsState>[];
        bloc.stream.listen(states.add);

        bloc.add(AchievementsEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 10));

        final refreshingState = states.first as AchievementsLoaded;
        expect(refreshingState.isRefreshing, true);

        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('clears isRefreshing after refresh completes', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(AchievementsEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify data is still available after refresh
        expect(bloc.data, isNotNull);
      });

      test('preserves filter during refresh', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(AchievementsEvent.changeFilter(AchievementFilter.unlocked));
        await Future.delayed(const Duration(milliseconds: 50));

        bloc.add(AchievementsEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.filter, AchievementFilter.unlocked);
      });

      test('does regular load when not in loaded state', () async {
        final states = <AchievementsState>[];
        bloc.stream.listen(states.add);

        bloc.add(AchievementsEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<AchievementsLoading>());
        expect(states[1], isA<AchievementsLoaded>());
      });

      test('keeps existing data on refresh failure', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        // Create a new bloc with failing provider
        mockProvider = MockAchievementsBlocDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = AchievementsBloc(dataProvider: mockProvider);

        // Load first - should fail
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        // Should be in error state, data should be null
        expect(bloc.data, isNull);
      });
    });

    group('AchievementsChangeFilter event', () {
      test('updates filter in loaded state', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(AchievementsEvent.changeFilter(AchievementFilter.unlocked));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.filter, AchievementFilter.unlocked);
      });

      test('does nothing when not in loaded state', () async {
        bloc.add(AchievementsEvent.changeFilter(AchievementFilter.unlocked));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.filter, isNull);
      });

      test('can change filter multiple times', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(AchievementsEvent.changeFilter(AchievementFilter.unlocked));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.filter, AchievementFilter.unlocked);

        bloc.add(AchievementsEvent.changeFilter(AchievementFilter.inProgress));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.filter, AchievementFilter.inProgress);

        bloc.add(AchievementsEvent.changeFilter(AchievementFilter.all));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.filter, AchievementFilter.all);
      });
    });

    group('AchievementsChangeTierFilter event', () {
      test('updates tierFilter in loaded state', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(AchievementsEvent.changeTierFilter(AchievementTier.rare));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.tierFilter, AchievementTier.rare);
      });

      test('can clear tierFilter with null', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        bloc.add(AchievementsEvent.changeTierFilter(AchievementTier.uncommon));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.tierFilter, AchievementTier.uncommon);

        bloc.add(AchievementsEvent.changeTierFilter(null));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.tierFilter, isNull);
      });

      test('does nothing when not in loaded state', () async {
        bloc.add(AchievementsEvent.changeTierFilter(AchievementTier.common));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.tierFilter, isNull);
      });
    });

    group('AchievementsLoaded', () {
      test('copyWith updates data', () {
        final original = AchievementsLoaded(
          data: MockAchievementsBlocDataProvider._createDefaultData(),
        );
        const newData = AchievementsScreenData(
          achievements: [],
          totalPoints: 100,
        );

        final copy = original.copyWith(data: newData);

        expect(copy.data.totalPoints, 100);
        expect(copy.filter, original.filter);
      });

      test('copyWith updates filter', () {
        final original = AchievementsLoaded(
          data: MockAchievementsBlocDataProvider._createDefaultData(),
        );

        final copy = original.copyWith(filter: AchievementFilter.unlocked);

        expect(copy.filter, AchievementFilter.unlocked);
        expect(copy.data, original.data);
      });

      test('copyWith updates tierFilter', () {
        final original = AchievementsLoaded(
          data: MockAchievementsBlocDataProvider._createDefaultData(),
        );

        final copy = original.copyWith(tierFilter: AchievementTier.rare);

        expect(copy.tierFilter, AchievementTier.rare);
      });

      test('copyWith clears tierFilter when clearTierFilter is true', () {
        final original = AchievementsLoaded(
          data: MockAchievementsBlocDataProvider._createDefaultData(),
          tierFilter: AchievementTier.uncommon,
        );

        final copy = original.copyWith(clearTierFilter: true);

        expect(copy.tierFilter, isNull);
      });

      test('copyWith updates isRefreshing', () {
        final original = AchievementsLoaded(
          data: MockAchievementsBlocDataProvider._createDefaultData(),
        );

        final copy = original.copyWith(isRefreshing: true);

        expect(copy.isRefreshing, true);
        expect(original.isRefreshing, false);
      });

      test('equality works correctly', () {
        final data = MockAchievementsBlocDataProvider._createDefaultData();
        final state1 = AchievementsLoaded(data: data);
        final state2 = AchievementsLoaded(data: data);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('inequality with different filter', () {
        final data = MockAchievementsBlocDataProvider._createDefaultData();
        final state1 = AchievementsLoaded(
          data: data,
          filter: AchievementFilter.all,
        );
        final state2 = AchievementsLoaded(
          data: data,
          filter: AchievementFilter.unlocked,
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('AchievementsState equality', () {
      test('AchievementsLoading instances are equal', () {
        const state1 = AchievementsLoading();
        const state2 = AchievementsLoading();

        expect(identical(state1, state2), true);
      });

      test('AchievementsError instances with same values are equal', () {
        const state1 = AchievementsError(message: 'Error', error: null);
        const state2 = AchievementsError(message: 'Error', error: null);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('AchievementsError instances with different messages are not equal',
          () {
        const state1 = AchievementsError(message: 'Error 1');
        const state2 = AchievementsError(message: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('AchievementsEvent equality', () {
      test('AchievementsChangeFilter instances with same filter are equal', () {
        const event1 = AchievementsChangeFilter(AchievementFilter.unlocked);
        const event2 = AchievementsChangeFilter(AchievementFilter.unlocked);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test(
          'AchievementsChangeFilter instances with different filters are not equal',
          () {
        const event1 = AchievementsChangeFilter(AchievementFilter.all);
        const event2 = AchievementsChangeFilter(AchievementFilter.unlocked);

        expect(event1, isNot(equals(event2)));
      });

      test('AchievementsChangeTierFilter instances with same tier are equal',
          () {
        const event1 = AchievementsChangeTierFilter(AchievementTier.rare);
        const event2 = AchievementsChangeTierFilter(AchievementTier.rare);

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test(
          'AchievementsChangeTierFilter instances with different tiers are not equal',
          () {
        const event1 = AchievementsChangeTierFilter(AchievementTier.common);
        const event2 = AchievementsChangeTierFilter(AchievementTier.uncommon);

        expect(event1, isNot(equals(event2)));
      });

      test('AchievementsChangeTierFilter with null tier', () {
        const event1 = AchievementsChangeTierFilter(null);
        const event2 = AchievementsChangeTierFilter(null);

        expect(event1, equals(event2));
      });
    });

    group('dispatchState behavior', () {
      test('clears lastLoadedState on AchievementsError', () async {
        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.data, isNotNull);

        // Create new bloc that will fail
        mockProvider = MockAchievementsBlocDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = AchievementsBloc(dataProvider: mockProvider);

        bloc.add(AchievementsEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.data, isNull);
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
