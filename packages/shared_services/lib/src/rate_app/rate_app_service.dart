import 'dart:convert';

import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rate_app_config.dart';
import 'rate_app_state.dart';

/// Result of a rate app prompt attempt.
sealed class RateAppResult {
  const RateAppResult();

  /// The prompt was shown successfully.
  const factory RateAppResult.shown() = RateAppResultShown;

  /// The prompt was not shown because conditions were not met.
  const factory RateAppResult.conditionsNotMet(String reason) =
      RateAppResultConditionsNotMet;

  /// The prompt was not shown because it's not available on this platform.
  const factory RateAppResult.notAvailable() = RateAppResultNotAvailable;

  /// An error occurred while showing the prompt.
  const factory RateAppResult.error(Object error) = RateAppResultError;
}

/// The prompt was shown successfully.
class RateAppResultShown extends RateAppResult {
  const RateAppResultShown();
}

/// The prompt was not shown because conditions were not met.
class RateAppResultConditionsNotMet extends RateAppResult {
  /// The reason why conditions were not met.
  final String reason;

  const RateAppResultConditionsNotMet(this.reason);
}

/// The prompt was not shown because it's not available on this platform.
class RateAppResultNotAvailable extends RateAppResult {
  const RateAppResultNotAvailable();
}

/// An error occurred while showing the prompt.
class RateAppResultError extends RateAppResult {
  /// The error that occurred.
  final Object error;

  const RateAppResultError(this.error);
}

/// Service key for storing rate app state in SharedPreferences.
const String _stateKey = 'rate_app_state';

/// Service for managing app rating prompts.
///
/// Implements intelligent timing for rating prompts based on:
/// - User engagement (completed quizzes, scores)
/// - Time since install
/// - Previous prompt history
/// - Platform availability
///
/// Example usage:
/// ```dart
/// final service = RateAppService(
///   config: RateAppConfig(
///     minCompletedQuizzes: 5,
///     minScorePercentage: 70,
///   ),
/// );
/// await service.initialize();
///
/// // Check after quiz completion
/// if (service.shouldShowPrompt(quizScore: 85, completedQuizzes: 10)) {
///   await service.showNativeRatingDialog();
/// }
/// ```
class RateAppService {
  /// Configuration for the rate app service.
  final RateAppConfig config;

  /// The in-app review instance.
  final InAppReview _inAppReview;

  /// SharedPreferences instance for persistence.
  SharedPreferences? _prefs;

  /// Current state of the rate app service.
  RateAppState _state = const RateAppState();

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Creates a new [RateAppService].
  RateAppService({
    required this.config,
    InAppReview? inAppReview,
  }) : _inAppReview = inAppReview ?? InAppReview.instance;

