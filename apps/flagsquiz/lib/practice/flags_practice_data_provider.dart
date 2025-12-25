import 'package:flutter/widgets.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart' hide QuizDataProvider;
import 'package:shared_services/shared_services.dart' as services show QuizDataProvider;

import '../extensions/app_localizations_extension.dart';
import '../l10n/app_localizations.dart';
import '../models/country.dart';

/// Type alias for shared services QuizDataProvider.
typedef SharedQuizDataProvider<T> = services.QuizDataProvider<T>;

/// Practice data provider for flags quiz.
///
/// Loads questions that the user got wrong and provides them
/// for practice sessions.
class FlagsPracticeDataProvider extends PracticeDataProvider {
  /// Creates a [FlagsPracticeDataProvider].
  FlagsPracticeDataProvider({
    required PracticeProgressRepository repository,
  }) : _repository = repository;

  final PracticeProgressRepository _repository;

  /// Cached countries for efficient lookup.
  /// Note: Cache is per-locale, cleared when locale changes.
  Map<String, Country>? _countriesCache;

  @override
  Future<PracticeTabData> loadPracticeData(BuildContext context) async {
    final practiceQuestions = await _repository.getQuestionsNeedingPractice();

    if (practiceQuestions.isEmpty) {
      return PracticeTabData.empty();
    }

    // Load all countries with proper localization
    final countries = await _loadCountriesMap(context);

    // Build set of practice question IDs and validate they exist
    final practiceQuestionIds = <String>{};
    final validPracticeQuestions = <PracticeQuestion>[];

    for (final pq in practiceQuestions) {
      if (countries.containsKey(pq.questionId)) {
        practiceQuestionIds.add(pq.questionId);
        validPracticeQuestions.add(pq);
      }
      // Orphaned questions (removed from app) are silently skipped
    }

    // Convert ALL countries to quiz format for option generation
    final allQuestions = countries.values
        .map((country) => country.toQuestionEntry)
        .toList();

    return PracticeTabData(
      practiceQuestions: validPracticeQuestions,
      allQuestions: allQuestions,
      practiceQuestionIds: practiceQuestionIds,
    );
  }

  @override
  Future<void> onPracticeSessionCompleted(
    List<String> correctQuestionIds,
  ) async {
    await _repository.markQuestionsAsPracticed(correctQuestionIds);
  }

  @override
  Future<void> updatePracticeProgress(
    QuizSession session,
    List<QuestionAnswer> wrongAnswers,
  ) async {
    await _repository.updatePracticeProgressFromSession(session, wrongAnswers);
  }

  @override
  Future<int> getPracticeQuestionCount() async {
    return _repository.getPracticeQuestionCount();
  }

  /// Loads all countries and creates a map keyed by country code.
  ///
  /// Uses the app's localizations to get properly localized country names.
  Future<Map<String, Country>> _loadCountriesMap(BuildContext context) async {
    // Always reload to get current locale's names
    // (Cache could be stale if locale changed)
    final appLocalizations = AppLocalizations.of(context)!;

    final countryProvider = SharedQuizDataProvider<Country>.standard(
      'assets/Countries.json',
      (data) => Country.fromJson(
        data,
        (key) => appLocalizations.resolveKey(key.toLowerCase()),
      ),
    );

    final countries = await countryProvider.provide();

    _countriesCache = {
      for (final country in countries) country.code: country,
    };

    return _countriesCache!;
  }

  /// Clears the countries cache.
  ///
  /// Called when locale changes or when data needs to be refreshed.
  void clearCache() {
    _countriesCache = null;
  }

  /// Creates a [FlagsPracticeDataProvider] using the service locator.
  ///
  /// This factory requires the service locator to be initialized with:
  /// - [PracticeProgressRepository]
  factory FlagsPracticeDataProvider.fromServiceLocator() {
    return FlagsPracticeDataProvider(
      repository: sl.get<PracticeProgressRepository>(),
    );
  }
}
