import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'lives_display.dart';
import 'timer_display.dart';

/// A status bar widget that displays game status information below the app bar.
///
/// This widget provides a dedicated horizontal bar for displaying:
/// - Lives (when lives mode is enabled)
/// - Question timer (when timed mode is enabled)
/// - Total timer (when total time limit is configured)
///
/// The status bar is positioned right after the AppBar and above the quiz content,
/// ensuring status information is always visible without crowding the title.
///
/// This widget automatically adapts to different screen sizes and orientations.
class QuizStatusBar extends StatelessWidget {
  /// The current quiz state containing progress and status information
  final QuizState? state;

  /// The quiz configuration for determining which status items to show
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

  /// Background color for the status bar
  final Color? backgroundColor;

  const QuizStatusBar({
    super.key,
    this.state,
    this.config,
    this.livesColor = Colors.red,
    this.lostLivesColor = Colors.grey,
    this.timerNormalColor = Colors.blue,
    this.timerWarningColor = Colors.orange,
    this.timerCriticalColor = Colors.red,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show anything if state is not available or is loading
    if (state == null || state is LoadingState) {
      return const SizedBox.shrink();
    }

    final statusItems = <Widget>[];

    // Add lives display if applicable
    final livesWidget = _buildLivesDisplay();
    if (livesWidget != null) {
      statusItems.add(livesWidget);
    }

    // Add timer displays if applicable
    final timerWidgets = _buildTimerDisplays();
    statusItems.addAll(timerWidgets);

    // If no status items, return empty widget
    if (statusItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get responsive padding
    final horizontalPadding = getValueForScreenType<double>(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
      watch: 12,
    );

    final verticalPadding = getValueForScreenType<double>(
      context: context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
      watch: 10,
    );

    // Return status bar with all items
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: statusItems,
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
}
