import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'lives_display.dart';
import 'timer_display.dart';

/// A flexible widget for displaying action items in the quiz app bar.
///
/// This widget provides a container for multiple action items that can be
/// displayed in the app bar, such as lives, timer, hints counter, etc.
///
/// Currently supports:
/// - Lives display (when lives mode is enabled)
///
/// Future additions can include:
/// - Timer display
/// - Hints counter
/// - Score display
/// - Pause button
class QuizAppBarActions extends StatelessWidget {
  /// The current quiz state containing progress and lives information
  final QuizState? state;

  /// The quiz configuration for determining which actions to show
  final QuizConfig? config;

  /// Color for the lives icons
  final Color livesColor;

  /// Color for empty/lost lives
  final Color lostLivesColor;

  /// Color for the timer when time is normal
  final Color timerNormalColor;

  /// Color for the timer when time is running low
  final Color timerWarningColor;

  /// Color for the timer when time is critical
  final Color timerCriticalColor;

  const QuizAppBarActions({
    super.key,
    this.state,
    this.config,
    this.livesColor = Colors.red,
    this.lostLivesColor = Colors.grey,
    this.timerNormalColor = Colors.blue,
    this.timerWarningColor = Colors.orange,
    this.timerCriticalColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show anything if state is not available or is loading
    if (state == null || state is LoadingState) {
      return const SizedBox.shrink();
    }

    final actions = <Widget>[];

    // Add lives display if applicable
    final livesWidget = _buildLivesDisplay();
    if (livesWidget != null) {
      actions.add(livesWidget);
    }

    // Add timer displays if applicable
    final timerWidgets = _buildTimerDisplays();
    actions.addAll(timerWidgets);

    // Future: Add hints counter
    // if (config?.hintConfig.initialHints.isNotEmpty == true) {
    //   actions.add(_buildHintsDisplay());
    // }

    // If no actions, return empty widget
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Return actions with spacing
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _intersperse(actions, const SizedBox(width: 16)),
      ),
    );
  }

  /// Builds the lives display widget if lives tracking is enabled
  Widget? _buildLivesDisplay() {
    int? remainingLives;
    int? totalLives = config?.modeConfig.lives;

    // Extract remaining lives from state
    if (state is QuestionState) {
      remainingLives = (state as QuestionState).remainingLives;
    } else if (state is AnswerFeedbackState) {
      remainingLives = (state as AnswerFeedbackState).remainingLives;
    }

    // Only show if lives are tracked
    if (remainingLives == null || totalLives == null) {
      return null;
    }

    return LivesDisplay(
      remainingLives: remainingLives,
      totalLives: totalLives,
      filledColor: livesColor,
      emptyColor: lostLivesColor,
    );
  }

  /// Builds timer display widgets if timer tracking is enabled
  List<Widget> _buildTimerDisplays() {
    final widgets = <Widget>[];
    int? questionTimeRemaining;
    int? totalTimeRemaining;

    // Extract timer values from state
    if (state is QuestionState) {
      final questionState = state as QuestionState;
      questionTimeRemaining = questionState.questionTimeRemaining;
      totalTimeRemaining = questionState.totalTimeRemaining;
    } else if (state is AnswerFeedbackState) {
      final feedbackState = state as AnswerFeedbackState;
      questionTimeRemaining = feedbackState.questionTimeRemaining;
      totalTimeRemaining = feedbackState.totalTimeRemaining;
    }

    // Add question timer if active
    if (questionTimeRemaining != null) {
      widgets.add(
        TimerDisplay(
          questionTimeRemaining: questionTimeRemaining,
          showQuestionTimer: true,
          showTotalTimer: false,
          normalColor: timerNormalColor,
          warningColor: timerWarningColor,
          criticalColor: timerCriticalColor,
        ),
      );
    }

    // Add total timer if active
    if (totalTimeRemaining != null) {
      widgets.add(
        TimerDisplay(
          totalTimeRemaining: totalTimeRemaining,
          showQuestionTimer: false,
          showTotalTimer: true,
          normalColor: timerNormalColor,
          warningColor: timerWarningColor,
          criticalColor: timerCriticalColor,
          timerIcon: Icons.hourglass_bottom, // Different icon for total timer
        ),
      );
    }

    return widgets;
  }

  /// Helper method to intersperse widgets with a separator
  List<Widget> _intersperse(List<Widget> widgets, Widget separator) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}