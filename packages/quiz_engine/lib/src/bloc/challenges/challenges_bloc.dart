/// BLoC for managing challenges state.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../../models/challenge_mode.dart';
import '../../models/quiz_category.dart';
import 'challenges_event.dart';
import 'challenges_state.dart';

/// Data class containing challenges configuration.
class ChallengesData {
  /// Creates a [ChallengesData].
  const ChallengesData({
    required this.challenges,
    required this.categories,
  });

  /// The list of available challenges.
  final List<ChallengeMode> challenges;

  /// The list of available categories.
  final List<QuizCategory> categories;

  /// Creates an empty data instance.
  static const empty = ChallengesData(
    challenges: [],
    categories: [],
  );
}

/// Interface for providing challenges data.
///
/// Apps must implement this interface to provide data to [ChallengesBloc].
abstract interface class ChallengesDataProvider {
  /// Loads challenges and categories.
  ///
  /// Returns [ChallengesData] containing challenges and categories.
  /// Throws an exception if loading fails.
  Future<ChallengesData> loadChallenges();
}

/// BLoC for managing challenges state.
///
/// Handles loading challenges and categories data.
class ChallengesBloc extends SingleSubscriptionBloc<ChallengesState> {
  /// Creates a [ChallengesBloc].
  ChallengesBloc({
    required ChallengesDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final ChallengesDataProvider _dataProvider;

  /// Tracks the last loaded state for access to current data.
  ChallengesLoaded? _lastLoadedState;

  @override
  ChallengesState get initialState => const ChallengesLoading();

  /// Returns the current challenges, if loaded.
  List<ChallengeMode>? get challenges => _lastLoadedState?.challenges;

  /// Returns the current categories, if loaded.
  List<QuizCategory>? get categories => _lastLoadedState?.categories;

  /// Adds an event to the BLoC.
  void add(ChallengesEvent event) {
    switch (event) {
      case LoadChallenges():
        _handleLoad();
      case RefreshChallenges():
        _handleRefresh();
    }
  }

  @override
  void dispatchState(ChallengesState state) {
    if (state is ChallengesLoaded) {
      _lastLoadedState = state;
    } else if (state is ChallengesLoading) {
      // Keep last loaded state for refresh purposes
    } else if (state is ChallengesError) {
      _lastLoadedState = null;
    }
    super.dispatchState(state);
  }

  Future<void> _handleLoad() async {
    dispatchState(const ChallengesLoading());

    try {
      final data = await _dataProvider.loadChallenges();
      dispatchState(ChallengesState.loaded(
        challenges: data.challenges,
        categories: data.categories,
      ));
    } catch (e) {
      dispatchState(ChallengesState.error(
        message: 'Failed to load challenges',
        error: e,
      ));
    }
  }

  Future<void> _handleRefresh() async {
    final currentState = _lastLoadedState;
    if (currentState == null) {
      // If not in loaded state, just do a full load
      await _handleLoad();
      return;
    }

    // Mark as refreshing
    dispatchState(currentState.copyWith(isRefreshing: true));

    try {
      final data = await _dataProvider.loadChallenges();
      dispatchState(ChallengesState.loaded(
        challenges: data.challenges,
        categories: data.categories,
        isRefreshing: false,
      ));
    } catch (e) {
      // On refresh failure, keep existing data but stop refreshing
      dispatchState(currentState.copyWith(isRefreshing: false));
    }
  }
}
