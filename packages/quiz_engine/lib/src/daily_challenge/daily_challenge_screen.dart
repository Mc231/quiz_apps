import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_accessibility.dart';
import '../theme/quiz_animations.dart';

/// Data required for the daily challenge screen.
class DailyChallengeScreenData {
  /// Creates [DailyChallengeScreenData].
  const DailyChallengeScreenData({
    required this.status,
    this.categoryName,
  });

  /// The current daily challenge status.
  final DailyChallengeStatus status;

  /// Optional category name for display.
  final String? categoryName;
}

/// Configuration for [DailyChallengeScreen].
class DailyChallengeScreenConfig {
  /// Creates a [DailyChallengeScreenConfig].
  const DailyChallengeScreenConfig({
    this.primaryColor,
    this.gradientColors,
    this.showRules = true,
    this.showCategory = true,
    this.animateEntrance = true,
  });

  /// Primary color for the screen theme.
  final Color? primaryColor;

  /// Gradient colors for the background header.
  final List<Color>? gradientColors;

  /// Whether to show the rules section.
  final bool showRules;

  /// Whether to show the category.
  final bool showCategory;

  /// Whether to animate the entrance.
  final bool animateEntrance;
}

/// Screen displaying the daily challenge intro with rules.
///
/// Shows challenge info, rules, and a start button.
/// If the challenge is already completed, shows the completed state.
class DailyChallengeScreen extends StatefulWidget {
  /// Creates a [DailyChallengeScreen].
  const DailyChallengeScreen({
    super.key,
    required this.data,
    this.config = const DailyChallengeScreenConfig(),
    required this.onStartChallenge,
    this.onViewResults,
    this.onBack,
  });

  /// The screen data.
  final DailyChallengeScreenData data;

  /// Configuration for the screen.
  final DailyChallengeScreenConfig config;

  /// Callback when user starts the challenge.
  final VoidCallback onStartChallenge;

  /// Callback when user wants to view previous results.
  final VoidCallback? onViewResults;

  /// Callback when user navigates back.
  final VoidCallback? onBack;

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: QuizAnimations.durationMedium,
    );

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: QuizAnimations.durationMedium,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: QuizAnimations.curveStandard,
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: QuizAnimations.curveEnter,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: QuizAnimations.curveStandard,
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: QuizAnimations.curveEnter,
      ),
    );

    if (widget.config.animateEntrance) {
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          _contentAnimationController.forward();
        }
      });
    } else {
      _headerAnimationController.value = 1.0;
      _contentAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _handleStartChallenge() {
    setState(() => _isLoading = true);
    widget.onStartChallenge();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final primaryColor = widget.config.primaryColor ?? theme.colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme, l10n, primaryColor),
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _contentSlideAnimation,
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.data.status.isCompleted
                      ? _buildCompletedContent(theme, l10n, primaryColor)
                      : _buildAvailableContent(theme, l10n, primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    final gradientColors = widget.config.gradientColors ??
        [
          primaryColor,
          primaryColor.withValues(alpha: 0.7),
        ];

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: widget.onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Only show simple title when collapsed
            final isCollapsed = constraints.maxHeight < 120;
            if (isCollapsed) {
              return Text(
                l10n.dailyChallenge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        background: SlideTransition(
          position: _headerSlideAnimation,
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.today,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dailyChallenge,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.config.showCategory &&
                                    widget.data.categoryName != null)
                                  Text(
                                    l10n.dailyChallengeCategory(
                                      widget.data.categoryName!,
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableContent(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    final challenge = widget.data.status.challenge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildChallengeInfoCard(theme, l10n, challenge),
        const SizedBox(height: 24),
        if (widget.config.showRules) ...[
          _buildRulesSection(theme, l10n, primaryColor),
          const SizedBox(height: 24),
        ],
        _buildStartButton(theme, l10n, primaryColor),
      ],
    );
  }

  Widget _buildChallengeInfoCard(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    DailyChallenge challenge,
  ) {
    final timeLimitMinutes = challenge.timeLimitSeconds != null
        ? (challenge.timeLimitSeconds! / 60).round()
        : null;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                theme,
                Icons.help_outline,
                l10n.dailyChallengeQuestions(challenge.questionCount),
                l10n.questions,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outlineVariant,
            ),
            Expanded(
              child: _buildInfoItem(
                theme,
                Icons.timer_outlined,
                timeLimitMinutes != null
                    ? '$timeLimitMinutes ${l10n.minutes}'
                    : l10n.dailyChallengeNoTimeLimit,
                l10n.duration,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRulesSection(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    final rules = [
      (Icons.check_circle_outline, l10n.dailyChallengeRule1),
      (Icons.local_fire_department_outlined, l10n.dailyChallengeRule2),
      (Icons.speed, l10n.dailyChallengeRule3),
      (Icons.calendar_today, l10n.dailyChallengeRule4),
    ];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyChallengeRules,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...rules.map((rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          rule.$1,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rule.$2,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    return QuizAccessibility.ensureMinTouchTarget(
      child: FilledButton.icon(
        onPressed: _isLoading ? null : _handleStartChallenge,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow, size: 24, color: Colors.white),
        label: Text(
          l10n.dailyChallengeStart,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedContent(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    Color primaryColor,
  ) {
    final result = widget.data.status.result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 1,
          color: Colors.green.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dailyChallengeAlreadyCompleted,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dailyChallengeAlreadyCompletedMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (result != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${result.score}%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    l10n.dailyChallengeYourScore,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildCountdownCard(theme, l10n),
        if (widget.onViewResults != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: widget.onViewResults,
            icon: const Icon(Icons.visibility_outlined),
            label: Text(l10n.dailyChallengeViewResults),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCountdownCard(ThemeData theme, QuizEngineLocalizations l10n) {
    final timeRemaining = widget.data.status.timeUntilNextChallenge;
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes.remainder(60);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyChallengeNextIn('${hours}h ${minutes}m'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.dailyChallengeSubtitle,
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
}
