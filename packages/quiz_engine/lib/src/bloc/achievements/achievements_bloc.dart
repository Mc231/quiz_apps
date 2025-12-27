/// BLoC for managing achievements screen state.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' show AchievementTier;

import '../../achievements/screens/achievements_screen.dart';
import '../../achievements/widgets/achievements_list.dart';
import 'achievements_event.dart';
import 'achievements_state.dart';

/// Interface for providing achievements data to [AchievementsBloc].
///
/// Apps must implement this interface to provide data loading capability.
/// Note: This is separate from the [AchievementsDataProvider] model interface.
abstract interface class AchievementsBlocDataProvider {
  /// Loads achievements data.
  ///
  /// Returns [AchievementsScreenData] containing all achievements.
  Future<AchievementsScreenData> loadAchievements();
}

/// BLoC for managing achievements screen state.
///
/// Handles loading, filtering, and refreshing achievements.
class AchievementsBloc extends SingleSubscriptionBloc<AchievementsState> {
  /// Creates an [AchievementsBloc].
  AchievementsBloc({
    required AchievementsBlocDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final AchievementsBlocDataProvider _dataProvider;

  /// Tracks the last loaded state for access to current data.
  AchievementsLoaded? _lastLoadedState;

  @override
  AchievementsState get initialState => const AchievementsLoading();

  /// Returns the current achievements data, if loaded.
  AchievementsScreenData? get data => _lastLoadedState?.data;

  /// Returns the current filter, if loaded.
  AchievementFilter? get filter => _lastLoadedState?.filter;

  /// Returns the current tier filter, if loaded.
  AchievementTier? get tierFilter => _lastLoadedState?.tierFilter;

  /// Adds an event to the BLoC.
  void add(AchievementsEvent event) {
    switch (event) {
      case LoadAchievements():
        _handleLoad();
      case RefreshAchievements():
        _handleRefresh();
      case AchievementsChangeFilter():
        _handleChangeFilter(event);
      case AchievementsChangeTierFilter():
        _handleChangeTierFilter(event);
    }
  }

  @override
  void dispatchState(AchievementsState state) {
    if (state is AchievementsLoaded) {
      _lastLoadedState = state;
    } else if (state is AchievementsLoading) {
      // Keep last loaded state for reference
    } else if (state is AchievementsError) {
      _lastLoadedState = null;
    }
    super.dispatchState(state);
  }

  Future<void> _handleLoad() async {
    dispatchState(const AchievementsLoading());

    try {
      final data = await _dataProvider.loadAchievements();
      dispatchState(AchievementsState.loaded(data: data));
    } catch (e) {
      dispatchState(AchievementsState.error(
        message: 'Failed to load achievements',
        error: e,
      ));
    }
  }

  Future<void> _handleRefresh() async {
    final currentState = _lastLoadedState;
    if (currentState == null) {
      // If not loaded, just do a regular load
      await _handleLoad();
      return;
    }

    // Set refreshing state
    dispatchState(currentState.copyWith(isRefreshing: true));

    try {
      final data = await _dataProvider.loadAchievements();
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          data: data,
          isRefreshing: false,
        ));
      }
    } catch (e) {
      final latestState = _lastLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(isRefreshing: false));
      }
    }
  }

  void _handleChangeFilter(AchievementsChangeFilter event) {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(filter: event.filter));
  }

  void _handleChangeTierFilter(AchievementsChangeTierFilter event) {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    if (event.tier == null) {
      dispatchState(currentState.copyWith(clearTierFilter: true));
    } else {
      dispatchState(currentState.copyWith(tierFilter: event.tier));
    }
  }
}
