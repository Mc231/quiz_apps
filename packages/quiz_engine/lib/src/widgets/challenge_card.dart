import 'package:flutter/material.dart';

import '../models/challenge_mode.dart';

/// Style configuration for [ChallengeCard].
class ChallengeCardStyle {
  /// Creates a [ChallengeCardStyle].
  const ChallengeCardStyle({
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.descriptionStyle,
    this.borderRadius = 12.0,
    this.elevation = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.iconSize = 32.0,
    this.showDifficultyBadge = true,
    this.showDifficultyIcon = false,
  });

  /// Background color of the card.
  final Color? backgroundColor;

  /// Color of the challenge icon.
  final Color? iconColor;

  /// Text style for the title.
  final TextStyle? titleStyle;

  /// Text style for the description.
  final TextStyle? descriptionStyle;

  /// Border radius of the card.
  final double borderRadius;

  /// Elevation of the card.
  final double elevation;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Size of the challenge icon.
  final double iconSize;

  /// Whether to show the difficulty badge.
  final bool showDifficultyBadge;

  /// Whether to show difficulty icon instead of text.
  final bool showDifficultyIcon;
}

/// A card widget displaying a challenge mode.
///
/// Shows the challenge icon, name, description, and difficulty indicator.
///
/// Example:
/// ```dart
/// ChallengeCard(
///   challenge: survivalChallenge,
///   onTap: () => startChallenge(survivalChallenge),
/// )
/// ```
class ChallengeCard extends StatelessWidget {
  /// Creates a [ChallengeCard].
  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.style = const ChallengeCardStyle(),
    this.trailing,
  });

  /// The challenge mode to display.
  final ChallengeMode challenge;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Style configuration for the card.
  final ChallengeCardStyle style;

  /// Optional trailing widget (e.g., best score).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: style.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      color: style.backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(style.borderRadius),
        child: Padding(
          padding: style.padding,
          child: Row(
            children: [
              _buildIcon(theme),
              const SizedBox(width: 16),
              Expanded(child: _buildContent(theme)),
              if (style.showDifficultyBadge) ...[
                const SizedBox(width: 8),
                _buildDifficultyBadge(theme),
              ],
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Container(
      width: style.iconSize + 16,
      height: style.iconSize + 16,
      decoration: BoxDecoration(
        color: challenge.difficulty.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: Icon(
        challenge.icon,
        size: style.iconSize,
        color: style.iconColor ?? challenge.difficulty.color,
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          challenge.name,
          style: style.titleStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          challenge.description,
          style: style.descriptionStyle ??
              theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge(ThemeData theme) {
    if (style.showDifficultyIcon) {
      return Icon(
        challenge.difficulty.icon,
        color: challenge.difficulty.color,
        size: 24,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: challenge.difficulty.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        challenge.difficulty.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: challenge.difficulty.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A widget that displays a difficulty indicator.
///
/// Can be used standalone or as part of other widgets.
class DifficultyIndicator extends StatelessWidget {
  /// Creates a [DifficultyIndicator].
  const DifficultyIndicator({
    super.key,
    required this.difficulty,
    this.showLabel = true,
    this.showIcon = false,
    this.size = DifficultyIndicatorSize.medium,
  });

  /// The difficulty level to display.
  final ChallengeDifficulty difficulty;

  /// Whether to show the text label.
  final bool showLabel;

  /// Whether to show the icon.
  final bool showIcon;

  /// Size of the indicator.
  final DifficultyIndicatorSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (iconSize, fontSize, padding) = switch (size) {
      DifficultyIndicatorSize.small => (12.0, 10.0, const EdgeInsets.symmetric(horizontal: 4, vertical: 2)),
      DifficultyIndicatorSize.medium => (16.0, 12.0, const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      DifficultyIndicatorSize.large => (20.0, 14.0, const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: difficulty.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              difficulty.icon,
              color: difficulty.color,
              size: iconSize,
            ),
            if (showLabel) const SizedBox(width: 4),
          ],
          if (showLabel)
            Text(
              difficulty.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: difficulty.color,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
        ],
      ),
    );
  }
}

/// Size options for [DifficultyIndicator].
enum DifficultyIndicatorSize {
  /// Small size.
  small,

  /// Medium size (default).
  medium,

  /// Large size.
  large,
}
