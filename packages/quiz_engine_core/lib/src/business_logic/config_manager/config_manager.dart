import '../../model/config/quiz_config.dart';
import 'config_source.dart';

/// Manages quiz configuration
///
/// For MVP, this simply returns the default configuration.
/// Future releases will add support for:
/// - Local storage caching
/// - Remote configuration (Firebase Remote Config, API, etc.)
class ConfigManager {
  /// The default configuration to use
  final QuizConfig defaultConfig;

  const ConfigManager({required this.defaultConfig});

  /// Get configuration from specified source
  ///
  /// [source] - Where to load config from (currently only Default is supported)
  ///
  /// Examples:
  /// ```dart
  /// final configManager = ConfigManager(
  ///   defaultConfig: QuizConfig(quizId: 'my_quiz'),
  /// );
  ///
  /// // Get default config
  /// final config = await configManager.getConfig(
  ///   source: ConfigSource.defaultOnly(),
  /// );
  ///
  /// // Alternative: Use const constructor directly
  /// final config = await configManager.getConfig(
  ///   source: const DefaultSource(),
  /// );
  /// ```
  Future<QuizConfig> getConfig({required ConfigSource source}) async {
    return switch (source) {
      DefaultSource() => defaultConfig,
    };
  }
}
