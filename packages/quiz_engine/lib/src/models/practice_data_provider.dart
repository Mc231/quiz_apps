import 'package:flutter/widgets.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

/// Data for displaying the practice tab.
///
/// Contains both the questions needing practice and their converted
/// form ready for quiz display.
class PracticeTabData {
  /// Creates [PracticeTabData].
  const PracticeTabData({
    required this.practiceQuestions,
    required this.questions,
  });

  /// The raw practice questions with metadata (wrong count, dates, etc.).
  final List<PracticeQuestion> practiceQuestions;

  /// The questions converted to quiz format for display.
  final List<QuestionEntry> questions;

  /// Whether there are questions to practice.
  bool get hasQuestions => practiceQuestions.isNotEmpty;

  /// The number of questions to practice.
  int get questionCount => practiceQuestions.length;

  /// Creates empty practice tab data.
  factory PracticeTabData.empty() => const PracticeTabData(
        practiceQuestions: [],
        questions: [],
      );
}

/// Interface for loading and managing practice data.
///
/// Apps implement this interface to integrate their practice system
/// with [QuizApp]. The provider handles:
/// - Loading questions that need practice
/// - Converting practice questions to quiz format
/// - Marking questions as practiced after completion
///
/// ## Example
///
/// ```dart
/// class MyPracticeDataProvider implements PracticeDataProvider {
///   final PracticeProgressRepository _repository;
///   final MyQuestionLoader _loader;
///
///   @override
///   Future<PracticeTabData> loadPracticeData(BuildContext context) async {
///     final practiceQuestions = await _repository.getQuestionsNeedingPractice();
///     final questions = await _convertToQuestions(context, practiceQuestions);
///     return PracticeTabData(
///       practiceQuestions: practiceQuestions,
///       questions: questions,
///     );
///   }
///
///   @override
///   Future<void> onPracticeSessionCompleted(
///     List<String> correctQuestionIds,
///   ) async {
///     await _repository.markQuestionsAsPracticed(correctQuestionIds);
///   }
///
///   @override
///   Future<void> updatePracticeProgress(
///     QuizSession session,
///     List<QuestionAnswer> wrongAnswers,
///   ) async {
///     await _repository.updatePracticeProgressFromSession(session, wrongAnswers);
///   }
/// }
/// ```
abstract class PracticeDataProvider {
  /// Creates a [PracticeDataProvider].
  const PracticeDataProvider();

  /// Loads practice data for the Practice tab.
  ///
  /// Called when the Practice tab is displayed or needs to be refreshed.
  /// Returns practice questions with their quiz-ready counterparts.
  ///
  /// [context] is provided for localization of question content.
  Future<PracticeTabData> loadPracticeData(BuildContext context);

  /// Called when a practice session completes.
  ///
  /// This method is invoked by [QuizApp] after a practice quiz finishes.
  /// Implementations should mark the correctly answered questions as
  /// practiced, so they no longer appear in the practice list (unless
  /// answered wrong again in a regular quiz).
  ///
  /// [correctQuestionIds] - Question IDs that were answered correctly
  /// during this practice session.
  Future<void> onPracticeSessionCompleted(List<String> correctQuestionIds);

  /// Updates practice progress after a regular quiz session completes.
  ///
  /// This method is called by [QuizApp] after any regular quiz finishes.
  /// It should record wrong answers in the practice progress system.
  ///
  /// [session] - The completed quiz session.
  /// [wrongAnswers] - List of questions that were answered incorrectly.
  Future<void> updatePracticeProgress(
    QuizSession session,
    List<QuestionAnswer> wrongAnswers,
  );

  /// Gets the current count of questions needing practice.
  ///
  /// Used for displaying a badge on the Practice tab.
  Future<int> getPracticeQuestionCount();
}
