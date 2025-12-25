import 'package:quiz_engine_core/quiz_engine_core.dart';

import 'theme/quiz_theme_data.dart';

/// Configuration entry for initializing a quiz widget.
///
/// This class organizes all necessary data and configuration for a quiz:
/// - Title for the quiz
/// - Data provider function
/// - Quiz configuration (via ConfigManager or defaultConfig)
/// - Optional theme customization
/// - Optional storage service for persisting quiz sessions
/// - Optional quiz completion callback for achievements/analytics
/// - Optional filter for question selection
///
/// All localized UI strings (exit dialog, feedback, hints, etc.) are now
/// provided by [QuizLocalizations] from the quiz_engine l10n system.
class QuizWidgetEntry {
  /// The title of the quiz (e.g., "European Flags Quiz").
  ///
  /// This is typically provided by the category via `category.title(context)`.
  final String title;

  /// The function that provides quiz data.
  final Future<List<QuestionEntry>> Function() dataProvider;

  /// Configuration manager for loading quiz configuration.
  final ConfigManager configManager;

  /// Theme data for quiz UI customization.
  final QuizThemeData themeData;

  /// Optional storage service for persisting quiz sessions.
  final QuizStorageService? storageService;

  /// Optional callback invoked when the quiz is completed.
  ///
  /// Use this to integrate with achievement systems, analytics,
  /// or any post-quiz processing. The callback receives the complete
  /// [QuizResults] with all session data.
  final void Function(QuizResults results)? onQuizCompleted;

  /// Optional filter to apply when loading questions.
  ///
  /// When provided, only questions that pass this filter will be asked.
  /// All questions are still available for generating wrong options.
  /// This is useful for practice mode where you want to practice specific
  /// questions but need all questions for option generation.
  final bool Function(QuestionEntry)? filter;

  /// Creates a `QuizWidgetEntry` with a ConfigManager.
  ///
  /// [title] - Title for the quiz UI
  /// [dataProvider] - Function to fetch quiz data
  /// [configManager] - Configuration manager with settings integration
  /// [themeData] - Theme customization (defaults to QuizThemeData())
  /// [storageService] - Optional storage service for persisting sessions
  /// [onQuizCompleted] - Optional callback for achievement/analytics integration
  /// [filter] - Optional filter for question selection
  QuizWidgetEntry({
    required this.title,
    required this.dataProvider,
    required this.configManager,
    this.themeData = const QuizThemeData(),
    this.storageService,
    this.onQuizCompleted,
    this.filter,
  });

  /// Creates a `QuizWidgetEntry` with a default configuration.
  ///
  /// This is a convenience constructor that creates a ConfigManager
  /// without settings integration.
  ///
  /// [title] - Title for the quiz UI
  /// [dataProvider] - Function to fetch quiz data
  /// [defaultConfig] - Default quiz configuration
  /// [themeData] - Theme customization (defaults to QuizThemeData())
  /// [storageService] - Optional storage service for persisting sessions
  /// [onQuizCompleted] - Optional callback for achievement/analytics integration
  /// [filter] - Optional filter for question selection
  QuizWidgetEntry.withDefaultConfig({
    required this.title,
    required this.dataProvider,
    required QuizConfig defaultConfig,
    this.themeData = const QuizThemeData(),
    this.storageService,
    this.onQuizCompleted,
    this.filter,
  }) : configManager = ConfigManager(defaultConfig: defaultConfig);
}
