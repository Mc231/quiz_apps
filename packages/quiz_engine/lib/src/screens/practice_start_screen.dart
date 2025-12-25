import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';

/// Screen displayed before starting a practice session.
///
/// Shows the number of questions to practice and a start button.
class PracticeStartScreen extends StatelessWidget {
  /// Creates a [PracticeStartScreen].
  const PracticeStartScreen({
    super.key,
    required this.questionCount,
    required this.onStartPractice,
    this.onBack,
  });

  /// The number of questions to practice.
  final int questionCount;

  /// Called when the user taps the "Start Practice" button.
  final VoidCallback onStartPractice;

  /// Called when the user wants to go back.
  ///
  /// If null, the back button is hidden.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
        title: Text(l10n.practiceStartTitle),
      ),
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
                    // Practice icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        size: 56,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 32),

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
      ),
    );
  }
}
