/// Widget for displaying a breakdown of the score calculation.
library;

import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../l10n/quiz_localizations.dart';

/// Displays a breakdown of the score showing base points and bonuses.
///
/// This widget shows how the final score was calculated,
/// including base points and any bonus points earned.
class ScoreBreakdownWidget extends StatelessWidget {
  /// Creates a [ScoreBreakdownWidget].
  const ScoreBreakdownWidget({
    super.key,
    required this.breakdown,
    this.showTitle = true,
    this.compact = false,
  });

  /// The score breakdown data to display.
  final ScoreBreakdownData breakdown;

  /// Whether to show the "Score Breakdown" title.
  final bool showTitle;

  /// Whether to use compact layout (single row).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizEngineLocalizations.of(context);

    // Fallback strings if localization is not available
    final scoreBreakdownLabel = l10n?.scoreBreakdown ?? 'Score Breakdown';
    final basePointsLabel = l10n?.basePoints ?? 'Base Points';
    final bonusLabel = l10n?.bonus ?? 'Bonus';
    final totalScoreLabel = l10n?.totalScore ?? 'Total Score';
    final pointsLabel = l10n?.pointsLabel ?? 'pts';

    if (compact) {
      return _CompactBreakdown(
        breakdown: breakdown,
        theme: theme,
        pointsLabel: pointsLabel,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Text(
            scoreBreakdownLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        _BreakdownRow(
          label: basePointsLabel,
          value: breakdown.basePoints,
          theme: theme,
        ),
        if (breakdown.bonusPoints > 0) ...[
          const SizedBox(height: 4),
          _BreakdownRow(
            label: breakdown.bonusDescription ?? bonusLabel,
            value: breakdown.bonusPoints,
            isBonus: true,
            theme: theme,
          ),
        ],
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
        _BreakdownRow(
          label: totalScoreLabel,
          value: breakdown.totalScore,
          isTotal: true,
          theme: theme,
        ),
      ],
    );
  }
}

/// A single row in the score breakdown.
class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isBonus = false,
    this.isTotal = false,
  });

  final String label;
  final int value;
  final ThemeData theme;
  final bool isBonus;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isTotal
        ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    final valueStyle = isTotal
        ? theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          )
        : isBonus
            ? theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
              )
            : theme.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(
          isBonus ? '+$value' : value.toString(),
          style: valueStyle,
        ),
      ],
    );
  }
}

/// Compact version showing score as "base + bonus".
class _CompactBreakdown extends StatelessWidget {
  const _CompactBreakdown({
    required this.breakdown,
    required this.theme,
    required this.pointsLabel,
  });

  final ScoreBreakdownData breakdown;
  final ThemeData theme;
  final String pointsLabel;

  @override
  Widget build(BuildContext context) {
    if (breakdown.bonusPoints == 0) {
      return Text(
        '${breakdown.totalScore} $pointsLabel',
        style: theme.textTheme.bodyMedium,
      );
    }

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(text: '${breakdown.basePoints}'),
          TextSpan(
            text: ' + ${breakdown.bonusPoints}',
            style: TextStyle(color: Colors.green.shade700),
          ),
          TextSpan(
            text: ' $pointsLabel',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
