import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import 'practice_state.dart';
import '../l10n/quiz_localizations.dart';
import '../models/practice_data_provider.dart';
import '../services/quiz_services_context.dart';

/// Screen displayed before starting a practice session.
///
/// Shows the number of questions to practice and a start button.
/// This widget does not include a Scaffold - it's designed to be
/// embedded in a tab or wrapped by a parent Scaffold.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class PracticeStartScreen extends StatelessWidget {
  /// Creates a [PracticeStartScreen].
  const PracticeStartScreen({
    super.key,
    required this.questionCount,
    required this.onStartPractice,
    this.categoryId,
    this.categoryName,
  });

  /// The number of questions to practice.
  final int questionCount;

  /// Called when the user taps the "Start Practice" button.
  final VoidCallback onStartPractice;

  /// Category ID for analytics.
  final String? categoryId;

  /// Category name for analytics.
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);
    final analyticsService = context.screenAnalyticsService;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Question count
                  Text(
                    l10n.practiceQuestionCount(questionCount),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    l10n.practiceDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Start Practice button
            FilledButton.icon(
              onPressed: () {
                // Log practice started event
                analyticsService.logEvent(
                  ScreenViewEvent.practice(
                    categoryId: categoryId ?? 'unknown',
                    categoryName: categoryName ?? 'Practice',
                  ),
                );
                onStartPractice();
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.startPractice),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stateless content widget for practice start screen.
///
/// This widget receives BLoC state directly, making it suitable for use
/// with [PracticeBuilder].
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
///
/// Example:
/// ```dart
/// PracticeBuilder(
///   bloc: practiceBloc,
///   readyBuilder: (context, state) => PracticeStartContent(
///     state: state,
///     onStartPractice: () => startPracticeQuiz(state.data),
///   ),
///   completeBuilder: (context, state) => PracticeCompleteContent(...),
/// )
/// ```
class PracticeStartContent extends StatelessWidget {
  /// Creates a [PracticeStartContent].
  const PracticeStartContent({
    super.key,
    required this.state,
    required this.onStartPractice,
  });

  /// The practice ready state from BLoC.
  final PracticeReady state;

  /// Called when the user taps the "Start Practice" button.
  final VoidCallback onStartPractice;

  /// Convenience getter for the practice data.
  PracticeTabData get data => state.data;

  @override
  Widget build(BuildContext context) {
    return PracticeStartScreen(
      questionCount: state.questionCount,
      onStartPractice: onStartPractice,
    );
  }
}
