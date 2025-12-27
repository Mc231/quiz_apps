/// BLoC for managing practice screen state.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../../models/practice_data_provider.dart';
import 'practice_event.dart';
import 'practice_state.dart';

/// Interface for providing practice data to [PracticeBloc].
///
/// Apps must implement this interface to provide data loading capability.
/// Unlike [PracticeDataProvider], this interface doesn't require BuildContext,
/// making it suitable for use in a BLoC.
abstract interface class PracticeBlocDataProvider {
  /// Loads practice data.
  ///
  /// Returns [PracticeTabData] containing questions needing practice.
  Future<PracticeTabData> loadPracticeData();

  /// Called when a practice session completes.
  ///
  /// [correctQuestionIds] - Question IDs that were answered correctly.
  Future<void> onPracticeSessionCompleted(List<String> correctQuestionIds);
}

/// BLoC for managing practice screen state.
///
/// Handles loading practice data, tracking session progress, and updating
/// practice progress after completion.
class PracticeBloc extends SingleSubscriptionBloc<PracticeState> {
  /// Creates a [PracticeBloc].
  PracticeBloc({
    required PracticeBlocDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final PracticeBlocDataProvider _dataProvider;

  /// Tracks the last ready state for access to current data.
  PracticeReady? _lastReadyState;

  /// Tracks the last complete state for access to results.
  PracticeComplete? _lastCompleteState;

  @override
  PracticeState get initialState => const PracticeLoading();

  /// Returns the current practice data, if ready.
  PracticeTabData? get data => _lastReadyState?.data;

  /// Returns the question count, if ready.
  int? get questionCount => _lastReadyState?.questionCount;

  /// Returns whether there are questions to practice.
  bool get hasQuestions => _lastReadyState?.hasQuestions ?? false;

  /// Returns the correct count if complete.
  int? get correctCount => _lastCompleteState?.correctCount;

  /// Returns the need more practice count if complete.
  int? get needMorePracticeCount => _lastCompleteState?.needMorePracticeCount;

  /// Adds an event to the BLoC.
  void add(PracticeEvent event) {
    switch (event) {
      case LoadPractice():
        _handleLoad();
      case RefreshPractice():
        _handleRefresh();
      case PracticeSessionComplete():
        _handleComplete(event);
      case ResetPractice():
        _handleReset();
    }
  }

  @override
  void dispatchState(PracticeState state) {
    if (state is PracticeReady) {
      _lastReadyState = state;
      _lastCompleteState = null;
    } else if (state is PracticeComplete) {
      _lastCompleteState = state;
    } else if (state is PracticeLoading) {
      // Keep last ready state for reference
    } else if (state is PracticeError) {
      _lastReadyState = null;
      _lastCompleteState = null;
    }
    super.dispatchState(state);
  }

  Future<void> _handleLoad() async {
    dispatchState(const PracticeLoading());

    try {
      final data = await _dataProvider.loadPracticeData();
      dispatchState(PracticeState.ready(data: data));
    } catch (e) {
      dispatchState(PracticeState.error(
        message: 'Failed to load practice data',
        error: e,
      ));
    }
  }

  Future<void> _handleRefresh() async {
    final currentState = _lastReadyState;
    if (currentState == null) {
      // If not ready, just do a regular load
      await _handleLoad();
      return;
    }

    // Set refreshing state
    dispatchState(currentState.copyWith(isRefreshing: true));

    try {
      final data = await _dataProvider.loadPracticeData();
      dispatchState(PracticeState.ready(data: data));
    } catch (e) {
      // On error during refresh, keep current data
      dispatchState(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<void> _handleComplete(PracticeSessionComplete event) async {
    // Notify the data provider about completed questions
    try {
      await _dataProvider.onPracticeSessionCompleted(event.correctQuestionIds);
    } catch (_) {
      // Continue even if the update fails
    }

    // Dispatch complete state
    dispatchState(PracticeState.complete(
      correctCount: event.correctCount,
      needMorePracticeCount: event.needMorePracticeCount,
    ));
  }

  Future<void> _handleReset() async {
    // Reload practice data to get updated list
    await _handleLoad();
  }
}
