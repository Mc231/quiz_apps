import 'package:flutter/widgets.dart';
import 'package:quiz_engine/quiz_engine.dart' as engine;
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' as services;

import '../extensions/app_localizations_extension.dart';
import '../l10n/app_localizations.dart';
import '../models/continent.dart';
import '../models/country.dart';

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
      hintConfig: HintConfig.noHints(),
    );
  }

  /// Converts category ID to Continent enum.
  Continent _getContinentFromId(String id) {
    switch (id.toLowerCase()) {
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
