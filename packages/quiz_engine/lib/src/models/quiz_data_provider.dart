import 'package:flutter/widgets.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../quiz_widget_entry.dart';
import 'quiz_category.dart';

/// Interface for loading quiz data for a category.
///
/// Apps implement this interface to provide questions and configuration
/// for each quiz category. The data provider is called when the user
/// selects a category to start a quiz.
///
/// Example:
/// ```dart
/// class FlagsDataProvider extends QuizDataProvider {
///   @override
///   Future<List<QuestionEntry>> loadQuestions(
///     BuildContext context,
///     QuizCategory category,
///   ) async {
///     final countries = loadCountriesForContinent(category.id);
///     return countries.map((c) => c.toQuestionEntry()).toList();
///   }
///
///   @override
///   QuizTexts createQuizTexts(BuildContext context, QuizCategory category) {
///     final l10n = AppLocalizations.of(context)!;
///     return QuizTexts(
///       title: category.title(context),
///       gameOverText: l10n.gameOver,
///       // ... other texts
///     );
///   }
/// }
/// ```
abstract class QuizDataProvider {
  /// Creates a [QuizDataProvider].
  const QuizDataProvider();

  /// Loads questions for the given category.
  ///
  /// Called when the user starts a quiz for [category].
  /// Returns a list of [QuestionEntry] objects to be used in the quiz.
  ///
  /// [context] - BuildContext for localization access
  /// [category] - The selected quiz category
  Future<List<QuestionEntry>> loadQuestions(
    BuildContext context,
    QuizCategory category,
  );

  /// Creates quiz texts for the given category.
  ///
  /// Returns localized text strings for the quiz UI.
  /// If null, the QuizApp will use default texts from engine localizations.
  ///
  /// [context] - BuildContext for localization access
  /// [category] - The selected quiz category
  QuizTexts? createQuizTexts(BuildContext context, QuizCategory category);

  /// Creates storage configuration for the given category.
  ///
  /// Returns storage settings for persisting quiz sessions.
  /// If null, storage will be disabled for this category.
  ///
  /// [context] - BuildContext for localization access
  /// [category] - The selected quiz category
  StorageConfig? createStorageConfig(
    BuildContext context,
    QuizCategory category,
  );

  /// Creates quiz configuration for the given category.
  ///
  /// Returns the full quiz configuration including mode, scoring, hints, etc.
  /// If null, the category's config or default config will be used.
  ///
  /// [context] - BuildContext for localization access
  /// [category] - The selected quiz category
  QuizConfig? createQuizConfig(BuildContext context, QuizCategory category) {
    return category.config;
  }
}

/// Callback-based implementation of [QuizDataProvider].
///
/// Allows creating a data provider using callbacks instead of subclassing.
/// Useful for simple cases where full class hierarchy is not needed.
///
/// Example:
/// ```dart
/// final provider = CallbackQuizDataProvider(
///   loadQuestionsCallback: (context, category) async {
///     return loadQuestionsForCategory(category.id);
///   },
///   createQuizTextsCallback: (context, category) {
///     return QuizTexts(title: category.title(context), ...);
///   },
/// );
/// ```
class CallbackQuizDataProvider extends QuizDataProvider {
  /// Callback for loading questions.
  final Future<List<QuestionEntry>> Function(
    BuildContext context,
    QuizCategory category,
  ) loadQuestionsCallback;

  /// Optional callback for creating quiz texts.
  final QuizTexts? Function(BuildContext context, QuizCategory category)?
      createQuizTextsCallback;

  /// Optional callback for creating storage config.
  final StorageConfig? Function(BuildContext context, QuizCategory category)?
      createStorageConfigCallback;

  /// Optional callback for creating quiz config.
  final QuizConfig? Function(BuildContext context, QuizCategory category)?
      createQuizConfigCallback;

  /// Creates a [CallbackQuizDataProvider].
  ///
  /// [loadQuestionsCallback] is required.
  /// Other callbacks are optional and will return null if not provided.
  const CallbackQuizDataProvider({
    required this.loadQuestionsCallback,
    this.createQuizTextsCallback,
    this.createStorageConfigCallback,
    this.createQuizConfigCallback,
  });

  @override
  Future<List<QuestionEntry>> loadQuestions(
    BuildContext context,
    QuizCategory category,
  ) {
    return loadQuestionsCallback(context, category);
  }

  @override
  QuizTexts? createQuizTexts(BuildContext context, QuizCategory category) {
    return createQuizTextsCallback?.call(context, category);
  }

  @override
  StorageConfig? createStorageConfig(
    BuildContext context,
    QuizCategory category,
  ) {
    return createStorageConfigCallback?.call(context, category);
  }

  @override
  QuizConfig? createQuizConfig(BuildContext context, QuizCategory category) {
    return createQuizConfigCallback?.call(context, category) ?? category.config;
  }
}
