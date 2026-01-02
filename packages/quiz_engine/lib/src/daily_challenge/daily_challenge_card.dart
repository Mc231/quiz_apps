import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_accessibility.dart';
import '../theme/quiz_animations.dart';

/// Style configuration for [DailyChallengeCard].
class DailyChallengeCardStyle {
  /// Creates a [DailyChallengeCardStyle].
  const DailyChallengeCardStyle({
    this.backgroundColor,
    this.completedBackgroundColor,
    this.accentColor,
    this.borderRadius = 16.0,
    this.elevation = 2.0,
    this.padding = const EdgeInsets.all(16.0),
    this.showCountdown = true,
    this.compact = false,
    this.hideWhenCompleted = false,
  });

  /// Background color of the card when challenge is available.
  final Color? backgroundColor;

  /// Background color when challenge is completed.
  final Color? completedBackgroundColor;

  /// Accent color for badges and icons.
  final Color? accentColor;

  /// Border radius of the card.
  final double borderRadius;

  /// Elevation of the card.
  final double elevation;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Whether to show the countdown timer.
  final bool showCountdown;

  /// Whether to use compact layout.
  final bool compact;

  /// Whether to hide the card when challenge is completed.
  ///
  /// If true, the card will not be shown after the user completes
  /// today's challenge. Default is false.
  final bool hideWhenCompleted;
}

/// A card widget displaying the daily challenge status.
///
/// Shows whether the challenge is available, completed, or countdown
/// to the next challenge.
///
/// Example:
/// ```dart
/// DailyChallengeCard(
///   status: dailyChallengeStatus,
///   onTap: () => navigateToDailyChallenge(),
/// )
/// ```
class DailyChallengeCard extends StatefulWidget {
  /// Creates a [DailyChallengeCard].
  const DailyChallengeCard({
    super.key,
    required this.status,
    this.onTap,
    this.onViewResults,
    this.style = const DailyChallengeCardStyle(),
  });

  /// The current daily challenge status.
  final DailyChallengeStatus status;

  /// Callback when the card is tapped (to start challenge).
  final VoidCallback? onTap;

  /// Callback when "View Results" is tapped (after completion).
  final VoidCallback? onViewResults;

  /// Style configuration for the card.
  final DailyChallengeCardStyle style;

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _countdownTimer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.status.timeUntilNextChallenge;