  /// Current state of the rate app service.
  RateAppState get state => _state;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the service by loading state from storage.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadState();
    _isInitialized = true;
  }

  /// Loads the state from SharedPreferences.
  Future<void> _loadState() async {
    final stateJson = _prefs?.getString(_stateKey);
    if (stateJson != null) {
      try {
        final json = jsonDecode(stateJson) as Map<String, dynamic>;
        _state = RateAppState.fromJson(json);
      } catch (_) {
        // If parsing fails, start with a fresh state
        _state = RateAppState.initial();
        await _saveState();
      }
    } else {
      // First launch - initialize with current date
      _state = RateAppState.initial();
      await _saveState();
    }
  }

  /// Saves the current state to SharedPreferences.
  Future<void> _saveState() async {
    await _prefs?.setString(_stateKey, jsonEncode(_state.toJson()));
  }

  /// Checks if the prompt should be shown based on all conditions.
  ///
  /// [quizScore] - The score percentage from the last quiz (0-100).
  /// [completedQuizzes] - Total number of quizzes completed by the user.
  ///
  /// Returns `true` if all conditions are met and the prompt should be shown.
  bool shouldShowPrompt({
    required int quizScore,
    required int completedQuizzes,
  }) {
    // Check if disabled
    if (!config.isEnabled) return false;

    // Check if user has already rated
    if (_state.hasRated) return false;

    // Check max lifetime prompts
    if (_state.promptCount >= config.maxLifetimePrompts) return false;

    // Check max declines
    if (_state.declineCount >= config.maxDeclines) return false;

    // Check minimum completed quizzes
    if (completedQuizzes < config.minCompletedQuizzes) return false;

    // Check minimum days since install
    if (_state.daysSinceInstall < config.minDaysSinceInstall) return false;

    // Check minimum score
    if (quizScore < config.minScorePercentage) return false;

    // Check cooldown period
    final daysSinceLastPrompt = _state.daysSinceLastPrompt;
    if (daysSinceLastPrompt != null &&
        daysSinceLastPrompt < config.cooldownDays) {
      return false;
    }

    return true;
  }

  /// Returns the reason why the prompt should not be shown.
  ///
  /// Returns `null` if the prompt should be shown.
  String? getBlockingReason({
    required int quizScore,
    required int completedQuizzes,
  }) {
    if (!config.isEnabled) {
      return 'Rate prompts are disabled';
    }

    if (_state.hasRated) {
      return 'User has already rated';
    }

    if (_state.promptCount >= config.maxLifetimePrompts) {
      return 'Maximum lifetime prompts reached (${config.maxLifetimePrompts})';
    }

    if (_state.declineCount >= config.maxDeclines) {
      return 'Maximum declines reached (${config.maxDeclines})';
    }

    if (completedQuizzes < config.minCompletedQuizzes) {
      return 'Not enough quizzes completed '
          '($completedQuizzes/${config.minCompletedQuizzes})';
    }

    if (_state.daysSinceInstall < config.minDaysSinceInstall) {
      return 'Not enough days since install '
          '(${_state.daysSinceInstall}/${config.minDaysSinceInstall})';
    }

    if (quizScore < config.minScorePercentage) {
      return 'Score too low ($quizScore%/${config.minScorePercentage}%)';
    }

    final daysSinceLastPrompt = _state.daysSinceLastPrompt;
    if (daysSinceLastPrompt != null &&
        daysSinceLastPrompt < config.cooldownDays) {
      return 'In cooldown period '
          '($daysSinceLastPrompt/${config.cooldownDays} days)';
    }

    return null;
  }

  /// Shows the native in-app rating dialog.
  ///
  /// Returns a [RateAppResult] indicating the outcome.
  Future<RateAppResult> showNativeRatingDialog() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) {
        return const RateAppResult.notAvailable();
      }

      await _inAppReview.requestReview();
      await recordPromptShown();
      return const RateAppResult.shown();
    } catch (e) {
      return RateAppResult.error(e);
    }
  }

  /// Opens the app store page for rating.
  ///
  /// Use this as a fallback when the native dialog is not available
  /// or when the user explicitly wants to rate the app.
  ///
  /// [appStoreId] - The App Store ID (iOS only).
  /// [microsoftStoreId] - The Microsoft Store ID (Windows only).
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) async {
    await _inAppReview.openStoreListing(
      appStoreId: appStoreId,
      microsoftStoreId: microsoftStoreId,
    );
  }

  /// Records that a prompt was shown to the user.
  Future<void> recordPromptShown() async {
    _state = _state.copyWith(
      lastPromptDate: DateTime.now(),
      promptCount: _state.promptCount + 1,
    );
    await _saveState();
  }

  /// Records that the user completed a rating.
  ///
  /// After calling this, no more prompts will be shown.
  Future<void> recordUserRated() async {
    _state = _state.copyWith(hasRated: true);
    await _saveState();
  }

  /// Records that the user declined the prompt.
  Future<void> recordUserDeclined() async {
    _state = _state.copyWith(
      declineCount: _state.declineCount + 1,
    );
    await _saveState();
  }

  /// Records that the user dismissed the prompt without action.
  ///
  /// This is less aggressive than a decline - doesn't increment decline count.
  Future<void> recordUserDismissed() async {
    // Just update the last prompt date to trigger cooldown
    _state = _state.copyWith(
      lastPromptDate: DateTime.now(),
    );
    await _saveState();
  }

  /// Records that the user submitted feedback.
  ///
  /// This is treated similar to a decline for prompt purposes.
  Future<void> recordFeedbackSubmitted() async {
    _state = _state.copyWith(
      declineCount: _state.declineCount + 1,
    );
    await _saveState();
  }

  /// Resets the state for testing purposes.
  ///
  /// This clears all stored state and reinitializes with fresh values.
  Future<void> resetState() async {
    await _prefs?.remove(_stateKey);
    _state = RateAppState.initial();
    await _saveState();
  }

  /// Updates the state directly (for testing purposes).
  void updateStateForTesting(RateAppState newState) {
    _state = newState;
  }
}
