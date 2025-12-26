/// Widget for displaying the total score on the results screen.
library;

import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_animations.dart';

/// Displays the total score with optional animation.
///
/// This widget shows the score in a visually prominent way,
/// typically used on the quiz results screen.
class ScoreDisplay extends StatelessWidget {
  /// Creates a [ScoreDisplay].
  const ScoreDisplay({
    super.key,
    required this.score,
    this.animate = true,
    this.style,
    this.labelStyle,
  });

  /// The total score to display.
  final int score;

  /// Whether to animate the score counting up.
  final bool animate;

  /// Custom text style for the score value.
  final TextStyle? style;

  /// Custom text style for the "pts" label.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizEngineLocalizations.of(context);
    final ptsLabel = l10n?.pointsLabel ?? 'pts';

    final scoreStyle = style ??
        theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        );

    final ptsStyle = labelStyle ??
        theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        );

    if (animate) {
      return _AnimatedScoreDisplay(
        score: score,
        scoreStyle: scoreStyle,
        ptsStyle: ptsStyle,
        ptsLabel: ptsLabel,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          score.toString(),
          style: scoreStyle,
        ),
        const SizedBox(width: 4),
        Text(
          ptsLabel,
          style: ptsStyle,
        ),
      ],
    );
  }
}

/// Animated version of the score display that counts up.
class _AnimatedScoreDisplay extends StatefulWidget {
  const _AnimatedScoreDisplay({
    required this.score,
    required this.scoreStyle,
    required this.ptsStyle,
    required this.ptsLabel,
  });

  final int score;
  final TextStyle? scoreStyle;
  final TextStyle? ptsStyle;
  final String ptsLabel;

  @override
  State<_AnimatedScoreDisplay> createState() => _AnimatedScoreDisplayState();
}

class _AnimatedScoreDisplayState extends State<_AnimatedScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: QuizAnimations.scoreCountDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: QuizAnimations.scoreCountCurve,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayScore = (_animation.value * widget.score).round();
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              displayScore.toString(),
              style: widget.scoreStyle,
            ),
            const SizedBox(width: 4),
            Text(
              widget.ptsLabel,
              style: widget.ptsStyle,
            ),
          ],
        );
      },
    );
  }
}
