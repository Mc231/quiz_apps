import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'theme/quiz_theme_data.dart';

/// Contains text strings used in the quiz UI.
class QuizTexts {
  /// The title of the quiz.
  final String title;

  /// Game over text displayed when quiz ends.
  final String gameOverText;

  const QuizTexts({
    required this.title,
    required this.gameOverText,
  });
}

/// Configuration entry for initializing a quiz widget.
///
/// This class organizes all necessary data and configuration for a quiz:
/// - UI texts (title, game over message)
/// - Data provider function
/// - Quiz configuration (auto-constructs ConfigManager)
/// - Optional theme customization
class QuizWidgetEntry {
  /// Text strings for the quiz UI.
  final QuizTexts texts;

  /// The function that provides quiz data.
  final Future<List<QuestionEntry>> Function() dataProvider;

  /// Configuration manager for loading quiz configuration.
  final ConfigManager configManager;

  /// Theme data for quiz UI customization (optional).
  final QuizThemeData? themeData;

  /// Creates a `QuizWidgetEntry` with the specified configuration.
  ///
  /// [texts] - Text strings for quiz UI
  /// [dataProvider] - Function to fetch quiz data
  /// [defaultConfig] - Default quiz configuration (used to construct ConfigManager)
  /// [themeData] - Optional theme customization
  QuizWidgetEntry({
    required this.texts,
    required this.dataProvider,
    required QuizConfig defaultConfig,
    this.themeData,
  }) : configManager = ConfigManager(defaultConfig: defaultConfig);
}