import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';

/// Screen displayed when a practice session is complete.
///
/// Shows the number of correct answers and questions needing more practice.
class PracticeCompleteScreen extends StatelessWidget {
  /// Creates a [PracticeCompleteScreen].
  const PracticeCompleteScreen({
    super.key,
    required this.correctCount,
    required this.needMorePracticeCount,
    required this.onDone,
  });

  /// The number of questions answered correctly.
  final int correctCount;

  /// The number of questions that still need more practice.
  final int needMorePracticeCount;

  /// Called when the user taps the "Done" button.
  final VoidCallback onDone;

  /// Total number of questions in the practice session.
  int get totalCount => correctCount + needMorePracticeCount;

  /// Whether all questions were answered correctly.
  bool get isAllCorrect => needMorePracticeCount == 0;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      l10n.practiceCompleteTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Results
                    _buildResultRow(
                      context,
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      text: l10n.practiceCorrectCount(correctCount),
                    ),
                    const SizedBox(height: 12),
                    if (needMorePracticeCount > 0)
                      _buildResultRow(
                        context,
                        icon: Icons.refresh,
                        iconColor: theme.colorScheme.error,
                        text: l10n.practiceNeedMorePractice(needMorePracticeCount),
                      ),
                    const SizedBox(height: 24),

                    // Encouragement message
                    Text(
                      isAllCorrect
                          ? l10n.practiceAllCorrect
                          : l10n.practiceKeepGoing,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Done button
              FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium,
                ),
                child: Text(l10n.practiceDone),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