    _animationController = AnimationController(
      vsync: this,
      duration: QuizAnimations.durationMedium,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: QuizAnimations.curveEnter,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: QuizAnimations.curveStandard,
      ),
    );

    _animationController.forward();
    _startCountdownTimer();
  }

  @override
  void didUpdateWidget(DailyChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status.timeUntilNextChallenge !=
        widget.status.timeUntilNextChallenge) {
      _timeRemaining = widget.status.timeUntilNextChallenge;
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    if (widget.status.isCompleted && widget.style.showCountdown) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_timeRemaining.inSeconds > 0) {
            _timeRemaining = _timeRemaining - const Duration(seconds: 1);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    final statusText = widget.status.isCompleted
        ? l10n.dailyChallengeCompleted
        : l10n.dailyChallengeAvailable;

    final backgroundColor = widget.status.isCompleted
        ? widget.style.completedBackgroundColor ??
            theme.colorScheme.primaryContainer
        : widget.style.backgroundColor ?? theme.colorScheme.surface;

    final accentColor = widget.style.accentColor ?? theme.colorScheme.primary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: QuizAccessibility.semanticButton(
          label: l10n.accessibilityDailyChallengeCard(statusText),
          hint: widget.status.isCompleted
              ? l10n.accessibilityDoubleTapToView
              : l10n.accessibilityDoubleTapToStart,
          enabled: widget.onTap != null || widget.onViewResults != null,
          child: Card(
            elevation: widget.style.elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.style.borderRadius),
            ),
            color: backgroundColor,
            child: InkWell(
              onTap: widget.status.isCompleted
                  ? widget.onViewResults
                  : widget.onTap,
              borderRadius: BorderRadius.circular(widget.style.borderRadius),
              excludeFromSemantics: true,
              child: Padding(
                padding: widget.style.padding,
                child: widget.style.compact
                    ? _buildCompactContent(theme, l10n, accentColor)
                    : _buildFullContent(theme, l10n, accentColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color accentColor,
  ) {
    return Row(
      children: [
        _buildIcon(theme, accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.dailyChallenge,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              _buildStatusText(theme, l10n, accentColor),
            ],
          ),
        ),
        ExcludeSemantics(
          child: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIcon(theme, accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.dailyChallenge,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(theme, l10n, accentColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dailyChallengeSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChallengeInfo(theme, l10n, accentColor),
        const SizedBox(height: 16),
        _buildActionRow(theme, l10n, accentColor),
      ],
    );
  }

  Widget _buildIcon(ThemeData theme, Color accentColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.status.isCompleted ? Icons.check_circle : Icons.today,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, QuizEngineLocalizations l10n, Color accentColor) {
    final isCompleted = widget.status.isCompleted;
    final isDark = theme.brightness == Brightness.dark;
    // Use high-contrast green for visibility on all backgrounds
    final completedColor = isDark ? Colors.green.shade400 : const Color(0xFF1B5E20);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? completedColor.withValues(alpha: 0.15)
            : accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCompleted
            ? l10n.dailyChallengeCompleted
            : l10n.dailyChallengeAvailable,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isCompleted ? completedColor : accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusText(ThemeData theme, QuizEngineLocalizations l10n, Color accentColor) {
    final isDark = theme.brightness == Brightness.dark;
    // Use high-contrast green for visibility on all backgrounds
    // Light mode: green.shade900 (0xFF1B5E20) - very dark green
    // Dark mode: green.shade400 - bright enough for dark backgrounds
    final completedColor = isDark ? Colors.green.shade400 : const Color(0xFF1B5E20);

    if (widget.status.isCompleted) {
      final result = widget.status.result;
      if (result != null) {
        return Text(
          '${l10n.score}: ${result.score}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: completedColor,
            fontWeight: FontWeight.w600,
          ),
        );
      }
      return Text(
        l10n.dailyChallengeCompleted,
        style: theme.textTheme.bodySmall?.copyWith(
          color: completedColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Text(
      l10n.dailyChallengeAvailable,
      style: theme.textTheme.bodySmall?.copyWith(
        color: accentColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildChallengeInfo(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color accentColor,
  ) {
    final challenge = widget.status.challenge;
    final timeLimitMinutes = challenge.timeLimitSeconds != null
        ? (challenge.timeLimitSeconds! / 60).round()
        : null;

    return Row(
      children: [
        _buildInfoChip(
          theme,
          Icons.help_outline,
          l10n.dailyChallengeQuestions(challenge.questionCount),
          accentColor,
        ),
        const SizedBox(width: 12),
        _buildInfoChip(
          theme,
          Icons.timer_outlined,
          timeLimitMinutes != null
              ? l10n.dailyChallengeTimeLimit(timeLimitMinutes)
              : l10n.dailyChallengeNoTimeLimit,
          accentColor,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    ThemeData theme,
    IconData icon,
    String label,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(ThemeData theme, QuizEngineLocalizations l10n, Color accentColor) {
    if (widget.status.isCompleted) {
      return Row(
        children: [
          Expanded(
            child: _buildCountdown(theme, l10n),
          ),
          if (widget.onViewResults != null)
            TextButton.icon(
              onPressed: widget.onViewResults,
              icon: const Icon(Icons.visibility_outlined),
              label: Text(l10n.dailyChallengeViewResults),
            ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: widget.onTap,
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.dailyChallengeStart),
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCountdown(ThemeData theme, QuizEngineLocalizations l10n) {
    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);

    final timeString = hours > 0
        ? '${hours}h ${minutes}m'
        : minutes > 0
            ? '${minutes}m ${seconds}s'
            : '${seconds}s';

    return Semantics(
      label: l10n.accessibilityDailyChallengeCountdown(timeString),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            l10n.dailyChallengeNextIn(timeString),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact version of [DailyChallengeCard] for use in lists or grids.
class DailyChallengeCardCompact extends StatelessWidget {
  /// Creates a compact [DailyChallengeCard].
  const DailyChallengeCardCompact({
    super.key,
    required this.status,
    this.onTap,
  });

  /// The current daily challenge status.
  final DailyChallengeStatus status;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DailyChallengeCard(
      status: status,
      onTap: onTap,
      style: const DailyChallengeCardStyle(compact: true),
    );
  }
}
