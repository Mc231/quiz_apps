import 'package:flutter/widgets.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' hide QuizDataProvider;
import 'package:shared_services/shared_services.dart' as services show QuizDataProvider;

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
    required SharedQuizDataProvider<Country> countryProvider,
  })  : _repository = repository,
        _countryProvider = countryProvider;

  final PracticeProgressRepository _repository;
  final SharedQuizDataProvider<Country> _countryProvider;

  /// Cached countries for efficient lookup.
  Map<String, Country>? _countriesCache;

  @override
  Future<PracticeTabData> loadPracticeData(BuildContext context) async {
    final practiceQuestions = await _repository.getQuestionsNeedingPractice();

    if (practiceQuestions.isEmpty) {
      return PracticeTabData.empty();
    }

    // Load all countries to convert practice questions
    final countries = await _loadCountriesMap(context);

    // Convert practice questions to quiz format
    final questions = <QuestionEntry>[];
    final validPracticeQuestions = <PracticeQuestion>[];

    for (final pq in practiceQuestions) {
      final country = countries[pq.questionId];
      if (country != null) {
        questions.add(country.toQuestionEntry);
        validPracticeQuestions.add(pq);
      }
      // Orphaned questions (removed from app) are silently skipped
    }

    return PracticeTabData(
      practiceQuestions: validPracticeQuestions,
      questions: questions,
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
  Future<Map<String, Country>> _loadCountriesMap(BuildContext context) async {
    if (_countriesCache != null) {
      return _countriesCache!;
    }

    final countries = await _countryProvider.provide();

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
  ///
  /// [resolveKey] is a function that resolves country codes to localized names.
  factory FlagsPracticeDataProvider.fromServiceLocator(
    String Function(String) resolveKey,
  ) {
    final repository = sl.get<PracticeProgressRepository>();
    final countryProvider = SharedQuizDataProvider<Country>.standard(
      'assets/Countries.json',
      (data) => Country.fromJson(data, resolveKey),
    );

    return FlagsPracticeDataProvider(
      repository: repository,
      countryProvider: countryProvider,
    );
  }
}
