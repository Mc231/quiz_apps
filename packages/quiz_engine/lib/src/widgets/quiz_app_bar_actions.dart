import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'adaptive_resource_panel.dart';
import 'game_resource_panel.dart';
import 'timer_display.dart';

/// A flexible widget for displaying action items in the quiz app bar.
///
/// This widget provides a container for multiple action items that can be
/// displayed in the app bar, such as game resources (lives, hints), timer, etc.
///
/// Supports:
/// - Game resource panel (lives, 50/50, skip) with adaptive placement
/// - Timer display (question timer, total timer)
///
/// The game resources use [AdaptiveResourcePanel] which only shows in the
/// AppBar when the screen is in landscape mode or on tablet/desktop.
class QuizAppBarActions extends StatelessWidget {
  /// The current quiz state containing progress and lives information
  final QuizState? state;

  /// The quiz configuration for determining which actions to show
  final QuizConfig? config;

  /// Game resource panel data (lives, 50/50, skip).
  /// If null, resources are not shown.
  final GameResourcePanelData? resourceData;

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
    this.resourceData,
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

    // Add game resource panel if applicable (adaptive - shows only on landscape/tablet/desktop)
    if (resourceData != null && resourceData!.hasResources) {
      actions.add(
        AdaptiveResourcePanel.forAppBar(data: resourceData!),
      );
    }

    // Add timer displays if applicable
    final timerWidgets = _buildTimerDisplays();
    actions.addAll(timerWidgets);

    // If no actions, return empty widget
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Return actions with spacing
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _intersperse(actions, const SizedBox(width: 12)),
      ),
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
