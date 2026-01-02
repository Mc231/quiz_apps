import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_animations.dart';
import '../theme/status_bar_style.dart';

/// Data required for the daily challenge results screen.
class DailyChallengeResultsData {
  /// Creates [DailyChallengeResultsData].
  const DailyChallengeResultsData({
    required this.todayResult,
    this.yesterdayResult,
    required this.currentStreak,
    required this.bestStreak,
    this.categoryName,
  });

  /// Today's challenge result.
  final DailyChallengeResult todayResult;

  /// Yesterday's result for comparison (if available).
  final DailyChallengeResult? yesterdayResult;

  /// Current daily challenge streak.
  final int currentStreak;

  /// Best daily challenge streak ever.
  final int bestStreak;

  /// Optional category name for display.
  final String? categoryName;

  /// Calculate the score difference from yesterday.
  int? get scoreDifference {
    if (yesterdayResult == null) return null;
    return todayResult.score - yesterdayResult!.score;
  }

  /// Whether today's score is better than yesterday's.
  bool get isImprovement => (scoreDifference ?? 0) > 0;

  /// Whether today's score is the same as yesterday's.
  bool get isSameScore => scoreDifference == 0;

  /// Whether today's score is a perfect 100%.
  bool get isPerfectScore => todayResult.isPerfectScore;
}

/// Configuration for [DailyChallengeResultsScreen].
class DailyChallengeResultsConfig {
  /// Creates a [DailyChallengeResultsConfig].
  const DailyChallengeResultsConfig({
    this.primaryColor,
    this.showScoreBreakdown = true,
    this.showStreakInfo = true,
    this.showYesterdayComparison = true,
    this.animateEntrance = true,
    this.showConfetti = true,
  });

  /// Primary color for the screen theme.
  final Color? primaryColor;

  /// Whether to show score breakdown.
  final bool showScoreBreakdown;

  /// Whether to show streak information.
  final bool showStreakInfo;

  /// Whether to show comparison with yesterday.
  final bool showYesterdayComparison;

  /// Whether to animate the entrance.
  final bool animateEntrance;

  /// Whether to show confetti on perfect score.
  final bool showConfetti;
}

/// Screen displaying daily challenge results with yesterday comparison.
class DailyChallengeResultsScreen extends StatefulWidget {
  /// Creates a [DailyChallengeResultsScreen].
  const DailyChallengeResultsScreen({
    super.key,
    required this.data,
    this.config = const DailyChallengeResultsConfig(),
    required this.onDone,
    this.onShareResult,
  });

  /// The results data.
  final DailyChallengeResultsData data;

  /// Configuration for the screen.
  final DailyChallengeResultsConfig config;

  /// Callback when user is done viewing results.
  final VoidCallback onDone;

  /// Callback to share the result.
  final VoidCallback? onShareResult;

  @override
  State<DailyChallengeResultsScreen> createState() =>
      _DailyChallengeResultsScreenState();
}

