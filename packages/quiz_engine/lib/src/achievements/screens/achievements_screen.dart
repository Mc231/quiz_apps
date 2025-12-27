import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievements_list.dart';

/// Helper to track achievement detail viewed events.
void _trackAchievementDetailViewed(
  AnalyticsService analyticsService,
  AchievementDisplayData data,
) {
  analyticsService.logEvent(
    AchievementEvent.detailViewed(
      achievementId: data.achievement.id,
      achievementName: data.achievement.id, // Name requires context
      achievementCategory: data.achievement.tier.name,
      isUnlocked: data.isUnlocked,
      progress: data.progress.currentValue / data.progress.targetValue,
    ),
  );
}

/// Data model for achievements screen.
class AchievementsScreenData {
  /// Creates an [AchievementsScreenData].
  const AchievementsScreenData({
    required this.achievements,
    required this.totalPoints,
  });

  /// Creates empty data for loading states.
  const AchievementsScreenData.empty()
      : achievements = const [],
        totalPoints = 0;

  /// All achievements with their progress.
  final List<AchievementDisplayData> achievements;

  /// Total points earned from unlocked achievements.
  final int totalPoints;

  /// Number of unlocked achievements.
  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  /// Total number of achievements.
  int get totalCount => achievements.length;

  /// Points that can still be earned.
  int get remainingPoints {
    return achievements
        .where((a) => !a.isUnlocked)
        .fold(0, (sum, a) => sum + a.achievement.points);
  }

  /// Creates filter counts map.
  Map<AchievementFilter, int> get filterCounts => {
        AchievementFilter.all: achievements.length,
        AchievementFilter.unlocked:
            achievements.where((a) => a.isUnlocked).length,
        AchievementFilter.inProgress: achievements
            .where((a) => !a.isUnlocked && a.progress.hasProgress)
            .length,
        AchievementFilter.locked: achievements
            .where((a) => !a.isUnlocked && !a.progress.hasProgress)
            .length,
      };
}

/// Configuration for [AchievementsScreen].
class AchievementsScreenConfig {
  /// Creates an [AchievementsScreenConfig].
  const AchievementsScreenConfig({
    this.showHeader = true,
    this.showFilterChips = true,
    this.showTierFilter = false,
    this.showPointsInHeader = true,
    this.groupByCategory = true,
    this.enablePullToRefresh = true,
    this.initialFilter = AchievementFilter.all,
    this.headerStyle = const AchievementsHeaderStyle(),
    this.listConfig = const AchievementsListConfig(),
  });

  /// Default configuration.
  static const defaultConfig = AchievementsScreenConfig();

  /// Whether to show the stats header.
  final bool showHeader;

  /// Whether to show filter chips.
  final bool showFilterChips;

  /// Whether to show tier filter chips.
  final bool showTierFilter;

  /// Whether to show points in the header.
  final bool showPointsInHeader;

  /// Whether to group achievements by category.
  final bool groupByCategory;

  /// Whether to enable pull-to-refresh.
  final bool enablePullToRefresh;

  /// Initial filter selection.
  final AchievementFilter initialFilter;

  /// Style for the header.
  final AchievementsHeaderStyle headerStyle;

  /// Configuration for the achievements list.
  final AchievementsListConfig listConfig;
}

/// Style configuration for the achievements header.
class AchievementsHeaderStyle {
  /// Creates an [AchievementsHeaderStyle].
  const AchievementsHeaderStyle({
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.counterStyle,
    this.pointsStyle,
    this.progressBarHeight = 8.0,
    this.showProgressBar = true,
  });

  /// Background color for the header.
  final Color? backgroundColor;

  /// Padding around the header content.
  final EdgeInsets padding;

  /// Text style for the counter.
  final TextStyle? counterStyle;

  /// Text style for the points.
  final TextStyle? pointsStyle;

  /// Height of the progress bar.
  final double progressBarHeight;

  /// Whether to show the overall progress bar.
  final bool showProgressBar;
}

