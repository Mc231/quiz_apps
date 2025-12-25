import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';

/// Widget displayed when there are no questions to practice.
///
/// Shows an encouraging message and optionally a button to start a quiz.
class PracticeEmptyState extends StatelessWidget {
  /// Creates a [PracticeEmptyState].
  const PracticeEmptyState({
    super.key,
    this.onStartQuiz,
  });

  /// Called when the user taps the "Start a Quiz" button.
  ///
  /// If null, the button is hidden.
  final VoidCallback? onStartQuiz;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              l10n.practiceEmptyTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              l10n.practiceEmptyMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Start Quiz button
            if (onStartQuiz != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onStartQuiz,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.practiceStartQuiz),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
