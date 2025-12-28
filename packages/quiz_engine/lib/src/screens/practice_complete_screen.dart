import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import 'practice_state.dart';
import '../l10n/quiz_localizations.dart';
import '../services/quiz_services_context.dart';

/// Screen displayed when a practice session is complete.
///
/// Shows the number of correct answers and questions needing more practice.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class PracticeCompleteScreen extends StatefulWidget {
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
  State<PracticeCompleteScreen> createState() => _PracticeCompleteScreenState();
}

class _PracticeCompleteScreenState extends State<PracticeCompleteScreen> {
  // Service accessor via context
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  bool _screenViewLogged = false;

  void _logScreenView() {
    final scorePercentage = widget.totalCount > 0
        ? (widget.correctCount / widget.totalCount * 100)
        : 0.0;

    _analyticsService.logEvent(
      ScreenViewEvent.custom(
        name: 'practice_complete',
        className: 'PracticeCompleteScreen',
        additionalParams: {
          'correct_count': widget.correctCount,
          'need_more_practice_count': widget.needMorePracticeCount,
          'total_count': widget.totalCount,
          'score_percentage': scorePercentage,
          'is_all_correct': widget.isAllCorrect,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Log screen view on first build (deferred from initState for context access)
    if (!_screenViewLogged) {
      _screenViewLogged = true;
      _logScreenView();
    }

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
                      text: l10n.practiceCorrectCount(widget.correctCount),
                    ),
                    const SizedBox(height: 12),
                    if (widget.needMorePracticeCount > 0)
                      _buildResultRow(
                        context,
                        icon: Icons.refresh,
                        iconColor: theme.colorScheme.error,
                        text: l10n.practiceNeedMorePractice(widget.needMorePracticeCount),
                      ),
                    const SizedBox(height: 24),

                    // Encouragement message
                    Text(
                      widget.isAllCorrect
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
                onPressed: widget.onDone,
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

/// A stateless content widget for practice complete screen.
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
///   readyBuilder: (context, state) => PracticeStartContent(...),
///   completeBuilder: (context, state) => PracticeCompleteContent(
///     state: state,
///     onDone: () => bloc.add(PracticeEvent.reset()),
///   ),
/// )
/// ```
class PracticeCompleteContent extends StatelessWidget {
  /// Creates a [PracticeCompleteContent].
  const PracticeCompleteContent({
    super.key,
    required this.state,
    required this.onDone,
  });

  /// The practice complete state from BLoC.
  final PracticeComplete state;

  /// Called when the user taps the "Done" button.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return PracticeCompleteScreen(
      correctCount: state.correctCount,
      needMorePracticeCount: state.needMorePracticeCount,
      onDone: onDone,
    );
  }
}
