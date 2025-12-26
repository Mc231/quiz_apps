import 'package:flutter/widgets.dart';
import 'package:shared_services/shared_services.dart';

/// Standardized feedback patterns for quiz interactions.
///
/// Combines audio and haptic feedback with consistent patterns
/// that respect user preferences.
enum QuizFeedbackPattern {
  /// Correct answer feedback (light haptic + correct sound).
  correctAnswer,

  /// Incorrect answer feedback (medium haptic + incorrect sound).
  incorrectAnswer,

  /// Button/option tap (selection haptic + click sound).
  buttonTap,

  /// Resource button tap (selection haptic).
  resourceTap,

  /// Resource depleted (heavy haptic + life lost sound).
  resourceDepleted,

  /// Hint used (light haptic + hint sound).
  hintUsed,

  /// Life lost (medium haptic + life lost sound).
  lifeLost,

  /// Quiz start (light haptic + quiz start sound).
  quizStart,

  /// Quiz complete (heavy haptic + quiz complete sound).
  quizComplete,

  /// Achievement unlocked (heavy haptic + achievement sound).
  achievementUnlocked,

  /// Timer warning (light haptic + timer warning sound).
  timerWarning,

  /// Time out (medium haptic + timeout sound).
  timeout,

  /// Selection change (selection haptic only).
  selectionChange,

  /// Error/invalid action (vibrate haptic).
  error,
}

/// A service that provides combined audio and haptic feedback
/// for quiz interactions.
///
/// This service respects user preferences for sound and haptic feedback,
/// and provides a consistent API for triggering feedback throughout the app.
///
/// Example:
/// ```dart
/// final feedbackService = QuizFeedbackService();
/// await feedbackService.initialize();
///
/// // Play correct answer feedback
/// await feedbackService.trigger(QuizFeedbackPattern.correctAnswer);
///
/// // Check if sounds are enabled
/// if (feedbackService.soundsEnabled) { ... }
/// ```
class QuizFeedbackService {
  final AudioService _audioService;
  final HapticService _hapticService;

  bool _soundsEnabled;
  bool _hapticsEnabled;
  bool _initialized = false;

  /// Creates a [QuizFeedbackService].
  ///
  /// Optionally provide existing [AudioService] and [HapticService] instances.
  /// If not provided, new instances will be created.
  QuizFeedbackService({
    AudioService? audioService,
    HapticService? hapticService,
    bool soundsEnabled = true,
    bool hapticsEnabled = true,
  })  : _audioService = audioService ?? AudioService(),
        _hapticService = hapticService ?? HapticService(),
        _soundsEnabled = soundsEnabled,
        _hapticsEnabled = hapticsEnabled;

  /// Whether sound effects are currently enabled.
  bool get soundsEnabled => _soundsEnabled;

  /// Whether haptic feedback is currently enabled.
  bool get hapticsEnabled => _hapticsEnabled;

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  /// The underlying audio service.
  AudioService get audioService => _audioService;

  /// The underlying haptic service.
  HapticService get hapticService => _hapticService;

  /// Initializes the feedback service.
  ///
  /// Must be called before triggering any feedback.
  /// Optionally preloads frequently used sounds.
  Future<void> initialize({bool preloadSounds = true}) async {
    if (_initialized) return;

    await _audioService.initialize();
    _audioService.setMuted(!_soundsEnabled);
    _hapticService.setEnabled(_hapticsEnabled);

    if (preloadSounds && _soundsEnabled) {
      await _audioService.preloadMultiple([
        QuizSoundEffect.correctAnswer,
        QuizSoundEffect.incorrectAnswer,
        QuizSoundEffect.buttonClick,
      ]);
    }

    _initialized = true;
  }

  /// Updates sound enabled state.
  void setSoundsEnabled(bool enabled) {
    _soundsEnabled = enabled;
    _audioService.setMuted(!enabled);
  }

