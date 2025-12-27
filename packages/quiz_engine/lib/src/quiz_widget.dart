import 'package:flutter/material.dart';
import 'package:quiz_engine/src/quiz/quiz_screen.dart';
import 'package:quiz_engine/src/quiz_widget_entry.dart';
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
/// Usage:
/// ```dart
/// QuizWidget(
///   title: "Flags Quiz",
///   dataProvider: () async => loadCountriesForContinent(Continent.europe),
/// );
/// ```
class QuizWidget extends StatelessWidget {
  final QuizWidgetEntry quizEntry;

  const QuizWidget({super.key, required this.quizEntry});

  @override
  Widget build(BuildContext context) {
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
    );

    return BlocProvider(
      bloc: bloc,
      child: QuizLifecycleHandler(
        analyticsService: quizEntry.screenAnalyticsService,
        child: QuizScreen(
          title: quizEntry.title,
          themeData: quizEntry.themeData,
          screenAnalyticsService: quizEntry.screenAnalyticsService,
        ),
      ),
    );
  }
}
