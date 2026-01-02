import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_animations.dart';
import 'streak_badge.dart';

/// Style configuration for [StreakCard].
class StreakCardStyle {
  /// Creates a [StreakCardStyle].
  const StreakCardStyle({
    this.backgroundColor,
    this.activeGradient,
    this.atRiskGradient,
    this.inactiveGradient,
    this.borderRadius = 16.0,
    this.elevation = 2.0,
    this.padding = const EdgeInsets.all(16.0),
    this.showProgressBar = true,
    this.showStats = true,
    this.showMessage = true,
    this.compact = false,
  });

  /// Default style.
  static const StreakCardStyle defaults = StreakCardStyle();

  /// Compact style for smaller displays.
  static const StreakCardStyle compactStyle = StreakCardStyle(
    compact: true,
    showStats: false,
    padding: EdgeInsets.all(12.0),
  );

  /// Background color (overrides gradient).
  final Color? backgroundColor;

  /// Gradient for active streaks.
  final Gradient? activeGradient;

  /// Gradient for at-risk streaks.
  final Gradient? atRiskGradient;

  /// Gradient for inactive streaks.
  final Gradient? inactiveGradient;

  /// Border radius of the card.
  final double borderRadius;

  /// Elevation of the card.
  final double elevation;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Whether to show progress bar to next milestone.
  final bool showProgressBar;

  /// Whether to show streak statistics.
  final bool showStats;

  /// Whether to show status message.
  final bool showMessage;

  /// Whether to use compact layout.
  final bool compact;
}

/// Data required to display a [StreakCard].
class StreakCardData {
  /// Creates a [StreakCardData].
  const StreakCardData({
    required this.currentStreak,
    required this.longestStreak,
    required this.status,
    this.nextMilestone,
    this.milestoneProgress = 0.0,
    this.totalDaysPlayed = 0,
  });

  /// Creates empty data for new users.
  factory StreakCardData.empty() => const StreakCardData(
        currentStreak: 0,
        longestStreak: 0,
        status: StreakStatus.none,
      );

  /// Creates data from a [StreakData] and [StreakStatus].
  factory StreakCardData.fromStreakData({
    required StreakData data,
    required StreakStatus status,
    int? nextMilestone,
    double milestoneProgress = 0.0,
  }) {
    return StreakCardData(
      currentStreak: data.currentStreak,
      longestStreak: data.longestStreak,
      status: status,
      nextMilestone: nextMilestone,
      milestoneProgress: milestoneProgress,
      totalDaysPlayed: data.totalDaysPlayed,
    );
  }

  /// Current consecutive days of play.
  final int currentStreak;

  /// Longest streak ever achieved.
  final int longestStreak;

  /// Current streak status.
  final StreakStatus status;

  /// Next milestone to reach (e.g., 7, 30, 100).
  final int? nextMilestone;

  /// Progress to next milestone (0.0 to 1.0).
  final double milestoneProgress;

  /// Total days the user has played.
  final int totalDaysPlayed;
}

/// A card widget displaying streak information for the home screen.
///
/// Shows current streak with animated flame, progress to next milestone,
/// and contextual messages based on streak status.
///
/// Example:
/// ```dart
/// StreakCard(
///   data: StreakCardData(
///     currentStreak: 7,
///     longestStreak: 14,
///     status: StreakStatus.active,
///     nextMilestone: 14,
///     milestoneProgress: 0.5,
///   ),
///   onTap: () => navigateToStatistics(),
/// )
/// ```
class StreakCard extends StatefulWidget {
  /// Creates a [StreakCard].
  const StreakCard({
    super.key,
    required this.data,
    this.style = StreakCardStyle.defaults,
    this.onTap,
  });

  /// The streak data to display.
  final StreakCardData data;

  /// Style configuration.
  final StreakCardStyle style;