  /// Updates haptic feedback enabled state.
  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
    _hapticService.setEnabled(enabled);
  }

  /// Updates both sound and haptic settings.
  void updateSettings({bool? soundsEnabled, bool? hapticsEnabled}) {
    if (soundsEnabled != null) setSoundsEnabled(soundsEnabled);
    if (hapticsEnabled != null) setHapticsEnabled(hapticsEnabled);
  }

  /// Triggers feedback for the specified pattern.
  ///
  /// This will play the appropriate sound and haptic feedback
  /// based on the pattern, respecting user preferences.
  Future<void> trigger(QuizFeedbackPattern pattern) async {
    // Run audio and haptic concurrently
    await Future.wait([
      _triggerAudio(pattern),
      _triggerHaptic(pattern),
    ]);
  }

  /// Triggers only the haptic feedback for a pattern.
  Future<void> triggerHaptic(QuizFeedbackPattern pattern) async {
    await _triggerHaptic(pattern);
  }

  /// Triggers only the audio feedback for a pattern.
  Future<void> triggerAudio(QuizFeedbackPattern pattern) async {
    await _triggerAudio(pattern);
  }

  Future<void> _triggerAudio(QuizFeedbackPattern pattern) async {
    if (!_soundsEnabled) return;

    final sound = _getSoundForPattern(pattern);
    if (sound != null) {
      await _audioService.playSoundEffect(sound);
    }
  }

  Future<void> _triggerHaptic(QuizFeedbackPattern pattern) async {
    if (!_hapticsEnabled) return;

    final hapticType = _getHapticForPattern(pattern);
    if (hapticType != null) {
      await _hapticService.impact(hapticType);
    }
  }

  QuizSoundEffect? _getSoundForPattern(QuizFeedbackPattern pattern) {
    return switch (pattern) {
      QuizFeedbackPattern.correctAnswer => QuizSoundEffect.correctAnswer,
      QuizFeedbackPattern.incorrectAnswer => QuizSoundEffect.incorrectAnswer,
      QuizFeedbackPattern.buttonTap => QuizSoundEffect.buttonClick,
      QuizFeedbackPattern.resourceTap => null,
      QuizFeedbackPattern.resourceDepleted => QuizSoundEffect.lifeLost,
      QuizFeedbackPattern.hintUsed => QuizSoundEffect.hintUsed,
      QuizFeedbackPattern.lifeLost => QuizSoundEffect.lifeLost,
      QuizFeedbackPattern.quizStart => QuizSoundEffect.quizStart,
      QuizFeedbackPattern.quizComplete => QuizSoundEffect.quizComplete,
      QuizFeedbackPattern.achievementUnlocked => QuizSoundEffect.achievement,
      QuizFeedbackPattern.timerWarning => QuizSoundEffect.timerWarning,
      QuizFeedbackPattern.timeout => QuizSoundEffect.timeOut,
      QuizFeedbackPattern.selectionChange => null,
      QuizFeedbackPattern.error => null,
    };
  }

  HapticFeedbackType? _getHapticForPattern(QuizFeedbackPattern pattern) {
    return switch (pattern) {
      QuizFeedbackPattern.correctAnswer => HapticFeedbackType.light,
      QuizFeedbackPattern.incorrectAnswer => HapticFeedbackType.medium,
      QuizFeedbackPattern.buttonTap => HapticFeedbackType.selection,
      QuizFeedbackPattern.resourceTap => HapticFeedbackType.selection,
      QuizFeedbackPattern.resourceDepleted => HapticFeedbackType.heavy,
      QuizFeedbackPattern.hintUsed => HapticFeedbackType.light,
      QuizFeedbackPattern.lifeLost => HapticFeedbackType.medium,
      QuizFeedbackPattern.quizStart => HapticFeedbackType.light,
      QuizFeedbackPattern.quizComplete => HapticFeedbackType.heavy,
      QuizFeedbackPattern.achievementUnlocked => HapticFeedbackType.heavy,
      QuizFeedbackPattern.timerWarning => HapticFeedbackType.light,
      QuizFeedbackPattern.timeout => HapticFeedbackType.medium,
      QuizFeedbackPattern.selectionChange => HapticFeedbackType.selection,
      QuizFeedbackPattern.error => HapticFeedbackType.vibrate,
    };
  }

  /// Disposes of resources used by the service.
  Future<void> dispose() async {
    await _audioService.dispose();
  }
}

/// InheritedWidget for providing [QuizFeedbackService] to descendants.
class QuizFeedbackProvider extends InheritedWidget {
  /// The feedback service to provide.
  final QuizFeedbackService feedbackService;

  const QuizFeedbackProvider({
    super.key,
    required this.feedbackService,
    required super.child,
  });

  /// Gets the [QuizFeedbackService] from the nearest ancestor.
  ///
  /// Returns null if no provider is found.
  static QuizFeedbackService? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<QuizFeedbackProvider>()
        ?.feedbackService;
  }

  /// Gets the [QuizFeedbackService] from the nearest ancestor.
  ///
  /// Throws if no provider is found.
  static QuizFeedbackService of(BuildContext context) {
    final service = maybeOf(context);
    assert(service != null, 'No QuizFeedbackProvider found in context');
    return service!;
  }

  @override
  bool updateShouldNotify(QuizFeedbackProvider oldWidget) {
    return feedbackService != oldWidget.feedbackService;
  }
}

/// Extension for easy access to feedback service from BuildContext.
extension QuizFeedbackContextExtension on BuildContext {
  /// Gets the [QuizFeedbackService] from the nearest ancestor, if available.
  QuizFeedbackService? get feedbackService =>
      QuizFeedbackProvider.maybeOf(this);

  /// Triggers feedback for the specified pattern.
  ///
  /// Does nothing if no [QuizFeedbackProvider] is found.
  Future<void> triggerFeedback(QuizFeedbackPattern pattern) async {
    await feedbackService?.trigger(pattern);
  }
}
