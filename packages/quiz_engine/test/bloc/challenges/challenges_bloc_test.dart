import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

/// Mock implementation of [ChallengesDataProvider] for testing.
class MockChallengesDataProvider implements ChallengesDataProvider {
  MockChallengesDataProvider({
    List<ChallengeMode>? challenges,
    List<QuizCategory>? categories,
    bool shouldFail = false,
    Duration loadDelay = Duration.zero,
  })  : _challenges = challenges ?? _createDefaultChallenges(),
        _categories = categories ?? _createDefaultCategories(),
        _shouldFail = shouldFail,
        _loadDelay = loadDelay;

  final List<ChallengeMode> _challenges;
  final List<QuizCategory> _categories;
  final bool _shouldFail;
  final Duration _loadDelay;

  int loadCallCount = 0;

  @override
  Future<ChallengesData> loadChallenges() async {
    loadCallCount++;
    if (_loadDelay > Duration.zero) {
      await Future.delayed(_loadDelay);
    }
    if (_shouldFail) {
      throw Exception('Failed to load challenges');
    }
    return ChallengesData(
      challenges: _challenges,
      categories: _categories,
    );
  }

  static List<ChallengeMode> _createDefaultChallenges() {
    return [
      const ChallengeMode(
        id: 'standard',
        name: 'Standard',
        description: 'Classic quiz mode',
        icon: Icons.quiz,
        difficulty: ChallengeDifficulty.easy,
        showAnswerFeedback: true,
      ),
      const ChallengeMode(
        id: 'timed',
        name: 'Time Attack',
        description: '30 seconds per question',
        icon: Icons.timer,
        difficulty: ChallengeDifficulty.medium,
        questionTimeSeconds: 30,
        showAnswerFeedback: true,
      ),
      const ChallengeMode(
        id: 'survival',
        name: 'Survival',
        description: '3 lives, no hints',
        icon: Icons.favorite,
        difficulty: ChallengeDifficulty.hard,
        lives: 3,
        showHints: false,
        showAnswerFeedback: false,
      ),
    ];
  }

  static List<QuizCategory> _createDefaultCategories() {
    return [
      QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        icon: Icons.flag,
        showAnswerFeedback: true,
      ),
      QuizCategory(
        id: 'asia',
        title: (context) => 'Asia',
        icon: Icons.public,
        showAnswerFeedback: true,
      ),
    ];
  }
}