/// A full-screen achievements display.
///
/// Shows a stats header with achievement counter and points,
/// filter chips for filtering achievements, and a scrollable
/// list of achievements grouped by category.
///
/// Example:
/// ```dart
/// AchievementsScreen(
///   data: AchievementsScreenData(
///     achievements: allAchievements,
///     totalPoints: 450,
///   ),
///   onRefresh: () async => loadAchievements(),
///   onAchievementTap: (data) => showDetails(data),
/// )
/// ```
class AchievementsScreen extends StatefulWidget {
  /// Creates an [AchievementsScreen].
  const AchievementsScreen({
    super.key,
    required this.data,
    this.config = const AchievementsScreenConfig(),
    this.onRefresh,
    this.onAchievementTap,
    this.appBar,
    this.showScaffold = false,
    required  this.analyticsService,
  });

  /// The achievements data to display.
  final AchievementsScreenData data;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData)? onAchievementTap;

  /// Optional custom app bar.
  final PreferredSizeWidget? appBar;

  /// Whether to wrap content in a Scaffold with AppBar.
  ///
  /// Set to `false` when using inside a tab or another scaffold.
  /// Defaults to `false` for use in QuizHomeScreen tabs.
  final bool showScaffold;

  /// Optional analytics service for tracking achievement views.
  final AnalyticsService analyticsService;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late AchievementFilter _currentFilter;
  AchievementTier? _currentTierFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.config.initialFilter;
    _logScreenView();
  }

  void _logScreenView() {
    widget.analyticsService.logEvent(
      ScreenViewEvent.achievements(
        unlockedCount: widget.data.unlockedCount,
        totalCount: widget.data.totalCount,
        totalPoints: widget.data.totalPoints,
      ),
    );
  }

  void _handleAchievementTap(AchievementDisplayData data) {
    // Track the view event
    _trackAchievementDetailViewed(widget.analyticsService, data);
    // Call the original callback
    widget.onAchievementTap?.call(data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    final content = widget.config.enablePullToRefresh && widget.onRefresh != null
        ? RefreshIndicator(
            onRefresh: widget.onRefresh!,
            child: _buildContent(context),
          )
        : _buildContent(context);

    if (!widget.showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            title: Text(l10n.achievements),
          ),
      body: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (widget.config.showHeader)
          SliverToBoxAdapter(
            child: _AchievementsHeader(
              data: widget.data,
              style: widget.config.headerStyle,
              showPoints: widget.config.showPointsInHeader,
            ),
          ),
        if (widget.config.showFilterChips)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementFilterChips(
                selected: _currentFilter,
                onChanged: (filter) => setState(() => _currentFilter = filter),
                counts: widget.data.filterCounts,
              ),
            ),
          ),
        if (widget.config.showTierFilter)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementTierFilterChips(
                selected: _currentTierFilter,
                onChanged: (tier) => setState(() => _currentTierFilter = tier),
              ),
            ),
          ),
        if (widget.config.showFilterChips || widget.config.showTierFilter)
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverFillRemaining(
          child: AchievementsList(
            achievements: widget.data.achievements,
            config: widget.config.listConfig.copyWith(
              filter: _currentFilter,
              tierFilter: _currentTierFilter,
              groupByCategory: widget.config.groupByCategory,
            ),
            onAchievementTap: widget.onAchievementTap != null
                ? _handleAchievementTap
                : null,
          ),
        ),
      ],
    );
  }
}

/// Stats header showing achievement count and points.
class _AchievementsHeader extends StatelessWidget {
  const _AchievementsHeader({
    required this.data,
    required this.style,
    required this.showPoints,
  });

  final AchievementsScreenData data;
  final AchievementsHeaderStyle style;
  final bool showPoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    final progress =
        data.totalCount > 0 ? data.unlockedCount / data.totalCount : 0.0;

    return Container(
      color: style.backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      padding: style.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  iconColor: Colors.amber,
                  label: l10n.achievementsUnlocked(
                    data.unlockedCount,
                    data.totalCount,
                  ),
                  sublabel: l10n.achievements,
                ),
              ),
              if (showPoints) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.stars,
                    iconColor: theme.colorScheme.secondary,
                    label: l10n.achievementPoints(data.totalPoints),
                    sublabel: _getRemainingPointsText(l10n),
                  ),
                ),
              ],
            ],
          ),
          if (style.showProgressBar) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(style.progressBarHeight / 2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: style.progressBarHeight,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.completionPercentage((progress * 100).toInt()),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRemainingPointsText(QuizEngineLocalizations l10n) {
    if (data.remainingPoints > 0) {
      return l10n.pointsRemaining(data.remainingPoints);
    }
    return l10n.allPointsEarned;
  }
}

