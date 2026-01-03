import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import 'achievement_tier_badge.dart';

/// Style configuration for [AchievementCard].
class AchievementCardStyle {
  /// Creates an [AchievementCardStyle].
  const AchievementCardStyle({
    this.backgroundColor,
    this.lockedBackgroundColor,
    this.iconSize = 40.0,
    this.borderRadius = 12.0,
    this.elevation = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.showTierBadge = true,
    this.showPoints = true,
    this.showProgressBar = true,
    this.progressBarHeight = 6.0,
    this.lockedOpacity = 0.5,
  });

  /// Background color for unlocked achievements.
  final Color? backgroundColor;

  /// Background color for locked achievements.
  final Color? lockedBackgroundColor;

  /// Size of the achievement icon.
  final double iconSize;

  /// Border radius of the card.
  final double borderRadius;

  /// Elevation of the card.
  final double elevation;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Whether to show the tier badge.
  final bool showTierBadge;

  /// Whether to show the points value.
  final bool showPoints;

  /// Whether to show the progress bar.
  final bool showProgressBar;

  /// Height of the progress bar.
  final double progressBarHeight;

  /// Opacity for locked achievements.
  final double lockedOpacity;
}

/// Data model combining achievement definition with progress.
class AchievementDisplayData {
  /// Creates an [AchievementDisplayData].
  const AchievementDisplayData({
    required this.achievement,
    required this.progress,
  });

  /// The achievement definition.
  final Achievement achievement;

  /// The progress toward this achievement.
  final AchievementProgress progress;

  /// Whether the achievement is unlocked.
  bool get isUnlocked => progress.isUnlocked;

  /// Whether the achievement is hidden and not yet unlocked.
  bool get isHiddenAndLocked => achievement.isHidden && !isUnlocked;

  /// Whether to show progress (has target > 1 and not unlocked).
  bool get showProgress =>
      !isUnlocked && achievement.progressTarget > 1 && progress.hasProgress;
}

/// A card widget displaying an achievement.
///
/// Shows the achievement icon, name, description, tier badge,
/// progress bar (for progressive achievements), and points value.
///
/// Example:
/// ```dart
/// AchievementCard(
///   data: AchievementDisplayData(
///     achievement: firstQuizAchievement,
///     progress: AchievementProgress.unlocked(...),
///   ),
///   onTap: () => showAchievementDetails(achievement),
/// )
/// ```
class AchievementCard extends StatefulWidget {
  /// Creates an [AchievementCard].
  const AchievementCard({
    super.key,
    required this.data,
    this.onTap,
    this.style = const AchievementCardStyle(),
    this.isHighlighted = false,
  });

  /// The achievement data to display.
  final AchievementDisplayData data;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Style configuration for the card.
  final AchievementCardStyle style;

