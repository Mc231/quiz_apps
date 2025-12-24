import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';

/// Size options for [AchievementTierBadge].
enum AchievementTierBadgeSize {
  /// Small size - compact display.
  small,

  /// Medium size - default display.
  medium,

  /// Large size - prominent display.
  large,
}

/// A widget that displays an achievement tier indicator.
///
/// Shows the tier color, optional icon, and optional label.
/// Used in [AchievementCard] and other achievement displays.
///
/// Example:
/// ```dart
/// AchievementTierBadge(
///   tier: AchievementTier.rare,
///   showLabel: true,
///   showIcon: true,
/// )
/// ```
class AchievementTierBadge extends StatelessWidget {
  /// Creates an [AchievementTierBadge].
  const AchievementTierBadge({
    super.key,
    required this.tier,
    this.showLabel = true,
    this.showIcon = false,
    this.size = AchievementTierBadgeSize.medium,
  });

  /// Creates a small [AchievementTierBadge] with icon only.
  const AchievementTierBadge.iconOnly({
    super.key,
    required this.tier,
    this.size = AchievementTierBadgeSize.small,
  })  : showLabel = false,
        showIcon = true;

  /// Creates a [AchievementTierBadge] with both icon and label.
  const AchievementTierBadge.full({
    super.key,
    required this.tier,
    this.size = AchievementTierBadgeSize.medium,
  })  : showLabel = true,
        showIcon = true;

  /// The achievement tier to display.
  final AchievementTier tier;

  /// Whether to show the text label.
  final bool showLabel;

  /// Whether to show the tier icon/emoji.
  final bool showIcon;

  /// Size of the badge.
  final AchievementTierBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    final (iconSize, fontSize, padding) = switch (size) {
      AchievementTierBadgeSize.small => (
          12.0,
          10.0,
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
        ),
      AchievementTierBadgeSize.medium => (
          14.0,
          12.0,
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        ),
      AchievementTierBadgeSize.large => (
          18.0,
          14.0,
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        ),
    };

    return Semantics(
      label: l10n.accessibilityTierBadge(tier.label),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: tier.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: tier.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Text(
                tier.icon,
                style: TextStyle(fontSize: iconSize),
              ),
              if (showLabel) const SizedBox(width: 4),
            ],
            if (showLabel)
              Text(
                tier.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tier.color,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A compact points indicator for achievements.
///
/// Displays the points value with a styled badge.
class AchievementPointsBadge extends StatelessWidget {
  /// Creates an [AchievementPointsBadge].
  const AchievementPointsBadge({
    super.key,
    required this.points,
    this.size = AchievementTierBadgeSize.medium,
    this.color,
  });

  /// The points value to display.
  final int points;

  /// Size of the badge.
  final AchievementTierBadgeSize size;

  /// Optional custom color (defaults to theme secondary).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final badgeColor = color ?? theme.colorScheme.secondary;

    final (fontSize, padding) = switch (size) {
      AchievementTierBadgeSize.small => (
          10.0,
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
        ),
      AchievementTierBadgeSize.medium => (
          12.0,
          const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
        ),
      AchievementTierBadgeSize.large => (
          14.0,
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        ),
    };

    return Semantics(
      label: l10n.accessibilityPointsBadge(points),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$points pts',
          style: theme.textTheme.labelSmall?.copyWith(
            color: badgeColor,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