/// A stat card for the header.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sublabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A sliver version of the achievements screen for use in CustomScrollView.
class AchievementsScreenSliver extends StatefulWidget {
  /// Creates an [AchievementsScreenSliver].
  const AchievementsScreenSliver({
    super.key,
    required this.data,
    this.config = const AchievementsScreenConfig(),
    this.onAchievementTap,
    required this.analyticsService,
  });

  /// The achievements data to display.
  final AchievementsScreenData data;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData)? onAchievementTap;

  /// Optional analytics service for tracking achievement views.
  final AnalyticsService analyticsService;

  @override
  State<AchievementsScreenSliver> createState() =>
      _AchievementsScreenSliverState();
}

class _AchievementsScreenSliverState extends State<AchievementsScreenSliver> {
  late AchievementFilter _currentFilter;
  AchievementTier? _currentTierFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.config.initialFilter;
    _logScreenView();
  }

  void _logScreenView() {
    widget.analyticsService.logEvent(
      ScreenViewEvent.achievements(
        unlockedCount: widget.data.unlockedCount,
        totalCount: widget.data.totalCount,
        totalPoints: widget.data.totalPoints,
      ),
    );
  }

  void _handleAchievementTap(AchievementDisplayData data) {
    // Track the view event
    _trackAchievementDetailViewed(widget.analyticsService, data);
    // Call the original callback
    widget.onAchievementTap?.call(data);
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        if (widget.config.showHeader)
          SliverToBoxAdapter(
            child: _AchievementsHeader(
              data: widget.data,
              style: widget.config.headerStyle,
              showPoints: widget.config.showPointsInHeader,
            ),
          ),
        if (widget.config.showFilterChips)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementFilterChips(
                selected: _currentFilter,
                onChanged: (filter) => setState(() => _currentFilter = filter),
                counts: widget.data.filterCounts,
              ),
            ),
          ),
        if (widget.config.showTierFilter)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementTierFilterChips(
                selected: _currentTierFilter,
                onChanged: (tier) => setState(() => _currentTierFilter = tier),
              ),
            ),
          ),
        if (widget.config.showFilterChips || widget.config.showTierFilter)
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: AchievementsList(
            achievements: widget.data.achievements,
            config: widget.config.listConfig.copyWith(
              filter: _currentFilter,
              tierFilter: _currentTierFilter,
              groupByCategory: widget.config.groupByCategory,
            ),
            onAchievementTap: widget.onAchievementTap != null
                ? _handleAchievementTap
                : null,
          ),
        ),
      ],
    );
  }
}

/// A stateless content widget for use with AchievementsBloc.
///
/// This widget renders achievements content without managing its own state,
/// making it suitable for use with [AchievementsBuilder] and BLoC pattern.
///
/// Example:
/// ```dart
/// AchievementsBuilder(
///   bloc: achievementsBloc,
///   builder: (context, state) => AchievementsContent(
///     data: state.data,
///     filter: state.filter,
///     tierFilter: state.tierFilter,
///     isRefreshing: state.isRefreshing,
///     onFilterChanged: (filter) =>
///         achievementsBloc.add(AchievementsEvent.changeFilter(filter)),
///     onTierFilterChanged: (tier) =>
///         achievementsBloc.add(AchievementsEvent.changeTierFilter(tier)),
///     onRefresh: () async =>
///         achievementsBloc.add(AchievementsEvent.refresh()),
///   ),
/// )
/// ```
class AchievementsContent extends StatelessWidget {
  /// Creates an [AchievementsContent].
  const AchievementsContent({
    super.key,
    required this.data,
    this.filter = AchievementFilter.all,
    this.tierFilter,
    this.isRefreshing = false,
    this.config = const AchievementsScreenConfig(),
    this.onFilterChanged,
    this.onTierFilterChanged,
    this.onRefresh,
    this.onAchievementTap,
    required this.analyticsService,
  });