class _DailyChallengeResultsScreenState
    extends State<DailyChallengeResultsScreen> with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _scoreScaleAnimation;
  late Animation<int> _scoreCountAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: QuizAnimations.scoreCountDuration,
    );

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: QuizAnimations.durationMedium,
    );

    _scoreScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: QuizAnimations.curveBounce,
      ),
    );

    _scoreCountAnimation = IntTween(
      begin: 0,
      end: widget.data.todayResult.score,
    ).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: QuizAnimations.scoreCountCurve,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: QuizAnimations.curveStandard,
      ),
    );

    if (widget.config.animateEntrance) {
      _scoreAnimationController.forward();
      Future.delayed(QuizAnimations.durationMedium, () {
        if (mounted) {
          _contentAnimationController.forward();
        }
      });
    } else {
      _scoreAnimationController.value = 1.0;
      _contentAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final primaryColor =
        widget.config.primaryColor ?? theme.colorScheme.primary;

    return StatusBarStyle.matchAppBar(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(l10n.dailyChallengeResultTitle),
              centerTitle: true,
              actions: [
                if (widget.onShareResult != null)
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: widget.onShareResult,
                    tooltip: l10n.share,
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScoreSection(theme, l10n, primaryColor),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _contentFadeAnimation,
                      child: Column(
                        children: [
                          if (widget.config.showYesterdayComparison)
                            _buildComparisonSection(theme, l10n, primaryColor),
                          if (widget.config.showScoreBreakdown) ...[
                            const SizedBox(height: 16),
                            _buildScoreBreakdown(theme, l10n),
                          ],
                          if (widget.config.showStreakInfo) ...[
                            const SizedBox(height: 16),
                            _buildStreakSection(theme, l10n, primaryColor),
                          ],
                          const SizedBox(height: 32),
                          _buildDoneButton(theme, l10n, primaryColor),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    final isPerfect = widget.data.isPerfectScore;
    final isDark = theme.brightness == Brightness.dark;

    // Use theme-aware background colors for better visibility
    final cardColor = isPerfect
        ? (isDark
            ? Colors.amber.withValues(alpha: 0.15)
            : Colors.amber.shade50)
        : (isDark
            ? primaryColor.withValues(alpha: 0.15)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.5));

    return AnimatedBuilder(
      animation: _scoreAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scoreScaleAnimation.value,
          child: Card(
            elevation: isDark ? 2 : 0,
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  if (isPerfect) ...[
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.dailyChallengePerfectScore,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    l10n.dailyChallengeYourScore,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_scoreCountAnimation.value}%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPerfect ? Colors.amber.shade700 : primaryColor,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.data.todayResult.correctCount} / ${widget.data.todayResult.totalQuestions}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonSection(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    final yesterdayResult = widget.data.yesterdayResult;

    if (yesterdayResult == null) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.dailyChallengeNoYesterday,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final difference = widget.data.scoreDifference ?? 0;
    final isImprovement = difference > 0;
    final isSame = difference == 0;

    final (icon, color, message) = isSame
        ? (Icons.remove, Colors.grey, l10n.dailyChallengeSameScore)
        : isImprovement
            ? (
                Icons.arrow_upward,
                Colors.green,
                l10n.dailyChallengeImprovement(difference)
              )
            : (
                Icons.arrow_downward,
                Colors.orange,
                l10n.dailyChallengeDecline(difference.abs())
              );

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildComparisonItem(
                    theme,
                    l10n.dailyChallengeYourScore,
                    '${widget.data.todayResult.score}%',
                    primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                Expanded(
                  child: _buildComparisonItem(
                    theme,
                    l10n.dailyChallengeYesterdayScore,
                    '${yesterdayResult.score}%',
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(
    ThemeData theme,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBreakdown(ThemeData theme, QuizEngineLocalizations l10n) {
    final result = widget.data.todayResult;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyChallengeScoreBreakdown,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow(
              theme,
              l10n.dailyChallengeBaseScore,
              result.baseScore,
              Icons.check_circle_outline,
            ),
            if (result.streakBonus > 0) ...[
              const SizedBox(height: 8),
              _buildBreakdownRow(
                theme,
                l10n.dailyChallengeStreakBonus,
                result.streakBonus,
                Icons.local_fire_department,
                color: Colors.orange,
              ),
            ],
            if (result.timeBonus > 0) ...[
              const SizedBox(height: 8),
              _buildBreakdownRow(
                theme,
                l10n.dailyChallengeTimeBonus,
                result.timeBonus,
                Icons.timer,
                color: Colors.blue,
              ),
            ],
            const Divider(height: 24),
            _buildBreakdownRow(
              theme,
              l10n.dailyChallengeTotalScore,
              result.score,
              Icons.star,
              isTotal: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${l10n.dailyChallengeCompletionTime}: ${_formatDuration(Duration(seconds: result.completionTimeSeconds))}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    ThemeData theme,
    String label,
    int value,
    IconData icon, {
    Color? color,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTotal ? 24 : 20,
          color: color ?? theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          '+$value',
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: color ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ],
    );
  }

  Widget _buildStreakSection(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    final isNewBest = widget.data.currentStreak >= widget.data.bestStreak &&
        widget.data.currentStreak > 1;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              l10n.dailyChallengeStreak,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakItem(
                    theme,
                    l10n.dailyChallengeCurrentStreak,
                    widget.data.currentStreak,
                    Icons.local_fire_department,
                    Colors.deepOrange,
                    isHighlighted: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildStreakItem(
                    theme,
                    l10n.dailyChallengeBestStreak,
                    widget.data.bestStreak,
                    Icons.emoji_events,
                    Colors.amber.shade700,
                    isHighlighted: false,
                  ),
                ),
              ],
            ),
            if (isNewBest) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade300,
                      Colors.orange.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.dailyChallengeNewBestStreak,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(
    ThemeData theme,
    String label,
    int value,
    IconData icon,
    Color color, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: isHighlighted
          ? BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isHighlighted ? color : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onDone,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              l10n.done,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
