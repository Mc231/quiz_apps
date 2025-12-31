import 'package:flutter/widgets.dart';
import 'package:quiz_engine/quiz_engine.dart' as engine;
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' as services;

import '../extensions/app_localizations_extension.dart';
import '../l10n/app_localizations.dart';
import '../models/continent.dart';
import '../models/country.dart';

export 'package:quiz_engine_core/quiz_engine_core.dart'
    show
        QuizLayoutConfig,
        ImageQuestionTextAnswersLayout,
        TextQuestionImageAnswersLayout,
        TextQuestionTextAnswersLayout,
        MixedLayout;

/// Data provider for flags quiz.
///
/// Loads country questions and creates quiz configuration
/// for the flags quiz app.
class FlagsDataProvider extends engine.QuizDataProvider {
  /// Creates a [FlagsDataProvider].
  const FlagsDataProvider();

  @override
  Future<List<QuestionEntry>> loadQuestions(
    BuildContext context,
    engine.QuizCategory category,
  ) async {
    final appLocalizations = AppLocalizations.of(context)!;
    final continent = _getContinentFromId(category.id);

    final provider = services.QuizDataProvider<Country>.standard(
      'assets/Countries.json',
      (data) => Country.fromJson(
        data,
        (key) => appLocalizations.resolveKey(key.toLowerCase()),
      ),
    );

    final countries = await provider.provide();

    final filteredCountries = continent == Continent.all
        ? countries
        : countries.where((country) => country.continent == continent).toList();

    return filteredCountries.map((country) => country.toQuestionEntry).toList();
  }

  @override
  StorageConfig? createStorageConfig(
    BuildContext context,
    engine.QuizCategory category,
  ) {
    return StorageConfig(
      enabled: true,
      quizType: 'flags',
      quizName: category.title(context),
      quizCategory: category.id,
    );
  }

  @override
  QuizConfig? createQuizConfig(BuildContext context, engine.QuizCategory category) {
    return QuizConfig(
      quizId: category.id,
      // Enable only 50/50 and skip hints for Play tab
      hintConfig: const HintConfig(
        initialHints: {
          HintType.fiftyFifty: 3,
          HintType.skip: 2,
        },
      ),
      // Lives mode with 5 hearts and skip button enabled
      // showAnswerFeedback comes from the category
      modeConfig: QuizModeConfig.lives(
        showAnswerFeedback: category.showAnswerFeedback,
        lives: 5,
        allowSkip: true,
      ),
      // Use timed scoring: 100 base points + 5 points per second saved (30s threshold)
      scoringStrategy: const TimedScoring(
        basePointsPerQuestion: 100,
        bonusPerSecondSaved: 5,
        timeThresholdSeconds: 30,
      ),
    );
  }

  @override
  QuizLayoutConfig? createLayoutConfig(
    BuildContext context,
    engine.QuizCategory category,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final layoutConfig = category.layoutConfig;

    // If no layout config specified, use default (image question, text answers)
    if (layoutConfig == null) {
      return const ImageQuestionTextAnswersLayout();
    }

    // If it's a text-question-image-answers layout, apply localized template
    if (layoutConfig is TextQuestionImageAnswersLayout) {
      return TextQuestionImageAnswersLayout(
        imageSize: layoutConfig.imageSize,
        questionTemplate: l10n.whichFlagIs('{name}'),
      );
    }

    // If it's a mixed layout, apply localized templates to any text-image layouts
    if (layoutConfig is MixedLayout) {
      return MixedLayout(
        layouts: layoutConfig.layouts.map((layout) {
          if (layout is TextQuestionImageAnswersLayout) {
            return TextQuestionImageAnswersLayout(
              imageSize: layout.imageSize,
              questionTemplate: l10n.whichFlagIs('{name}'),
            );
          }
          return layout;
        }).toList(),
        strategy: layoutConfig.strategy,
      );
    }

    // Return as-is for other layouts
    return layoutConfig;
  }

  /// Converts category ID to Continent enum.
  ///
  /// Handles suffixed IDs like `eu_reverse` or `eu_mixed` by stripping
  /// the suffix before matching.
  Continent _getContinentFromId(String id) {
    // Strip layout mode suffix if present (e.g., "eu_reverse" -> "eu")
    final baseId = id.toLowerCase().split('_').first;

    switch (baseId) {
      case 'all':
        return Continent.all;
      case 'af':
        return Continent.af;
      case 'eu':
        return Continent.eu;
      case 'as':
        return Continent.as;
      case 'na':
        return Continent.na;
      case 'sa':
        return Continent.sa;
      case 'oc':
        return Continent.oc;
      default:
        return Continent.all;
    }
  }
}
