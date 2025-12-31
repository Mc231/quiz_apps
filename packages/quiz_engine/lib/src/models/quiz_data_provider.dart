import 'package:flutter/widgets.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import 'quiz_category.dart';

export 'package:quiz_engine_core/quiz_engine_core.dart'
    show QuizLayoutConfig, ImageAnswerSize;

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

  /// Creates layout configuration for the given category.
  ///
  /// Returns how questions and answers should be displayed in the quiz UI.
  /// By default, returns the category's layoutConfig.
  ///
  /// Override this method to customize layout based on context or
  /// to apply transformations to the category's layout.
  ///
  /// ## Layout Configuration Pattern
  ///
  /// There are two ways to configure layouts:
  ///
  /// ### 1. Static Layout (via category definition)
  ///
  /// Set the layout directly on the category when defining it:
  ///
  /// ```dart
  /// final category = QuizCategory(
  ///   id: 'flags_reverse',
  ///   title: (context) => 'Find the Flag',
  ///   showAnswerFeedback: true,
  ///   layoutConfig: QuizLayoutConfig.textQuestionImageAnswers(
  ///     questionTemplate: 'Select the flag of {name}',
  ///   ),
  /// );
  /// ```
  ///
  /// ### 2. Dynamic Layout (via data provider)
  ///
  /// Override this method when layout depends on runtime context:
  ///
  /// ```dart
  /// @override
  /// QuizLayoutConfig? createLayoutConfig(
  ///   BuildContext context,
  ///   QuizCategory category,
  /// ) {
  ///   final l10n = AppLocalizations.of(context)!;
  ///
  ///   // Use category's layout if specified
  ///   if (category.layoutConfig != null) {
  ///     // Apply localized template if text-image layout
  ///     if (category.layoutConfig is TextQuestionImageAnswersLayout) {
  ///       return QuizLayoutConfig.textQuestionImageAnswers(
  ///         questionTemplate: l10n.selectFlagOf,
  ///       );
  ///     }
  ///     return category.layoutConfig;
  ///   }
  ///
  ///   // Default to image-text layout
  ///   return QuizLayoutConfig.imageQuestionTextAnswers();
  /// }
  /// ```
  ///
  /// [context] - BuildContext for localization access
  /// [category] - The selected quiz category
  QuizLayoutConfig? createLayoutConfig(
    BuildContext context,
    QuizCategory category,
  ) {
    return category.layoutConfig;
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
/// );
/// ```
class CallbackQuizDataProvider extends QuizDataProvider {
  /// Callback for loading questions.
  final Future<List<QuestionEntry>> Function(
    BuildContext context,
    QuizCategory category,
  ) loadQuestionsCallback;

  /// Optional callback for creating storage config.
  final StorageConfig? Function(BuildContext context, QuizCategory category)?
      createStorageConfigCallback;

  /// Optional callback for creating quiz config.
  final QuizConfig? Function(BuildContext context, QuizCategory category)?
      createQuizConfigCallback;

  /// Optional callback for creating layout config.
  final QuizLayoutConfig? Function(BuildContext context, QuizCategory category)?
      createLayoutConfigCallback;

  /// Creates a [CallbackQuizDataProvider].
  ///
  /// [loadQuestionsCallback] is required.
  /// Other callbacks are optional and will return null if not provided.
  const CallbackQuizDataProvider({
    required this.loadQuestionsCallback,
    this.createStorageConfigCallback,
    this.createQuizConfigCallback,
    this.createLayoutConfigCallback,
  });

  @override
  Future<List<QuestionEntry>> loadQuestions(
    BuildContext context,
    QuizCategory category,
  ) {
    return loadQuestionsCallback(context, category);
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

  @override
  QuizLayoutConfig? createLayoutConfig(
    BuildContext context,
    QuizCategory category,
  ) {
    return createLayoutConfigCallback?.call(context, category) ??
        category.layoutConfig;
  }
}
