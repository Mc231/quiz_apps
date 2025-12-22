import '../../model/config/quiz_config.dart';
import '../../model/config/ui_behavior_config.dart';
import 'config_source.dart';

/// Manages quiz configuration with optional settings integration
///
/// ConfigManager handles:
/// - Loading configuration from various sources (default, remote, cached - future)
/// - Applying user settings (sound, haptic, feedback) if provided
///
/// For MVP, supports default configuration with optional settings application.
/// Future releases will add support for:
/// - Local storage caching
/// - Remote configuration (Firebase Remote Config, API, etc.)
class ConfigManager {
  /// The default configuration to use
  final QuizConfig defaultConfig;

  /// Optional callback to get user settings for applying to configuration
  /// Returns a map with 'soundEnabled', 'hapticEnabled', 'showAnswerFeedback'
  final Map<String, bool> Function()? getSettings;

  const ConfigManager({
    required this.defaultConfig,
    this.getSettings,
  });

  /// Get configuration from specified source with optional settings applied
  ///
  /// [source] - Where to load config from (currently only Default is supported)
  ///
  /// Examples:
  /// ```dart
  /// // Without settings
  /// final configManager = ConfigManager(
  ///   defaultConfig: QuizConfig(quizId: 'my_quiz'),
  /// );
  ///
  /// // With settings
  /// final configManager = ConfigManager(
  ///   defaultConfig: QuizConfig(quizId: 'my_quiz'),
  ///   getSettings: () => {
  ///     'soundEnabled': settingsService.currentSettings.soundEnabled,
  ///     'hapticEnabled': settingsService.currentSettings.hapticEnabled,
  ///     'showAnswerFeedback': settingsService.currentSettings.showAnswerFeedback,
  ///   },
  /// );
  ///
  /// // Get config with settings applied
  /// final config = await configManager.getConfig(
  ///   source: ConfigSource.defaultOnly(),
  /// );
  /// ```
  Future<QuizConfig> getConfig({required ConfigSource source}) async {
    // 1. Get base config from source
    final baseConfig = switch (source) {
      DefaultSource() => defaultConfig,
    };

    // 2. Apply user settings if available
    if (getSettings != null) {
      final settings = getSettings!();

      // Create UI behavior config from settings
      final uiBehaviorConfig = UIBehaviorConfig(
        playSounds: settings['soundEnabled'] ?? true,
        hapticFeedback: settings['hapticEnabled'] ?? true,
        showAnswerFeedback: settings['showAnswerFeedback'] ?? true,
        // Preserve other UI behavior settings from base config
        answerFeedbackDuration: baseConfig.uiBehaviorConfig.answerFeedbackDuration,
        showExitConfirmation: baseConfig.uiBehaviorConfig.showExitConfirmation,
      );

      // Return config with settings applied
      return baseConfig.copyWith(uiBehaviorConfig: uiBehaviorConfig);
    }

    return baseConfig;
  }
}
