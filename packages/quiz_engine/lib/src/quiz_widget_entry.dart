import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'theme/quiz_theme_data.dart';

/// Contains text strings used in the quiz UI.
///
/// This class centralizes all user-facing text strings to enable easy localization.
/// Apps must provide all text strings explicitly - no defaults are provided.
class QuizTexts {
  /// The title of the quiz.
  final String title;

  /// Game over text displayed when quiz ends.
  final String gameOverText;

  // Exit Confirmation Dialog
  /// Title of the exit confirmation dialog.
  final String exitDialogTitle;

  /// Message shown in the exit confirmation dialog.
  final String exitDialogMessage;

  /// Text for the confirm/yes button in exit dialog.
  final String exitDialogConfirm;

  /// Text for the cancel/no button in exit dialog.
  final String exitDialogCancel;

  // Answer Feedback
  /// Text shown when answer is correct.
  final String correctFeedback;

  /// Text shown when answer is incorrect.
  final String incorrectFeedback;

  // Hints
  /// Label for the 50/50 hint button.
  final String hint5050Label;

  /// Label for the skip hint button.
  final String hintSkipLabel;

  // Timer
  /// Suffix for seconds in timer display (e.g., "s" in "30s").
  final String timerSecondsSuffix;

  // Error Messages
  /// Error message shown when video fails to load.
  final String videoLoadError;

  const QuizTexts({
    required this.title,
    required this.gameOverText,
    required this.exitDialogTitle,
    required this.exitDialogMessage,
    required this.exitDialogConfirm,
    required this.exitDialogCancel,
    required this.correctFeedback,
    required this.incorrectFeedback,
    required this.hint5050Label,
    required this.hintSkipLabel,
    required this.timerSecondsSuffix,
    required this.videoLoadError,
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

  /// Theme data for quiz UI customization.
  final QuizThemeData themeData;

  /// Creates a `QuizWidgetEntry` with the specified configuration.
  ///
  /// [texts] - Text strings for quiz UI
  /// [dataProvider] - Function to fetch quiz data
  /// [defaultConfig] - Default quiz configuration (used to construct ConfigManager)
  /// [themeData] - Theme customization (defaults to QuizThemeData())
  QuizWidgetEntry({
    required this.texts,
    required this.dataProvider,
    required QuizConfig defaultConfig,
    this.themeData = const QuizThemeData(),
  }) : configManager = ConfigManager(defaultConfig: defaultConfig);
}
