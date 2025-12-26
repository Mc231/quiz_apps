import 'dart:math';

import '../../model/config/hint_config.dart';
import '../../model/question.dart';
import '../../model/question_entry.dart';

/// Callback signature for when a hint is used and state changes.
typedef OnHintStateChanged = void Function({
  required HintState hintState,
  required Set<QuestionEntry> disabledOptions,
});

/// Manages hint state and hint usage during a quiz session.
///
/// This manager is responsible for:
/// - Tracking hint availability and usage
/// - Managing disabled options from 50/50 hints
/// - Providing hint statistics for storage
class QuizHintManager {
  /// The current hint state tracking which hints have been used.
  HintState? _hintState;

  /// Options disabled for the current question (e.g., from 50/50 hint).
  Set<QuestionEntry> _disabledOptions = {};

  /// Count of 50/50 hints used this session.
  int _hintsUsed5050 = 0;

  /// Count of skip hints used this session.
  int _hintsUsedSkip = 0;

  /// Random number generator for 50/50 selection.
  final Random _random;

  /// Callback invoked when hint state changes.
  final OnHintStateChanged? onHintStateChanged;

  /// Creates a new hint manager.
  ///
  /// [onHintStateChanged] - Called when hint state changes (for UI updates)
  /// [random] - Optional random generator for testing
  QuizHintManager({
    this.onHintStateChanged,
    Random? random,
  }) : _random = random ?? Random();

  // ============ Getters ============

  /// The current hint state.
  HintState? get hintState => _hintState;

  /// Options disabled for the current question.
  Set<QuestionEntry> get disabledOptions => Set.unmodifiable(_disabledOptions);

  /// Count of 50/50 hints used this session.
  int get hintsUsed5050 => _hintsUsed5050;

  /// Count of skip hints used this session.
  int get hintsUsedSkip => _hintsUsedSkip;

  /// Whether the manager has been initialized.
  bool get isInitialized => _hintState != null;

  // ============ Initialization ============

  /// Initializes the hint manager from config.
  ///
  /// [hintConfig] - The hint configuration
  void initialize(HintConfig hintConfig) {
    _hintState = HintState.fromConfig(hintConfig);
    _disabledOptions = {};
    _hintsUsed5050 = 0;
    _hintsUsedSkip = 0;
  }

  // ============ Hint Availability ============

  /// Checks if a hint type is available.
  ///
  /// Returns false if not initialized or hint is not available.
  bool canUseHint(HintType type) {
    return _hintState?.canUseHint(type) ?? false;
  }

  /// Gets the remaining count for a hint type.
  int getRemainingCount(HintType type) {
    return _hintState?.getRemainingCount(type) ?? 0;
  }

  // ============ 50/50 Hint ============

  /// Uses the 50/50 hint to disable 2 incorrect options.
  ///
  /// [question] - The current question
  ///
  /// Returns the set of disabled options, or empty set if hint unavailable.
  Set<QuestionEntry> use5050Hint(Question question) {
    if (!canUseHint(HintType.fiftyFifty)) {
      return {};
    }

    // Find all incorrect options
    final incorrectOptions = question.options
        .where((option) => option != question.answer)
        .toList();

    // If there are less than 2 incorrect options, can't use this hint
    if (incorrectOptions.length < 2) {
      return {};
    }

    // Mark hint as used
    _hintState!.useHint(HintType.fiftyFifty);
    _hintsUsed5050++;

    // Randomly select 2 incorrect options to disable
    incorrectOptions.shuffle(_random);
    _disabledOptions = incorrectOptions.take(2).toSet();

    // Notify listeners
    _notifyStateChanged();

    return _disabledOptions;
  }

  // ============ Skip Hint ============

  /// Uses the skip hint.
  ///
  /// Returns true if the hint was used successfully.
  bool useSkipHint() {
    if (!canUseHint(HintType.skip)) {
      return false;
    }

    _hintState!.useHint(HintType.skip);
    _hintsUsedSkip++;

    _notifyStateChanged();

    return true;
  }

  // ============ Question Transitions ============

  /// Resets disabled options for a new question.
  ///
  /// Call this when moving to a new question.
  void resetForNewQuestion() {
    _disabledOptions = {};
  }

  // ============ Hint Rewards ============

  /// Adds hints of a specific type (e.g., from achievements or ads).
  void addHint(HintType type, int count) {
    _hintState?.addHint(type, count);
    _notifyStateChanged();
  }

  // ============ Helper Methods ============

  void _notifyStateChanged() {
    if (_hintState != null) {
      onHintStateChanged?.call(
        hintState: _hintState!,
        disabledOptions: _disabledOptions,
      );
    }
  }

  // ============ Reset ============

  /// Resets all hint state.
  void reset() {
    _hintState = null;
    _disabledOptions = {};
    _hintsUsed5050 = 0;
    _hintsUsedSkip = 0;
  }
}
