import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' as services;

import '../extensions/app_localizations_extension.dart';
import '../l10n/app_localizations.dart';
import '../models/continent.dart';
import '../models/country.dart';

/// Data provider for loading daily challenge questions.
///
/// Loads country questions based on the daily challenge's category,
/// shuffles them, and limits to the question count.
class FlagsDailyChallengeDataProvider {
  /// Creates a [FlagsDailyChallengeDataProvider].
  const FlagsDailyChallengeDataProvider();

  /// Loads questions for a daily challenge.
  ///
  /// The [categoryId] determines which continent's flags to use.
  /// Questions are shuffled using the [seed] for consistent ordering
  /// across app restarts on the same day.
  /// The [count] limits the number of questions.
  Future<List<QuestionEntry>> loadQuestions(
    BuildContext context, {
    required String categoryId,
    required int seed,
    required int count,
  }) async {
    final appLocalizations = AppLocalizations.of(context)!;
    final continent = _getContinentFromId(categoryId);

    final provider = services.QuizDataProvider<Country>.standard(
      'assets/Countries.json',
      (data) => Country.fromJson(
        data,
        (key) => appLocalizations.resolveKey(key.toLowerCase()),
      ),
    );

    final countries = await provider.provide();

    // Filter by continent if not 'all'
    final filteredCountries = continent == Continent.all
        ? countries.toList()
        : countries.where((c) => c.continent == continent).toList();

    // Shuffle with seed for consistent ordering
    final random = Random(seed);
    filteredCountries.shuffle(random);

    // Take only the required count
    final selectedCountries = filteredCountries.take(count).toList();

    return selectedCountries.map((country) => country.toQuestionEntry).toList();
  }

  /// Creates quiz configuration for a daily challenge.
  ///
  /// Daily challenges use:
  /// - No hints (pure skill test)
  /// - Standard mode (no lives, answer feedback enabled)
  /// - Time bonus scoring for fast answers
  QuizConfig createQuizConfig({
    required String challengeId,
    int? timeLimitSeconds,
  }) {
    return QuizConfig(
      quizId: challengeId,
      // No hints for daily challenges - pure skill test
      hintConfig: const HintConfig.noHints(),
      // Standard mode with answer feedback
      modeConfig: QuizModeConfig.timed(
        answerFeedbackConfig: AnswerFeedbackConfig.always(),
        timePerQuestion: timeLimitSeconds ?? 30,
        allowSkip: false,
      ),
      // Bonus scoring for fast answers
      scoringStrategy: const TimedScoring(
        basePointsPerQuestion: 100,
        bonusPerSecondSaved: 5,
        timeThresholdSeconds: 30,
      ),
    );
  }

  /// Creates storage configuration for a daily challenge.
  StorageConfig createStorageConfig(String categoryId) {
    return StorageConfig(
      enabled: true,
      quizType: 'daily_challenge',
      quizName: 'Daily Challenge',
      quizCategory: categoryId,
    );
  }

  /// Gets the layout configuration for daily challenges.
  ///
  /// Uses image question with text answers (standard flags layout).
  QuizLayoutConfig createLayoutConfig() {
    return const ImageQuestionTextAnswersLayout();
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
