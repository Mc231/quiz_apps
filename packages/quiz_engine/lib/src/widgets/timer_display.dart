import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../quiz_widget_entry.dart';

/// A widget that displays the remaining time in a quiz game.
///
/// Shows a timer icon with the remaining time in seconds or MM:SS format.
/// The color changes based on how much time is left (e.g., red when time is running low).
///
/// This widget is only visible when the quiz mode supports timer tracking
/// (TimedMode or SurvivalMode).
class TimerDisplay extends StatelessWidget {
  /// The remaining time in seconds for the current question (null if not in timed mode)
  final int? questionTimeRemaining;

  /// The remaining time in seconds for the total quiz (null if no total time limit)
  final int? totalTimeRemaining;

  /// Whether to show the question timer (default: true)
  final bool showQuestionTimer;

  /// Whether to show the total timer (default: false)
  final bool showTotalTimer;

  /// The icon to use for the timer
  final IconData timerIcon;

  /// The normal color for the timer (when time is plentiful)
  final Color normalColor;

  /// The warning color (when time is running low)
  final Color warningColor;

  /// The critical color (when time is almost out)
  final Color criticalColor;

  /// The threshold (in seconds) below which to show warning color
  final int warningThreshold;

  /// The threshold (in seconds) below which to show critical color
  final int criticalThreshold;

  /// Text strings for the quiz UI
  final QuizTexts texts;

  const TimerDisplay({
    super.key,
    this.questionTimeRemaining,
    this.totalTimeRemaining,
    this.showQuestionTimer = true,
    this.showTotalTimer = false,
    this.timerIcon = Icons.timer,
    this.normalColor = Colors.blue,
    this.warningColor = Colors.orange,
    this.criticalColor = Colors.red,
    this.warningThreshold = 10,
    this.criticalThreshold = 5,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which timer to display
    final timeToDisplay = _getTimeToDisplay();

    // Don't show anything if no timer is active
    if (timeToDisplay == null) {
      return const SizedBox.shrink();
    }

    final timerColor = _getTimerColor(timeToDisplay);
    final formattedTime = _formatTime(timeToDisplay);

    final iconSize = getValueForScreenType<double>(
      context: context,
      mobile: 20,
      tablet: 24,
      desktop: 24,
      watch: 16,
    );

    final fontSize = getValueForScreenType<double>(
      context: context,
      mobile: 16,
      tablet: 20,
      desktop: 20,
      watch: 14,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: timerColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            timerIcon,
            color: timerColor,
            size: iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            formattedTime,
            style: TextStyle(
              color: timerColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// Determines which time value to display based on settings
  int? _getTimeToDisplay() {
    if (showQuestionTimer && questionTimeRemaining != null) {
      return questionTimeRemaining;
    } else if (showTotalTimer && totalTimeRemaining != null) {
      return totalTimeRemaining;
    }
    return null;
  }

  /// Determines the color based on remaining time
  Color _getTimerColor(int remainingTime) {
    if (remainingTime <= criticalThreshold) {
      return criticalColor;
    } else if (remainingTime <= warningThreshold) {
      return warningColor;
    }
    return normalColor;
  }

  /// Formats time in seconds to MM:SS format if >= 60, otherwise just seconds
  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds${texts.timerSecondsSuffix}';
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}