  /// Whether this card is highlighted (e.g., from deep link navigation).
  ///
  /// When true, the card displays a glowing border in the tier color
  /// that fades out over 2 seconds.
  final bool isHighlighted;

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _highlightAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeOut),
    );

    if (widget.isHighlighted) {
      // Start fade-out after a brief moment
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _highlightController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AchievementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _highlightController.reset();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _highlightController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  AchievementDisplayData get data => widget.data;
  VoidCallback? get onTap => widget.onTap;
  AchievementCardStyle get style => widget.style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    // If hidden and locked, show placeholder
    if (data.isHiddenAndLocked) {
      return _buildHiddenCard(context, theme, l10n);
    }

    return _buildCard(context, theme);
  }

  Widget _buildHiddenCard(
    BuildContext context,
    ThemeData theme,
    QuizEngineLocalizations l10n,
  ) {
    return Semantics(
      label: '${l10n.hiddenAchievement}. ${l10n.hiddenAchievementDesc}',
      hint: onTap != null ? l10n.accessibilityDoubleTapToView : null,
      button: onTap != null,
      child: Card(
        elevation: style.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        color: style.lockedBackgroundColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(style.borderRadius),
          excludeFromSemantics: true,
          child: Padding(
            padding: style.padding,
            child: Row(
              children: [
                _buildHiddenIcon(theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.hiddenAchievement,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: style.lockedOpacity),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.hiddenAchievementDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: style.lockedOpacity),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: style.lockedOpacity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenIcon(ThemeData theme) {
    return Container(
      width: style.iconSize + 16,
      height: style.iconSize + 16,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline,
          size: style.iconSize * 0.6,
          color: theme.colorScheme.onSurfaceVariant
              .withValues(alpha: style.lockedOpacity),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ThemeData theme) {
    final isUnlocked = data.isUnlocked;
    final l10n = QuizL10n.of(context);
    final tierName = data.achievement.tier.name;
    final tierColor = data.achievement.tier.color;

    // Build accessibility label
    final String semanticLabel;
    if (isUnlocked) {
      semanticLabel = l10n.accessibilityAchievementUnlocked(
        data.achievement.name(context),
        tierName,
        data.achievement.points,
      );
    } else {
      semanticLabel = l10n.accessibilityAchievementLocked(
        data.achievement.name(context),
        tierName,
        data.achievement.points,
        data.progress.percentageInt,
      );
    }

    Widget card = Card(
      elevation: style.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      color: isUnlocked
          ? style.backgroundColor
          : style.lockedBackgroundColor ??
              theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: style.lockedOpacity),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(style.borderRadius),
        excludeFromSemantics: true,
        child: Padding(
          padding: style.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(context, theme, isUnlocked),
                  const SizedBox(width: 16),
                  Expanded(child: _buildContent(context, theme, isUnlocked)),
                  _buildTrailing(context, theme, isUnlocked),
                ],
              ),
              if (style.showProgressBar && data.showProgress) ...[
                const SizedBox(height: 12),
                _buildProgressBar(context, theme),
              ],
            ],
          ),
        ),
      ),
    );

    // Apply highlight glow effect if highlighted
    if (widget.isHighlighted) {
      card = AnimatedBuilder(
        animation: _highlightAnimation,
        builder: (context, child) {
          final glowOpacity = _highlightAnimation.value * 0.6;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(style.borderRadius + 4),
              boxShadow: glowOpacity > 0
                  ? [
                      BoxShadow(
                        color: tierColor.withValues(alpha: glowOpacity),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: child,
          );
        },
        child: card,
      );
    }

    return Semantics(
      label: semanticLabel,
      hint: onTap != null ? l10n.accessibilityDoubleTapToView : null,
      button: onTap != null,
      child: card,
    );
  }

  Widget _buildIcon(BuildContext context, ThemeData theme, bool isUnlocked) {
    final tierColor = data.achievement.tier.color;

    return Container(
      width: style.iconSize + 16,
      height: style.iconSize + 16,
      decoration: BoxDecoration(
        color: isUnlocked
            ? tierColor.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: isUnlocked
            ? Border.all(color: tierColor.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Center(
        child: Opacity(
          opacity: isUnlocked ? 1.0 : style.lockedOpacity,
          child: Text(
            data.achievement.icon,
            style: TextStyle(fontSize: style.iconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isUnlocked) {
    final opacity = isUnlocked ? 1.0 : style.lockedOpacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                data.achievement.name(context),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: opacity),
                ),
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.green,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          data.achievement.description(context),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: opacity),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (style.showTierBadge || style.showPoints) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (style.showTierBadge)
                Opacity(
                  opacity: opacity,
                  child: AchievementTierBadge(
                    tier: data.achievement.tier,
                    size: AchievementTierBadgeSize.small,
                  ),
                ),
              if (style.showTierBadge && style.showPoints)
                const SizedBox(width: 8),
              if (style.showPoints)
                Opacity(
                  opacity: opacity,
                  child: AchievementPointsBadge(
                    points: data.achievement.points,
                    size: AchievementTierBadgeSize.small,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing(BuildContext context, ThemeData theme, bool isUnlocked) {
    if (data.showProgress) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${data.progress.currentValue}/${data.progress.targetValue}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            '${data.progress.percentageInt}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (!isUnlocked) {
      return Icon(
        Icons.lock_outline,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant
            .withValues(alpha: style.lockedOpacity),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProgressBar(BuildContext context, ThemeData theme) {
    final progress = data.progress.percentage;
    final tierColor = data.achievement.tier.color;
    final l10n = QuizL10n.of(context);

    return Semantics(
      label: l10n.accessibilityProgressBar(
        data.progress.currentValue,
        data.progress.targetValue,
      ),
      value: '${data.progress.percentageInt}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.progressBarHeight / 2),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: style.progressBarHeight,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(tierColor),
        ),
      ),
    );
  }
}

/// A compact achievement card for grid layouts.
class AchievementCardCompact extends StatelessWidget {
  /// Creates an [AchievementCardCompact].
  const AchievementCardCompact({
    super.key,
    required this.data,
    this.onTap,
    this.size = 80.0,
  });

  /// The achievement data to display.
  final AchievementDisplayData data;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Size of the card (width and height).
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final isUnlocked = data.isUnlocked;
    final isHidden = data.isHiddenAndLocked;
    final tierColor = data.achievement.tier.color;
    final tierName = data.achievement.tier.name;

    // Build accessibility label
    final String semanticLabel;
    if (isHidden) {
      semanticLabel = '${l10n.hiddenAchievement}. ${l10n.hiddenAchievementDesc}';
    } else if (isUnlocked) {
      semanticLabel = l10n.accessibilityAchievementUnlocked(
        data.achievement.name(context),
        tierName,
        data.achievement.points,
      );
    } else {
      semanticLabel = l10n.accessibilityAchievementLocked(
        data.achievement.name(context),
        tierName,
        data.achievement.points,
        data.progress.percentageInt,
      );
    }

    return Semantics(
      label: semanticLabel,
      hint: onTap != null ? l10n.accessibilityDoubleTapToView : null,
      button: onTap != null,
      child: Tooltip(
        message: isHidden ? '???' : data.achievement.name(context),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          excludeFromSemantics: true,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? tierColor.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: isUnlocked
                  ? Border.all(color: tierColor.withValues(alpha: 0.5), width: 2)
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Opacity(
                    opacity: isUnlocked ? 1.0 : 0.4,
                    child: Text(
                      isHidden ? '?' : data.achievement.icon,
                      style: TextStyle(fontSize: size * 0.4),
                    ),
                  ),
                ),
                if (isUnlocked)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
                if (!isUnlocked && data.showProgress)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    right: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: data.progress.percentage,
                        minHeight: 4,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
