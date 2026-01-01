import 'package:flutter/material.dart';
import 'package:quiz_engine/src/quiz/quiz_screen.dart';
import 'package:quiz_engine/src/quiz_widget_entry.dart';
import 'package:quiz_engine/src/services/quiz_services_context.dart';
import 'package:quiz_engine/src/widgets/quiz_lifecycle_handler.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'bloc/bloc_provider.dart';

/// A reusable widget that encapsulates the quiz logic.
///
/// This widget initializes the `QuizBloc` and provides a quiz interface
/// for any dataset that matches the `QuestionEntry` model.
///
/// Automatically handles app lifecycle to pause/resume timers when
/// the app goes to background or returns to foreground.
///
/// Services are obtained from [QuizServicesProvider] via context.
/// The QuizScreen and QuizResultsScreen will use `context.screenAnalyticsService`.
///
/// Usage:
/// ```dart
/// QuizWidget(
///   quizEntry: QuizWidgetEntry(
///     title: "Flags Quiz",
///     dataProvider: () async => loadCountriesForContinent(Continent.europe),
///     configManager: configManager,
///     quizAnalyticsService: quizAnalyticsService,
///   ),
/// );
/// ```
class QuizWidget extends StatelessWidget {
  final QuizWidgetEntry quizEntry;

  const QuizWidget({super.key, required this.quizEntry});

  @override
  Widget build(BuildContext context) {
    // Get resourceManager from QuizServicesProvider if useResourceManager is true
    final resourceManager = quizEntry.useResourceManager
        ? context.maybeServices?.resourceManager
        : null;

    final bloc = QuizBloc(
      quizEntry.dataProvider,
      RandomItemPicker([]),
      configManager: quizEntry.configManager,
      storageService: quizEntry.storageService,
      analyticsService: quizEntry.quizAnalyticsService,
      quizName: quizEntry.title,
      categoryId: quizEntry.categoryId,
      categoryName: quizEntry.categoryName,
      onQuizCompleted: quizEntry.onQuizCompleted,
      filter: quizEntry.filter,
      resourceManager: resourceManager,
      useResourceManager: quizEntry.useResourceManager,
    );

    return BlocProvider(
      bloc: bloc,
      child: QuizLifecycleHandler(
        child: QuizScreen(
          title: quizEntry.title,
          themeData: quizEntry.themeData,
          shareConfig: quizEntry.shareConfig,
        ),
      ),
    );
  }
}