  /// Optional callback when card is tapped.
  final VoidCallback? onTap;

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  late Animation<double> _celebrationOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Trigger celebration animation if streak is active
    if (widget.data.status == StreakStatus.active) {
      _celebrationController.forward();
    }
  }

  void _setupAnimations() {
    _celebrationController = AnimationController(
      duration: QuizAnimations.durationLong,
      vsync: this,
    );

    _celebrationScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: QuizAnimations.curveOvershoot,
      ),
    );

    _celebrationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    final statusMessage = _getStatusMessage(l10n);
    final semanticLabel =
        l10n.accessibilityStreakCard(widget.data.currentStreak, statusMessage);

    return Semantics(
      label: semanticLabel,
      button: widget.onTap != null,
      child: AnimatedBuilder(
        animation: _celebrationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _celebrationScale.value,
            child: Opacity(
              opacity: _celebrationOpacity.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Card(
          elevation: widget.style.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.style.borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            excludeFromSemantics: true,
            child: Container(
              decoration: BoxDecoration(
                color: widget.style.backgroundColor,
                gradient: widget.style.backgroundColor == null
                    ? _getGradient(theme)
                    : null,
              ),
              padding: widget.style.padding,
              child: widget.style.compact
                  ? _buildCompactLayout(theme, l10n)
                  : _buildFullLayout(theme, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(ThemeData theme, QuizEngineLocalizations l10n) {
    return Row(
      children: [
        StreakBadge(
          streakCount: widget.data.currentStreak,
          status: widget.data.status,
          size: StreakBadgeSize.medium,
          style: StreakBadgeStyle(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.style.showMessage)
                Text(
                  _getStatusMessage(l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (widget.style.showProgressBar &&
                  widget.data.nextMilestone != null) ...[
                const SizedBox(height: 8),
                _buildProgressBar(theme, l10n),
              ],
            ],
          ),
        ),
        if (widget.onTap != null)
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.7),
          ),
      ],
    );
  }

  Widget _buildFullLayout(ThemeData theme, QuizEngineLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _AnimatedFlame(
                        status: widget.data.status,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.data.currentStreak}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.streakDayStreak,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.7),
                size: 28,
              ),
          ],
        ),
        if (widget.style.showMessage) ...[
          const SizedBox(height: 12),
          _buildStatusMessage(theme, l10n),
        ],
        if (widget.style.showProgressBar &&
            widget.data.nextMilestone != null) ...[
          const SizedBox(height: 16),
          _buildProgressBar(theme, l10n),
        ],
        if (widget.style.showStats) ...[
          const SizedBox(height: 16),
          _buildStats(theme, l10n),
        ],
      ],
    );
  }

  Widget _buildStatusMessage(ThemeData theme, QuizEngineLocalizations l10n) {
    final message = _getStatusMessage(l10n);
    final icon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, QuizEngineLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.streakNextMilestone(widget.data.nextMilestone!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Text(
              '${(widget.data.milestoneProgress * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.data.milestoneProgress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ThemeData theme, QuizEngineLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            label: l10n.streakLongestLabel,
            value: '${widget.data.longestStreak}',
            icon: Icons.emoji_events_outlined,
          ),
        ),
        Container(
          width: 1,
          height: 30,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        Expanded(
          child: _StatItem(
            label: l10n.streakTotalDaysLabel,
            value: '${widget.data.totalDaysPlayed}',
            icon: Icons.calendar_today_outlined,
          ),
        ),
      ],
    );
  }

  Gradient _getGradient(ThemeData theme) {
    switch (widget.data.status) {
      case StreakStatus.active:
        return widget.style.activeGradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
            );
      case StreakStatus.atRisk:
        return widget.style.atRiskGradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
            );
      case StreakStatus.broken:
      case StreakStatus.none:
        return widget.style.inactiveGradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surfaceContainerHigh,
              ],
            );
    }
  }

  String _getStatusMessage(QuizEngineLocalizations l10n) {
    switch (widget.data.status) {
      case StreakStatus.active:
        return l10n.streakPlayedToday;
      case StreakStatus.atRisk:
        return l10n.streakPlayToday;
      case StreakStatus.broken:
        return l10n.streakBroken;
      case StreakStatus.none:
        return l10n.streakNone;
    }
  }

  IconData? _getStatusIcon() {
    switch (widget.data.status) {
      case StreakStatus.active:
        return Icons.check_circle_outline;
      case StreakStatus.atRisk:
        return Icons.warning_amber_outlined;
      case StreakStatus.broken:
        return Icons.error_outline;
      case StreakStatus.none:
        return Icons.play_circle_outline;
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedFlame extends StatefulWidget {
  const _AnimatedFlame({
    required this.status,
    required this.size,
  });

  final StreakStatus status;
  final double size;

  @override
  State<_AnimatedFlame> createState() => _AnimatedFlameState();
}

class _AnimatedFlameState extends State<_AnimatedFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: QuizAnimations.resourcePulseDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: QuizAnimations.curveStandard,
      ),
    );

    if (widget.status.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.status.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.status.isActive
        ? Colors.white
        : Colors.white.withValues(alpha: 0.5);

    if (widget.status.isActive) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Icon(
          Icons.local_fire_department,
          size: widget.size,
          color: color,
        ),
      );
    }

    return Icon(
      Icons.local_fire_department,
      size: widget.size,
      color: color,
    );
  }
}