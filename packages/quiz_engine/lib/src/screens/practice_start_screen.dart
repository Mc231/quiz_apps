import 'package:flutter/material.dart';

import '../bloc/practice/practice_state.dart';
import '../l10n/quiz_localizations.dart';
import '../models/practice_data_provider.dart';

/// Screen displayed before starting a practice session.
///
/// Shows the number of questions to practice and a start button.
/// This widget does not include a Scaffold - it's designed to be
/// embedded in a tab or wrapped by a parent Scaffold.
class PracticeStartScreen extends StatelessWidget {
  /// Creates a [PracticeStartScreen].
  const PracticeStartScreen({
    super.key,
    required this.questionCount,
    required this.onStartPractice,
  });

  /// The number of questions to practice.
  final int questionCount;

  /// Called when the user taps the "Start Practice" button.
  final VoidCallback onStartPractice;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

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
              onPressed: onStartPractice,
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