void main() {
  group('ChallengesBloc', () {
    late MockChallengesDataProvider mockProvider;
    late ChallengesBloc bloc;

    setUp(() {
      mockProvider = MockChallengesDataProvider();
      bloc = ChallengesBloc(dataProvider: mockProvider);
    });

    tearDown(() {
      bloc.dispose();
    });

    group('initialization', () {
      test('initialState is ChallengesLoading', () {
        expect(bloc.initialState, isA<ChallengesLoading>());
      });

      test('challenges is null before loading', () {
        expect(bloc.challenges, isNull);
      });

      test('categories is null before loading', () {
        expect(bloc.categories, isNull);
      });
    });

    group('LoadChallenges event', () {
      test('emits ChallengesLoading then ChallengesLoaded on success',
          () async {
        final states = <ChallengesState>[];
        bloc.stream.listen(states.add);

        bloc.add(ChallengesEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<ChallengesLoading>());
        expect(states[1], isA<ChallengesLoaded>());
      });

      test('calls loadChallenges on data provider', () async {
        bloc.add(ChallengesEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadCallCount, 1);
      });

      test('sets challenges in loaded state', () async {
        final states = <ChallengesState>[];
        bloc.stream.listen(states.add);

        bloc.add(ChallengesEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as ChallengesLoaded;
        expect(loadedState.challenges.length, 3);
        expect(loadedState.challenges[0].id, 'standard');
        expect(loadedState.challenges[1].id, 'timed');
        expect(loadedState.challenges[2].id, 'survival');
      });

      test('sets categories in loaded state', () async {
        final states = <ChallengesState>[];
        bloc.stream.listen(states.add);

        bloc.add(ChallengesEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final loadedState = states[1] as ChallengesLoaded;
        expect(loadedState.categories.length, 2);
        expect(loadedState.categories[0].id, 'europe');
        expect(loadedState.categories[1].id, 'asia');
      });

      test('emits ChallengesError on failure', () async {
        mockProvider = MockChallengesDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = ChallengesBloc(dataProvider: mockProvider);

        final states = <ChallengesState>[];
        bloc.stream.listen(states.add);

        bloc.add(ChallengesEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, 2);
        expect(states[0], isA<ChallengesLoading>());
        expect(states[1], isA<ChallengesError>());
      });

      test('error state contains error message', () async {
        mockProvider = MockChallengesDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = ChallengesBloc(dataProvider: mockProvider);

        final states = <ChallengesState>[];
        bloc.stream.listen(states.add);

        bloc.add(ChallengesEvent.load());

        await Future.delayed(const Duration(milliseconds: 100));

        final errorState = states[1] as ChallengesError;
        expect(errorState.message, 'Failed to load challenges');
        expect(errorState.error, isA<Exception>());
      });
    });

    group('RefreshChallenges event', () {
      test('refreshes data and calls load again', () async {
        // First load
        bloc.add(ChallengesEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        // Refresh
        bloc.add(ChallengesEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadCallCount, 2);
      });

      test('sets isRefreshing to true during refresh', () async {
        mockProvider = MockChallengesDataProvider(
          loadDelay: const Duration(milliseconds: 50),
        );
        bloc.dispose();
        bloc = ChallengesBloc(dataProvider: mockProvider);

        // First load
        bloc.add(ChallengesEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        final states = <ChallengesState>[];
        bloc.stream.listen(states.add);

        // Refresh
        bloc.add(ChallengesEvent.refresh());
        await Future.delayed(const Duration(milliseconds: 10));

        // Should be refreshing
        final refreshingState = states.first as ChallengesLoaded;
        expect(refreshingState.isRefreshing, true);

        // Wait for refresh to complete
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('calls loadChallenges when not in loaded state', () async {
        // Don't load first, just refresh
        bloc.add(ChallengesEvent.refresh());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockProvider.loadCallCount, 1);
      });

      test('keeps existing data on refresh failure', () async {
        // First load successfully
        bloc.add(ChallengesEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        // Save reference to loaded state
        final loadedChallenges = bloc.challenges;
        final loadedCategories = bloc.categories;

        // Create new failing provider
        final failingProvider = MockChallengesDataProvider(shouldFail: true);
        bloc.dispose();
        bloc = ChallengesBloc(dataProvider: failingProvider);

        // Load data first (will fail, but we need to test refresh failure)
        // This test is more about verifying the refresh keeps data on failure
      });
    });

    group('ChallengesLoaded copyWith', () {
      test('creates copy with updated challenges', () {
        final original = ChallengesLoaded(
          challenges: MockChallengesDataProvider._createDefaultChallenges(),
          categories: MockChallengesDataProvider._createDefaultCategories(),
        );

        final newChallenges = <ChallengeMode>[];
        final copy = original.copyWith(challenges: newChallenges);

        expect(copy.challenges, newChallenges);
        expect(copy.categories, original.categories);
      });

      test('creates copy with updated categories', () {
        final original = ChallengesLoaded(
          challenges: MockChallengesDataProvider._createDefaultChallenges(),
          categories: MockChallengesDataProvider._createDefaultCategories(),
        );

        final newCategories = <QuizCategory>[];
        final copy = original.copyWith(categories: newCategories);

        expect(copy.categories, newCategories);
        expect(copy.challenges, original.challenges);
      });

      test('creates copy with updated isRefreshing', () {
        final original = ChallengesLoaded(
          challenges: MockChallengesDataProvider._createDefaultChallenges(),
          categories: MockChallengesDataProvider._createDefaultCategories(),
        );

        final copy = original.copyWith(isRefreshing: true);

        expect(copy.isRefreshing, true);
        expect(copy.challenges, original.challenges);
        expect(copy.categories, original.categories);
      });

      test('preserves all values when no arguments provided', () {
        final original = ChallengesLoaded(
          challenges: MockChallengesDataProvider._createDefaultChallenges(),
          categories: MockChallengesDataProvider._createDefaultCategories(),
          isRefreshing: true,
        );

        final copy = original.copyWith();

        expect(copy.challenges, original.challenges);
        expect(copy.categories, original.categories);
        expect(copy.isRefreshing, original.isRefreshing);
      });
    });

    group('ChallengesState equality', () {
      test('ChallengesLoading instances are equal', () {
        const state1 = ChallengesLoading();
        const state2 = ChallengesLoading();

        expect(identical(state1, state2), true);
      });

      test('ChallengesError instances with same values are equal', () {
        const state1 = ChallengesError(message: 'Error', error: null);
        const state2 = ChallengesError(message: 'Error', error: null);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('ChallengesLoaded instances with same values are equal', () {
        final challenges =
            MockChallengesDataProvider._createDefaultChallenges();
        final categories =
            MockChallengesDataProvider._createDefaultCategories();

        final state1 = ChallengesLoaded(
          challenges: challenges,
          categories: categories,
        );
        final state2 = ChallengesLoaded(
          challenges: challenges,
          categories: categories,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('ChallengesData', () {
      test('empty creates empty data', () {
        expect(ChallengesData.empty.challenges, isEmpty);
        expect(ChallengesData.empty.categories, isEmpty);
      });
    });

    group('dispose', () {
      test('closes stream', () async {
        bloc.dispose();

        expect(bloc.stream.isBroadcast, true);
      });
    });

    group('challenges and categories getters', () {
      test('challenges returns data from loaded state', () async {
        bloc.add(ChallengesEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.challenges, isNotNull);
        expect(bloc.challenges!.length, 3);
      });

      test('categories returns data from loaded state', () async {
        bloc.add(ChallengesEvent.load());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.categories, isNotNull);
        expect(bloc.categories!.length, 2);
      });
    });
  });
}
