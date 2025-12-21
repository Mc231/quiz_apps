import '../../model/config/quiz_config.dart';
import 'config_source.dart';

/// Manages quiz configuration
///
/// For MVP, this simply returns the default configuration.
/// Future releases will add support for:
/// - Local storage caching
/// - Remote configuration (Firebase Remote Config, API, etc.)
class ConfigManager {
  const ConfigManager();

  /// Get configuration from specified source
  ///
  /// [source] - Where to load config from (currently only Default is supported)
  /// [defaultConfig] - The default configuration to use
  ///
  /// Examples:
  /// ```dart
  /// final configManager = ConfigManager();
  ///
  /// // Get default config
  /// final config = await configManager.getConfig(
  ///   source: ConfigSource.defaultOnly(),
  ///   defaultConfig: QuizConfig(quizId: 'my_quiz'),
  /// );
  ///
  /// // Alternative: Use const constructor directly
  /// final config = await configManager.getConfig(
  ///   source: const DefaultSource(),
  ///   defaultConfig: QuizConfig(quizId: 'my_quiz'),
  /// );
  /// ```
  Future<QuizConfig> getConfig({
    required ConfigSource source,
    required QuizConfig defaultConfig,
  }) async {
    return switch (source) {
      DefaultSource() => defaultConfig,
    };
  }
}