  /// The achievements data to display.
  final AchievementsScreenData data;

  /// Current filter selection.
  final AchievementFilter filter;

  /// Current tier filter selection.
  final AchievementTier? tierFilter;

  /// Whether a refresh is in progress.
  final bool isRefreshing;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback when filter changes.
  final void Function(AchievementFilter)? onFilterChanged;

  /// Callback when tier filter changes.
  final void Function(AchievementTier?)? onTierFilterChanged;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData)? onAchievementTap;

  /// Optional analytics service for tracking achievement views.
  final AnalyticsService analyticsService;

  void _handleAchievementTap(AchievementDisplayData achievementData) {
    // Track the view event
    _trackAchievementDetailViewed(analyticsService, achievementData);
    // Call the original callback
    onAchievementTap?.call(achievementData);
  }

  @override
  Widget build(BuildContext context) {
    final content = config.enablePullToRefresh && onRefresh != null
        ? RefreshIndicator(
            onRefresh: onRefresh!,
            child: _buildContent(context),
          )
        : _buildContent(context);

    return content;
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (config.showHeader)
          SliverToBoxAdapter(
            child: _AchievementsHeader(
              data: data,
              style: config.headerStyle,
              showPoints: config.showPointsInHeader,
            ),
          ),
        if (config.showFilterChips)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementFilterChips(
                selected: filter,
                onChanged: onFilterChanged ?? (_) {},
                counts: data.filterCounts,
              ),
            ),
          ),
        if (config.showTierFilter)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AchievementTierFilterChips(
                selected: tierFilter,
                onChanged: onTierFilterChanged ?? (_) {},
              ),
            ),
          ),
        if (config.showFilterChips || config.showTierFilter)
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverFillRemaining(
          child: AchievementsList(
            achievements: data.achievements,
            config: config.listConfig.copyWith(
              filter: filter,
              tierFilter: tierFilter,
              groupByCategory: config.groupByCategory,
            ),
            onAchievementTap:
                onAchievementTap != null ? _handleAchievementTap : null,
          ),
        ),
      ],
    );
  }
}

/// An async builder for achievements screen data.
///
/// Handles loading and error states while fetching achievement data.
class AchievementsScreenBuilder extends StatelessWidget {
  /// Creates an [AchievementsScreenBuilder].
  const AchievementsScreenBuilder({
    super.key,
    required this.dataLoader,
    required this.analyticsService,
    this.config = const AchievementsScreenConfig(),
    this.onAchievementTap,
    this.loadingBuilder,
    this.errorBuilder,
    this.appBar,
  });

  /// Function to load achievements data.
  final Future<AchievementsScreenData> Function() dataLoader;

  /// Configuration for the screen.
  final AchievementsScreenConfig config;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData)? onAchievementTap;

  /// Custom loading widget builder.
  final Widget Function(BuildContext)? loadingBuilder;

  /// Custom error widget builder.
  final Widget Function(BuildContext, Object error, VoidCallback retry)?
      errorBuilder;

  /// Optional custom app bar.
  final PreferredSizeWidget? appBar;

  // Analytics service for tracking achievement views.
  final AnalyticsService analyticsService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AchievementsScreenData>(
      future: dataLoader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? _buildLoading(context);
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(
                context,
                snapshot.error!,
                () => (context as Element).markNeedsBuild(),
              ) ??
              _buildError(context, snapshot.error!);
        }

        return AchievementsScreen(
          data: snapshot.data ?? const AchievementsScreenData.empty(),
          config: config,
          onRefresh: () async {
            await dataLoader();
            if (context.mounted) {
              (context as Element).markNeedsBuild();
            }
          },
          onAchievementTap: onAchievementTap,
          appBar: appBar, analyticsService: analyticsService,
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return Scaffold(
      appBar: appBar ??
          AppBar(
            title: Text(l10n.achievements),
          ),
      body: const LoadingIndicator(),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final l10n = QuizL10n.of(context);

    return Scaffold(
      appBar: appBar ??
          AppBar(
            title: Text(l10n.achievements),
          ),
      body: ErrorStateWidget(
        message: l10n.initializationError(error.toString()),
        analyticsService: analyticsService,
      ),
    );
  }
}
